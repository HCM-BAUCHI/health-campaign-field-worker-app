// GENERATED using mason_cli
import 'dart:async';

import 'package:collection/collection.dart';
import 'package:digit_data_model/data_model.dart';
import 'package:digit_data_model/models/entities/household_type.dart';
import 'package:digit_data_model/utils/typedefs.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:registration_delivery/registration_delivery.dart';
import 'package:stream_transform/stream_transform.dart';

import 'package:registration_delivery/data/repositories/local/household_global_search.dart';
import 'package:registration_delivery/data/repositories/local/individual_global_search.dart';
import 'package:registration_delivery/data/repositories/local/registration_delivery_address.dart';
import 'package:registration_delivery/models/entities/household.dart';
import 'package:registration_delivery/models/entities/household_member.dart';
import 'package:registration_delivery/models/entities/project_beneficiary.dart';
import 'package:registration_delivery/models/entities/referral.dart';
import 'package:registration_delivery/models/entities/side_effect.dart';
import 'package:registration_delivery/models/entities/task.dart';
import 'package:registration_delivery/utils/global_search_parameters.dart';
import 'package:registration_delivery/utils/typedefs.dart';

import '../../data/repositories/local/registration_delivery/custom_registration_delivery.dart';

part 'custom_search_household.freezed.dart';

typedef SearchHouseholdsEmitter = Emitter<CustomSearchHouseholdsState>;

EventTransformer<Event> debounce<Event>(Duration duration) {
  return (events, mapper) => events.debounce(duration).switchMap(mapper);
}

class CustomSearchHouseholdsBloc
    extends Bloc<CustomSearchHouseholdsEvent, CustomSearchHouseholdsState> {
  final BeneficiaryType beneficiaryType;
  final String projectId;
  final String userUid;
  final IndividualDataRepository individual;
  final HouseholdDataRepository household;
  final CustomRegistrationDeliveryAddressRepo addressRepository;
  final HouseholdMemberDataRepository householdMember;
  final ProjectBeneficiaryDataRepository projectBeneficiary;
  final TaskDataRepository taskDataRepository;
  final SideEffectDataRepository sideEffectDataRepository;
  final ReferralDataRepository referralDataRepository;
  final IndividualGlobalSearchRepository individualGlobalSearchRepository;
  final HouseHoldGlobalSearchRepository houseHoldGlobalSearchRepository;

  CustomSearchHouseholdsBloc(
      {required this.userUid,
      required this.projectId,
      required this.individual,
      required this.householdMember,
      required this.household,
      required this.projectBeneficiary,
      required this.taskDataRepository,
      required this.beneficiaryType,
      required this.sideEffectDataRepository,
      required this.addressRepository,
      required this.referralDataRepository,
      required this.individualGlobalSearchRepository,
      required this.houseHoldGlobalSearchRepository})
      : super(const CustomSearchHouseholdsState()) {
    on(_handleInitialize);
    on(_handleLoad);
    on(_handleClear);
    on(_handleSearchByHousehold);
    on(_handleSearchByProximity);
    on(
      _handleSearchByHouseholdHead,
      transformer: debounce<SearchHouseholdsSearchByHouseholdHeadEvent>(
        const Duration(milliseconds: 100),
      ),
    );
  }

  // This function is been used in Individual details screen.

  void _handleInitialize(
    SearchHouseholdsInitializedEvent event,
    SearchHouseholdsEmitter emit,
  ) async {
    final beneficiaries = await projectBeneficiary.search(
      ProjectBeneficiarySearchModel(
        projectId: [projectId],
      ),
    );

    final tasks = await taskDataRepository.search(
      TaskSearchModel(
        projectId: projectId,
      ),
    );

    final sideEffects = await sideEffectDataRepository.search(
      SideEffectSearchModel(projectId: projectId),
    );

    final referrals = await referralDataRepository.search(
      ReferralSearchModel(projectId: projectId),
    );
    final interventionDelivered = tasks
        .where((element) => element.projectId == projectId)
        .whereNotNull()
        .map(
          (task) {
            return task.resources?.where((element) {
              return element.auditDetails?.createdBy == userUid;
            }).map(
              (taskResource) {
                return int.tryParse(taskResource.quantity ?? '0');
              },
            ).whereNotNull();
          },
        )
        .whereNotNull()
        .expand((element) => [...element])
        .fold(0, (previousValue, element) => previousValue + element);

    final observedSideEffects = sideEffects.length;

    final referralsDone = referrals.length;

    emit(state.copyWith(
      registeredHouseholds: beneficiaries.where((element) {
        return element.auditDetails?.createdBy == userUid;
      }).length,
      deliveredInterventions: interventionDelivered,
      sideEffectsObserved: observedSideEffects,
      referralsDone: referralsDone,
    ));
  }

  FutureOr<void> _handleLoad(
    SearchHouseholdsLoadingEvent event,
    SearchHouseholdsEmitter emit,
  ) async {
    emit(state.copyWith(
      loading: true,
    ));
  }

  FutureOr<void> _handleClear(
    SearchHouseholdsClearEvent event,
    SearchHouseholdsEmitter emit,
  ) async {
    emit(state.copyWith(
      searchQuery: null,
      householdMembers: [],
      tag: null,
    ));
  }

  Future<void> _handleSearchByHousehold(
    SearchHouseholdsByHouseholdsEvent event,
    SearchHouseholdsEmitter emit,
  ) async {
    emit(state.copyWith(loading: true));

    try {
      final householdMembers = await householdMember.search(
        HouseholdMemberSearchModel(
          householdClientReferenceId: [event.householdModel.clientReferenceId],
        ),
      );

      final individuals = await fetchIndividuals(
        householdMembers
            .map((e) => e.individualClientReferenceId)
            .whereNotNull()
            .toList(),
        null,
      );

      final projectBeneficiaries = await fetchProjectBeneficiary(
        beneficiaryType == BeneficiaryType.individual
            ? individuals.map((e) => e.clientReferenceId).toList()
            : [event.householdModel.clientReferenceId],
      );

      final headOfHousehold = individuals.firstWhereOrNull(
        (element) =>
            element.clientReferenceId ==
            householdMembers.firstWhereOrNull(
              (element) {
                return element.isHeadOfHousehold;
              },
            )?.individualClientReferenceId,
      );
      final tasks = await fetchTaskByProjectBeneficiary(projectBeneficiaries);

      final sideEffects =
          await sideEffectDataRepository.search(SideEffectSearchModel(
        taskClientReferenceId: tasks.map((e) => e.clientReferenceId).toList(),
      ));

      final referrals = await referralDataRepository.search(ReferralSearchModel(
        projectBeneficiaryClientReferenceId:
            projectBeneficiaries.map((e) => e.clientReferenceId).toList(),
      ));

      if (headOfHousehold == null) {
        emit(state.copyWith(
          loading: false,
          householdMembers: [],
        ));
      } else {
        final householdMemberWrapper = HouseholdMemberWrapper(
          household: event.householdModel,
          headOfHousehold: headOfHousehold,
          members: individuals,
          projectBeneficiaries: projectBeneficiaries,
          tasks: tasks.isNotEmpty ? tasks : null,
          sideEffects: sideEffects.isNotEmpty ? sideEffects : null,
          referrals: referrals.isNotEmpty ? referrals : null,
        );

        emit(
          state.copyWith(
            loading: false,
            householdMembers: [
              householdMemberWrapper,
            ],
            searchQuery: [
              headOfHousehold.name?.givenName,
              headOfHousehold.name?.familyName,
            ].whereNotNull().join(' '),
          ),
        );
      }
    } catch (error) {
      emit(state.copyWith(
        loading: false,
        householdMembers: [],
      ));
    }
  }

  FutureOr<void> _handleSearchByProximity(
    SearchHouseholdsByProximityEvent event,
    SearchHouseholdsEmitter emit,
  ) async {
    emit(state.copyWith(loading: true));
    // Fetch individual results based on proximity and other criteria.
    final List<HouseholdModel> proximityBasedHouseholdsResults =
        await addressRepository.searchHouseHoldbyAddress(AddressSearchModel(
      latitude: event.latitude,
      longitude: event.longititude,
      maxRadius: event.maxRadius,
      offset: event.offset,
      limit: event.limit,
    ));

    // Extract individual IDs from proximity-based individual results.
    final househHoldIds = proximityBasedHouseholdsResults
        .map((e) => e.clientReferenceId)
        .toList();

    final List<HouseholdMemberModel> householdMembers =
        await fetchHouseholdMembersBulk(
      null,
      househHoldIds,
    );

    final List<String> individualClientReferenceIds = householdMembers
        .map((e) => e.individualClientReferenceId.toString())
        .toList();

    final List<IndividualModel> individuals = await individual.search(
      IndividualSearchModel(clientReferenceId: individualClientReferenceIds),
    );

    final projectBeneficiaries = await fetchProjectBeneficiary(
      beneficiaryType != BeneficiaryType.individual
          ? househHoldIds
          : individualClientReferenceIds,
    );

    List<SideEffectModel> sideEffects = [];
    List<ReferralModel> referrals = [];
    List<TaskModel> tasks = [];
    if (projectBeneficiaries.isNotEmpty) {
      // Search for tasks and side effects based on project beneficiaries.
      tasks = await fetchTaskByProjectBeneficiary(projectBeneficiaries);

      sideEffects = await sideEffectDataRepository.search(SideEffectSearchModel(
        taskClientReferenceId: tasks.map((e) => e.clientReferenceId).toList(),
      ));

      referrals = await referralDataRepository.search(ReferralSearchModel(
        projectBeneficiaryClientReferenceId:
            projectBeneficiaries.map((e) => e.clientReferenceId).toList(),
      ));
    }

    // Initialize a list to store household member wrappers.
    final containers = <HouseholdMemberWrapper>[...state.householdMembers];

    // Group household members by household client reference ID.
    final groupedHouseholds = householdMembers
        .groupListsBy((element) => element.householdClientReferenceId);

    // Iterate through grouped households and retrieve additional data.
    for (final entry in groupedHouseholds.entries) {
      final householdId = entry.key;

      final exisitingHousehold = state.householdMembers.firstWhereOrNull(
        (element) => element.household?.clientReferenceId == householdId,
      );
      if (exisitingHousehold != null) continue;
      if (householdId == null) continue;

      // Search for households based on client reference ID and proximity.

      // Retrieve the first household result.
      final householdresult = proximityBasedHouseholdsResults
          .firstWhere((e) => e.clientReferenceId == householdId);
      // Search for individuals based on proximity, beneficiary type, and search text.
      final List<String?> membersIds =
          entry.value.map((e) => e.individualClientReferenceId).toList();
      final List<IndividualModel> individualMemebrs = individuals
          .where((element) => membersIds.contains(element.clientReferenceId))
          .toList();
      final List<ProjectBeneficiaryModel> beneficiaries = projectBeneficiaries
          .where((element) => beneficiaryType == BeneficiaryType.individual
              ? membersIds.contains(element.beneficiaryClientReferenceId)
              : householdId == element.beneficiaryClientReferenceId)
          .toList();

      final beneficiaryClientReferenceIds =
          beneficiaries.map((e) => e.beneficiaryClientReferenceId).toList();

      final List<IndividualModel> beneficiaryIndividuals = individualMemebrs
          .where((element) =>
              beneficiaryClientReferenceIds.contains(element.clientReferenceId))
          .toList();

      final projectBeneficiaryClientReferenceIds =
          beneficiaries.map((e) => e.clientReferenceId).toList();

      final List<TaskModel> filteredTasks = tasks
          .where((element) => projectBeneficiaryClientReferenceIds
              .contains(element.projectBeneficiaryClientReferenceId))
          .toList();

      final List<ReferralModel> filteredReferrals = referrals
          .where((element) => projectBeneficiaryClientReferenceIds
              .contains(element.projectBeneficiaryClientReferenceId))
          .toList();

      final taskClientReferenceIds =
          filteredTasks.map((e) => e.clientReferenceId).toList();

      final List<SideEffectModel> filteredSideEffects = sideEffects
          .where((element) =>
              taskClientReferenceIds.contains(element.taskClientReferenceId))
          .toList();

      // Find the head of household from the individuals.
      final head = (beneficiaryType == BeneficiaryType.individual
              ? beneficiaryIndividuals
              : individualMemebrs)
          .firstWhereOrNull(
        (element) =>
            element.clientReferenceId ==
            entry.value
                .firstWhereOrNull(
                  (element) => element.isHeadOfHousehold,
                )
                ?.individualClientReferenceId,
      );

      if (head == null || beneficiaries.isEmpty) continue;
      // Create a container for household members and associated data.
      containers.add(
        HouseholdMemberWrapper(
          household: householdresult,
          headOfHousehold: head,
          members: beneficiaryType == BeneficiaryType.individual
              ? beneficiaryIndividuals
              : individualMemebrs,
          projectBeneficiaries: beneficiaries,
          tasks: filteredTasks.isEmpty ? null : filteredTasks,
          sideEffects: filteredSideEffects.isEmpty ? null : filteredSideEffects,
          referrals: filteredReferrals.isEmpty ? null : filteredReferrals,
        ),
      );
    }
    // Update the state with the   results and mark the search as completed.
    emit(state.copyWith(
      householdMembers: containers,
      loading: false,
      offset: event.offset + event.limit,
      limit: event.limit,
    ));
  }

  FutureOr<void> _handleSearchByHouseholdHead(
    SearchHouseholdsSearchByHouseholdHeadEvent event,
    SearchHouseholdsEmitter emit,
  ) async {
    // Check if the search text is empty; if so, clear the results and return.
    if (event.searchText.trim().isEmpty) {
      emit(state.copyWith(
        householdMembers: [],
        searchQuery: null,
        loading: false,
      ));

      return;
    }

    // Update the state to indicate that the search is in progress.
    emit(state.copyWith(
      loading: true,
      searchQuery: event.searchText,
    ));

    // Perform a series of asynchronous data retrieval operations based on the search criteria.

    // Fetch household results based on proximity and other criteria.

    List<IndividualModel> proximityBasedIndividualResults = [];

    if (event.isProximityEnabled) {
      // Fetch individual results based on proximity and other criteria.
      proximityBasedIndividualResults =
          await addressRepository.searchHouseHoldByIndividual(
        AddressSearchModel(
          latitude: event.latitude,
          longitude: event.longitude,
          maxRadius: event.maxRadius,
          offset: event.offset,
          limit: event.limit,
        ),
        null,
        event.searchText.trim(),
      );
    }
    // Extract individual IDs from proximity-based individual results.
    final List<String> indIds = proximityBasedIndividualResults
        .map((e) => e.clientReferenceId)
        .toList();

    // Search for individual results using the extracted IDs and search text in first name.
    final firstNameClientRefResults = await individual.search(
      event.isProximityEnabled
          ? IndividualSearchModel(
              clientReferenceId: indIds,
              name: NameSearchModel(
                givenName: event.searchText.trim(),
              ),
            )
          : IndividualSearchModel(
              name: NameSearchModel(
                givenName: event.searchText.trim(),
              ),
              offset: event.offset,
              limit: event.limit,
            ),
    );

    // Search for individual results using the extracted IDs and search text in last name.
    // final lastNameClientRefResults = await individual.search(
    //   event.isProximityEnabled
    //       ? IndividualSearchModel(
    //           clientReferenceId: indIds,
    //           name: NameSearchModel(
    //             familyName: event.searchText.trim(),
    //           ),
    //         )
    //       : IndividualSearchModel(
    //           name: NameSearchModel(
    //             familyName: event.searchText.trim(),
    //           ),
    //           offset: event.offset,
    //           limit: event.limit,
    //         ),
    // );

    final individualClientReferenceIds = [
      ...firstNameClientRefResults,
      // ...lastNameClientRefResults,
    ].map((e) => e.clientReferenceId).toList();
    // Search for individual results using the extracted IDs and search text.
    final List<HouseholdMemberModel> householdMembers =
        await fetchHouseholdMembersBulk(
      individualClientReferenceIds,
      null,
    );

    final househHoldIds =
        householdMembers.map((e) => e.householdClientReferenceId!).toList();

    final List<HouseholdModel> houseHolds = await household.search(
      HouseholdSearchModel(
        clientReferenceId: househHoldIds,
      ),
    );

    final List<HouseholdMemberModel> allHouseholdMembers =
        await fetchHouseholdMembersBulk(
      null,
      househHoldIds,
    );

    final List<String> allIndividualClientreferenceIds =
        allHouseholdMembers.map((e) => e.individualClientReferenceId!).toList();

    final List<IndividualModel> allIndividuals = await individual.search(
      IndividualSearchModel(
        clientReferenceId: allIndividualClientreferenceIds,
      ),
    );

    final projectBeneficiaries = await fetchProjectBeneficiary(
      beneficiaryType != BeneficiaryType.individual
          ? househHoldIds
          : allIndividualClientreferenceIds,
    );
    // Search for individual results based on the search text only.

    List<SideEffectModel> sideEffects = [];
    final containers = <HouseholdMemberWrapper>[];
    List<ReferralModel> referrals = [];
    List<TaskModel> tasks = [];
    if (projectBeneficiaries.isNotEmpty) {
      // Search for tasks and side effects based on project beneficiaries.
      tasks = await fetchTaskByProjectBeneficiary(projectBeneficiaries);

      sideEffects = await sideEffectDataRepository.search(SideEffectSearchModel(
        taskClientReferenceId: tasks.map((e) => e.clientReferenceId).toList(),
      ));

      referrals = await referralDataRepository.search(ReferralSearchModel(
        projectBeneficiaryClientReferenceId:
            projectBeneficiaries.map((e) => e.clientReferenceId).toList(),
      ));
    }

    // Initialize a list to store household members.
    final groupedHouseholds = allHouseholdMembers
        .groupListsBy((element) => element.householdClientReferenceId);

    // Iterate through grouped households and retrieve additional data.
    for (final entry in groupedHouseholds.entries) {
      final householdId = entry.key;

      final exisitingHousehold = state.householdMembers.firstWhereOrNull(
        (element) => element.household?.clientReferenceId == householdId,
      );
      if (exisitingHousehold != null) continue;
      if (householdId == null) continue;
      // Retrieve the first household result.
      final householdresult =
          houseHolds.firstWhere((e) => e.clientReferenceId == householdId);
      // Search for individuals based on proximity, beneficiary type, and search text.
      final List<String?> membersIds =
          entry.value.map((e) => e.individualClientReferenceId).toList();
      final List<IndividualModel> individualMemebrs = allIndividuals
          .where((element) => membersIds.contains(element.clientReferenceId))
          .toList();
      final List<ProjectBeneficiaryModel> beneficiaries = projectBeneficiaries
          .where((element) => beneficiaryType == BeneficiaryType.individual
              ? membersIds.contains(element.beneficiaryClientReferenceId)
              : householdId == element.beneficiaryClientReferenceId)
          .toList();

      final beneficiaryClientReferenceIds =
          beneficiaries.map((e) => e.beneficiaryClientReferenceId).toList();

      final List<IndividualModel> beneficiaryIndividuals = individualMemebrs
          .where((element) =>
              beneficiaryClientReferenceIds.contains(element.clientReferenceId))
          .toList();

      final projectBeneficiaryClientReferenceIds =
          beneficiaries.map((e) => e.clientReferenceId).toList();

      final List<TaskModel> filteredTasks = tasks
          .where((element) => projectBeneficiaryClientReferenceIds
              .contains(element.projectBeneficiaryClientReferenceId))
          .toList();

      final List<ReferralModel> filteredReferrals = referrals
          .where((element) => projectBeneficiaryClientReferenceIds
              .contains(element.projectBeneficiaryClientReferenceId))
          .toList();

      final taskClientReferenceIds =
          filteredTasks.map((e) => e.clientReferenceId).toList();

      final List<SideEffectModel> filteredSideEffects = sideEffects
          .where((element) =>
              taskClientReferenceIds.contains(element.taskClientReferenceId))
          .toList();

      // Find the head of household from the individuals.
      final head = ((beneficiaryType == BeneficiaryType.individual
              ? beneficiaryIndividuals
              : individualMemebrs))
          .firstWhereOrNull(
        (element) =>
            element.clientReferenceId ==
            entry.value
                .firstWhereOrNull(
                  (element) => element.isHeadOfHousehold,
                )
                ?.individualClientReferenceId,
      );

      if (head == null || beneficiaries.isEmpty) continue;

      // Search for project beneficiaries based on client reference ID and project.
      containers.add(
        HouseholdMemberWrapper(
          household: householdresult,
          headOfHousehold: head,
          members: beneficiaryType == BeneficiaryType.individual
              ? beneficiaryIndividuals
              : individualMemebrs,
          projectBeneficiaries: beneficiaries,
          tasks: filteredTasks.isEmpty ? null : filteredTasks,
          sideEffects: filteredSideEffects.isEmpty ? null : filteredSideEffects,
          referrals: filteredReferrals.isEmpty ? null : filteredReferrals,
        ),
      );

      // Update the state with the results and mark the search as completed.
    }
    emit(state.copyWith(
      householdMembers: [...state.householdMembers, ...containers],
      loading: false,
      offset: event.offset + event.limit,
      limit: event.limit,
    ));
  }

  Future<List<HouseholdMemberModel>> fetchHouseholdMembers(
    String? householdClientReferenceId,
    String? individualClientReferenceId,
    bool? isHeadOfHousehold,
  ) async {
    return await householdMember.search(
      HouseholdMemberSearchModel(
        householdClientReferenceId: [householdClientReferenceId.toString()],
        individualClientReferenceId: [individualClientReferenceId.toString()],
        isHeadOfHousehold: isHeadOfHousehold,
      ),
    );
  }

  Future<List<HouseholdMemberModel>> fetchHouseholdMembersBulk(
    List<String>? individualClientReferenceIds,
    List<String>? householdClientReferenceIds,
  ) async {
    return await householdMember.search(
      HouseholdMemberSearchModel(
        individualClientReferenceIds: individualClientReferenceIds,
        householdClientReferenceIds: householdClientReferenceIds,
        isHeadOfHousehold: RegistrationDeliverySingleton().householdType ==
                HouseholdType.community
            ? true
            : null,
      ),
    );
  }

  // Fetch the task
  Future<List<TaskModel>> fetchTaskByProjectBeneficiary(
    List<ProjectBeneficiaryModel> projectBeneficiaries,
  ) async {
    return await taskDataRepository.search(TaskSearchModel(
      projectBeneficiaryClientReferenceId:
          projectBeneficiaries.map((e) => e.clientReferenceId).toList(),
    ));
  }

  // Fetch the project Beneficiary
  Future<List<ProjectBeneficiaryModel>> fetchProjectBeneficiary(
    List<String> projectBeneficiariesIds,
  ) async {
    return await projectBeneficiary.search(
      ProjectBeneficiarySearchModel(
        projectId: [projectId],
        beneficiaryClientReferenceId: projectBeneficiariesIds,
      ),
    );
  }

  Future<List<IndividualModel>> fetchIndividuals(
    List<String> individualIds,
    String? name,
  ) async {
    return await individual.search(
      IndividualSearchModel(
        clientReferenceId: individualIds,
        name: name != null ? NameSearchModel(givenName: name.trim()) : null,
      ),
    );
  }
}

@freezed
class CustomSearchHouseholdsEvent with _$CustomSearchHouseholdsEvent {
  const factory CustomSearchHouseholdsEvent.initialize() =
      SearchHouseholdsInitializedEvent;

  const factory CustomSearchHouseholdsEvent.searchByHousehold({
    required String projectId,
    double? latitude,
    double? longitude,
    double? maxRadius,
    required final bool isProximityEnabled,
    required HouseholdModel householdModel,
  }) = SearchHouseholdsByHouseholdsEvent;

  const factory CustomSearchHouseholdsEvent.searchByHouseholdHead({
    required String searchText,
    required String projectId,
    required final bool isProximityEnabled,
    double? latitude,
    double? longitude,
    double? maxRadius,
    String? tag,
    required int offset,
    required int limit,
  }) = SearchHouseholdsSearchByHouseholdHeadEvent;

  const factory CustomSearchHouseholdsEvent.searchByProximity({
    required double latitude,
    required double longititude,
    required String projectId,
    required double maxRadius,
    required int offset,
    required int limit,
  }) = SearchHouseholdsByProximityEvent;

  const factory CustomSearchHouseholdsEvent.searchByTag({
    required String tag,
    required String projectId,
  }) = SearchHouseholdsByTagEvent;

  const factory CustomSearchHouseholdsEvent.clear() =
      SearchHouseholdsClearEvent;
  const factory CustomSearchHouseholdsEvent.load() =
      SearchHouseholdsLoadingEvent;

  const factory CustomSearchHouseholdsEvent.individualGlobalSearch({
    required GlobalSearchParameters globalSearchParams,
  }) = IndividualGlobalSearchEvent;

  const factory CustomSearchHouseholdsEvent.houseHoldGlobalSearch({
    required GlobalSearchParameters globalSearchParams,
  }) = HouseHoldGlobalSearchEvent;
}

@freezed
class CustomSearchHouseholdsState with _$CustomSearchHouseholdsState {
  const CustomSearchHouseholdsState._();

  const factory CustomSearchHouseholdsState({
    @Default(0) int offset,
    @Default(10) int limit,
    @Default(false) bool loading,
    String? searchQuery,
    String? tag,
    @Default([]) List<HouseholdMemberWrapper> householdMembers,
    @Default(0) int registeredHouseholds,
    @Default(0) int deliveredInterventions,
    @Default(0) int sideEffectsObserved,
    @Default(0) int referralsDone,
    @Default(0) int totalResults,
  }) = _SearchHouseholdsState;

  bool get resultsNotFound {
    if (loading) return false;

    if (searchQuery?.isEmpty ?? true && tag == null) return false;

    return householdMembers.isEmpty;
  }
}

@freezed
class HouseholdMemberWrapper with _$HouseholdMemberWrapper {
  const factory HouseholdMemberWrapper({
    HouseholdModel? household,
    IndividualModel? headOfHousehold,
    List<IndividualModel>? members,
    List<ProjectBeneficiaryModel>? projectBeneficiaries,
    double? distance,
    List<TaskModel>? tasks,
    List<SideEffectModel>? sideEffects,
    List<ReferralModel>? referrals,
  }) = _HouseholdMemberWrapper;
}
