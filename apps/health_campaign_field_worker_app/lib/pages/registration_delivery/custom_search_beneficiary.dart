import 'package:digit_components/widgets/digit_info_card.dart';
import 'package:digit_data_model/data_model.dart';
import 'package:digit_data_model/models/entities/household_type.dart';
import 'package:digit_scanner/blocs/scanner.dart';
import 'package:digit_ui_components/digit_components.dart';
import 'package:digit_ui_components/services/location_bloc.dart';
import 'package:digit_ui_components/theme/digit_extended_theme.dart';
import 'package:digit_ui_components/widgets/atoms/digit_chip.dart';
import 'package:digit_ui_components/widgets/atoms/digit_search_bar.dart';
import 'package:digit_ui_components/widgets/atoms/pop_up_card.dart';
import 'package:digit_ui_components/widgets/atoms/switch.dart';
import 'package:digit_ui_components/widgets/molecules/digit_card.dart';
import 'package:digit_ui_components/widgets/molecules/show_pop_up.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import '../../blocs/registration_delivery/custom_beneficairy_registration.dart';
import '../../utils/constants.dart';
import '../../widgets/custom_back_navigation.dart';
import 'package:registration_delivery/blocs/search_households/search_bloc_common_wrapper.dart';
import 'package:registration_delivery/blocs/search_households/search_households.dart'
    as registration_delivery;

import 'package:registration_delivery/utils/i18_key_constants.dart' as i18;
import '../../utils/extensions/extensions.dart';
import '../../blocs/search/individual_global_search_smc.dart';
import '../../blocs/search/search_households_smc.dart'
    as searchHouseholdSMCBloc;
import '../../utils/i18_key_constants.dart' as i18_local;
import 'package:registration_delivery/models/entities/status.dart';
import 'package:registration_delivery/router/registration_delivery_router.gm.dart';
import 'package:registration_delivery/utils/utils.dart';
import 'package:registration_delivery/widgets/beneficiary/view_beneficiary_card.dart';
import 'package:registration_delivery/widgets/localized.dart';
import 'package:registration_delivery/widgets/status_filter/status_filter.dart';

import '../../blocs/registration_delivery/custom_search_household.dart';
import '../../router/app_router.dart';
import '../../../utils/i18_key_constants.dart' as i18_local;
import '../../utils/search/global_search_parameters_smc.dart';
import '../../widgets/showcase/showcase_wrappers.dart';
import 'custom_view_beneficiary_card.dart';

@RoutePage()
class CustomSearchBeneficiaryPage extends LocalizedStatefulWidget {
  const CustomSearchBeneficiaryPage({
    super.key,
    super.appLocalizations,
  });

  @override
  State<CustomSearchBeneficiaryPage> createState() =>
      _CustomSearchBeneficiaryPageState();
}

class _CustomSearchBeneficiaryPageState
    extends LocalizedState<CustomSearchBeneficiaryPage> {
  final TextEditingController searchController = TextEditingController();
  bool isProximityEnabled = false;
  bool isSearchByBeneficaryIdEnabled = false;
  bool isSearchByMobileNumberEnabled = false;

  int offset = 0;
  int limit = 10;
  RegExp pattern = RegExp(r'^[0-9A-Z-]+$');

  double lat = 0.0;
  double long = 0.0;
  List<String> selectedFilters = [];

  // late final SearchBlocWrapper blocWrapper; // Declare BlocWrapper
  late final CustomSearchHouseholdsBloc customSearchHouseholdsBloc;

  searchHouseholdSMCBloc.SearchHouseholdsSMCState searchHouseholdsSMCState =
      const searchHouseholdSMCBloc.SearchHouseholdsSMCState(
          loading: false, householdMembers: []);

  late final SearchBlocWrapper blocWrapper; // Declare BlocWrapper

  @override
  void initState() {
    // Initialize the BlocWrapper with instances of SearchHouseholdsBloc, SearchMemberBloc, and ProximitySearchBloc
    customSearchHouseholdsBloc = context.read<CustomSearchHouseholdsBloc>();
    context.read<LocationBloc>().add(const LoadLocationEvent());
    blocWrapper = context.read<SearchBlocWrapper>();

    context
        .read<IndividualGlobalSearchSMCBloc>()
        .add(const searchHouseholdSMCBloc.SearchHouseholdsSMCEvent.clear());
    super.initState();
  }

  @override
  void dispose() {
    blocWrapper.clearEvent();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.digitTextTheme(context);

    return KeyboardVisibilityBuilder(
      builder: (context, isKeyboardVisible) => Scaffold(
        body: NotificationListener<ScrollNotification>(
          onNotification: (scrollNotification) {
            if (scrollNotification is ScrollUpdateNotification) {
              final metrics = scrollNotification.metrics;
              if (metrics.atEdge && metrics.pixels != 0) {
                triggerGlobalSearchEvent(isPagination: true);
              }
            }
            return true;
          },
          child: BlocBuilder<CustomSearchHouseholdsBloc,
              CustomSearchHouseholdsState>(
            builder: (context, searchHouseholdsState) {
              return ScrollableContent(
                header: const Column(children: [
                  CustomBackNavigationHelpHeaderWidget(
                    showHelp: false,
                  ),
                ]),
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(spacer2),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(spacer2),
                            child: Align(
                              alignment: Alignment.topLeft,
                              child: Text(
                                localizations.translate(
                                  RegistrationDeliverySingleton()
                                                  .householdType !=
                                              null &&
                                          RegistrationDeliverySingleton()
                                                  .householdType ==
                                              HouseholdType.community
                                      ? i18.searchBeneficiary.searchCLFLabel
                                      : RegistrationDeliverySingleton()
                                                  .beneficiaryType !=
                                              BeneficiaryType.household
                                          ? i18.searchBeneficiary
                                              .statisticsLabelText
                                          : i18.searchBeneficiary
                                              .searchIndividualLabelText,
                                ),
                                style: textTheme.headingXl.copyWith(
                                  color: theme.colorTheme.text.primary,
                                ),
                                textAlign: TextAlign.left,
                              ),
                            ),
                          ),
                          BlocBuilder<LocationBloc, LocationState>(
                            builder: (context, locationState) {
                              return Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(spacer2),
                                    child: DigitSearchBar(
                                      controller: searchController,
                                      icon: const SizedBox.shrink(),
                                      hintText: (RegistrationDeliverySingleton()
                                                  .householdType ==
                                              HouseholdType.community)
                                          ? localizations.translate(i18
                                              .searchBeneficiary
                                              .clfSearchHintText)
                                          : localizations.translate(
                                              i18.searchBeneficiary
                                                  .beneficiarySearchHintText,
                                            ),
                                      textCapitalization:
                                          TextCapitalization.words,
                                      onChanged: (value) {
                                        if (isSearchByBeneficaryIdEnabled &&
                                            isBeneficiaryIdValid(
                                                value.trim()) &&
                                            searchController.text
                                                    .trim()
                                                    .length ==
                                                14) {
                                          searchByBeneficiaryId(
                                              beneficiaryId: value.trim());
                                        } else if (isSearchByBeneficaryIdEnabled &&
                                            searchController.text
                                                    .trim()
                                                    .length <
                                                14) {
                                          blocWrapper.clearEvent();
                                          context
                                              .read<
                                                  IndividualGlobalSearchSMCBloc>()
                                              .add(const searchHouseholdSMCBloc
                                                  .SearchHouseholdsSMCEvent.clear());
                                        } else if (isSearchByMobileNumberEnabled &&
                                            searchController.text
                                                    .trim()
                                                    .length ==
                                                Constants.mobileNumberLength) {
                                          searchByMobileNumber(
                                              mobileNumber: value.trim());
                                        } else if (isSearchByMobileNumberEnabled &&
                                            searchController.text
                                                    .trim()
                                                    .length !=
                                                Constants.mobileNumberLength) {
                                          blocWrapper.clearEvent();
                                          context
                                              .read<
                                                  IndividualGlobalSearchSMCBloc>()
                                              .add(const searchHouseholdSMCBloc
                                                  .SearchHouseholdsSMCEvent.clear());
                                        } else if (!isSearchByBeneficaryIdEnabled &&
                                            !isSearchByMobileNumberEnabled &&
                                            (value.isEmpty ||
                                                value.trim().length > 2)) {
                                          triggerGlobalSearchEvent();
                                        }
                                      },
                                    ),
                                  ),
                                  if (!isSearchByBeneficaryIdEnabled &&
                                      !isSearchByMobileNumberEnabled)
                                    RegistrationDeliverySingleton()
                                                    .searchHouseHoldFilter !=
                                                null &&
                                            RegistrationDeliverySingleton()
                                                .searchHouseHoldFilter!
                                                .isNotEmpty &&
                                            RegistrationDeliverySingleton()
                                                    .householdType !=
                                                HouseholdType.community
                                        ? Align(
                                            alignment: Alignment.topLeft,
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(spacer2),
                                              child: DigitButton(
                                                label: getFilterIconNLabel()[
                                                    'label'],
                                                size: DigitButtonSize.medium,
                                                type: DigitButtonType.tertiary,
                                                suffixIcon:
                                                    getFilterIconNLabel()[
                                                        'icon'],
                                                onPressed: () =>
                                                    showFilterDialog(),
                                              ),
                                            ),
                                          )
                                        : const Offstage(),
                                  locationState.latitude != null
                                      ? Column(
                                          children: [
                                            Row(children: [
                                              Padding(
                                                padding: const EdgeInsets.all(
                                                    spacer2),
                                                child: DigitSwitch(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  label: (RegistrationDeliverySingleton()
                                                              .householdType ==
                                                          HouseholdType
                                                              .community)
                                                      ? localizations.translate(
                                                          i18.searchBeneficiary
                                                              .communityProximityLabel,
                                                        )
                                                      : localizations.translate(
                                                          i18.searchBeneficiary
                                                              .proximityLabel,
                                                        ),
                                                  value: isProximityEnabled,
                                                  onChanged: (value) {
                                                    searchController.clear();
                                                    setState(() {
                                                      isProximityEnabled =
                                                          value;
                                                      isSearchByBeneficaryIdEnabled =
                                                          false;
                                                      isSearchByMobileNumberEnabled =
                                                          false;
                                                      lat = locationState
                                                          .latitude!;
                                                      long = locationState
                                                          .longitude!;
                                                    });

                                                    if (locationState
                                                            .hasPermissions &&
                                                        value &&
                                                        locationState
                                                                .latitude !=
                                                            null &&
                                                        locationState
                                                                .longitude !=
                                                            null &&
                                                        RegistrationDeliverySingleton()
                                                                .maxRadius !=
                                                            null &&
                                                        isProximityEnabled) {
                                                      triggerGlobalSearchEvent();
                                                    } else {
                                                      triggerGlobalSearchEvent();
                                                    }
                                                  },
                                                ),
                                              )
                                            ]),
                                            Row(
                                              children: [
                                                Padding(
                                                  padding: const EdgeInsets.all(
                                                      spacer2),
                                                  child: DigitSwitch(
                                                    label: localizations
                                                        .translate(i18_local
                                                            .beneficiaryDetails
                                                            .searchbybeneficiaryidtextupdate),
                                                    value:
                                                        isSearchByBeneficaryIdEnabled,
                                                    onChanged: (value) {
                                                      customSearchHouseholdsBloc
                                                          .add(
                                                        const SearchHouseholdsClearEvent(),
                                                      );
                                                      searchController.clear();
                                                      context
                                                          .read<
                                                              IndividualGlobalSearchSMCBloc>()
                                                          .add(const searchHouseholdSMCBloc
                                                              .SearchHouseholdsSMCEvent.clear());
                                                      setState(() {
                                                        isSearchByBeneficaryIdEnabled =
                                                            value;
                                                        isProximityEnabled =
                                                            false;
                                                        isSearchByMobileNumberEnabled =
                                                            false;
                                                        searchController
                                                            .clear();
                                                        blocWrapper
                                                            .clearEvent();
                                                      });
                                                    },
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                Padding(
                                                  padding: const EdgeInsets.all(
                                                      spacer2),
                                                  child: DigitSwitch(
                                                    label: localizations
                                                        .translate(i18_local
                                                            .beneficiaryDetails
                                                            .searchByMobileNumber),
                                                    value:
                                                        isSearchByMobileNumberEnabled,
                                                    onChanged: (value) {
                                                      customSearchHouseholdsBloc
                                                          .add(
                                                        const SearchHouseholdsClearEvent(),
                                                      );
                                                      searchController.clear();
                                                      context
                                                          .read<
                                                              IndividualGlobalSearchSMCBloc>()
                                                          .add(const searchHouseholdSMCBloc
                                                              .SearchHouseholdsSMCEvent.clear());
                                                      setState(() {
                                                        isSearchByMobileNumberEnabled =
                                                            value;
                                                        isProximityEnabled =
                                                            false;
                                                        isSearchByBeneficaryIdEnabled =
                                                            false;
                                                        searchController
                                                            .clear();
                                                        blocWrapper
                                                            .clearEvent();
                                                      });
                                                    },
                                                  ),
                                                ),
                                              ],
                                            )
                                          ],
                                        )
                                      : const Offstage(),
                                  selectedFilters.isNotEmpty
                                      ? Align(
                                          alignment: Alignment.topLeft,
                                          child: SizedBox(
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                0.06,
                                            child: ListView.builder(
                                                shrinkWrap: true,
                                                scrollDirection:
                                                    Axis.horizontal,
                                                itemCount:
                                                    selectedFilters.length,
                                                itemBuilder: (context, index) {
                                                  return Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            spacer1),
                                                    child: DigitChip(
                                                      label:
                                                          '${localizations.translate(getStatus(selectedFilters[index]))}'
                                                          ' (${searchHouseholdsState.totalResults})',
                                                      capitalizedFirstLetter:
                                                          false,
                                                      onItemDelete: () {
                                                        setState(() {
                                                          selectedFilters.remove(
                                                              selectedFilters[
                                                                  index]);
                                                        });

                                                        triggerGlobalSearchEvent();
                                                      },
                                                    ),
                                                  );
                                                }),
                                          ),
                                        )
                                      : const Offstage(),
                                ],
                              );
                            },
                          ),
                          if (!isSearchByBeneficaryIdEnabled &&
                              !isSearchByMobileNumberEnabled &&
                              searchHouseholdsState.resultsNotFound &&
                              !searchHouseholdsState.loading)
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: spacer2, top: spacer2, right: spacer2),
                              child: InfoCard(
                                type: InfoType.info,
                                description: (RegistrationDeliverySingleton()
                                            .householdType ==
                                        HouseholdType.community)
                                    ? localizations.translate(
                                        i18.searchBeneficiary.clfInfoTitle)
                                    : localizations.translate(
                                        i18_local.searchBeneficiary
                                            .beneficiaryInfoDescription,
                                      ),
                                title: localizations.translate(
                                  i18.searchBeneficiary.beneficiaryInfoTitle,
                                ),
                              ),
                            ),
                          if (isSearchByBeneficaryIdEnabled &&
                              searchController.text.trim().isNotEmpty &&
                              !isBeneficiaryIdValidPattern(
                                  searchController.text.trim()))
                            DigitInfoCard(
                              description: localizations.translate(
                                i18_local.searchBeneficiary
                                    .beneficiaryIdValidInfoDescription,
                              ),
                              title: localizations.translate(
                                i18.searchBeneficiary.beneficiaryInfoTitle,
                              ),
                            ),
                          if (isSearchByMobileNumberEnabled &&
                              searchController.text.trim().isNotEmpty &&
                              searchController.text.trim().length !=
                                  Constants.mobileNumberLength)
                            DigitInfoCard(
                              description: localizations.translate(
                                i18_local.searchBeneficiary
                                    .mobileNumberValidInfoDescription,
                              ),
                              title: localizations.translate(
                                i18_local
                                    .searchBeneficiary.mobileNumberInfoTitle,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  if (!isSearchByBeneficaryIdEnabled &&
                      !isSearchByMobileNumberEnabled &&
                      searchHouseholdsState.loading)
                    const SliverFillRemaining(
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  BlocListener<DigitScannerBloc, DigitScannerState>(
                    listener: (context, scannerState) {
                      if (scannerState.qrCodes.isNotEmpty) {
                        context.read<SearchBlocWrapper>().tagSearchBloc.add(
                              registration_delivery.SearchHouseholdsEvent
                                  .searchByTag(
                                tag: scannerState.qrCodes.isNotEmpty
                                    ? scannerState.qrCodes.lastOrNull!
                                    : '',
                                projectId:
                                    RegistrationDeliverySingleton().projectId!,
                              ),
                            );
                      }
                    },
                    child: BlocBuilder<LocationBloc, LocationState>(
                      builder: (context, locationState) {
                        return SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (ctx, index) {
                              HouseholdMemberWrapper i = searchHouseholdsState
                                  .householdMembers
                                  .elementAt(index);
                              registration_delivery.HouseholdMemberWrapper
                                  householdMemberWrapper =
                                  registration_delivery.HouseholdMemberWrapper(
                                household: i.household,
                                headOfHousehold: i.headOfHousehold,
                                members: i.members,
                                projectBeneficiaries: i.projectBeneficiaries,
                                distance: i.distance,
                                tasks: i.tasks,
                                sideEffects: i.sideEffects,
                                referrals: i.referrals,
                              );
                              final distance = calculateDistance(
                                Coordinate(
                                  lat,
                                  long,
                                ),
                                Coordinate(
                                  householdMemberWrapper
                                      .household?.address?.latitude,
                                  householdMemberWrapper
                                      .household?.address?.longitude,
                                ),
                              );

                              return Container(
                                margin: const EdgeInsets.only(bottom: spacer2),
                                child: CustomViewBeneficiaryCard(
                                  distance:
                                      isProximityEnabled ? distance : null,
                                  householdMember: householdMemberWrapper,
                                  onOpenPressed: () async {
                                    final scannerBloc =
                                        context.read<DigitScannerBloc>();

                                    scannerBloc.add(
                                      const DigitScannerEvent.handleScanner(),
                                    );

                                    if ((householdMemberWrapper.tasks != null &&
                                            householdMemberWrapper.tasks
                                                    ?.lastOrNull!.status ==
                                                Status.closeHousehold
                                                    .toValue() &&
                                            (householdMemberWrapper.tasks ?? [])
                                                .isNotEmpty) ||
                                        (householdMemberWrapper
                                                    .projectBeneficiaries ??
                                                [])
                                            .isEmpty) {
                                      setState(() {
                                        selectedFilters = [];
                                      });
                                      customSearchHouseholdsBloc.add(
                                        const SearchHouseholdsClearEvent(),
                                      );
                                      await context.router.push(
                                        CustomBeneficiaryRegistrationWrapperRoute(
                                          initialState: BeneficiaryRegistrationState.editHousehold(
                                              householdModel: householdMemberWrapper
                                                  .household!,
                                              individualModel: householdMemberWrapper
                                                  .members!,
                                              registrationDate: DateTime.now(),
                                              projectBeneficiaryModel:
                                                  (householdMemberWrapper.projectBeneficiaries ?? [])
                                                          .isNotEmpty
                                                      ? householdMemberWrapper
                                                          .projectBeneficiaries
                                                          ?.lastOrNull
                                                      : null,
                                              addressModel: (RegistrationDeliverySingleton()
                                                          .householdType ==
                                                      HouseholdType.community)
                                                  ? householdMemberWrapper
                                                      .household!.address!
                                                  : householdMemberWrapper
                                                      .headOfHousehold!
                                                      .address!
                                                      .lastOrNull!,
                                              headOfHousehold: householdMemberWrapper
                                                  .headOfHousehold),
                                        ),
                                      );
                                    } else {
                                      await context.router.push(
                                        BeneficiaryWrapperRoute(
                                          wrapper: householdMemberWrapper,
                                        ),
                                      );
                                    }
                                    setState(() {
                                      isProximityEnabled = false;
                                    });
                                    searchController.clear();
                                    selectedFilters.clear();
                                    customSearchHouseholdsBloc.add(
                                      const SearchHouseholdsClearEvent(),
                                    );
                                  },
                                ),
                              );
                            },
                            childCount:
                                searchHouseholdsState.householdMembers.length,
                          ),
                        );
                      },
                    ),
                  ),
                  if (isSearchByBeneficaryIdEnabled)
                    BlocConsumer<IndividualGlobalSearchSMCBloc,
                        searchHouseholdSMCBloc.SearchHouseholdsSMCState>(
                      listener: (context, searchSMCstate) {},
                      builder: (context, searchSMCstate) {
                        if (searchSMCstate.loading) {
                          return const
                              // SliverToBoxAdapter(
                              //   child:
                              Center(
                            child: CircularProgressIndicator(),
                          );
                        } else {
                          return SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (ctx, index) {
                                final i =
                                    searchSMCstate.householdMembers[index];
                                return Container(
                                  margin:
                                      const EdgeInsets.only(bottom: kPadding),
                                  child: CustomViewBeneficiaryCard(
                                    householdMember: i,
                                    onOpenPressed: () async {
                                      final scannerBloc =
                                          context.read<DigitScannerBloc>();

                                      scannerBloc.add(
                                        const DigitScannerEvent.handleScanner(),
                                      );

                                      if ((i.tasks != null &&
                                              i.tasks?.last.status ==
                                                  Status.closeHousehold
                                                      .toValue() &&
                                              (i.tasks ?? []).isNotEmpty) ||
                                          (i.projectBeneficiaries ?? [])
                                              .isEmpty) {
                                        setState(() {
                                          selectedFilters = [];
                                        });
                                        blocWrapper.clearEvent();
                                        await context.router.push(
                                          CustomBeneficiaryRegistrationWrapperRoute(
                                            initialState: BeneficiaryRegistrationState.editHousehold(
                                                householdModel: i.household!,
                                                individualModel: i.members!,
                                                registrationDate:
                                                    DateTime.now(),
                                                projectBeneficiaryModel:
                                                    (i.projectBeneficiaries ??
                                                                [])
                                                            .isNotEmpty
                                                        ? i.projectBeneficiaries
                                                            ?.lastOrNull
                                                        : null,
                                                addressModel:
                                                    (RegistrationDeliverySingleton()
                                                                .householdType ==
                                                            HouseholdType
                                                                .community)
                                                        ? i.household!.address!
                                                        : i
                                                            .headOfHousehold!
                                                            .address!
                                                            .lastOrNull!,
                                                headOfHousehold:
                                                    i.headOfHousehold),
                                          ),
                                        );
                                      } else {
                                        await context.router.push(
                                            BeneficiaryWrapperRoute(
                                                wrapper: i));
                                      }
                                      setState(() {
                                        isProximityEnabled = false;
                                        isSearchByBeneficaryIdEnabled = false;
                                        isSearchByMobileNumberEnabled = false;
                                      });
                                      searchController.clear();
                                      selectedFilters.clear();
                                      blocWrapper.clearEvent();
                                    },
                                  ),
                                );
                              },
                              childCount:
                                  searchSMCstate.householdMembers.length,
                            ),
                          );
                        }
                      },
                    ),
                  if (isSearchByBeneficaryIdEnabled &&
                      searchController.text.trim().isNotEmpty &&
                      !isBeneficiaryIdValid(searchController.text.trim()))
                    SliverList(
                        delegate: SliverChildBuilderDelegate((ctx, index) {
                      return DigitInfoCard(
                        description: localizations.translate(
                          i18_local.searchBeneficiary
                              .beneficiaryIdValidInfoDescription,
                        ),
                        title: localizations.translate(
                          i18.searchBeneficiary.beneficiaryInfoTitle,
                        ),
                      );
                    }, childCount: 1)),
                  if (isSearchByMobileNumberEnabled)
                    BlocConsumer<IndividualGlobalSearchSMCBloc,
                        searchHouseholdSMCBloc.SearchHouseholdsSMCState>(
                      listener: (context, searchSMCstate) {},
                      builder: (context, searchSMCstate) {
                        if (searchSMCstate.loading) {
                          return const
                              //  SliverToBoxAdapter(
                              //   child:
                              Center(
                            child: CircularProgressIndicator(),
                          );
                        } else {
                          return SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (ctx, index) {
                                final i =
                                    searchSMCstate.householdMembers[index];
                                return Container(
                                  margin:
                                      const EdgeInsets.only(bottom: kPadding),
                                  child: CustomViewBeneficiaryCard(
                                    householdMember: i,
                                    onOpenPressed: () async {
                                      final scannerBloc =
                                          context.read<DigitScannerBloc>();

                                      scannerBloc.add(
                                        const DigitScannerEvent.handleScanner(),
                                      );

                                      if ((i.tasks != null &&
                                              i.tasks?.last.status ==
                                                  Status.closeHousehold
                                                      .toValue() &&
                                              (i.tasks ?? []).isNotEmpty) ||
                                          (i.projectBeneficiaries ?? [])
                                              .isEmpty) {
                                        setState(() {
                                          selectedFilters = [];
                                        });
                                        blocWrapper.clearEvent();
                                        await context.router.push(
                                          CustomBeneficiaryRegistrationWrapperRoute(
                                            initialState: BeneficiaryRegistrationState.editHousehold(
                                                householdModel: i.household!,
                                                individualModel: i.members!,
                                                registrationDate:
                                                    DateTime.now(),
                                                projectBeneficiaryModel:
                                                    (i.projectBeneficiaries ??
                                                                [])
                                                            .isNotEmpty
                                                        ? i.projectBeneficiaries
                                                            ?.lastOrNull
                                                        : null,
                                                addressModel:
                                                    (RegistrationDeliverySingleton()
                                                                .householdType ==
                                                            HouseholdType
                                                                .community)
                                                        ? i.household!.address!
                                                        : i
                                                            .headOfHousehold!
                                                            .address!
                                                            .lastOrNull!,
                                                headOfHousehold:
                                                    i.headOfHousehold),
                                          ),
                                        );
                                      } else {
                                        await context.router.push(
                                            BeneficiaryWrapperRoute(
                                                wrapper: i));
                                      }
                                      setState(() {
                                        isProximityEnabled = false;
                                        isSearchByBeneficaryIdEnabled = false;
                                        isSearchByMobileNumberEnabled = false;
                                      });
                                      searchController.clear();
                                      selectedFilters.clear();
                                      blocWrapper.clearEvent();
                                    },
                                  ),
                                );
                              },
                              childCount:
                                  searchSMCstate.householdMembers.length,
                            ),
                          );
                        }
                      },
                    ),
                  if (isSearchByMobileNumberEnabled &&
                      searchController.text.trim().isNotEmpty &&
                      searchController.text.trim().length !=
                          Constants.mobileNumberLength)
                    SliverList(
                        delegate: SliverChildBuilderDelegate((ctx, index) {
                      return DigitInfoCard(
                        description: localizations.translate(
                          i18_local.searchBeneficiary
                              .mobileNumberValidInfoDescription,
                        ),
                        title: localizations.translate(
                          i18_local.searchBeneficiary.mobileNumberInfoTitle,
                        ),
                      );
                    }, childCount: 1))
                ],
              );
            },
          ),
        ),
        bottomNavigationBar: Offstage(
          offstage: RegistrationDeliverySingleton().householdType ==
                  HouseholdType.community &&
              searchController.text.length < 3,
          child: DigitCard(
              margin: const EdgeInsets.only(top: spacer2),
              padding: const EdgeInsets.all(spacer4),
              children: [
                BlocBuilder<CustomSearchHouseholdsBloc,
                    CustomSearchHouseholdsState>(
                  builder: (context, searchHouseholdsState) {
                    return DigitButton(
                      capitalizeLetters: false,
                      label: (RegistrationDeliverySingleton().householdType ==
                              HouseholdType.community)
                          ? localizations.translate(
                              i18.searchBeneficiary.clfAddActionLabel)
                          : localizations.translate(
                              i18.searchBeneficiary.beneficiaryAddActionLabel,
                            ),
                      mainAxisSize: MainAxisSize.max,
                      type: DigitButtonType.primary,
                      size: DigitButtonSize.large,
                      isDisabled: false,
                      onPressed: () {
                        int spaq1 = context.spaq1;
                        int spaq2 = context.spaq2;
                        int blueVas = context.blueVas;
                        int redVas = context.redVas;

                        String descriptionText = localizations.translate(
                            i18_local
                                .beneficiaryDetails.insufficientStockMessage);

                        if (spaq1 == 0) {
                          descriptionText +=
                              "\n ${localizations.translate(i18_local.beneficiaryDetails.spaq1DoseUnit)}";
                        }
                        if (spaq2 == 0) {
                          descriptionText +=
                              "\n ${localizations.translate(i18_local.beneficiaryDetails.spaq2DoseUnit)}";
                        }
                        if (blueVas == 0) {
                          descriptionText +=
                              "\n ${localizations.translate(i18_local.beneficiaryDetails.blueVasZeroQuantity)}";
                        }
                        if (redVas == 0) {
                          descriptionText +=
                              "\n ${localizations.translate(i18_local.beneficiaryDetails.redVasZeroQuantity)}";
                        }

                        if ((spaq1 > 0 ||
                            spaq2 > 0 ||
                            blueVas > 0 ||
                            redVas > 0)) {
                          FocusManager.instance.primaryFocus?.unfocus();
                          context.read<DigitScannerBloc>().add(
                                const DigitScannerEvent.handleScanner(),
                              );
                          context.router
                              .push(CustomBeneficiaryRegistrationWrapperRoute(
                            initialState: BeneficiaryRegistrationCreateState(
                              searchQuery: searchHouseholdsState.searchQuery,
                            ),
                          ));
                          searchController.clear();
                          selectedFilters = [];
                          customSearchHouseholdsBloc.add(
                            const SearchHouseholdsClearEvent(),
                          );
                        } else {
                          showCustomPopup(
                            context: context,
                            builder: (popupContext) => Popup(
                              title: localizations.translate(i18_local
                                  .beneficiaryDetails.insufficientStockHeading),
                              onOutsideTap: () {
                                Navigator.of(popupContext).pop(false);
                              },
                              description: descriptionText,
                              type: PopUpType.alert,
                              actions: [
                                DigitButton(
                                  label: localizations.translate(
                                    i18_local.beneficiaryDetails.goToHome,
                                  ),
                                  onPressed: () {
                                    Navigator.of(
                                      popupContext,
                                      rootNavigator: true,
                                    ).pop();
//
                                  },
                                  type: DigitButtonType.primary,
                                  size: DigitButtonSize.large,
                                ),
                              ],
                            ),
                          );
                        }
                      },
                    );
                  },
                ),
              ]),
        ),
      ),
    );
  }

  getFilterIconNLabel() {
    return {
      'label': localizations.translate(
        i18.searchBeneficiary.filterLabel,
      ),
      'icon': Icons.filter_alt
    };
  }

  showFilterDialog() async {
    var filters = await showDialog(
        context: context,
        builder: (ctx) => Popup(
                title: getFilterIconNLabel()['label'],
                titleIcon: Icon(
                  getFilterIconNLabel()['icon'],
                  color: DigitTheme.instance.colorScheme.primary,
                ),
                onCrossTap: () {
                  Navigator.of(
                    context,
                    rootNavigator: true,
                  ).pop();
                },
                additionalWidgets: [
                  StatusFilter(
                    selectedFilters: selectedFilters,
                  ),
                ]));

    if (filters != null && filters.isNotEmpty) {
      setState(() {
        selectedFilters = [];
      });
      setState(() {
        selectedFilters.addAll(filters);
      });
      triggerGlobalSearchEvent();
    } else {
      setState(() {
        selectedFilters = [];
      });
      customSearchHouseholdsBloc.add(
        const SearchHouseholdsClearEvent(),
      );
      triggerGlobalSearchEvent();
    }
  }

  void searchByBeneficiaryId(
      {bool isPagination = false, String beneficiaryId = ""}) {
    final individualglobalsearchSMC =
        context.read<IndividualGlobalSearchSMCBloc>();
    individualglobalsearchSMC
        .add(searchHouseholdSMCBloc.IndividualGlobalSearchSMCEvent(
            globalSearchParams: GlobalSearchParametersSMC(
      isProximityEnabled: isProximityEnabled,
      latitude: lat,
      longitude: long,
      maxRadius: RegistrationDeliverySingleton().maxRadius,
      nameSearch: searchController.text.trim().length > 2
          ? searchController.text.trim()
          : blocWrapper.searchHouseholdsBloc.state.searchQuery,
      beneficiaryId: beneficiaryId,
      filter: selectedFilters,
      offset: isPagination
          ? blocWrapper.individualGlobalSearchBloc.state.offset
          : offset,
      limit: isPagination
          ? blocWrapper.individualGlobalSearchBloc.state.limit
          : limit,
      projectId: RegistrationDeliverySingleton().projectId!,
    )));
  }

  void searchByMobileNumber(
      {bool isPagination = false, String mobileNumber = ""}) {
    final individualglobalsearchSMC =
        context.read<IndividualGlobalSearchSMCBloc>();
    individualglobalsearchSMC
        .add(searchHouseholdSMCBloc.IndividualGlobalSearchSMCEvent(
            globalSearchParams: GlobalSearchParametersSMC(
      isProximityEnabled: isProximityEnabled,
      latitude: lat,
      longitude: long,
      maxRadius: RegistrationDeliverySingleton().maxRadius,
      nameSearch: searchController.text.trim().length > 2
          ? searchController.text.trim()
          : blocWrapper.searchHouseholdsBloc.state.searchQuery,
      mobileNumber: mobileNumber,
      filter: selectedFilters,
      offset: isPagination
          ? blocWrapper.individualGlobalSearchBloc.state.offset
          : offset,
      limit: isPagination
          ? blocWrapper.individualGlobalSearchBloc.state.limit
          : limit,
      projectId: RegistrationDeliverySingleton().projectId!,
      beneficiaryId: '',
    )));
  }

  bool isBeneficiaryIdValid(String value) {
    if (value.trim().length != 14) return false;
    for (var i = 0; i < value.length; i++) {
      if ((i == 4 || i == 9) && value[i] != '-')
        return false;
      else if (isLowerCase(value[i])) return false;
    }
    return true;
  }

  bool isLowerCase(String ch) {
    return ch.codeUnitAt(0) >= 97 && ch.codeUnitAt(0) <= 122;
  }

  bool isBeneficiaryIdValidPattern(String value) {
    bool isValid = true;
    if (value.trim().length > 14) {
      isValid = false;
    } else if (!pattern.hasMatch(value.trim())) {
      isValid = false;
    }
    return isValid;
  }

  void triggerGlobalSearchEvent({bool isPagination = false}) {
    if (!isPagination) {
      customSearchHouseholdsBloc.add(
        const SearchHouseholdsClearEvent(),
      );
    }

    if (searchController.text.trim().length < 3 && !isProximityEnabled) {
      customSearchHouseholdsBloc.add(
        const SearchHouseholdsClearEvent(),
      );
      return;
    } else {
      if (isProximityEnabled && searchController.text.trim().length < 3) {
        customSearchHouseholdsBloc.add(
          const SearchHouseholdsLoadingEvent(),
        );
        customSearchHouseholdsBloc
            .add(CustomSearchHouseholdsEvent.searchByProximity(
          latitude: lat,
          longititude: long,
          projectId: RegistrationDeliverySingleton().projectId!,
          maxRadius: RegistrationDeliverySingleton().maxRadius!,
          offset:
              isPagination ? customSearchHouseholdsBloc.state.offset : offset,
          limit: isPagination ? customSearchHouseholdsBloc.state.limit : limit,
        ));
      } else {
        customSearchHouseholdsBloc.add(
          const SearchHouseholdsLoadingEvent(),
        );
        customSearchHouseholdsBloc.add(
          CustomSearchHouseholdsEvent.searchByHouseholdHead(
            searchText: searchController.text.trim(),
            projectId: RegistrationDeliverySingleton().projectId!,
            latitude: lat,
            longitude: long,
            isProximityEnabled: isProximityEnabled,
            maxRadius: RegistrationDeliverySingleton().maxRadius,
            offset:
                isPagination ? customSearchHouseholdsBloc.state.offset : offset,
            limit:
                isPagination ? customSearchHouseholdsBloc.state.limit : limit,
          ),
        );
      }
    }
  }
}
