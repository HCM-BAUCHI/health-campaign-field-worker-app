import 'package:auto_route/auto_route.dart';
import 'package:collection/collection.dart';
import 'package:digit_data_model/data_model.dart';
import 'package:digit_data_model/models/entities/household_type.dart';
import 'package:digit_ui_components/enum/app_enums.dart';
import 'package:digit_ui_components/theme/digit_extended_theme.dart';
import 'package:digit_ui_components/theme/digit_theme.dart';
import 'package:digit_ui_components/theme/spacers.dart';
import 'package:digit_ui_components/utils/date_utils.dart';
import 'package:digit_ui_components/widgets/atoms/digit_action_card.dart';
import 'package:digit_ui_components/widgets/atoms/digit_button.dart';
import 'package:digit_ui_components/widgets/atoms/digit_chip.dart';
import 'package:digit_ui_components/widgets/atoms/digit_search_bar.dart';
import 'package:digit_ui_components/widgets/atoms/pop_up_card.dart';
import 'package:digit_ui_components/widgets/molecules/digit_card.dart';
import 'package:digit_ui_components/widgets/molecules/show_pop_up.dart';
import 'package:digit_ui_components/widgets/scrollable_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_campaign_field_worker_app/blocs/registration_delivery/custom_beneficairy_registration.dart';
import 'package:registration_delivery/widgets/component_wrapper/product_variant_bloc_wrapper.dart';
import 'package:survey_form/survey_form.dart';

import 'package:registration_delivery/widgets/status_filter/status_filter.dart';
import 'package:registration_delivery/blocs/delivery_intervention/deliver_intervention.dart';
import 'package:registration_delivery/blocs/household_overview/household_overview.dart';
import 'package:registration_delivery/blocs/search_households/search_bloc_common_wrapper.dart';
import 'package:registration_delivery/blocs/search_households/search_households.dart';
import 'package:registration_delivery/models/entities/household.dart';
import 'package:registration_delivery/models/entities/registration_delivery_enums.dart';
import 'package:registration_delivery/models/entities/status.dart';
import 'package:registration_delivery/router/registration_delivery_router.gm.dart';
import 'package:registration_delivery/utils/i18_key_constants.dart' as i18;
import '../../utils/i18_key_constants.dart' as i18_local;
import 'package:registration_delivery/utils/utils.dart';
import '../../utils/extensions/extensions.dart';
import '../../widgets/custom_back_navigation.dart';
import 'package:registration_delivery/widgets/localized.dart';
import 'package:registration_delivery/widgets/member_card/member_card.dart';
import 'package:registration_delivery/widgets/table_card/table_card.dart';

import '../../router/app_router.dart';
import '../../utils/app_enums.dart';
import '../../utils/registration_delivery/utils_smc.dart';
import '../../widgets/registration_delivery/custom_member_card.dart';
import '../../utils/i18_key_constants.dart' as i18_local;

@RoutePage()
class CustomHouseholdOverviewPage extends LocalizedStatefulWidget {
  const CustomHouseholdOverviewPage({super.key, super.appLocalizations});

  @override
  State<CustomHouseholdOverviewPage> createState() =>
      _CustomHouseholdOverviewPageState();
}

class _CustomHouseholdOverviewPageState
    extends LocalizedState<CustomHouseholdOverviewPage> {
  final TextEditingController searchController = TextEditingController();
  int offset = 0;
  int limit = 10;

  String? householdClientReferenceId;

  List<String> selectedFilters = [];

  @override
  void initState() {
    callReloadEvent(offset: offset, limit: limit);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final beneficiaryType = RegistrationDeliverySingleton().beneficiaryType!;
    final textTheme = theme.digitTextTheme(context);

    return ProductVariantBlocWrapper(
      child: PopScope(
        onPopInvoked: (didPop) async {
          context
              .read<SearchBlocWrapper>()
              .searchHouseholdsBloc
              .add(const SearchHouseholdsClearEvent());
          context.router.maybePop();
        },
        child: BlocBuilder<HouseholdOverviewBloc, HouseholdOverviewState>(
          builder: (ctx, state) {
            return Scaffold(
              body: state.loading
                  ? const Center(child: CircularProgressIndicator())
                  : NotificationListener<ScrollNotification>(
                      onNotification: (scrollNotification) {
                        if (scrollNotification is ScrollUpdateNotification) {
                          final metrics = scrollNotification.metrics;
                          if (metrics.atEdge && metrics.pixels != 0) {
                            if (state.offset != null) {
                              callReloadEvent(
                                  offset: state.offset ?? 0, limit: limit);
                            }
                          }
                        }
                        //Return true to allow the notification to continue to be dispatched to further ancestors.
                        return true;
                      },
                      child: ScrollableContent(
                        header: Padding(
                          padding: const EdgeInsets.only(bottom: spacer2),
                          child: CustomBackNavigationHelpHeaderWidget(
                            showHelp: false,
                            handleback: () {
                              context
                                  .read<SearchHouseholdsBloc>()
                                  .add(const SearchHouseholdsEvent.clear());
                            },
                          ),
                        ),
                        enableFixedDigitButton: true,
                        footer: DigitCard(
                          margin: const EdgeInsets.only(top: spacer2),
                          children: [
                            Offstage(
                              offstage: beneficiaryType ==
                                      BeneficiaryType.individual ||
                                  isOutsideProjectDateRange(),
                              child: BlocBuilder<ServiceDefinitionBloc,
                                  ServiceDefinitionState>(
                                builder: (context, serviceDefinitionState) =>
                                    BlocBuilder<DeliverInterventionBloc,
                                        DeliverInterventionState>(
                                  builder: (ctx, deliverInterventionState) =>
                                      state.householdMemberWrapper.tasks
                                                  ?.lastOrNull?.status ==
                                              Status.administeredSuccess
                                                  .toValue()
                                          ? Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: spacer2),
                                              child: DigitButton(
                                                label: localizations.translate(
                                                  '${RegistrationDeliverySingleton().selectedProject!.projectType}_${i18.memberCard.deliverDetailsUpdateLabel}',
                                                ),
                                                capitalizeLetters: false,
                                                isDisabled: state
                                                            .householdMemberWrapper
                                                            .tasks
                                                            ?.lastOrNull
                                                            ?.status ==
                                                        Status
                                                            .administeredSuccess
                                                            .toValue()
                                                    ? true
                                                    : false,
                                                type: DigitButtonType.secondary,
                                                size: DigitButtonSize.large,
                                                mainAxisSize: MainAxisSize.max,
                                                onPressed: () {
                                                  serviceDefinitionState.when(
                                                      empty: () {},
                                                      isloading: () {},
                                                      serviceDefinitionFetch:
                                                          (value, model) {
                                                        if (value
                                                            .where((element) =>
                                                                element.code
                                                                    .toString()
                                                                    .contains(
                                                                        '${RegistrationDeliverySingleton().selectedProject!.name}.${RegistrationDeliveryEnums.eligibility.toValue()}'))
                                                            .toList()
                                                            .isEmpty) {
                                                          context.router.push(
                                                            CustomDeliverInterventionRoute(
                                                                eligibilityAssessmentType:
                                                                    EligibilityAssessmentType
                                                                        .smc),
                                                          );
                                                        } else {
                                                          navigateToChecklist(
                                                              ctx,
                                                              state
                                                                  .householdMemberWrapper
                                                                  .household!
                                                                  .clientReferenceId);
                                                        }
                                                      });
                                                  callReloadEvent(
                                                      offset: state
                                                          .householdMemberWrapper
                                                          .members!
                                                          .length,
                                                      limit: limit);
                                                },
                                              ),
                                            )
                                          : DigitButton(
                                              label: localizations.translate(
                                                '${RegistrationDeliverySingleton().selectedProject!.projectType}_${i18.householdOverView.householdOverViewActionText}',
                                              ),
                                              capitalizeLetters: false,
                                              type: DigitButtonType.primary,
                                              size: DigitButtonSize.large,
                                              mainAxisSize: MainAxisSize.max,
                                              isDisabled: (state.householdMemberWrapper
                                                                  .projectBeneficiaries ??
                                                              [])
                                                          .isEmpty ||
                                                      state
                                                              .householdMemberWrapper
                                                              .tasks
                                                              ?.lastOrNull
                                                              ?.status ==
                                                          Status.closeHousehold
                                                              .toValue()
                                                  ? true
                                                  : false,
                                              onPressed: () async {
                                                final bloc = ctx.read<
                                                    HouseholdOverviewBloc>();

                                                final projectId =
                                                    RegistrationDeliverySingleton()
                                                        .projectId!;

                                                bloc.add(
                                                  HouseholdOverviewReloadEvent(
                                                    projectId: projectId,
                                                    projectBeneficiaryType:
                                                        beneficiaryType,
                                                  ),
                                                );

                                                serviceDefinitionState.when(
                                                    empty: () {},
                                                    isloading: () {},
                                                    serviceDefinitionFetch:
                                                        (value, model) {
                                                      if (value
                                                          .where((element) =>
                                                              element.code
                                                                  .toString()
                                                                  .contains(
                                                                      '${RegistrationDeliverySingleton().selectedProject?.name}.${RegistrationDeliveryEnums.iec.toValue()}') ||
                                                              element.code
                                                                  .toString()
                                                                  .contains(
                                                                      '${RegistrationDeliverySingleton().selectedProject!.name}.${RegistrationDeliveryEnums.eligibility.toValue()}'))
                                                          .toList()
                                                          .isEmpty) {
                                                        context.router.push(
                                                          CustomDeliverInterventionRoute(
                                                              eligibilityAssessmentType:
                                                                  EligibilityAssessmentType
                                                                      .smc),
                                                        );
                                                      } else {
                                                        navigateToChecklist(
                                                            ctx,
                                                            RegistrationDeliverySingleton()
                                                                        .beneficiaryType ==
                                                                    BeneficiaryType
                                                                        .individual
                                                                ? state
                                                                    .selectedIndividual!
                                                                    .clientReferenceId
                                                                : state
                                                                    .householdMemberWrapper
                                                                    .household!
                                                                    .clientReferenceId);
                                                      }
                                                    });
                                                callReloadEvent(
                                                    offset: state
                                                        .householdMemberWrapper
                                                        .members!
                                                        .length,
                                                    limit: limit);
                                              },
                                            ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        slivers: [
                          SliverToBoxAdapter(
                            child: DigitCard(
                                margin: const EdgeInsets.all(spacer2),
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.max,
                                    children: [
                                      // Row(
                                      //   children: [
                                      //     Align(
                                      //       alignment: Alignment.centerLeft,
                                      //       child: Padding(
                                      //         padding:
                                      //             const EdgeInsets.all(spacer2),
                                      //         child: Text(
                                      //           RegistrationDeliverySingleton()
                                      //                           .householdType !=
                                      //                       null &&
                                      //                   RegistrationDeliverySingleton()
                                      //                           .householdType ==
                                      //                       HouseholdType
                                      //                           .community
                                      //               ? localizations.translate(
                                      //                   i18.householdOverView
                                      //                       .clfOverviewLabel)
                                      //               : localizations.translate(i18
                                      //                   .householdOverView
                                      //                   .householdOverViewLabel),
                                      //           style: textTheme.headingXl
                                      //               .copyWith(
                                      //                   color: theme.colorTheme
                                      //                       .text.primary),
                                      //         ),
                                      //       ),
                                      //     ),
                                      //     const Spacer(),
                                      //     if ((state.householdMemberWrapper
                                      //                 .projectBeneficiaries ??
                                      //             [])
                                      //         .isNotEmpty)
                                      //       Align(
                                      //         alignment: Alignment.centerRight,
                                      //         child: DigitButton(
                                      //           onPressed: () {
                                      //             final projectId =
                                      //                 RegistrationDeliverySingleton()
                                      //                     .projectId!;

                                      //             final bloc = context.read<
                                      //                 HouseholdOverviewBloc>();
                                      //             bloc.add(
                                      //               HouseholdOverviewReloadEvent(
                                      //                 projectId: projectId,
                                      //                 projectBeneficiaryType:
                                      //                     beneficiaryType,
                                      //               ),
                                      //             );
                                      //             showDialog(
                                      //               context: context,
                                      //               builder: (ctx) =>
                                      //                   DigitActionCard(
                                      //                 actions: [
                                      //                   DigitButton(
                                      //                     capitalizeLetters:
                                      //                         false,
                                      //                     prefixIcon:
                                      //                         Icons.edit,
                                      //                     label: (RegistrationDeliverySingleton()
                                      //                                 .householdType ==
                                      //                             HouseholdType
                                      //                                 .community)
                                      //                         ? localizations
                                      //                             .translate(i18
                                      //                                 .householdOverView
                                      //                                 .clfOverViewEditLabel)
                                      //                         : localizations
                                      //                             .translate(
                                      //                             i18.householdOverView
                                      //                                 .householdOverViewEditLabel,
                                      //                           ),
                                      //                     type: DigitButtonType
                                      //                         .secondary,
                                      //                     size: DigitButtonSize
                                      //                         .large,
                                      //                     onPressed: () async {
                                      //                       Navigator.of(
                                      //                         context,
                                      //                         rootNavigator:
                                      //                             true,
                                      //                       ).pop();

                                      //                       HouseholdMemberWrapper
                                      //                           wrapper = state
                                      //                               .householdMemberWrapper;

                                      //                       final timestamp = wrapper
                                      //                           .headOfHousehold
                                      //                           ?.clientAuditDetails
                                      //                           ?.createdTime;
                                      //                       final date = DateTime
                                      //                           .fromMillisecondsSinceEpoch(
                                      //                         timestamp ??
                                      //                             DateTime.now()
                                      //                                 .millisecondsSinceEpoch,
                                      //                       );

                                      //                       final address =
                                      //                           wrapper
                                      //                               .household
                                      //                               ?.address;

                                      //                       if (address == null)
                                      //                         return;

                                      //                       final projectBeneficiary = state
                                      //                           .householdMemberWrapper
                                      //                           .projectBeneficiaries
                                      //                           ?.firstWhereOrNull(
                                      //                         (element) =>
                                      //                             element
                                      //                                 .beneficiaryClientReferenceId ==
                                      //                             wrapper
                                      //                                 .household
                                      //                                 ?.clientReferenceId,
                                      //                       );

                                      //                       await context
                                      //                           .router.root
                                      //                           .push(
                                      //                         CustomBeneficiaryRegistrationWrapperRoute(
                                      //                           initialState:
                                      //                               BeneficiaryRegistrationEditHouseholdState(
                                      //                             addressModel:
                                      //                                 address,
                                      //                             individualModel:
                                      //                                 state.householdMemberWrapper
                                      //                                         .members ??
                                      //                                     [],
                                      //                             householdModel: state
                                      //                                 .householdMemberWrapper
                                      //                                 .household!,
                                      //                             registrationDate:
                                      //                                 date,
                                      //                             projectBeneficiaryModel:
                                      //                                 projectBeneficiary,
                                      //                           ),
                                      //                           children: [
                                      //                             HouseholdLocationRoute(),
                                      //                           ],
                                      //                         ),
                                      //                       );
                                      //                       callReloadEvent(
                                      //                           offset: 0,
                                      //                           limit: 10);
                                      //                     },
                                      //                   ),
                                      //                 ],
                                      //               ),
                                      //             );
                                      //           },
                                      //           label: (RegistrationDeliverySingleton()
                                      //                       .householdType ==
                                      //                   HouseholdType.community)
                                      //               ? localizations.translate(i18
                                      //                   .householdOverView
                                      //                   .clfOverViewEditIconText)
                                      //               : localizations.translate(
                                      //                   i18.householdOverView
                                      //                       .householdOverViewEditIconText,
                                      //                 ),
                                      //           type: DigitButtonType.tertiary,
                                      //           size: DigitButtonSize.medium,
                                      //           prefixIcon: Icons.edit,
                                      //           capitalizeLetters: false,
                                      //         ),
                                      //       ),
                                      //   ],
                                      // ),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          left: spacer2,
                                          right: spacer2,
                                        ),
                                        child: BlocBuilder<
                                                DeliverInterventionBloc,
                                                DeliverInterventionState>(
                                            builder: (ctx,
                                                deliverInterventionState) {
                                          bool shouldShowStatus =
                                              beneficiaryType ==
                                                  BeneficiaryType.household;

                                          if (RegistrationDeliverySingleton()
                                                  .householdType ==
                                              HouseholdType.community) {
                                            return Column(
                                              children: [
                                                DigitTableCard(element: {
                                                  localizations.translate(i18
                                                      .householdOverView
                                                      .instituteNameLabel): state
                                                          .householdMemberWrapper
                                                          .household
                                                          ?.address
                                                          ?.buildingName ??
                                                      localizations.translate(
                                                          i18.common
                                                              .coreCommonNA),
                                                }),
                                              ],
                                            );
                                          }

                                          return Column(
                                            children: [
                                              DigitTableCard(
                                                element: {
                                                  localizations.translate(i18
                                                      .householdOverView
                                                      .householdOverViewHouseholdHeadNameLabel): state
                                                          .householdMemberWrapper
                                                          .headOfHousehold
                                                          ?.name
                                                          ?.givenName ??
                                                      localizations.translate(
                                                          i18.common
                                                              .coreCommonNA),
                                                  localizations.translate(
                                                    i18.householdLocation
                                                        .administrationAreaFormLabel,
                                                  ): localizations.translate(state
                                                          .householdMemberWrapper
                                                          .headOfHousehold
                                                          ?.address
                                                          ?.first
                                                          .locality
                                                          ?.code ??
                                                      i18.common.coreCommonNA),
                                                  if (shouldShowStatus)
                                                    localizations.translate(i18
                                                            .beneficiaryDetails
                                                            .status):
                                                        localizations.translate(
                                                      getStatusAttributes(state,
                                                              deliverInterventionState)[
                                                          'textLabel'],
                                                    )
                                                },
                                              ),
                                            ],
                                          );
                                        }),
                                      ),
                                      if (RegistrationDeliverySingleton()
                                              .householdType ==
                                          HouseholdType.community) ...[
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              top: spacer2, bottom: spacer2),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: DigitSearchBar(
                                                  controller: searchController,
                                                  hintText:
                                                      localizations.translate(
                                                    i18.common.searchByName,
                                                  ),
                                                  textCapitalization:
                                                      TextCapitalization.words,
                                                  onChanged: (value) {
                                                    if (value.length >= 3) {
                                                      callReloadEvent(
                                                          offset: 0, limit: 10);
                                                    } else if (searchController
                                                        .value.text.isEmpty) {
                                                      callReloadEvent(
                                                          offset: 0, limit: 10);
                                                    }
                                                  },
                                                ),
                                              ),
                                              Column(
                                                children: [
                                                  getFilters()
                                                      ? Align(
                                                          alignment:
                                                              Alignment.topLeft,
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(
                                                                    spacer2),
                                                            child: DigitButton(
                                                              label:
                                                                  getFilterIconNLabel()[
                                                                      'label'],
                                                              size:
                                                                  DigitButtonSize
                                                                      .medium,
                                                              type:
                                                                  DigitButtonType
                                                                      .tertiary,
                                                              suffixIcon:
                                                                  getFilterIconNLabel()[
                                                                      'icon'],
                                                              onPressed: () =>
                                                                  showFilterDialog(),
                                                            ),
                                                          ),
                                                        )
                                                      : const Offstage(),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
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
                                                    itemBuilder:
                                                        (context, index) {
                                                      return Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(spacer1),
                                                        child: DigitChip(
                                                          label:
                                                              '${localizations.translate(getStatus(selectedFilters[index]))}'
                                                              ' (${state.householdMemberWrapper.members!.length})',
                                                          onItemDelete: () {
                                                            selectedFilters.remove(
                                                                selectedFilters[
                                                                    index]);
                                                            callReloadEvent(
                                                                offset: 0,
                                                                limit: 10);
                                                          },
                                                        ),
                                                      );
                                                    }),
                                              ),
                                            )
                                          : const Offstage(),
                                      Column(
                                        children: (state.householdMemberWrapper
                                                    .members ??
                                                [])
                                            .map(
                                          (e) {
                                            final isHead = state
                                                    .householdMemberWrapper
                                                    .headOfHousehold
                                                    ?.clientReferenceId ==
                                                e.clientReferenceId;
                                            final projectBeneficiaryId = state
                                                .householdMemberWrapper
                                                .projectBeneficiaries
                                                ?.firstWhereOrNull((b) =>
                                                    b.beneficiaryClientReferenceId ==
                                                    e.clientReferenceId)
                                                ?.clientReferenceId;

                                            final projectBeneficiary = state
                                                .householdMemberWrapper
                                                .projectBeneficiaries
                                                ?.where(
                                                  (element) =>
                                                      element
                                                          .beneficiaryClientReferenceId ==
                                                      (RegistrationDeliverySingleton()
                                                                  .beneficiaryType ==
                                                              BeneficiaryType
                                                                  .individual
                                                          ? e.clientReferenceId
                                                          : state
                                                              .householdMemberWrapper
                                                              .household
                                                              ?.clientReferenceId),
                                                )
                                                .toList();

                                            final taskData = (projectBeneficiary ??
                                                        [])
                                                    .isNotEmpty
                                                ? state.householdMemberWrapper
                                                    .tasks
                                                    ?.where((element) =>
                                                        element
                                                            .projectBeneficiaryClientReferenceId ==
                                                        projectBeneficiary
                                                            ?.first
                                                            .clientReferenceId)
                                                    .toList()
                                                : null;
                                            final referralData =
                                                (projectBeneficiary ?? [])
                                                        .isNotEmpty
                                                    ? state
                                                        .householdMemberWrapper
                                                        .referrals
                                                        ?.where((element) =>
                                                            element
                                                                .projectBeneficiaryClientReferenceId ==
                                                            projectBeneficiary
                                                                ?.first
                                                                .clientReferenceId)
                                                        .toList()
                                                    : null;
                                            final sideEffectData = taskData !=
                                                        null &&
                                                    taskData.isNotEmpty
                                                ? state.householdMemberWrapper
                                                    .sideEffects
                                                    ?.where((element) =>
                                                        element
                                                            .taskClientReferenceId ==
                                                        taskData.lastOrNull
                                                            ?.clientReferenceId)
                                                    .toList()
                                                : null;
                                            final ageInYears = e.dateOfBirth !=
                                                    null
                                                ? DigitDateUtils.calculateAge(
                                                    DigitDateUtils
                                                            .getFormattedDateToDateTime(
                                                          e.dateOfBirth!,
                                                        ) ??
                                                        DateTime.now(),
                                                  ).years
                                                : 0;
                                            final ageInMonths = e.dateOfBirth !=
                                                    null
                                                ? DigitDateUtils.calculateAge(
                                                    DigitDateUtils
                                                            .getFormattedDateToDateTime(
                                                          e.dateOfBirth!,
                                                        ) ??
                                                        DateTime.now(),
                                                  ).months
                                                : 0;
                                            final currentCycle =
                                                RegistrationDeliverySingleton()
                                                    .projectType
                                                    ?.cycles
                                                    ?.firstWhereOrNull(
                                                      (e) =>
                                                          (e.startDate) <
                                                              DateTime.now()
                                                                  .millisecondsSinceEpoch &&
                                                          (e.endDate) >
                                                              DateTime.now()
                                                                  .millisecondsSinceEpoch,
                                                    );

                                            final isBeneficiaryRefused =
                                                checkIfBeneficiaryRefused(
                                              taskData,
                                            );
                                            final isBeneficiaryReferred =
                                                checkIfBeneficiaryReferred(
                                              referralData,
                                              currentCycle,
                                            );

                                            return BlocBuilder<
                                                ProductVariantBloc,
                                                ProductVariantState>(
                                              builder: (context,
                                                  productVariantState) {
                                                return productVariantState
                                                    .maybeWhen(
                                                  orElse: () =>
                                                      const SizedBox.shrink(),
                                                  fetched: (value) {
                                                    return CustomMemberCard(
                                                      variant: value,
                                                      isHead: isHead,
                                                      individual: e,
                                                      projectBeneficiaries:
                                                          projectBeneficiary ??
                                                              [],
                                                      tasks: taskData,
                                                      sideEffects:
                                                          sideEffectData,
                                                      editMemberAction:
                                                          () async {
                                                        final bloc = ctx.read<
                                                            HouseholdOverviewBloc>();

                                                        Navigator.of(
                                                          context,
                                                          rootNavigator: true,
                                                        ).pop();

                                                        final address =
                                                            e.address;
                                                        if (address == null ||
                                                            address.isEmpty) {
                                                          return;
                                                        }

                                                        final projectId =
                                                            RegistrationDeliverySingleton()
                                                                .projectId!;
                                                        bloc.add(
                                                          HouseholdOverviewReloadEvent(
                                                            projectId:
                                                                projectId,
                                                            projectBeneficiaryType:
                                                                beneficiaryType,
                                                          ),
                                                        );

                                                        await context
                                                            .router.root
                                                            .push(
                                                          CustomBeneficiaryRegistrationWrapperRoute(
                                                            initialState:
                                                                BeneficiaryRegistrationEditIndividualState(
                                                              individualModel:
                                                                  e,
                                                              householdModel: state
                                                                  .householdMemberWrapper
                                                                  .household!,
                                                              addressModel:
                                                                  address.first,
                                                              projectBeneficiaryModel: state
                                                                  .householdMemberWrapper
                                                                  .projectBeneficiaries
                                                                  ?.firstWhereOrNull(
                                                                (element) =>
                                                                    element
                                                                        .beneficiaryClientReferenceId ==
                                                                    (RegistrationDeliverySingleton().beneficiaryType ==
                                                                            BeneficiaryType
                                                                                .individual
                                                                        ? e
                                                                            .clientReferenceId
                                                                        : state
                                                                            .householdMemberWrapper
                                                                            .household
                                                                            ?.clientReferenceId),
                                                              ),
                                                            ),
                                                            children: [
                                                              CustomIndividualDetailsRoute(
                                                                isHeadOfHousehold:
                                                                    isHead,
                                                              ),
                                                            ],
                                                          ),
                                                        );
                                                        callReloadEvent(
                                                            offset: 0,
                                                            limit: 10);
                                                      },
                                                      setAsHeadAction: () {
                                                        ctx
                                                            .read<
                                                                HouseholdOverviewBloc>()
                                                            .add(
                                                              HouseholdOverviewSetAsHeadEvent(
                                                                individualModel:
                                                                    e,
                                                                projectId:
                                                                    RegistrationDeliverySingleton()
                                                                        .projectId!,
                                                                householdModel: state
                                                                    .householdMemberWrapper
                                                                    .household!,
                                                                projectBeneficiaryType:
                                                                    beneficiaryType,
                                                              ),
                                                            );

                                                        Navigator.of(
                                                          context,
                                                          rootNavigator: true,
                                                        ).pop();
                                                      },
                                                      deleteMemberAction: () {
                                                        showCustomPopup(
                                                          context: context,
                                                          builder: (BuildContext
                                                                  context) =>
                                                              Popup(
                                                                  title: localizations
                                                                      .translate(i18
                                                                          .householdOverView
                                                                          .householdOverViewActionCardTitle),
                                                                  type: PopUpType
                                                                      .simple,
                                                                  actions: [
                                                                DigitButton(
                                                                    label: localizations.translate(i18
                                                                        .householdOverView
                                                                        .householdOverViewPrimaryActionLabel),
                                                                    onPressed:
                                                                        () {
                                                                      Navigator
                                                                          .of(
                                                                        context,
                                                                        rootNavigator:
                                                                            true,
                                                                      )
                                                                        ..pop()
                                                                        ..pop();
                                                                      context
                                                                          .read<
                                                                              HouseholdOverviewBloc>()
                                                                          .add(
                                                                            HouseholdOverviewEvent.selectedIndividual(
                                                                              individualModel: e,
                                                                            ),
                                                                          );
                                                                      context
                                                                          .router
                                                                          .push(
                                                                        ReasonForDeletionRoute(
                                                                          isHousholdDelete:
                                                                              false,
                                                                        ),
                                                                      );
                                                                    },
                                                                    type: DigitButtonType
                                                                        .primary,
                                                                    size: DigitButtonSize
                                                                        .large),
                                                                DigitButton(
                                                                    label: localizations.translate(i18
                                                                        .householdOverView
                                                                        .householdOverViewSecondaryActionLabel),
                                                                    onPressed:
                                                                        () {
                                                                      Navigator
                                                                          .of(
                                                                        context,
                                                                        rootNavigator:
                                                                            true,
                                                                      ).pop();
                                                                    },
                                                                    type: DigitButtonType
                                                                        .tertiary,
                                                                    size: DigitButtonSize
                                                                        .large)
                                                              ]),
                                                        );
                                                      },
                                                      isNotEligibleSMC:
                                                          RegistrationDeliverySingleton()
                                                                      .projectType
                                                                      ?.cycles !=
                                                                  null
                                                              ? !checkEligibilityForAgeAndSideEffectAll(
                                                                  DigitDOBAgeConvertor(
                                                                    years:
                                                                        ageInYears,
                                                                    months:
                                                                        ageInMonths,
                                                                  ),
                                                                  RegistrationDeliverySingleton()
                                                                      .projectType,
                                                                  (taskData ??
                                                                              [])
                                                                          .isNotEmpty
                                                                      ? taskData
                                                                          ?.lastOrNull
                                                                      : null,
                                                                  sideEffectData,
                                                                )
                                                              : false,
                                                      isNotEligibleVAS:
                                                          RegistrationDeliverySingleton()
                                                                      .projectType
                                                                      ?.cycles !=
                                                                  null
                                                              ? !checkEligibilityForAgeAndSideEffectAll(
                                                                  DigitDOBAgeConvertor(
                                                                    years:
                                                                        ageInYears,
                                                                    months:
                                                                        ageInMonths,
                                                                  ),
                                                                  RegistrationDeliverySingleton()
                                                                      .selectedProject
                                                                      ?.additionalDetails
                                                                      ?.additionalProjectType,
                                                                  (taskData ??
                                                                              [])
                                                                          .isNotEmpty
                                                                      ? taskData
                                                                          ?.lastOrNull
                                                                      : null,
                                                                  sideEffectData,
                                                                )
                                                              : false,
                                                      name: e.name?.givenName ??
                                                          ' - - ',
                                                      years:
                                                          (e.dateOfBirth == null
                                                              ? null
                                                              : DigitDateUtils
                                                                  .calculateAge(
                                                                  DigitDateUtils
                                                                          .getFormattedDateToDateTime(
                                                                        e.dateOfBirth!,
                                                                      ) ??
                                                                      DateTime
                                                                          .now(),
                                                                ).years),
                                                      months:
                                                          (e.dateOfBirth == null
                                                              ? null
                                                              : DigitDateUtils
                                                                  .calculateAge(
                                                                  DigitDateUtils
                                                                          .getFormattedDateToDateTime(
                                                                        e.dateOfBirth!,
                                                                      ) ??
                                                                      DateTime
                                                                          .now(),
                                                                ).months),
                                                      gender: e.gender?.name,
                                                      isBeneficiaryRefused:
                                                          isBeneficiaryRefused &&
                                                              !checkStatusSMC(
                                                                taskData,
                                                                currentCycle,
                                                              ),
                                                      isBeneficiaryReferred:
                                                          isBeneficiaryReferred,
                                                      isSMCDelivered: taskData ==
                                                              null
                                                          ? false
                                                          : taskData.isNotEmpty &&
                                                                  !checkStatusSMC(
                                                                    taskData,
                                                                    currentCycle,
                                                                  )
                                                              ? true
                                                              : false,
                                                      isVASDelivered: taskData ==
                                                              null
                                                          ? false
                                                          : taskData.isNotEmpty &&
                                                                  !checkStatusVAS(
                                                                    taskData,
                                                                    currentCycle,
                                                                  )
                                                              ? true
                                                              : false,
                                                      localizations:
                                                          localizations,
                                                      projectBeneficiaryClientReferenceId:
                                                          projectBeneficiaryId,
                                                    );
                                                  },
                                                );
                                              },
                                            );
                                          },
                                        ).toList(),
                                      ),
                                    ],
                                  ),
                                  DigitButton(
                                    mainAxisSize: MainAxisSize.max,
                                    onPressed: () {
                                      int spaq1 = context.spaq1;
                                      int spaq2 = context.spaq2;
                                      int blueVas = context.blueVas;
                                      int redVas = context.redVas;
                                      String descriptionText =
                                          localizations.translate(i18_local
                                              .beneficiaryDetails
                                              .insufficientStockMessage);
                                      if (spaq1 == 0) {
                                        descriptionText +=
                                            "\n ${localizations.translate(i18_local.beneficiaryDetails.spaq1DoseUnit)}";
                                      }
                                      if (spaq2 == 0) {
                                        descriptionText +=
                                            "\n ${localizations.translate(i18_local.beneficiaryDetails.spaq2DoseUnit)}";
                                      }
                                      // if (blueVas == 0) {
                                      //   descriptionText +=
                                      //       "\n ${localizations.translate(i18_local.beneficiaryDetails.blueVasZeroQuantity)}";
                                      // }
                                      // if (redVas == 0) {
                                      //   descriptionText +=
                                      //       "\n ${localizations.translate(i18_local.beneficiaryDetails.redVasZeroQuantity)}";
                                      // }

                                      if (spaq1 > 0 || spaq2 > 0) {
                                        addIndividual(
                                          context,
                                          state
                                              .householdMemberWrapper.household,
                                        );
                                      } else {
                                        showCustomPopup(
                                          context: context,
                                          builder: (popupContext) => Popup(
                                            title: localizations.translate(
                                                i18_local.beneficiaryDetails
                                                    .insufficientStockHeading),
                                            onOutsideTap: () {
                                              Navigator.of(popupContext)
                                                  .pop(false);
                                            },
                                            description: descriptionText,
                                            type: PopUpType.simple,
                                            actions: [
                                              DigitButton(
                                                label: localizations.translate(
                                                  i18_local.beneficiaryDetails
                                                      .goToHome,
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
                                    label: localizations.translate(i18_local
                                        .householdDetails.addBeneficiartText),
                                    prefixIcon: Icons.add_circle,
                                    type: DigitButtonType.tertiary,
                                    size: DigitButtonSize.large,
                                  ),
                                ]),
                          ),
                        ],
                      ),
                    ),
            );
          },
        ),
      ),
    );
  }

  addIndividual(BuildContext context, HouseholdModel? household) async {
    final bloc = context.read<HouseholdOverviewBloc>();

    final address = household?.address;

    if (address == null) return;
    bloc.add(
      HouseholdOverviewReloadEvent(
        projectId: RegistrationDeliverySingleton().projectId!,
        projectBeneficiaryType:
            RegistrationDeliverySingleton().beneficiaryType!,
      ),
    );
    await context.router.popAndPush(
      CustomBeneficiaryRegistrationWrapperRoute(
        initialState: BeneficiaryRegistrationAddMemberState(
          addressModel: address,
          householdModel: household!,
        ),
        children: [
          CustomIndividualDetailsRoute(),
        ],
      ),
    );
  }

  bool isOutsideProjectDateRange() {
    final project = RegistrationDeliverySingleton().selectedProject;

    if (project?.startDate != null && project?.endDate != null) {
      final now = DateTime.now().millisecondsSinceEpoch;
      final startDate = project!.startDate!;
      final endDate = project.endDate!;

      return now < startDate || now > endDate;
    }

    return false;
  }

  getStatusAttributes(HouseholdOverviewState state,
      DeliverInterventionState deliverInterventionState) {
    var textLabel =
        i18.householdOverView.householdOverViewNotRegisteredIconLabel;
    var color = DigitTheme.instance.colorScheme.error;
    var icon = Icons.info_rounded;

    if ((state.householdMemberWrapper.projectBeneficiaries ?? []).isNotEmpty) {
      textLabel = state.householdMemberWrapper.tasks?.isNotEmpty ?? false
          ? getTaskStatus(state.householdMemberWrapper.tasks ?? []).toValue() ==
                  Status.administeredSuccess.toValue()
              ? '${RegistrationDeliverySingleton().selectedProject!.projectType}_${getTaskStatus(state.householdMemberWrapper.tasks ?? []).toValue()}'
              : getTaskStatus(state.householdMemberWrapper.tasks ?? [])
                  .toValue()
          : Status.registered.toValue();

      color = state.householdMemberWrapper.tasks?.isNotEmpty ?? false
          ? (state.householdMemberWrapper.tasks?.lastOrNull?.status ==
                  Status.administeredSuccess.toValue()
              ? DigitTheme.instance.colorScheme.onSurfaceVariant
              : DigitTheme.instance.colorScheme.error)
          : DigitTheme.instance.colorScheme.onSurfaceVariant;

      icon = state.householdMemberWrapper.tasks?.isNotEmpty ?? false
          ? (state.householdMemberWrapper.tasks?.lastOrNull?.status ==
                  Status.administeredSuccess.toValue()
              ? Icons.check_circle
              : Icons.info_rounded)
          : Icons.check_circle;
    } else {
      textLabel = i18.householdOverView.householdOverViewNotRegisteredIconLabel;
      color = DigitTheme.instance.colorScheme.error;
      icon = Icons.info_rounded;
    }

    return {'textLabel': textLabel, 'color': color, 'icon': icon};
  }

  void navigateToChecklist(
      BuildContext ctx, String beneficiaryClientRefId) async {
    await context.router.push(BeneficiaryChecklistRoute(
        beneficiaryClientRefId: beneficiaryClientRefId));
  }

  void callReloadEvent({
    required int offset,
    required int limit,
  }) {
    if (mounted) {
      final bloc = context.read<HouseholdOverviewBloc>();

      bloc.add(
        HouseholdOverviewReloadEvent(
          projectId: RegistrationDeliverySingleton().projectId!,
          projectBeneficiaryType:
              RegistrationDeliverySingleton().beneficiaryType!,
          offset: offset,
          limit: limit,
          searchByName: searchController.text.trim().length > 2
              ? searchController.text.trim()
              : null,
          selectedFilter: selectedFilters,
        ),
      );
    }
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
      selectedFilters.clear();
      selectedFilters.addAll(filters);
      callReloadEvent(offset: 0, limit: 10);
    } else {
      setState(() {
        selectedFilters = [];
      });

      callReloadEvent(offset: 0, limit: 10);
    }
  }

  String getStatus(String selectedFilter) {
    final statusMap = {
      Status.delivered.toValue(): Status.delivered,
      Status.notAdministered.toValue(): Status.notAdministered,
      Status.visited.toValue(): Status.visited,
      Status.notVisited.toValue(): Status.notVisited,
      Status.beneficiaryRefused.toValue(): Status.beneficiaryRefused,
      Status.beneficiaryReferred.toValue(): Status.beneficiaryReferred,
      Status.administeredSuccess.toValue(): Status.administeredSuccess,
      Status.administeredFailed.toValue(): Status.administeredFailed,
      Status.inComplete.toValue(): Status.inComplete,
      Status.toAdminister.toValue(): Status.toAdminister,
      Status.closeHousehold.toValue(): Status.closeHousehold,
      Status.registered.toValue(): Status.registered,
      Status.notRegistered.toValue(): Status.notRegistered,
    };

    var mappedStatus = statusMap.entries
        .where((element) => element.value.name == selectedFilter)
        .first
        .key;
    if (mappedStatus != null) {
      return mappedStatus;
    } else {
      return selectedFilter;
    }
  }

  getFilters() {
    bool hasFilters;
    if (RegistrationDeliverySingleton().householdType ==
        HouseholdType.community) {
      hasFilters = RegistrationDeliverySingleton().searchCLFFilters != null &&
          RegistrationDeliverySingleton().searchCLFFilters!.isNotEmpty;
    } else {
      hasFilters =
          RegistrationDeliverySingleton().searchHouseHoldFilter != null &&
              RegistrationDeliverySingleton().searchHouseHoldFilter!.isNotEmpty;
    }
    return hasFilters;
  }
}
