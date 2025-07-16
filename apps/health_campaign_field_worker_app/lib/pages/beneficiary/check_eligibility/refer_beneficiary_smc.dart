import 'package:collection/collection.dart';
import 'package:digit_components/digit_components.dart';
import 'package:digit_components/widgets/atoms/digit_radio_button_list.dart';
import 'package:digit_components/widgets/atoms/digit_toaster.dart';
import 'package:digit_ui_components/enum/app_enums.dart';
import 'package:digit_ui_components/theme/spacers.dart';
import 'package:digit_ui_components/widgets/atoms/digit_button.dart';
import 'package:digit_ui_components/widgets/atoms/pop_up_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:health_campaign_field_worker_app/pages/pages-SMC/beneficiary/custom_facility_selection_smc.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:referral_reconciliation/referral_reconciliation.dart';
import 'package:registration_delivery/models/entities/referral.dart';
import 'package:registration_delivery/models/entities/status.dart';
import 'package:registration_delivery/models/entities/task.dart';
import 'package:registration_delivery/pages/beneficiary/facility_selection.dart';
import 'package:registration_delivery/router/registration_delivery_router.gm.dart';
import 'package:registration_delivery/utils/utils.dart';
import 'package:registration_delivery/widgets/inventory/no_facilities_assigned_dialog.dart';

import '../../../models/entities/additional_fields_type.dart';
import '../../../utils/app_enums.dart';
import '../../../widgets/custom_back_navigation.dart';
import '../../../widgets/localized.dart';
import 'package:registration_delivery/blocs/delivery_intervention/deliver_intervention.dart';
import 'package:registration_delivery/blocs/household_overview/household_overview.dart';
import 'package:registration_delivery/blocs/referral_management/referral_management.dart';
import 'package:registration_delivery/blocs/search_households/search_households.dart';
import 'package:digit_data_model/data_model.dart';
import '../../../router/app_router.dart';
import '../../../utils/environment_config.dart';
import '../../../utils/i18_key_constants.dart' as i18_local;
import 'package:registration_delivery/utils/i18_key_constants.dart' as i18;
import '../../../utils/utils.dart';
import '../../../models/entities/additional_fields_type.dart'
    as additional_fields_local;

@RoutePage()
class CustomReferBeneficiarySMCPage extends LocalizedStatefulWidget {
  final bool isEditing;
  final String projectBeneficiaryClientRefId;
  final IndividualModel individual;
  final bool isReadministrationUnSuccessful;
  final List<String>? referralReasons;
  final String quantityWasted;
  final String? productVariantId;

  const CustomReferBeneficiarySMCPage({
    super.key,
    super.appLocalizations,
    this.isEditing = false,
    required this.projectBeneficiaryClientRefId,
    required this.individual,
    this.isReadministrationUnSuccessful = false,
    this.quantityWasted = "00",
    this.productVariantId,
    this.referralReasons,
  });
  @override
  State<CustomReferBeneficiarySMCPage> createState() =>
      CustomReferBeneficiarySMCPageState();
}

class CustomReferBeneficiarySMCPageState
    extends LocalizedState<CustomReferBeneficiarySMCPage> {
  static const _dateOfReferralKey = 'dateOfReferral';
  static const _administrativeUnitKey = 'administrativeUnit';
  static const _referredByKey = 'referredBy';
  static const _referredToKey = 'referredTo';
  final clickedStatus = ValueNotifier<bool>(false);
  static const referralReasons = "referralReasons";
  static const sideEffectFromCurrentCycle = "DRUG_SE_CC";

  @override
  void dispose() {
    clickedStatus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocConsumer<FacilityBloc, FacilityState>(
      listener: (context, state) {
        state.whenOrNull(
          empty: () => NoFacilitiesAssignedDialog.show(context),
        );
      },
      builder: (ctx, facilityState) {
        List<FacilityModel> facilities = [];
        final healthFacilities = facilityState.whenOrNull(
              fetched: (
                facilities,
                allFacilities,
              ) {
                final projectFacilities = facilities
                    .where((e) => e.usage == Constants.healthFacility)
                    .toList();

                return projectFacilities.isEmpty
                    ? allFacilities
                    : projectFacilities;
              },
            ) ??
            [];
        if (healthFacilities.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        facilities.addAll(healthFacilities);

        final reasons = widget.isReadministrationUnSuccessful
            ? [sideEffectFromCurrentCycle]
            : (widget.referralReasons ?? []);

        return WillPopScope(
          onWillPop: () =>
              _onBackPressed(context, widget.isReadministrationUnSuccessful),
          child: Scaffold(
            body: Scaffold(
              body: ReactiveFormBuilder(
                form: () => buildForm(healthFacilities),
                builder: (context, form, child) => ScrollableContent(
                  enableFixedButton: true,
                  header: Column(children: [
                    widget.isReadministrationUnSuccessful
                        ? const CustomBackNavigationHelpHeaderWidget(
                            showBackNavigation: false,
                            showHelp: false,
                            showcaseButton: null,
                          )
                        : const CustomBackNavigationHelpHeaderWidget(
                            showHelp: false,
                            showcaseButton: null,
                          ),
                  ]),
                  footer: DigitCard(
                    margin: const EdgeInsets.fromLTRB(0, kPadding, 0, 0),
                    padding:
                        const EdgeInsets.fromLTRB(kPadding, 0, kPadding, 0),
                    child: ValueListenableBuilder(
                      valueListenable: clickedStatus,
                      builder: (context, bool isClicked, _) {
                        return DigitElevatedButton(
                          onPressed: isClicked
                              ? null
                              : () async {
                                  form.markAllAsTouched();

                                  if (reasons.isEmpty) {
                                    return;
                                  }

                                  if (!form.valid) {
                                    return;
                                  } else {
                                    final submit = await showDialog(
                                      context: context,
                                      builder: (ctx) => Popup(
                                        title: localizations.translate(
                                          i18.deliverIntervention.dialogTitle,
                                        ),
                                        description: localizations.translate(
                                          i18.deliverIntervention.dialogContent,
                                        ),
                                        actions: [
                                          DigitButton(
                                              label: localizations.translate(
                                                i18.common.coreCommonSubmit,
                                              ),
                                              onPressed: () {
                                                clickedStatus.value = true;
                                                Navigator.of(
                                                  context,
                                                  rootNavigator: true,
                                                ).pop(true);
                                              },
                                              type: DigitButtonType.primary,
                                              size: DigitButtonSize.large),
                                          DigitButton(
                                              label: localizations.translate(
                                                i18.common.coreCommonCancel,
                                              ),
                                              onPressed: () => Navigator.of(
                                                    context,
                                                    rootNavigator: true,
                                                  ).pop(false),
                                              type: DigitButtonType.secondary,
                                              size: DigitButtonSize.large)
                                        ],
                                      ),
                                    );
                                    if (submit == null || !submit) {
                                      return;
                                    }
                                    if (healthFacilities.isEmpty) {
                                      return;
                                    }
                                    clickedStatus.value = true;
                                    final reason = reasons.first;

                                    final event = context.read<ReferralBloc>();
                                    event.add(ReferralSubmitEvent(
                                      ReferralModel(
                                        clientReferenceId: IdGen.i.identifier,
                                        projectId: context.projectId,
                                        projectBeneficiaryClientReferenceId:
                                            widget
                                                .projectBeneficiaryClientRefId,
                                        referrerId: context.loggedInUserUuid,
                                        recipientId: healthFacilities.first.id,
                                        recipientType: "FACILITY",
                                        reasons: [reason],
                                        tenantId: envConfig.variables.tenantId,
                                        rowVersion: 1,
                                        auditDetails: AuditDetails(
                                          createdBy: context.loggedInUserUuid,
                                          createdTime:
                                              context.millisecondsSinceEpoch(),
                                          lastModifiedBy:
                                              context.loggedInUserUuid,
                                          lastModifiedTime:
                                              context.millisecondsSinceEpoch(),
                                        ),
                                        clientAuditDetails: ClientAuditDetails(
                                          createdBy: context.loggedInUserUuid,
                                          createdTime:
                                              context.millisecondsSinceEpoch(),
                                          lastModifiedBy:
                                              context.loggedInUserUuid,
                                          lastModifiedTime:
                                              context.millisecondsSinceEpoch(),
                                        ),
                                        additionalFields:
                                            ReferralAdditionalFields(
                                          version: 1,
                                          fields: [
                                            AdditionalField(
                                              referralReasons,
                                              reasons.join(","),
                                            ),
                                            const AdditionalField(
                                                'referralType', 'smcReferred')
                                          ],
                                        ),
                                      ),
                                      false,
                                    ));

                                    final clientReferenceId =
                                        IdGen.i.identifier;
                                    final task = TaskModel(
                                      projectBeneficiaryClientReferenceId:
                                          widget.projectBeneficiaryClientRefId,
                                      clientReferenceId: clientReferenceId,
                                      tenantId: envConfig.variables.tenantId,
                                      rowVersion: 1,
                                      auditDetails: AuditDetails(
                                        createdBy: context.loggedInUserUuid,
                                        createdTime:
                                            context.millisecondsSinceEpoch(),
                                      ),
                                      projectId: context.projectId,
                                      status:
                                          Status.beneficiaryReferred.toValue(),
                                      clientAuditDetails: ClientAuditDetails(
                                        createdBy: context.loggedInUserUuid,
                                        createdTime:
                                            context.millisecondsSinceEpoch(),
                                        lastModifiedBy:
                                            context.loggedInUserUuid,
                                        lastModifiedTime:
                                            context.millisecondsSinceEpoch(),
                                      ),
                                      additionalFields: TaskAdditionalFields(
                                        version: 1,
                                        fields: [
                                          AdditionalField(
                                            AdditionalFieldsType.cycleIndex
                                                .toValue(),
                                            "0${context.selectedCycle?.id}",
                                          ),
                                          AdditionalField(
                                            'taskStatus',
                                            Status.beneficiaryReferred
                                                .toValue(),
                                          ),
                                          if (widget
                                              .isReadministrationUnSuccessful)
                                            AdditionalField(
                                              'quantityWasted',
                                              widget.quantityWasted
                                                          .toString()
                                                          .length ==
                                                      1
                                                  ? "0${widget.quantityWasted}"
                                                  : widget.quantityWasted
                                                      .toString(),
                                            ),
                                          if (widget
                                              .isReadministrationUnSuccessful)
                                            const AdditionalField(
                                              'unsuccessfullDelivery',
                                              'true',
                                            ),
                                          if (widget.productVariantId != null)
                                            AdditionalField(
                                              'productVariantId',
                                              widget.productVariantId,
                                            ),
                                          AdditionalField(
                                            additional_fields_local
                                                .AdditionalFieldsType
                                                .deliveryType
                                                .toValue(),
                                            EligibilityAssessmentStatus
                                                .smcDone.name,
                                          ),
                                          ...getIndividualAdditionalFields(
                                              widget.individual)
                                        ],
                                      ),
                                      address: widget.individual.address?.first
                                          .copyWith(
                                        relatedClientReferenceId:
                                            clientReferenceId,
                                        id: null,
                                      ),
                                    );
                                    // TODO: Currently, it's been shifted to the zero dose flow

                                    // context.read<DeliverInterventionBloc>().add(
                                    //       DeliverInterventionSubmitEvent(
                                    //         task: task,
                                    //         isEditing: false,
                                    //         boundaryModel: context.boundary,
                                    //       ),
                                    //     );
                                    // final searchBloc =
                                    //     context.read<SearchHouseholdsBloc>();
                                    // searchBloc.add(
                                    //   const SearchHouseholdsClearEvent(),
                                    // );

                                    final reloadState =
                                        context.read<HouseholdOverviewBloc>();
                                    Future.delayed(
                                      const Duration(milliseconds: 500),
                                      () {
                                        reloadState
                                            .add(HouseholdOverviewReloadEvent(
                                          projectId: context.projectId,
                                          projectBeneficiaryType:
                                              context.beneficiaryType,
                                        ));
                                      },
                                    ).then(
                                      (value) => context.router.popAndPush(
                                        ZeroDoseCheckRoute(
                                          eligibilityAssessmentType:
                                              EligibilityAssessmentType.smc,
                                          isAdministration: false,
                                          task: task,
                                        ),
                                        // CustomHouseholdAcknowledgementRoute(
                                        //   enableViewHousehold: true,
                                        //   eligibilityAssessmentType:
                                        //       EligibilityAssessmentType.vas,
                                        // ),
                                      ),
                                    );
                                  }
                                },
                          child: Center(
                            child: Text(
                              localizations
                                  .translate(i18_local.common.coreCommonSubmit),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  children: [
                    DigitCard(
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  localizations.translate(
                                    i18_local.referBeneficiary.referralDetails,
                                  ),
                                  style: theme.textTheme.displayMedium,
                                ),
                              ),
                            ],
                          ),
                          Column(children: [
                            DigitDateFormPicker(
                              margin:
                                  const EdgeInsets.symmetric(vertical: spacer2),
                              isEnabled: false,
                              formControlName: _dateOfReferralKey,
                              label: localizations.translate(
                                i18_local.referBeneficiary.dateOfReferralLabel,
                              ),
                              isRequired: false,
                              initialDate: DateTime.now(),
                              cancelText: localizations
                                  .translate(i18_local.common.coreCommonCancel),
                              confirmText: localizations
                                  .translate(i18_local.common.coreCommonOk),
                            ),
                            DigitTextFormField(
                              formControlName: _administrativeUnitKey,
                              label: localizations.translate(
                                i18_local
                                    .referBeneficiary.organizationUnitFormLabel,
                              ),
                              isRequired: true,
                              readOnly: true,
                            ),
                            DigitTextFormField(
                              formControlName: _referredByKey,
                              readOnly: true,
                              label: localizations.translate(
                                i18_local.referBeneficiary.referredToLabel,
                              ),
                              validationMessages: {
                                'required': (_) => localizations.translate(
                                      i18_local.common.corecommonRequired,
                                    ),
                              },
                              isRequired: true,
                            ),
                            DigitTextFormField(
                              formControlName: _referredToKey,
                              readOnly: true,
                              label: localizations.translate(
                                i18_local.referBeneficiary.referredByLabel,
                              ),
                              validationMessages: {
                                'required': (_) => localizations.translate(
                                      i18_local.common.corecommonRequired,
                                    ),
                              },
                              isRequired: true,
                            ),
                          ]),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  FormGroup buildForm(List<FacilityModel> healthFacilities) {
    return fb.group(<String, Object>{
      _dateOfReferralKey: FormControl<DateTime>(value: DateTime.now()),
      _administrativeUnitKey: FormControl<String>(
          value: localizations.translate(context.boundary.code!)),
      _referredByKey: FormControl<String>(
        value: context.loggedInUser.userName,
        validators: [Validators.required],
      ),
      _referredToKey: FormControl<String>(
        value: healthFacilities.isNotEmpty
            ? localizations.translate('FAC_${healthFacilities.first.id}')
            : null,
        // value: healthFacilities
        //     .where((e) =>
        //         e.boundaryCode == context.loggedInUserModel?.boundaryCode)
        //     .first
        //     .id
        //     .toString(),
        validators: [
          Validators.required,
        ],
      ),
    });
  }

  Future<bool> _onBackPressed(
    BuildContext context,
    bool isReadministrationUnSuccessful,
  ) async {
    if (!isReadministrationUnSuccessful) {
      return true;
    }
    if (clickedStatus.value) {
      return false;
    }
    bool? shouldNavigateBack = await showDialog<bool>(
      context: context,
      builder: (context) => DigitDialog(
        options: DigitDialogOptions(
          titleText: localizations.translate(
            i18_local.referBeneficiary.referAlertDialogTitle,
          ),
          content: Text(localizations.translate(
            i18_local.referBeneficiary.referAlertDialogContent,
          )),
          primaryAction: DigitDialogActions(
            label: localizations.translate(i18_local.common.coreCommonOk),
            action: (ctx) {
              Navigator.of(
                context,
                rootNavigator: false,
              ).pop(false);
            },
          ),
        ),
      ),
    );

    return shouldNavigateBack ?? false;
  }
}


// class CustomFacilityValueAccessor extends ControlValueAccessor<FacilityModel, String> {
//   final FacilityModel facility;

//   CustomFacilityValueAccessor(this.facility);

//   @override
//   String? modelToViewValue(FacilityModel? modelValue) {
//     return modelValue?.id;
//   }

//   @override
//   FacilityModel? viewToModelValue(String? viewValue) {
//     return facility((f) => f.id == viewValue);
//   }
// }