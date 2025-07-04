// GENERATED using mason_cli
import 'dart:async';

import 'package:collection/collection.dart';
import 'package:digit_data_model/data_model.dart';
import 'package:digit_data_model/utils/typedefs.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:registration_delivery/data/repositories/local/household_global_search.dart';
import 'package:registration_delivery/registration_delivery.dart';
import 'package:stream_transform/stream_transform.dart';

import '../../data/repositories/local/search/individual_global_search_smc.dart';
import '../../utils/search/global_search_parameters_smc.dart';

part 'search_households_smc.freezed.dart';

typedef SearchHouseholdsSMCEmitter = Emitter<SearchHouseholdsSMCState>;

EventTransformer<Event> debounce<Event>(Duration duration) {
  return (events, mapper) => events.debounce(duration).switchMap(mapper);
}

class SearchHouseholdsSMCBloc
    extends Bloc<SearchHouseholdsSMCEvent, SearchHouseholdsSMCState> {
  final BeneficiaryType beneficiaryType;
  final String projectId;
  final String userUid;
  final IndividualDataRepository individual;
  final HouseholdDataRepository household;
  final RegistrationDeliveryAddressRepo addressRepository;
  final HouseholdMemberDataRepository householdMember;
  final ProjectBeneficiaryDataRepository projectBeneficiary;
  final TaskDataRepository taskDataRepository;
  final SideEffectDataRepository sideEffectDataRepository;
  final ReferralDataRepository referralDataRepository;
  final IndividualGlobalSearchSMCRepository individualGlobalSearchSMCRepository;
  final HouseHoldGlobalSearchRepository houseHoldGlobalSearchRepository;

  SearchHouseholdsSMCBloc(
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
      required this.individualGlobalSearchSMCRepository,
      required this.houseHoldGlobalSearchRepository})
      : super(const SearchHouseholdsSMCState()) {
    on(_handleClear);
    on(_handleSearchByHousehold);
  }

  // This function is been used in Individual details screen.
  Future<void> _handleSearchByHousehold(
    SearchHouseholdsByHouseholdsEvent event,
    SearchHouseholdsSMCEmitter emit,
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
      final tasks = await fetchTaskbyProjectBeneficiary(projectBeneficiaries);

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

  FutureOr<void> _handleClear(
    SearchHouseholdsClearEvent event,
    SearchHouseholdsSMCEmitter emit,
  ) async {
    emit(state.copyWith(
      searchQuery: null,
      householdMembers: [],
      tag: null,
    ));
  }

// Fetch the HouseHold Members

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
      ),
    );
  }

  // Fetch the task
  Future<List<TaskModel>> fetchTaskbyProjectBeneficiary(
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
class SearchHouseholdsSMCEvent with _$SearchHouseholdsSMCEvent {
  const factory SearchHouseholdsSMCEvent.initialize() =
      SearchHouseholdsInitializedEvent;

  const factory SearchHouseholdsSMCEvent.searchByHousehold({
    required String projectId,
    double? latitude,
    double? longitude,
    double? maxRadius,
    required final bool isProximityEnabled,
    required HouseholdModel householdModel,
  }) = SearchHouseholdsByHouseholdsSMCEvent;

  const factory SearchHouseholdsSMCEvent.searchByHouseholdHead({
    required String searchText,
    required String projectId,
    required final bool isProximityEnabled,
    double? latitude,
    double? longitude,
    double? maxRadius,
    String? tag,
    required int offset,
    required int limit,
  }) = SearchHouseholdsSearchByHouseholdHeadSMCEvent;

  const factory SearchHouseholdsSMCEvent.searchByProximity({
    required double latitude,
    required double longititude,
    required String projectId,
    required double maxRadius,
    required int offset,
    required int limit,
  }) = SearchHouseholdsByProximitySMCEvent;

  const factory SearchHouseholdsSMCEvent.searchByTag({
    required String tag,
    required String projectId,
  }) = SearchHouseholdsByTagSMCEvent;

  const factory SearchHouseholdsSMCEvent.clear() = SearchHouseholdsClearEvent;

  const factory SearchHouseholdsSMCEvent.individualGlobalSearch({
    required GlobalSearchParametersSMC globalSearchParams,
  }) = IndividualGlobalSearchSMCEvent;

  const factory SearchHouseholdsSMCEvent.houseHoldGlobalSearch({
    required GlobalSearchParametersSMC globalSearchParams,
  }) = HouseHoldGlobalSearchSMCEvent;
}

@freezed
class SearchHouseholdsSMCState with _$SearchHouseholdsSMCState {
  const SearchHouseholdsSMCState._();

  const factory SearchHouseholdsSMCState({
    @Default(0) int offset,
    @Default(10) int limit,
    @Default(false) bool loading,
    String? searchQuery,
    String? tag,
    @Default([]) List<HouseholdMemberWrapper> householdMembers,
    @Default(0) int totalResults,
  }) = _SearchHouseholdsSMCState;

  bool get resultsNotFound {
    if (loading) return false;

    if (searchQuery?.isEmpty ?? true && tag == null) return false;

    return householdMembers.isEmpty;
  }
}
