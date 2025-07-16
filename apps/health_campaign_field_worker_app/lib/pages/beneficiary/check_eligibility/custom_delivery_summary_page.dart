import 'package:auto_route/auto_route.dart';
import 'package:digit_data_model/data_model.dart';
import 'package:digit_ui_components/digit_components.dart';
import 'package:digit_ui_components/theme/digit_extended_theme.dart';
import 'package:digit_ui_components/widgets/atoms/label_value_list.dart';
import 'package:digit_ui_components/widgets/atoms/pop_up_card.dart';
import 'package:digit_ui_components/widgets/molecules/digit_card.dart';
import 'package:digit_ui_components/widgets/molecules/label_value_summary.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:registration_delivery/blocs/delivery_intervention/deliver_intervention.dart';
import 'package:registration_delivery/blocs/household_overview/household_overview.dart';
import 'package:registration_delivery/models/entities/additional_fields_type.dart';
import 'package:registration_delivery/models/entities/status.dart';
import 'package:registration_delivery/models/entities/task.dart';
import 'package:registration_delivery/router/registration_delivery_router.gm.dart';
import 'package:registration_delivery/utils/constants.dart';
import 'package:registration_delivery/widgets/back_navigation_help_header.dart';
import 'package:registration_delivery/widgets/component_wrapper/product_variant_bloc_wrapper.dart';
import 'package:registration_delivery/widgets/showcase/showcase_button.dart';
import '../../../utils/date_utils.dart' as digits;

import 'package:registration_delivery/widgets/localized.dart';
import 'package:registration_delivery/utils/i18_key_constants.dart' as i18;
import 'package:registration_delivery/utils/utils.dart';

import '../../../router/app_router.dart';
import '../../../utils/app_enums.dart';
import '../../../utils/utils.dart';

@RoutePage()
class CustomDeliverySummaryPage extends LocalizedStatefulWidget {
  final EligibilityAssessmentType eligibilityAssessmentType;
  final TaskModel task;
  const CustomDeliverySummaryPage({
    super.key,
    super.appLocalizations,
    required this.eligibilityAssessmentType,
    required this.task,
  });

  @override
  State<CustomDeliverySummaryPage> createState() =>
      CustomDeliverySummaryPageState();
}

class CustomDeliverySummaryPageState
    extends LocalizedState<CustomDeliverySummaryPage> {
  final clickedStatus = ValueNotifier<bool>(false);

  String getLocalizedMessage(String code) {
    return localizations.translate(code);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.digitTextTheme(context);

    return ProductVariantBlocWrapper(
      child: Scaffold(
          body: BlocConsumer<DeliverInterventionBloc, DeliverInterventionState>(
        listener: (context, deliverState) {
          final router = context.router;
        },
        builder: (context, deliverState) {
          return ScrollableContent(
              enableFixedDigitButton: true,
              header: Column(children: [
                const BackNavigationHelpHeaderWidget(
                  showHelp: false,
                ),
                Padding(
                  padding: const EdgeInsets.all(spacer2),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      localizations.translate(
                        i18.common.coreCommonSummaryDetails,
                      ),
                      style: textTheme.headingXl
                          .copyWith(color: theme.colorTheme.primary.primary2),
                    ),
                  ),
                ),
              ]),
              footer: DigitCard(
                  margin: const EdgeInsets.only(top: spacer2),
                  children: [
                    ValueListenableBuilder(
                      valueListenable: clickedStatus,
                      builder: (context, bool isClicked, _) {
                        return DigitButton(
                          label: localizations
                              .translate(i18.common.coreCommonSubmit),
                          type: DigitButtonType.primary,
                          size: DigitButtonSize.large,
                          mainAxisSize: MainAxisSize.max,
                          isDisabled: isClicked ? true : false,
                          onPressed: () async {
                            final submit = await showDialog<bool>(
                              context: context,
                              builder: (ctx) => Popup(
                                title: localizations.translate(
                                    i18.deliverIntervention.dialogTitle),
                                description: localizations.translate(
                                    i18.deliverIntervention.dialogContent),
                                actions: [
                                  DigitButton(
                                      label: localizations.translate(
                                          i18.common.coreCommonSubmit),
                                      onPressed: () {
                                        clickedStatus.value = true;
                                        Navigator.of(context,
                                                rootNavigator: true)
                                            .pop(true);
                                      },
                                      type: DigitButtonType.primary,
                                      size: DigitButtonSize.large),
                                  DigitButton(
                                      label: localizations.translate(
                                          i18.common.coreCommonCancel),
                                      onPressed: () => Navigator.of(context,
                                              rootNavigator: true)
                                          .pop(false),
                                      type: DigitButtonType.secondary,
                                      size: DigitButtonSize.large),
                                ],
                              ),
                            );
                            if (submit ?? false) {
                              if (context.mounted) {
                                // TODO: Uncomment the following lines if you want to submit the task model here only
                                // Currently it's been shifted to the ZeroDose flow page

                                // context.read<DeliverInterventionBloc>().add(
                                //       DeliverInterventionSubmitEvent(
                                //         task: deliverState.oldTask ?? widget.task,
                                //         isEditing: (deliverState.tasks ?? [])
                                //                     .isNotEmpty &&
                                //                 RegistrationDeliverySingleton()
                                //                         .beneficiaryType ==
                                //                     BeneficiaryType.household
                                //             ? true
                                //             : false,
                                //         boundaryModel:
                                //             RegistrationDeliverySingleton()
                                //                 .boundary!,
                                //       ),
                                //     );

                                // ProjectTypeModel? projectTypeModel =
                                //     widget.eligibilityAssessmentType ==
                                //             EligibilityAssessmentType.smc
                                //         ? RegistrationDeliverySingleton()
                                //             .selectedProject
                                //             ?.additionalDetails
                                //             ?.projectType
                                //         : RegistrationDeliverySingleton()
                                //             .selectedProject
                                //             ?.additionalDetails
                                //             ?.additionalProjectType;

                                // if (deliverState.futureDeliveries != null &&
                                //     deliverState.futureDeliveries!.isNotEmpty &&
                                //     projectTypeModel?.cycles?.isNotEmpty ==
                                //         true) {
                                // context.router.popUntilRouteWithName(
                                //   BeneficiaryWrapperRoute.name,
                                // );
                                context.router.popAndPush(
                                    // CustomSplashAcknowledgementRoute(
                                    //     enableBackToSearch: false,
                                    //     eligibilityAssessmentType:
                                    //         widget.eligibilityAssessmentType),
                                    ZeroDoseCheckRoute(
                                  eligibilityAssessmentType:
                                      widget.eligibilityAssessmentType,
                                  isAdministration: true,
                                  task: widget.task,
                                  projectBeneficiaryClientReferenceId: widget
                                      .task.projectBeneficiaryClientReferenceId,
                                ));
                                // } else {
                                //   final reloadState =
                                //       context.read<HouseholdOverviewBloc>();

                                //   reloadState.add(
                                //     HouseholdOverviewReloadEvent(
                                //       projectId: RegistrationDeliverySingleton()
                                //           .projectId!,
                                //       projectBeneficiaryType:
                                //           RegistrationDeliverySingleton()
                                //               .beneficiaryType!,
                                //     ),
                                //   );
                                //   context.router.popAndPush(
                                //     HouseholdAcknowledgementRoute(
                                //       enableViewHousehold: true,
                                //     ),
                                //   );
                                // }
                              }
                            }
                          },
                        );
                      },
                    ),
                  ]),
              slivers: [
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      DigitCard(
                        margin: const EdgeInsets.all(spacer2),
                        children: [
                          LabelValueSummary(
                              padding: EdgeInsets.zero,
                              heading: localizations.translate(i18
                                  .householdLocation
                                  .householdLocationLabelText),
                              headingStyle: textTheme.headingL.copyWith(
                                color: theme.colorTheme.primary.primary2,
                              ),
                              withDivider: false,
                              items: [
                                LabelValueItem(
                                    label: localizations.translate(
                                        i18.householdLocation.villageLabel),
                                    value: localizations.translate(deliverState
                                            .householdMemberWrapper
                                            ?.household
                                            ?.address
                                            ?.locality
                                            ?.code ??
                                        i18.common.coreCommonNA),
                                    isInline: true,
                                    labelFlex: 5,
                                    padding:
                                        const EdgeInsets.only(bottom: spacer2)),
                                LabelValueItem(
                                    label: localizations.translate(i18
                                        .householdLocation.landmarkFormLabel),
                                    value: deliverState.householdMemberWrapper
                                            ?.household?.address?.landmark ??
                                        localizations
                                            .translate(i18.common.coreCommonNA),
                                    isInline: true,
                                    labelFlex: 5,
                                    padding:
                                        const EdgeInsets.only(top: spacer2)),
                              ]),
                        ],
                      ),
                      DigitCard(
                          margin: const EdgeInsets.all(spacer2),
                          children: [
                            LabelValueSummary(
                                padding: EdgeInsets.zero,
                                heading: localizations.translate(
                                    i18.householdDetails.householdDetailsLabel),
                                headingStyle: textTheme.headingL.copyWith(
                                  color: theme.colorTheme.primary.primary2,
                                ),
                                withDivider: false,
                                items: [
                                  LabelValueItem(
                                      label: localizations.translate(
                                        i18.householdDetails
                                            .noOfMembersCountLabel,
                                      ),
                                      value: deliverState.householdMemberWrapper
                                              ?.household?.memberCount
                                              .toString() ??
                                          '0',
                                      isInline: true,
                                      labelFlex: 5,
                                      padding: const EdgeInsets.only(
                                          bottom: spacer2)),

                                  // TODO: Uncomment if these fields are available

                                  //   LabelValueItem(
                                  //     label: localizations.translate(i18
                                  //         .householdDetails
                                  //         .noOfPregnantWomenCountLabel),
                                  //     value: deliverState
                                  //             .householdMemberWrapper
                                  //             ?.household
                                  //             ?.additionalFields
                                  //             ?.fields
                                  //             .where((h) =>
                                  //                 h.key ==
                                  //                 AdditionalFieldsType
                                  //                     .pregnantWomen
                                  //                     .toValue())
                                  //             .firstOrNull
                                  //             ?.value
                                  //             .toString() ??
                                  //         '0',
                                  //     isInline: true,
                                  //     labelFlex: 5,
                                  //   ),
                                  //   LabelValueItem(
                                  //       label: localizations.translate(i18
                                  //           .householdDetails
                                  //           .noOfChildrenBelow5YearsLabel),
                                  //       value: deliverState
                                  //               .householdMemberWrapper?.members
                                  //               ?.where((m) {
                                  //                 final dobString =
                                  //                     m.dateOfBirth?.trim();

                                  //                 if (dobString != null &&
                                  //                     dobString.isNotEmpty) {
                                  //                   final parsedDate = DateFormat(
                                  //                           'dd/MM/yyyy')
                                  //                       .parseStrict(dobString);
                                  //                   final age = digits
                                  //                           .DigitDateUtils
                                  //                       .calculateAge(parsedDate);
                                  //                   return age.years < 5;
                                  //                 }
                                  //                 return false;
                                  //               })
                                  //               .length
                                  //               .toString() ??
                                  //           '0',
                                  //       isInline: true,
                                  //       labelFlex: 5,
                                  //       padding:
                                  //           const EdgeInsets.only(top: spacer2)),
                                ]),
                          ]),

                      // TODO: Uncomment if household details card is needed and these fields are available

                      // DigitCard(
                      //     margin: const EdgeInsets.all(spacer2),
                      //     children: [
                      //       LabelValueSummary(
                      //           padding: EdgeInsets.zero,
                      //           heading: localizations.translate(
                      //               i18.householdDetails.houseDetailsLabel),
                      //           headingStyle: textTheme.headingL.copyWith(
                      //             color: theme.colorTheme.primary.primary2,
                      //           ),
                      //           withDivider: false,
                      //           items: [
                      //             LabelValueItem(
                      //                 label: localizations.translate(
                      //                     i18.householdDetails.noOfRoomsLabel),
                      //                 value: deliverState
                      //                         .householdMemberWrapper
                      //                         ?.household
                      //                         ?.additionalFields
                      //                         ?.fields
                      //                         .where((h) =>
                      //                             h.key ==
                      //                             AdditionalFieldsType.noOfRooms
                      //                                 .toValue())
                      //                         .firstOrNull
                      //                         ?.value
                      //                         .toString() ??
                      //                     '0',
                      //                 isInline: true,
                      //                 labelFlex: 5,
                      //                 padding: const EdgeInsets.only(
                      //                     bottom: spacer2)),
                      //             LabelValueItem(
                      //                 label: localizations.translate(
                      //                     i18.householdDetails.typeOfStructure),
                      //                 value: (deliverState
                      //                             .householdMemberWrapper
                      //                             ?.household
                      //                             ?.additionalFields
                      //                             ?.fields
                      //                             .where((h) =>
                      //                                 h.key ==
                      //                                 AdditionalFieldsType
                      //                                     .houseStructureTypes
                      //                                     .toValue())
                      //                             .firstOrNull
                      //                             ?.value ??
                      //                         [])
                      //                     .toString()
                      //                     .split('|')
                      //                     .map((item) =>
                      //                         getLocalizedMessage(item))
                      //                     .toList()
                      //                     .join(', '),
                      //                 isInline: true,
                      //                 labelFlex: 5,
                      //                 padding:
                      //                     const EdgeInsets.only(top: spacer2)),
                      // ]),
                      // ]),
                      BlocBuilder<ProductVariantBloc, ProductVariantState>(
                          builder: (context, productState) {
                        final variants = productState.whenOrNull(
                          fetched: (productVariants) {
                            final resourcesDelivered = deliverState
                                .oldTask?.resources
                                ?.map((e) => TaskResourceInfo(
                                    productVariants
                                            .where((p) =>
                                                p.id == e.productVariantId)
                                            .firstOrNull
                                            ?.sku ??
                                        productVariants
                                            .where((p) =>
                                                p.id == e.productVariantId)
                                            .firstOrNull
                                            ?.variation ??
                                        i18.common.coreCommonNA,
                                    e.quantity ?? '0'))
                                .toList();
                            return resourcesDelivered;
                          },
                        );
                        return DigitCard(
                            margin: const EdgeInsets.all(spacer2),
                            children: [
                              LabelValueSummary(
                                  padding: EdgeInsets.zero,
                                  heading: localizations.translate(
                                      '${RegistrationDeliverySingleton().selectedProject?.projectType?.toUpperCase()}_${i18.deliverIntervention.deliveryDetailsLabel}_${deliverState.oldTask?.status}'),
                                  headingStyle: textTheme.headingL.copyWith(
                                    color: theme.colorTheme.primary.primary2,
                                  ),
                                  withDivider: false,
                                  items: [
                                    LabelValueItem(
                                      label: localizations.translate(deliverState
                                                      .oldTask?.status ==
                                                  Status.administeredFailed
                                                      .toValue() ||
                                              deliverState.oldTask?.status ==
                                                  Status.beneficiaryRefused
                                                      .toValue()
                                          ? i18.deliverIntervention
                                              .reasonForRefusalLabel
                                          : '${RegistrationDeliverySingleton().selectedProject?.projectType?.toUpperCase()}_${i18.deliverIntervention.typeOfResourceUsed}'),
                                      value: deliverState.oldTask?.status ==
                                                  Status.administeredFailed
                                                      .toValue() ||
                                              deliverState.oldTask?.status ==
                                                  Status.beneficiaryRefused
                                                      .toValue()
                                          ? getLocalizedMessage(deliverState
                                                  .oldTask
                                                  ?.additionalFields
                                                  ?.fields
                                                  .where(
                                                    (d) =>
                                                        d.key ==
                                                        AdditionalFieldsType
                                                            .reasonOfRefusal
                                                            .toValue(),
                                                  )
                                                  .firstOrNull
                                                  ?.value ??
                                              i18.common.coreCommonNA)
                                          : variants
                                                  ?.map((e) =>
                                                      '${getLocalizedMessage(localizations.translate(getSpaqName(e.productName)))} : ${e.quantityDelivered}')
                                                  .toList()
                                                  .join('\n') ??
                                              localizations.translate(
                                                  i18.common.coreCommonNA),
                                      labelFlex: 5,
                                      padding: EdgeInsets.zero,
                                      maxLines: 4,
                                    ),
                                  ]),
                            ]);
                      }),
                    ],
                  ),
                )
              ]);
        },
      )),
    );
  }
}
