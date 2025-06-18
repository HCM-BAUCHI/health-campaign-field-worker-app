import 'package:auto_route/auto_route.dart';
import 'package:collection/collection.dart';
import 'package:digit_data_model/data_model.dart';
import 'package:digit_ui_components/digit_components.dart';
import 'package:digit_ui_components/theme/digit_extended_theme.dart';
import 'package:digit_ui_components/utils/date_utils.dart';
import 'package:digit_ui_components/widgets/atoms/pop_up_card.dart';
import 'package:digit_ui_components/widgets/molecules/digit_card.dart';
import 'package:digit_ui_components/widgets/molecules/show_pop_up.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_campaign_field_worker_app/widgets/custom_back_navigation.dart';
import 'package:health_campaign_field_worker_app/widgets/registration_delivery/past_delivery_smc.dart';
import 'package:intl/intl.dart';
import 'package:recase/recase.dart';
import 'package:registration_delivery/blocs/app_localization.dart';

import 'package:registration_delivery/blocs/delivery_intervention/deliver_intervention.dart';
import 'package:registration_delivery/blocs/household_overview/household_overview.dart';
import 'package:registration_delivery/models/entities/additional_fields_type.dart';
import 'package:registration_delivery/models/entities/task.dart';
import 'package:registration_delivery/router/registration_delivery_router.gm.dart';
import 'package:registration_delivery/utils/i18_key_constants.dart' as i18;
import '../../../models/entities/identifier_types.dart';
import '../../../router/app_router.dart';
import '../../../utils/app_enums.dart';
import '../../../utils/i18_key_constants.dart' as i18_local;
import '../../../models/entities/additional_fields_type.dart'
    as additional_fields_local;
import 'package:registration_delivery/utils/utils.dart';
import 'package:registration_delivery/widgets/back_navigation_help_header.dart';
import 'package:registration_delivery/widgets/component_wrapper/product_variant_bloc_wrapper.dart';
import 'package:registration_delivery/widgets/localized.dart';
import 'package:registration_delivery/widgets/table_card/table_card.dart';
import 'package:registration_delivery/pages/beneficiary/widgets/record_delivery_cycle.dart';

import '../../../widgets/registration_delivery/past_delivery_vas.dart';
import 'custom_record_delivery_cycle.dart';

@RoutePage()
class CustomBeneficiaryDetailsPage extends LocalizedStatefulWidget {
  final EligibilityAssessmentType eligibilityAssessmentType;
  final String? smcSuccess;
  const CustomBeneficiaryDetailsPage({
    required this.eligibilityAssessmentType,
    super.key,
    super.appLocalizations,
    this.smcSuccess = 'false',
  });

  @override
  State<CustomBeneficiaryDetailsPage> createState() =>
      CustomBeneficiaryDetailsPageState();
}

class CustomBeneficiaryDetailsPageState
    extends LocalizedState<CustomBeneficiaryDetailsPage> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  bool checkDeliveryType(TaskModel element) {
    EligibilityAssessmentStatus eligibilityAssessmentStatus =
        widget.eligibilityAssessmentType == EligibilityAssessmentType.smc
            ? EligibilityAssessmentStatus.smcDone
            : EligibilityAssessmentStatus.vasDone;
    return element.additionalFields?.fields.firstWhereOrNull(
          (e) =>
              e.key ==
                  additional_fields_local.AdditionalFieldsType.deliveryType
                      .toValue() &&
              e.value == eligibilityAssessmentStatus.name,
        ) !=
        null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localizations = RegistrationDeliveryLocalization.of(context);
    final router = context.router;
    final textTheme = theme.digitTextTheme(context);

    return ProductVariantBlocWrapper(
      child: BlocBuilder<HouseholdOverviewBloc, HouseholdOverviewState>(
        builder: (context, state) {
          ProjectTypeModel? projectType =
              widget.eligibilityAssessmentType == EligibilityAssessmentType.smc
                  ? RegistrationDeliverySingleton()
                      .selectedProject
                      ?.additionalDetails
                      ?.projectType
                  : RegistrationDeliverySingleton()
                      .selectedProject
                      ?.additionalDetails
                      ?.additionalProjectType;
          final householdMemberWrapper = state.householdMemberWrapper;
          // Filtering project beneficiaries based on the selected individual
          final projectBeneficiary =
              RegistrationDeliverySingleton().beneficiaryType !=
                      BeneficiaryType.individual
                  ? [householdMemberWrapper.projectBeneficiaries?.first]
                  : householdMemberWrapper.projectBeneficiaries
                      ?.where(
                        (element) =>
                            element.beneficiaryClientReferenceId ==
                            state.selectedIndividual?.clientReferenceId,
                      )
                      .toList();

          // Extracting task data related to the selected project beneficiary

          final taskData = state.householdMemberWrapper.tasks
              ?.where((element) =>
                  element.projectBeneficiaryClientReferenceId ==
                      projectBeneficiary?.first?.clientReferenceId &&
                  checkDeliveryType(element))
              .toList();
          final bloc = context.read<DeliverInterventionBloc>();
          final lastDose = taskData != null && taskData.isNotEmpty
              ? taskData.last.additionalFields?.fields
                      .firstWhereOrNull(
                        (e) =>
                            e.key == AdditionalFieldsType.doseIndex.toValue(),
                      )
                      ?.value ??
                  '1'
              : '0';
          final lastCycle = taskData != null && taskData.isNotEmpty
              ? taskData.last.additionalFields?.fields
                      .firstWhereOrNull(
                        (e) =>
                            e.key == AdditionalFieldsType.cycleIndex.toValue(),
                      )
                      ?.value ??
                  '1'
              : '1';

          // [TODO] Need to move this to Bloc Lisitner or consumer
          if (projectType != null) {
            bloc.add(
              DeliverInterventionEvent.setActiveCycleDose(
                lastDose: taskData != null && taskData.isNotEmpty
                    ? int.tryParse(
                          lastDose,
                        ) ??
                        1
                    : 0,
                lastCycle: taskData != null && taskData.isNotEmpty
                    ? int.tryParse(
                          lastCycle,
                        ) ??
                        1
                    : 1,
                individualModel: state.selectedIndividual,
                projectType: projectType,
              ),
            );
          }

          // Building the table content based on the DeliverInterventionState

          return BlocBuilder<ProductVariantBloc, ProductVariantState>(
            builder: (context, productState) {
              return productState.maybeWhen(
                  orElse: () => const Offstage(),
                  fetched: (productVariantsValue) {
                    final variant = productState.whenOrNull(
                      fetched: (productVariants) {
                        return productVariants;
                      },
                    );

                    return Scaffold(
                      body: ScrollableContent(
                        enableFixedDigitButton: true,
                        header: const Column(children: [
                          CustomBackNavigationHelpHeaderWidget(
                            showHelp: false,
                          ),
                        ]),
                        footer: BlocBuilder<DeliverInterventionBloc,
                            DeliverInterventionState>(
                          builder: (context, deliverState) {
                            final cycles = projectType?.cycles;

                            return cycles != null && cycles.isNotEmpty
                                ? deliverState.hasCycleArrived
                                    ? DigitCard(
                                        margin:
                                            const EdgeInsets.only(top: spacer2),
                                        children: [
                                            DigitButton(
                                              label:
                                                  '${localizations.translate(i18.beneficiaryDetails.recordCycle)} '
                                                  '${(deliverState.cycle == 0 ? (deliverState.cycle + 1) : deliverState.cycle).toString()} ${localizations.translate(i18.deliverIntervention.dose)} '
                                                  '${(deliverState.dose).toString()}',
                                              type: DigitButtonType.primary,
                                              size: DigitButtonSize.large,
                                              mainAxisSize: MainAxisSize.max,
                                              onPressed: () async {
                                                final selectedCycle = cycles
                                                    .firstWhereOrNull((c) =>
                                                        c.id ==
                                                        deliverState.cycle);
                                                if (selectedCycle != null) {
                                                  bloc.add(
                                                    DeliverInterventionEvent
                                                        .selectFutureCycleDose(
                                                      dose: deliverState.dose,
                                                      cycle: projectType!
                                                          .cycles!
                                                          .firstWhere((c) =>
                                                              c.id ==
                                                              deliverState
                                                                  .cycle),
                                                      individualModel: state
                                                          .selectedIndividual,
                                                    ),
                                                  );
                                                  showCustomPopup(
                                                    context: context,
                                                    builder: (popUpContext) => Popup(
                                                        title: localizations
                                                            .translate(i18
                                                                .beneficiaryDetails
                                                                .resourcesTobeDelivered),
                                                        type: PopUpType.simple,
                                                        contentPadding:
                                                            EdgeInsets.zero,
                                                        additionalWidgets: [
                                                          widget.eligibilityAssessmentType ==
                                                                  EligibilityAssessmentType
                                                                      .smc
                                                              ? buildTableContentSMC(
                                                                  deliverState,
                                                                  context,
                                                                  variant,
                                                                  state
                                                                      .selectedIndividual,
                                                                  state
                                                                      .householdMemberWrapper
                                                                      .household)
                                                              : buildTableContentVAS(
                                                                  deliverState,
                                                                  context,
                                                                  variant,
                                                                  state
                                                                      .selectedIndividual,
                                                                  state
                                                                      .householdMemberWrapper
                                                                      .household),
                                                        ],
                                                        actions: [
                                                          DigitButton(
                                                              label: localizations
                                                                  .translate(i18
                                                                      .beneficiaryDetails
                                                                      .ctaProceed),
                                                              onPressed: () {
                                                                Navigator.of(
                                                                  context,
                                                                  rootNavigator:
                                                                      true,
                                                                ).pop();
                                                                if (widget
                                                                        .eligibilityAssessmentType ==
                                                                    EligibilityAssessmentType
                                                                        .vas) {
                                                                  router.push(
                                                                    CustomDeliverInterventionRoute(
                                                                        eligibilityAssessmentType:
                                                                            widget
                                                                                .eligibilityAssessmentType,
                                                                        smcSuccess:
                                                                            widget.smcSuccess),
                                                                  );
                                                                } else {
                                                                  router.push(
                                                                    CustomDeliverInterventionRoute(
                                                                        eligibilityAssessmentType:
                                                                            widget.eligibilityAssessmentType),
                                                                  );
                                                                }
                                                              },
                                                              type:
                                                                  DigitButtonType
                                                                      .primary,
                                                              size:
                                                                  DigitButtonSize
                                                                      .large),
                                                        ]),
                                                  );
                                                }
                                              },
                                            ),
                                          ])
                                    : const SizedBox.shrink()
                                : DigitCard(
                                    margin: const EdgeInsets.only(top: spacer2),
                                    children: [
                                        DigitButton(
                                          label: localizations.translate(i18
                                              .householdOverView
                                              .householdOverViewActionText),
                                          type: DigitButtonType.primary,
                                          size: DigitButtonSize.large,
                                          mainAxisSize: MainAxisSize.max,
                                          onPressed: () {
                                            if (widget
                                                    .eligibilityAssessmentType ==
                                                EligibilityAssessmentType.vas) {
                                              context.router.push(
                                                CustomDeliverInterventionRoute(
                                                    eligibilityAssessmentType:
                                                        widget
                                                            .eligibilityAssessmentType,
                                                    smcSuccess:
                                                        widget.smcSuccess),
                                              );
                                            } else {
                                              context.router.push(
                                                CustomDeliverInterventionRoute(
                                                    eligibilityAssessmentType:
                                                        widget
                                                            .eligibilityAssessmentType),
                                              );
                                            }
                                          },
                                        ),
                                      ]);
                          },
                        ),
                        children: [
                          DigitCard(
                              margin: const EdgeInsets.all(spacer2),
                              children: [
                                Text(
                                  localizations.translate(
                                      widget.eligibilityAssessmentType ==
                                              EligibilityAssessmentType.smc
                                          ? i18_local.deliverIntervention
                                              .deliversmcintervention
                                          : i18_local.deliverIntervention
                                              .deliverVASIntervention),
                                  style: textTheme.headingXl.copyWith(
                                      color: theme.colorTheme.text.primary),
                                ),
                                DigitTableCard(
                                  element: {
                                    localizations.translate(
                                      RegistrationDeliverySingleton()
                                                  .beneficiaryType !=
                                              BeneficiaryType.individual
                                          ? i18.householdOverView
                                              .householdOverViewHouseholdHeadLabel
                                          : i18.common.coreCommonName,
                                    ): RegistrationDeliverySingleton()
                                                .beneficiaryType !=
                                            BeneficiaryType.individual
                                        ? householdMemberWrapper
                                            .headOfHousehold?.name?.givenName
                                        : state.selectedIndividual?.name
                                                ?.givenName ??
                                            '--',
                                    localizations.translate(i18_local
                                        .beneficiaryDetails.beneficiaryId): () {
                                      final String? beneficiaryId = state
                                          .selectedIndividual?.identifiers
                                          ?.lastWhereOrNull((e) =>
                                              e.identifierType ==
                                              IdentifierTypes
                                                  .uniqueBeneficiaryID
                                                  .toValue())
                                          ?.identifierId;
                                      return beneficiaryId ?? '--';
                                    }(),
                                    localizations.translate(
                                      i18.common.coreCommonAge,
                                    ): () {
                                      final dob =
                                          RegistrationDeliverySingleton()
                                                      .beneficiaryType !=
                                                  BeneficiaryType.individual
                                              ? householdMemberWrapper
                                                  .headOfHousehold?.dateOfBirth
                                              : state.selectedIndividual
                                                  ?.dateOfBirth;
                                      if (dob == null || dob.isEmpty) {
                                        return '--';
                                      }

                                      final int years =
                                          DigitDateUtils.calculateAge(
                                        DigitDateUtils
                                                .getFormattedDateToDateTime(
                                                    dob) ??
                                            DateTime.now(),
                                      ).years;
                                      final int months =
                                          DigitDateUtils.calculateAge(
                                        DigitDateUtils
                                                .getFormattedDateToDateTime(
                                                    dob) ??
                                            DateTime.now(),
                                      ).months;

                                      return "$years ${localizations.translate(i18.memberCard.deliverDetailsYearText)} ${localizations.translate(months.toString().toUpperCase())} ${localizations.translate(i18.memberCard.deliverDetailsMonthsText)}";
                                    }(),
                                    localizations.translate(
                                      i18.common.coreCommonGender,
                                    ): RegistrationDeliverySingleton()
                                                .beneficiaryType !=
                                            BeneficiaryType.individual
                                        ? householdMemberWrapper.headOfHousehold
                                            ?.gender?.name.sentenceCase
                                        : state.selectedIndividual?.gender?.name
                                                .sentenceCase ??
                                            '--',
                                    localizations.translate(
                                      i18.deliverIntervention
                                          .dateOfRegistrationLabel,
                                    ): () {
                                      final date = projectBeneficiary
                                          ?.first?.dateOfRegistration;

                                      final registrationDate =
                                          DateTime.fromMillisecondsSinceEpoch(
                                        date ??
                                            DateTime.now()
                                                .millisecondsSinceEpoch,
                                      );

                                      return DateFormat('dd MMMM yyyy')
                                          .format(registrationDate);
                                    }(),
                                  },
                                ),
                              ]),
                          if ((projectType?.cycles ?? []).isNotEmpty)
                            DigitCard(
                                margin: const EdgeInsets.all(spacer2),
                                children: projectType?.cycles != null
                                    ? [
                                        BlocBuilder<DeliverInterventionBloc,
                                            DeliverInterventionState>(
                                          builder: (context, deliverState) {
                                            return Column(
                                              children: [
                                                (projectType?.cycles ?? [])
                                                        .isNotEmpty
                                                    ? CustomRecordDeliveryCycle(
                                                        eligibilityAssessmentType:
                                                            widget
                                                                .eligibilityAssessmentType,
                                                        projectCycles:
                                                            projectType
                                                                    ?.cycles ??
                                                                [],
                                                        taskData:
                                                            taskData ?? [],
                                                        individualModel: state
                                                            .selectedIndividual,
                                                      )
                                                    : const Offstage(),
                                              ],
                                            );
                                          },
                                        ),
                                      ]
                                    : [])
                        ],
                      ),
                    );
                  },
                  empty: () => Center(
                        child: Text(
                          localizations.translate(
                            i18.deliverIntervention
                                .checkForProductVariantsConfig,
                          ),
                        ),
                      ));
            },
          );
        },
      ),
    );
  }
}
