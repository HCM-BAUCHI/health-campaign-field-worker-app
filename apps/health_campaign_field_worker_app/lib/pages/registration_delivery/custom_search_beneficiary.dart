import 'package:auto_route/auto_route.dart';
import 'package:digit_data_model/data_model.dart';
import 'package:digit_data_model/models/entities/household_type.dart';
import 'package:digit_scanner/blocs/scanner.dart';
import 'package:digit_scanner/pages/qr_scanner.dart';
import 'package:digit_ui_components/digit_components.dart';
import 'package:digit_ui_components/services/location_bloc.dart';
import 'package:digit_ui_components/theme/digit_extended_theme.dart';
import 'package:digit_ui_components/widgets/atoms/digit_chip.dart';
import 'package:digit_ui_components/widgets/atoms/digit_search_bar.dart';
import 'package:digit_ui_components/widgets/atoms/pop_up_card.dart';
import 'package:digit_ui_components/widgets/atoms/switch.dart';
import 'package:digit_ui_components/widgets/molecules/digit_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:health_campaign_field_worker_app/blocs/registration_delivery/custom_beneficairy_registration.dart';
import 'package:health_campaign_field_worker_app/widgets/custom_back_navigation.dart';
import 'package:registration_delivery/blocs/search_households/search_bloc_common_wrapper.dart';
import 'package:registration_delivery/blocs/search_households/search_households.dart'
    as registration_delivery;

import 'package:registration_delivery/utils/i18_key_constants.dart' as i18;
import '../../utils/i18_key_constants.dart' as i18_local;
import 'package:registration_delivery/models/entities/status.dart';
import 'package:registration_delivery/router/registration_delivery_router.gm.dart';
// import 'package:registration_delivery/utils/global_search_parameters.dart';
import 'package:registration_delivery/utils/utils.dart';
import 'package:registration_delivery/widgets/back_navigation_help_header.dart';
import 'package:registration_delivery/widgets/beneficiary/view_beneficiary_card.dart';
import 'package:registration_delivery/widgets/localized.dart';
import 'package:registration_delivery/widgets/status_filter/status_filter.dart';

import '../../blocs/registration_delivery/custom_search_household.dart';
import '../../router/app_router.dart';

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
  int offset = 0;
  int limit = 10;

  double lat = 0.0;
  double long = 0.0;
  List<String> selectedFilters = [];

  // late final SearchBlocWrapper blocWrapper; // Declare BlocWrapper
  late final CustomSearchHouseholdsBloc customSearchHouseholdsBloc;

  @override
  void initState() {
    // Initialize the BlocWrapper with instances of SearchHouseholdsBloc, SearchMemberBloc, and ProximitySearchBloc
    customSearchHouseholdsBloc = context.read<CustomSearchHouseholdsBloc>();
    context.read<LocationBloc>().add(const LoadLocationEvent());

    super.initState();
  }

  @override
  void dispose() {
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
                    showHelp: true,
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
                                        if (value.isEmpty ||
                                            value.trim().length > 2) {
                                          triggerGlobalSearchEvent();
                                        }
                                      },
                                    ),
                                  ),
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
                                                  getFilterIconNLabel()['icon'],
                                              onPressed: () =>
                                                  showFilterDialog(),
                                            ),
                                          ),
                                        )
                                      : const Offstage(),
                                  locationState.latitude != null
                                      ? Padding(
                                          padding:
                                              const EdgeInsets.all(spacer2),
                                          child: DigitSwitch(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            label:
                                                (RegistrationDeliverySingleton()
                                                            .householdType ==
                                                        HouseholdType.community)
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
                                                isProximityEnabled = value;
                                                lat = locationState.latitude!;
                                                long = locationState.longitude!;
                                              });

                                              if (locationState
                                                      .hasPermissions &&
                                                  value &&
                                                  locationState.latitude !=
                                                      null &&
                                                  locationState.longitude !=
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
                          if (searchHouseholdsState.resultsNotFound &&
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
                        ],
                      ),
                    ),
                  ),
                  if (searchHouseholdsState.loading)
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
                                child: ViewBeneficiaryCard(
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
