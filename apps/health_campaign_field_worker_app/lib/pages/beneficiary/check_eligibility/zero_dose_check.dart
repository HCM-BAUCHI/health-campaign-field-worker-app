import 'dart:math';

import 'package:collection/collection.dart';
import 'package:digit_components/digit_components.dart';
import 'package:digit_components/utils/date_utils.dart';
// import 'package:digit_components/digit_components.dart';
import 'package:digit_data_model/data_model.dart';
import 'package:digit_ui_components/enum/app_enums.dart';
import 'package:digit_ui_components/services/location_bloc.dart' as location;
import 'package:digit_ui_components/theme/digit_extended_theme.dart';
import 'package:digit_ui_components/theme/spacers.dart';
// import 'package:digit_ui_components/theme/digit_extended_theme.dart';
import 'package:digit_ui_components/widgets/atoms/digit_button.dart';
import 'package:digit_ui_components/widgets/atoms/digit_date_form_input.dart';
import 'package:digit_ui_components/widgets/atoms/digit_text_form_input.dart';
import 'package:digit_ui_components/widgets/atoms/pop_up_card.dart';
import 'package:digit_ui_components/widgets/atoms/reactive_fields.dart';
import 'package:digit_ui_components/widgets/molecules/show_pop_up.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:group_radio_button/group_radio_button.dart';
// import 'package:registration_delivery/models/entities/status.dart';
import 'package:registration_delivery/registration_delivery.dart';
import 'package:registration_delivery/router/registration_delivery_router.gm.dart';
import 'package:registration_delivery/utils/i18_key_constants.dart' as i18;
import 'package:registration_delivery/utils/utils.dart';
import 'package:registration_delivery/widgets/localized.dart';
import 'package:survey_form/survey_form.dart';

import '../../../models/entities/additional_fields_type.dart'
    as additional_fields_local;
import '../../../models/entities/additional_fields_type.dart';
import '../../../models/entities/assessment_checklist/status.dart'
    as status_local;
// import '../../../blocs/service/service.dart' as service;
import '../../../models/entities/roles_type.dart';
import '../../../models/entities/status.dart';
import '../../../router/app_router.dart';
import '../../../utils/app_enums.dart';
import '../../../utils/environment_config.dart';
import '../../../utils/i18_key_constants.dart' as i18_local;
import '../../../utils/upper_case.dart';
import '../../../utils/utils.dart';
import '../../../widgets/custom_back_navigation.dart';
// import '../../../widgets/showcase/showcase_wrappers.dart';

@RoutePage()
class ZeroDoseCheckPage extends LocalizedStatefulWidget {
  final EligibilityAssessmentType eligibilityAssessmentType;
  final bool isEditing;
  final bool isAdministration;
  final bool isChecklistAssessmentDone;
  final String? projectBeneficiaryClientReferenceId;
  final IndividualModel? individual;
  final TaskModel task;
  final bool? hasSideEffects;
  final SideEffectModel sideEffect;

  ZeroDoseCheckPage({
    super.key,
    super.appLocalizations,
    required this.eligibilityAssessmentType,
    required this.isAdministration,
    this.isEditing = false,
    this.isChecklistAssessmentDone = true,
    this.projectBeneficiaryClientReferenceId,
    this.individual,
    this.hasSideEffects = false,
    SideEffectModel? sideEffect,
    TaskModel? task,
  })  : task = task ?? TaskModel(clientReferenceId: ''),
        sideEffect = sideEffect ?? SideEffectModel(clientReferenceId: '');

  @override
  State<ZeroDoseCheckPage> createState() => ZeroDoseCheckPageState();
}

class ZeroDoseCheckPageState extends LocalizedState<ZeroDoseCheckPage> {
  // Constants for form control keys
  static const _doseAdministrationKey = 'doseAdministered';
  static const _dateOfAdministrationKey = 'dateOfAdministration';
  final clickedStatus = ValueNotifier<bool>(false);
  bool? shouldSubmit = false;

  var submitTriggered = false;
  List<TextEditingController> controller = [];
  List<AttributesModel>? initialAttributes;
  ServiceDefinitionModel? selectedServiceDefinition;
  bool isControllersInitialized = false;
  List<int> visibleChecklistIndexes = [];
  GlobalKey<FormState> checklistFormKey = GlobalKey<FormState>();
  Map<String?, String> responses = {};
  final String yes = "YES";
  final String no = "NO";

  // List of controllers for form elements
  final List _controllers = [];

  @override
  void initState() {
    context
        .read<location.LocationBloc>()
        .add(const location.LocationEvent.load());
    context.read<ServiceBloc>().add(ServiceSurveyFormEvent(
          value: Random().nextInt(100).toString(),
          submitTriggered: true,
        ));
    super.initState();
    // context.read<LocationBloc>().add(const LoadLocationEvent());
    // super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final deliveryInterventionState =
        context.read<DeliverInterventionBloc>().state;
    final relatedClientRefId = context
        .read<HouseholdOverviewBloc>()
        .state
        .selectedIndividual
        ?.clientReferenceId;

    final householdMemberWrapper =
        context.read<HouseholdOverviewBloc>().state.householdMemberWrapper;

    final projectBeneficiary =
        RegistrationDeliverySingleton().beneficiaryType !=
                BeneficiaryType.individual
            ? [householdMemberWrapper.projectBeneficiaries!.first]
            : householdMemberWrapper.projectBeneficiaries
                ?.where((element) =>
                    element.beneficiaryClientReferenceId ==
                    context
                        .read<HouseholdOverviewBloc>()
                        .state
                        .selectedIndividual
                        ?.clientReferenceId)
                .toList();

    final projectTypeModel =
        widget.eligibilityAssessmentType == EligibilityAssessmentType.smc
            ? RegistrationDeliverySingleton()
                .selectedProject
                ?.additionalDetails
                ?.projectType
            : RegistrationDeliverySingleton()
                .selectedProject
                ?.additionalDetails
                ?.additionalProjectType;

    final productVariants = !widget.isChecklistAssessmentDone
        ? projectTypeModel?.resources
            ?.map((r) =>
                DeliveryProductVariant(productVariantId: r.productVariantId))
            .toList()
        : projectTypeModel?.cycles?.isNotEmpty == true
            ? (fetchProductVariant(
                    projectTypeModel
                        ?.cycles?[deliveryInterventionState.cycle - 1]
                        .deliveries?[deliveryInterventionState.dose - 1],
                    context
                        .read<HouseholdOverviewBloc>()
                        .state
                        .selectedIndividual,
                    householdMemberWrapper.household)
                ?.productVariants)
            : projectTypeModel?.resources
                ?.map((r) => DeliveryProductVariant(
                    productVariantId: r.productVariantId))
                .toList();

    if ((productVariants ?? []).isEmpty && context.mounted) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        showCustomPopup(
          context: context,
          builder: (popUpContext) => Popup(
            title: localizations.translate(i18.common.noResultsFound),
            description: localizations.translate(
              i18.deliverIntervention.checkForProductVariantsConfig,
            ),
            type: PopUpType.alert,
            actions: [
              DigitButton(
                label: localizations.translate(i18.common.coreCommonOk),
                onPressed: () {
                  context.router.maybePop();
                  Navigator.of(popUpContext).pop();
                },
                type: DigitButtonType.primary,
                size: DigitButtonSize.large,
              ),
            ],
          ),
        );
      });
    }

    final productVariantState = context.read<ProductVariantBloc>().state;
    final variant = productVariantState.whenOrNull(
      fetched: (fetchedVariants) => fetchedVariants,
    );

    return WillPopScope(
      onWillPop: () async => _onBackPressed(context),
      child: Scaffold(
        body: BlocBuilder<location.LocationBloc, location.LocationState>(
          builder: (context, locationState) {
            return BlocBuilder<HouseholdOverviewBloc, HouseholdOverviewState>(
              builder: (context, householdOverviewState) {
                double? latitude = locationState.latitude;
                double? longitude = locationState.longitude;
                String zeroDoseAssessment = "ZERODOSE_ASSESSMENT";
                return BlocBuilder<ServiceDefinitionBloc,
                    ServiceDefinitionState>(
                  builder: (context, state) {
                    state.mapOrNull(
                      serviceDefinitionFetch: (value) {
                        selectedServiceDefinition = value.serviceDefinitionList
                            .where(
                                (element) => element.code.toString().contains(
                                      '${context.selectedProject.name}.$zeroDoseAssessment.${context.isCommunityDistributor ? RolesType.communityDistributor.toValue() : ''}',
                                    ))
                            .toList()
                            .firstOrNull;
                        initialAttributes =
                            selectedServiceDefinition?.attributes;
                        if (!isControllersInitialized) {
                          initialAttributes?.forEach((e) {
                            controller.add(TextEditingController());
                          });

                          isControllersInitialized = true;
                        }
                      },
                    );

                    return state.maybeMap(
                      orElse: () => Text(state.runtimeType.toString()),
                      serviceDefinitionFetch: (value) {
                        return ScrollableContent(
                          header: Column(
                            children: [
                              if (!(context.isHealthFacilitySupervisor))
                                const CustomBackNavigationHelpHeaderWidget(
                                  showHelp: false,
                                ),
                            ],
                          ),
                          enableFixedButton: true,
                          footer: DigitCard(
                            margin:
                                const EdgeInsets.fromLTRB(0, kPadding, 0, 0),
                            padding: const EdgeInsets.fromLTRB(
                                kPadding, 0, kPadding, 0),
                            child: DigitElevatedButton(
                              onPressed: () async {
                                submitTriggered = true;
                                final isValid =
                                    checklistFormKey.currentState?.validate();
                                if (!isValid!) {
                                  return;
                                }
                                final itemsAttributes = initialAttributes;

                                for (int i = 0; i < controller.length; i++) {
                                  if (i == 0 && controller[i].text == 'YES') {
                                    break;
                                  }
                                  if (itemsAttributes?[i].required == true &&
                                      itemsAttributes?[i].dataType ==
                                          'SingleValueList' &&
                                      visibleChecklistIndexes.contains(i) &&
                                      controller[i].text.isEmpty) {
                                    return;
                                  }
                                }
                                for (int i = 0; i < controller.length; i++) {
                                  var attributeCode =
                                      '${initialAttributes?[i].code}';
                                  var value = initialAttributes?[i].dataType !=
                                          'SingleValueList'
                                      ? controller[i]
                                              .text
                                              .toString()
                                              .trim()
                                              .isNotEmpty
                                          ? controller[i].text.toString()
                                          : (initialAttributes?[i].dataType !=
                                                  'Number'
                                              ? ''
                                              : '0')
                                      : visibleChecklistIndexes.contains(i)
                                          ? controller[i].text.toString()
                                          : i18_local.checklist.notSelectedKey;
                                  responses[attributeCode] = value;
                                }

                                bool showVaccineSelectionPage =
                                    shouldShowVaccinePage(responses);
                                bool zeroDose = isZeroDose(responses);
                                bool incompletementVaccine =
                                    isIncompletementVaccine(
                                  responses,
                                );

                                // TODO: Uncomment this block when the vaccine selection page is complete

                                if (showVaccineSelectionPage ||
                                    (!zeroDose && !incompletementVaccine)) {
                                  final referenceId = IdGen.i.identifier;
                                  List<ServiceAttributesModel> attributes = [];
                                  for (int i = 0; i < controller.length; i++) {
                                    final attribute = initialAttributes;

                                    attributes.add(ServiceAttributesModel(
                                      auditDetails: AuditDetails(
                                        createdBy: context.loggedInUserUuid,
                                        createdTime:
                                            context.millisecondsSinceEpoch(),
                                      ),
                                      attributeCode: '${attribute?[i].code}',
                                      dataType: attribute?[i].dataType,
                                      clientReferenceId: IdGen.i.identifier,
                                      referenceId: referenceId,
                                      value: attribute?[i].dataType !=
                                              'SingleValueList'
                                          ? controller[i]
                                                  .text
                                                  .toString()
                                                  .trim()
                                                  .isNotEmpty
                                              ? controller[i].text.toString()
                                              : ''
                                          : visibleChecklistIndexes.contains(i)
                                              ? controller[i].text.toString()
                                              : i18_local
                                                  .checklist.notSelectedKey,
                                      rowVersion: 1,
                                      tenantId: attribute?[i].tenantId,
                                      additionalFields:
                                          ServiceAttributesAdditionalFields(
                                        version: 1,
                                        // TODO: This needs to be done after adding locationbloc
                                        fields: [
                                          AdditionalField(
                                            'latitude',
                                            latitude,
                                          ),
                                          AdditionalField(
                                            'longitude',
                                            longitude,
                                          ),
                                        ],
                                      ),
                                    ));
                                  }

                                  context.read<ServiceBloc>().add(
                                        ServiceCreateEvent(
                                          serviceModel: ServiceModel(
                                              createdAt: DigitDateUtils
                                                  .getDateFromTimestamp(
                                                DateTime.now()
                                                    .toLocal()
                                                    .millisecondsSinceEpoch,
                                                dateFormat: Constants
                                                    .checklistViewDateFormat,
                                              ),
                                              tenantId:
                                                  selectedServiceDefinition!
                                                      .tenantId,
                                              clientId: referenceId,
                                              serviceDefId:
                                                  selectedServiceDefinition?.id,
                                              attributes: attributes,
                                              rowVersion: 1,
                                              accountId: context.projectId,
                                              auditDetails: AuditDetails(
                                                createdBy:
                                                    context.loggedInUserUuid,
                                                createdTime: DateTime.now()
                                                    .millisecondsSinceEpoch,
                                              ),
                                              clientAuditDetails:
                                                  ClientAuditDetails(
                                                createdBy:
                                                    context.loggedInUserUuid,
                                                createdTime: context
                                                    .millisecondsSinceEpoch(),
                                                lastModifiedBy:
                                                    context.loggedInUserUuid,
                                                lastModifiedTime: context
                                                    .millisecondsSinceEpoch(),
                                              ),
                                              additionalFields:
                                                  ServiceAdditionalFields(
                                                version: 1,
                                                fields: [
                                                  AdditionalField(
                                                      'boundaryCode',
                                                      context.boundary.code),
                                                ],
                                              )),
                                        ),
                                      );
                                  final projectBeneficiaryClientReferenceId =
                                      widget.projectBeneficiaryClientReferenceId ??
                                          relatedClientRefId;
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
                                  final isZeroDoseAlreadyDone =
                                      currentCycle!.id > 1;
                                  context.router.push(VaccineSelectionRoute(
                                      isAdministration: widget.isAdministration,
                                      eligibilityAssessmentType:
                                          widget.eligibilityAssessmentType,
                                      isChecklistAssessmentDone:
                                          widget.isChecklistAssessmentDone,
                                      projectBeneficiaryClientReferenceId:
                                          projectBeneficiaryClientReferenceId,
                                      individual: widget.individual,
                                      task: widget.task,
                                      hasSideEffects: widget.hasSideEffects!,
                                      sideEffect: widget.sideEffect!,
                                      isZeroDoseAlreadyDone:
                                          isZeroDoseAlreadyDone));
                                } else {
                                  final shouldSubmit = await DigitDialog.show(
                                    context,
                                    options: DigitDialogOptions(
                                      titleText: localizations.translate(
                                        i18.deliverIntervention.dialogTitle,
                                      ),
                                      content: Text(localizations
                                          .translate(
                                            i18.deliverIntervention
                                                .dialogContent,
                                          )
                                          .replaceFirst('{}', '')),
                                      primaryAction: DigitDialogActions(
                                        label: localizations.translate(
                                          i18_local.checklist
                                              .checklistDialogPrimaryAction,
                                        ),
                                        action: (ctx) {
                                          final referenceId =
                                              IdGen.i.identifier;
                                          List<ServiceAttributesModel>
                                              attributes = [];
                                          for (int i = 0;
                                              i < controller.length;
                                              i++) {
                                            final attribute = initialAttributes;

                                            attributes
                                                .add(ServiceAttributesModel(
                                              auditDetails: AuditDetails(
                                                createdBy:
                                                    context.loggedInUserUuid,
                                                createdTime: context
                                                    .millisecondsSinceEpoch(),
                                              ),
                                              attributeCode:
                                                  '${attribute?[i].code}',
                                              dataType: attribute?[i].dataType,
                                              clientReferenceId:
                                                  IdGen.i.identifier,
                                              referenceId: referenceId,
                                              value: attribute?[i].dataType !=
                                                      'SingleValueList'
                                                  ? controller[i]
                                                          .text
                                                          .toString()
                                                          .trim()
                                                          .isNotEmpty
                                                      ? controller[i]
                                                          .text
                                                          .toString()
                                                      : ''
                                                  : visibleChecklistIndexes
                                                          .contains(i)
                                                      ? controller[i]
                                                          .text
                                                          .toString()
                                                      : i18_local.checklist
                                                          .notSelectedKey,
                                              rowVersion: 1,
                                              tenantId: attribute?[i].tenantId,
                                              additionalFields:
                                                  ServiceAttributesAdditionalFields(
                                                version: 1,
                                                // TODO: This needs to be done after adding locationbloc
                                                fields: [
                                                  AdditionalField(
                                                    'latitude',
                                                    latitude,
                                                  ),
                                                  AdditionalField(
                                                    'longitude',
                                                    longitude,
                                                  ),
                                                ],
                                              ),
                                            ));
                                          }

                                          context.read<ServiceBloc>().add(
                                                ServiceCreateEvent(
                                                  serviceModel: ServiceModel(
                                                      createdAt: DigitDateUtils
                                                          .getDateFromTimestamp(
                                                        DateTime.now()
                                                            .toLocal()
                                                            .millisecondsSinceEpoch,
                                                        dateFormat: Constants
                                                            .checklistViewDateFormat,
                                                      ),
                                                      tenantId:
                                                          selectedServiceDefinition!
                                                              .tenantId,
                                                      clientId: referenceId,
                                                      serviceDefId:
                                                          selectedServiceDefinition
                                                              ?.id,
                                                      attributes: attributes,
                                                      rowVersion: 1,
                                                      accountId:
                                                          context.projectId,
                                                      auditDetails:
                                                          AuditDetails(
                                                        createdBy: context
                                                            .loggedInUserUuid,
                                                        createdTime: DateTime
                                                                .now()
                                                            .millisecondsSinceEpoch,
                                                      ),
                                                      clientAuditDetails:
                                                          ClientAuditDetails(
                                                        createdBy: context
                                                            .loggedInUserUuid,
                                                        createdTime: context
                                                            .millisecondsSinceEpoch(),
                                                        lastModifiedBy: context
                                                            .loggedInUserUuid,
                                                        lastModifiedTime: context
                                                            .millisecondsSinceEpoch(),
                                                      ),
                                                      additionalFields:
                                                          ServiceAdditionalFields(
                                                        version: 1,
                                                        fields: [
                                                          AdditionalField(
                                                              'boundaryCode',
                                                              context.boundary
                                                                  .code),
                                                        ],
                                                      )),
                                                ),
                                              );
                                          Navigator.of(
                                            context,
                                            rootNavigator: true,
                                          ).pop(true);
                                        },
                                      ),
                                      secondaryAction: DigitDialogActions(
                                        label: localizations.translate(
                                          i18_local.checklist
                                              .checklistDialogSecondaryAction,
                                        ),
                                        action: (context) {
                                          Navigator.of(
                                            context,
                                            rootNavigator: true,
                                          ).pop(false);
                                        },
                                      ),
                                    ),
                                  );
                                  if (shouldSubmit ?? false) {
                                    if (context.mounted) {
                                      if (widget.isChecklistAssessmentDone ==
                                          true) {
                                        final householdMember = context
                                            .read<HouseholdOverviewBloc>()
                                            .state
                                            .householdMemberWrapper;
                                        final deliverState = context
                                            .read<DeliverInterventionBloc>()
                                            .state;

                                        final oldTask =
                                            deliverState.oldTask ?? widget.task;
                                        final oldFields =
                                            oldTask.additionalFields?.fields ??
                                                [];

                                        final updatedFields = [
                                          ...oldFields,
                                          AdditionalField(
                                            additional_fields_local
                                                .AdditionalFieldsType
                                                .zeroDoseStatus
                                                .toValue(),
                                            zeroDose
                                                ? ZeroDoseStatus.zeroDose.name
                                                : incompletementVaccine
                                                    ? ZeroDoseStatus
                                                        .incompletementVaccine
                                                        .name
                                                    : ZeroDoseStatus.done.name,
                                          ),
                                        ];

                                        final updatedTask = oldTask.copyWith(
                                          additionalFields:
                                              TaskAdditionalFields(
                                            version: 1,
                                            fields: updatedFields,
                                          ),
                                        );

                                        context
                                            .read<DeliverInterventionBloc>()
                                            .add(
                                              DeliverInterventionSubmitEvent(
                                                task: updatedTask,
                                                isEditing: (deliverState
                                                                .tasks ??
                                                            [])
                                                        .isNotEmpty &&
                                                    RegistrationDeliverySingleton()
                                                            .beneficiaryType ==
                                                        BeneficiaryType
                                                            .household,
                                                boundaryModel:
                                                    RegistrationDeliverySingleton()
                                                        .boundary!,
                                              ),
                                            );

                                        ProjectTypeModel? projectTypeModel =
                                            widget.eligibilityAssessmentType ==
                                                    EligibilityAssessmentType
                                                        .smc
                                                ? RegistrationDeliverySingleton()
                                                    .selectedProject
                                                    ?.additionalDetails
                                                    ?.projectType
                                                : RegistrationDeliverySingleton()
                                                    .selectedProject
                                                    ?.additionalDetails
                                                    ?.additionalProjectType;

                                        if (widget.isAdministration == true) {
                                          final router = context.router;
                                          router.popUntilRouteWithName(
                                              BeneficiaryWrapperRoute.name);
                                          if (deliverState.futureDeliveries !=
                                                  null &&
                                              deliverState.futureDeliveries!
                                                  .isNotEmpty &&
                                              projectTypeModel
                                                      ?.cycles?.isNotEmpty ==
                                                  true) {
                                            router.push(
                                              CustomSplashAcknowledgementRoute(
                                                  enableBackToSearch: false,
                                                  eligibilityAssessmentType: widget
                                                      .eligibilityAssessmentType),
                                            );
                                          } else {
                                            final reloadState = context
                                                .read<HouseholdOverviewBloc>();

                                            reloadState.add(
                                              HouseholdOverviewReloadEvent(
                                                projectId:
                                                    RegistrationDeliverySingleton()
                                                        .projectId!,
                                                projectBeneficiaryType:
                                                    RegistrationDeliverySingleton()
                                                        .beneficiaryType!,
                                              ),
                                            );
                                            context.router.popAndPush(
                                              CustomHouseholdAcknowledgementRoute(
                                                enableViewHousehold: true,
                                                eligibilityAssessmentType: widget
                                                    .eligibilityAssessmentType,
                                              ),
                                            );
                                          }
                                        } else {
                                          final router = context.router;
                                          final searchBloc = context
                                              .read<SearchHouseholdsBloc>();
                                          searchBloc.add(
                                            const SearchHouseholdsClearEvent(),
                                          );
                                          router.popUntilRouteWithName(
                                              BeneficiaryWrapperRoute.name);
                                          router.push(
                                            CustomHouseholdAcknowledgementRoute(
                                                enableViewHousehold: true,
                                                eligibilityAssessmentType: widget
                                                    .eligibilityAssessmentType),
                                          );
                                        }
                                      } else {
                                        if (widget.hasSideEffects == true) {
                                          context.read<SideEffectsBloc>().add(
                                                SideEffectsSubmitEvent(
                                                  widget.sideEffect!,
                                                  false,
                                                ),
                                              );
                                        }
                                        final clientReferenceId =
                                            IdGen.i.identifier;
                                        List<String?> ineligibilityReasons = [];
                                        ineligibilityReasons.add(
                                            "CHILD_AGE_LESS_THAN_3_MONTHS");
                                        context
                                            .read<DeliverInterventionBloc>()
                                            .add(
                                              DeliverInterventionSubmitEvent(
                                                task: TaskModel(
                                                  projectBeneficiaryClientReferenceId:
                                                      widget
                                                          .projectBeneficiaryClientReferenceId,
                                                  clientReferenceId:
                                                      clientReferenceId,
                                                  tenantId: envConfig
                                                      .variables.tenantId,
                                                  rowVersion: 1,
                                                  auditDetails: AuditDetails(
                                                    createdBy: context
                                                        .loggedInUserUuid,
                                                    createdTime: context
                                                        .millisecondsSinceEpoch(),
                                                  ),
                                                  projectId: context.projectId,
                                                  status:
                                                      // (widget.hasSideEffects ??
                                                      //         false)
                                                      //     ? Status.inComplete
                                                      //         .toValue()
                                                      //     :
                                                      status_local.Status
                                                          .beneficiaryInEligible
                                                          .toValue(),
                                                  clientAuditDetails:
                                                      ClientAuditDetails(
                                                    createdBy: context
                                                        .loggedInUserUuid,
                                                    createdTime: context
                                                        .millisecondsSinceEpoch(),
                                                    lastModifiedBy: context
                                                        .loggedInUserUuid,
                                                    lastModifiedTime: context
                                                        .millisecondsSinceEpoch(),
                                                  ),
                                                  additionalFields:
                                                      TaskAdditionalFields(
                                                    version: 1,
                                                    fields: [
                                                      AdditionalField(
                                                        AdditionalFieldsType
                                                            .cycleIndex
                                                            .toValue(),
                                                        "0${context.selectedCycle?.id}",
                                                      ),
                                                      // AdditionalField(
                                                      //   'taskStatus',
                                                      //   status_local.Status
                                                      //       .beneficiaryInEligible
                                                      //       .toValue(),
                                                      // ),
                                                      if (widget
                                                              .hasSideEffects ??
                                                          false == false) ...[
                                                        AdditionalField(
                                                          'ineligibleReasons',
                                                          ineligibilityReasons
                                                              .join(","),
                                                        ),
                                                        AdditionalField(
                                                            'ageBelow3Months',
                                                            true.toString()),
                                                      ] else ...[
                                                        AdditionalField(
                                                            'ineligibleReasons',
                                                            ["SIDE_EFFECTS"]
                                                                .join(",")),
                                                        AdditionalField(
                                                            additional_fields_local
                                                                .AdditionalFieldsType
                                                                .hasSideEffects
                                                                .toValue(),
                                                            true.toString()),
                                                      ],
                                                      AdditionalField(
                                                        additional_fields_local
                                                            .AdditionalFieldsType
                                                            .deliveryType
                                                            .toValue(),
                                                        EligibilityAssessmentStatus
                                                            .smcDone.name,
                                                      ),
                                                      AdditionalField(
                                                        additional_fields_local
                                                            .AdditionalFieldsType
                                                            .zeroDoseStatus
                                                            .toValue(),
                                                        zeroDose
                                                            ? ZeroDoseStatus
                                                                .zeroDose.name
                                                            : incompletementVaccine
                                                                ? ZeroDoseStatus
                                                                    .incompletementVaccine
                                                                    .name
                                                                : ZeroDoseStatus
                                                                    .done.name,
                                                      ),
                                                      ...getIndividualAdditionalFields(
                                                          widget.individual)
                                                    ],
                                                  ),
                                                  address: widget.individual
                                                      ?.address?.first
                                                      .copyWith(
                                                    relatedClientReferenceId:
                                                        clientReferenceId,
                                                    id: null,
                                                  ),
                                                ),
                                                isEditing: false,
                                                boundaryModel: context.boundary,
                                                navigateToSummary: false,
                                                householdMemberWrapper: context
                                                    .read<
                                                        HouseholdOverviewBloc>()
                                                    .state
                                                    .householdMemberWrapper,
                                              ),
                                            );
                                        final searchBloc = context
                                            .read<SearchHouseholdsBloc>();
                                        searchBloc.add(
                                          const SearchHouseholdsClearEvent(),
                                        );
                                        final router = context.router;
                                        router.popUntilRouteWithName(
                                            BeneficiaryWrapperRoute.name);
                                        if (widget.isAdministration == true) {
                                          router.push(
                                            CustomSplashAcknowledgementRoute(
                                                enableBackToSearch: false,
                                                eligibilityAssessmentType: widget
                                                    .eligibilityAssessmentType),
                                          );
                                        } else {
                                          router.push(
                                            CustomHouseholdAcknowledgementRoute(
                                                enableViewHousehold: true,
                                                eligibilityAssessmentType: widget
                                                    .eligibilityAssessmentType),
                                          );
                                        }
                                      }
                                    }

                                    submitTriggered = true;
                                    context.read<ServiceBloc>().add(
                                          const ServiceSurveyFormEvent(
                                            value: '',
                                            submitTriggered: true,
                                          ),
                                        );
                                  }
                                }
                              },
                              child: Text(
                                localizations.translate(
                                    i18_local.common.coreCommonSubmit),
                              ),
                            ),
                          ),
                          children: [
                            DigitCard(
                              margin: const EdgeInsets.all(spacer2),
                              child: Column(
                                children: [
                                  ReactiveFormBuilder(
                                    form: () => buildForm(
                                        context, productVariants, variant),
                                    builder: (context, form, child) {
                                      return Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(left: 8),
                                            child: Text(
                                              localizations.translate(
                                                i18_local.deliverIntervention
                                                    .zeroDoseCheckLabel,
                                              ),
                                              style: theme
                                                  .textTheme.displayMedium
                                                  ?.copyWith(
                                                      fontWeight:
                                                          FontWeight.bold),
                                              textAlign: TextAlign.left,
                                            ),
                                          ),
                                          const SizedBox(
                                            height: 8,
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(8),
                                            child: Column(
                                              children: [
                                                if (RegistrationDeliverySingleton()
                                                        .beneficiaryType ==
                                                    BeneficiaryType.individual)
                                                  ReactiveWrapperField(
                                                    formControlName:
                                                        _doseAdministrationKey,
                                                    builder: (field) =>
                                                        LabeledField(
                                                      label: localizations
                                                          .translate(i18
                                                              .deliverIntervention
                                                              .currentCycle),
                                                      child: DigitTextFormInput(
                                                        inputFormatters: [
                                                          UpperCaseTextFormatter(),
                                                        ],
                                                        readOnly: true,
                                                        keyboardType:
                                                            TextInputType
                                                                .number,
                                                        initialValue: form
                                                            .control(
                                                                _doseAdministrationKey)
                                                            .value,
                                                      ),
                                                    ),
                                                  ),
                                                ReactiveWrapperField(
                                                  formControlName:
                                                      _dateOfAdministrationKey,
                                                  builder: (field) =>
                                                      LabeledField(
                                                    label: localizations
                                                        .translate(i18_local
                                                            .householdDetails
                                                            .dateOfAdministrationLabel),
                                                    child: DigitDateFormInput(
                                                      readOnly: true,
                                                      initialValue: DateFormat(
                                                              'dd MMM yyyy')
                                                          .format(form
                                                              .control(
                                                                  _dateOfAdministrationKey)
                                                              .value)
                                                          .toString(),
                                                      confirmText: localizations
                                                          .translate(i18.common
                                                              .coreCommonOk),
                                                      cancelText: localizations
                                                          .translate(i18.common
                                                              .coreCommonCancel),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                  Form(
                                    key: checklistFormKey,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        ...initialAttributes!.map((e) {
                                          int index = (initialAttributes ?? [])
                                              .indexOf(e);

                                          return Column(children: [
                                            if (e.dataType == 'String' &&
                                                !(e.code ?? '')
                                                    .contains('.')) ...[
                                              DigitTextField(
                                                autoValidation: AutovalidateMode
                                                    .onUserInteraction,
                                                isRequired: true,
                                                controller: controller[index],
                                                validator: (value) {
                                                  if (((value == null ||
                                                          value == '') &&
                                                      e.required == true)) {
                                                    return localizations
                                                        .translate(
                                                      i18_local.common
                                                          .corecommonRequired,
                                                    );
                                                  }
                                                  if (e.regex != null) {
                                                    return (RegExp(e.regex!)
                                                            .hasMatch(value!))
                                                        ? null
                                                        : localizations.translate(
                                                            "${e.code}_REGEX");
                                                  }

                                                  return null;
                                                },
                                                label: localizations.translate(
                                                  '${selectedServiceDefinition?.code}.${e.code}',
                                                ),
                                              ),
                                            ] else if (e.dataType == 'Number' &&
                                                !(e.code ?? '')
                                                    .contains('.')) ...[
                                              DigitTextField(
                                                autoValidation: AutovalidateMode
                                                    .onUserInteraction,
                                                textStyle: theme
                                                    .textTheme.headlineMedium,
                                                textInputType:
                                                    TextInputType.number,
                                                inputFormatter: [
                                                  FilteringTextInputFormatter
                                                      .allow(
                                                    RegExp(
                                                      "[0-9]",
                                                    ),
                                                  ),
                                                ],
                                                validator: (value) {
                                                  if (((value == null ||
                                                          value == '') &&
                                                      e.required == true)) {
                                                    return localizations
                                                        .translate(
                                                      i18_local.common
                                                          .corecommonRequired,
                                                    );
                                                  }
                                                  if (e.regex != null) {
                                                    return (RegExp(e.regex!)
                                                            .hasMatch(value!))
                                                        ? null
                                                        : localizations.translate(
                                                            "${e.code}_REGEX");
                                                  }

                                                  return null;
                                                },
                                                controller: controller[index],
                                                label: '${localizations.translate(
                                                      '${selectedServiceDefinition?.code}.${e.code}',
                                                    ).trim()} ${e.required == true ? '*' : ''}',
                                              ),
                                            ] else if (e.dataType ==
                                                    'MultiValueList' &&
                                                !(e.code ?? '')
                                                    .contains('.')) ...[
                                              Align(
                                                alignment: Alignment.topLeft,
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(8),
                                                  child: Column(
                                                    children: [
                                                      Text(
                                                        '${localizations.translate(
                                                          '${selectedServiceDefinition?.code}.${e.code}',
                                                        )} ${e.required == true ? '*' : ''}',
                                                        style: theme.textTheme
                                                            .headlineSmall,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              BlocBuilder<ServiceBloc,
                                                  ServiceState>(
                                                builder: (context, state) {
                                                  return Column(
                                                    children: e.values!
                                                        .map((e) =>
                                                            DigitCheckboxTile(
                                                              label: e,
                                                              value: controller[
                                                                      index]
                                                                  .text
                                                                  .split('.')
                                                                  .contains(e),
                                                              onChanged:
                                                                  (value) {
                                                                final String
                                                                    ele;
                                                                var val =
                                                                    controller[
                                                                            index]
                                                                        .text
                                                                        .split(
                                                                            '.');
                                                                if (val
                                                                    .contains(
                                                                        e)) {
                                                                  val.remove(e);
                                                                  ele =
                                                                      val.join(
                                                                          ".");
                                                                } else {
                                                                  ele =
                                                                      "${controller[index].text}.$e";
                                                                }
                                                                controller[index]
                                                                        .value =
                                                                    TextEditingController
                                                                        .fromValue(
                                                                  TextEditingValue(
                                                                    text: ele,
                                                                  ),
                                                                ).value;
                                                              },
                                                            ))
                                                        .toList(),
                                                  );
                                                },
                                              ),
                                            ] else if (e.dataType ==
                                                'SingleValueList') ...[
                                              if (!(e.code ?? '').contains('.'))
                                                DigitCard(
                                                  // Replace with your desired widget
                                                  child: _buildChecklist(
                                                    e,
                                                    index,
                                                    selectedServiceDefinition,
                                                    context,
                                                  ),
                                                ),
                                            ],
                                          ]);
                                        }),
                                      ],
                                    ),
                                  ),
                                  // ),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }

  // ignore: long-parameter-list

  // This method builds a form used for delivering interventions.
  FormGroup buildForm(
    BuildContext context,
    List<DeliveryProductVariant>? productVariants,
    List<ProductVariantModel>? variants,
  ) {
    final bloc = context.read<DeliverInterventionBloc>().state;
    final overViewbloc = context.read<HouseholdOverviewBloc>().state;
    _controllers.forEachIndexed((index, element) {
      _controllers.removeAt(index);
    });
    ProjectTypeModel? projectTypeModel =
        widget.eligibilityAssessmentType == EligibilityAssessmentType.smc
            ? RegistrationDeliverySingleton()
                .selectedProject
                ?.additionalDetails
                ?.projectType
            : RegistrationDeliverySingleton()
                .selectedProject
                ?.additionalDetails
                ?.additionalProjectType;
    // Add controllers for each product variant to the _controllers list.
    if (_controllers.isEmpty) {
      final int r = projectTypeModel?.cycles == null
          ? 1
          : fetchProductVariant(
                      projectTypeModel
                          ?.cycles![bloc.cycle - 1].deliveries?[bloc.dose - 1],
                      overViewbloc.selectedIndividual,
                      overViewbloc.householdMemberWrapper.household)
                  ?.productVariants
                  ?.length ??
              0;

      _controllers.addAll(List.generate(r, (index) => index)
          .mapIndexed((index, element) => index));
    }

    return fb.group(<String, Object>{
      _doseAdministrationKey: FormControl<String>(
        value:
            '${localizations.translate(i18.deliverIntervention.cycle)} ${bloc.cycle == 0 ? (bloc.cycle + 1) : bloc.cycle}'
                .toString(),
        validators: [],
      ),
      _dateOfAdministrationKey:
          FormControl<DateTime>(value: DateTime.now(), validators: []),
    });
  }

  Widget _buildChecklist(
    AttributesModel item,
    int index,
    ServiceDefinitionModel? selectedServiceDefinition,
    BuildContext context,
  ) {
    final theme = Theme.of(context);
    /* Check the data type of the attribute*/
    if (item.dataType == 'SingleValueList') {
      final childItems = getNextQuestions(
        item.code.toString(),
        initialAttributes ?? [],
      );
      List<int> excludedIndexes = [];

      // Ensure the current index is added to visible indexes and not excluded
      if (!visibleChecklistIndexes.contains(index) &&
          !excludedIndexes.contains(index)) {
        visibleChecklistIndexes.add(index);
      }

      // Determine excluded indexes
      for (int i = 0; i < (initialAttributes ?? []).length; i++) {
        if (!visibleChecklistIndexes.contains(i)) {
          excludedIndexes.add(i);
        }
      }

      return Column(
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: const EdgeInsets.all(4.0), // Add padding here
              child: Text(
                '${localizations.translate(
                  '${selectedServiceDefinition?.code}.${item.code}',
                )} ${item.required == true ? '*' : ''}',
                style: theme.textTheme.headlineSmall,
              ),
            ),
          ),
          Column(
            children: [
              BlocBuilder<ServiceBloc, ServiceState>(
                builder: (context, state) {
                  return RadioGroup<String>.builder(
                    groupValue: controller[index].text.trim(),
                    onChanged: (value) {
                      setState(() {
                        for (final matchingChildItem in childItems) {
                          final childIndex =
                              initialAttributes?.indexOf(matchingChildItem);
                          if (childIndex != null) {
                            visibleChecklistIndexes
                                .removeWhere((v) => v == childIndex);
                          }
                        }

                        // Update the current controller's value
                        controller[index].value =
                            TextEditingController.fromValue(
                          TextEditingValue(
                            text: value!,
                          ),
                        ).value;

                        // Remove corresponding controllers based on the removed attributes
                      });
                    },
                    items: item.values != null
                        ? item.values!
                            .where(
                                (e) => e != i18_local.checklist.notSelectedKey)
                            .toList()
                        : [],
                    itemBuilder: (item) => RadioButtonBuilder(
                      localizations.translate(
                        'CORE_COMMON_${item.trim().toUpperCase()}',
                      ),
                    ),
                  );
                },
              ),
              BlocBuilder<ServiceBloc, ServiceState>(
                builder: (context, state) {
                  final hasError = (item.required == true &&
                      controller[index].text.isEmpty &&
                      submitTriggered);

                  return Offstage(
                    offstage: !hasError,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        localizations.translate(
                          i18_local.common.corecommonRequired,
                        ),
                        style: TextStyle(
                          color: theme.colorScheme.error,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          if (childItems.isNotEmpty &&
              controller[index].text.trim().isNotEmpty) ...[
            _buildNestedChecklists(
              item.code.toString(),
              index,
              controller[index].text.trim(),
              context,
            ),
          ],
        ],
      );
    } else if (item.dataType == 'String') {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: DigitTextField(
          onChange: (value) {
            checklistFormKey.currentState?.validate();
          },
          isRequired: item.required ?? true,
          controller: controller[index],
          validator: (value) {
            if (((value == null || value == '') && item.required == true)) {
              return localizations.translate("${item.code}_REQUIRED");
            }
            if (item.regex != null) {
              return (RegExp(item.regex!).hasMatch(value!))
                  ? null
                  : localizations.translate("${item.code}_REGEX");
            }

            return null;
          },
          label: localizations.translate(
            '${selectedServiceDefinition?.code}.${item.code}',
          ),
        ),
      );
    } else if (item.dataType == 'Number') {
      return DigitTextField(
        autoValidation: AutovalidateMode.onUserInteraction,
        textStyle: theme.textTheme.headlineMedium,
        textInputType: TextInputType.number,
        inputFormatter: [
          FilteringTextInputFormatter.allow(RegExp(
            "[0-9]",
          )),
        ],
        validator: (value) {
          if (((value == null || value == '') && item.required == true)) {
            return localizations.translate(
              i18_local.common.corecommonRequired,
            );
          }
          if (item.regex != null) {
            return (RegExp(item.regex!).hasMatch(value!))
                ? null
                : localizations.translate("${item.code}_REGEX");
          }

          return null;
        },
        controller: controller[index],
        label: '${localizations.translate(
              '${selectedServiceDefinition?.code}.${item.code}',
            ).trim()} ${item.required == true ? '*' : ''}',
      );
    } else if (item.dataType == 'MultiValueList') {
      return Column(
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                children: [
                  Text(
                    '${localizations.translate(
                      '${selectedServiceDefinition?.code}.${item.code}',
                    )} ${item.required == true ? '*' : ''}',
                    style: theme.textTheme.headlineSmall,
                  ),
                ],
              ),
            ),
          ),
          BlocBuilder<ServiceBloc, ServiceState>(
            builder: (context, state) {
              return Column(
                children: item.values!
                    .map((e) => DigitCheckboxTile(
                          label: e,
                          value: controller[index].text.split('.').contains(e),
                          onChanged: (value) {
                            final String ele;
                            var val = controller[index].text.split('.');
                            if (val.contains(e)) {
                              val.remove(e);
                              ele = val.join(".");
                            } else {
                              ele = "${controller[index].text}.$e";
                            }
                            controller[index].value =
                                TextEditingController.fromValue(
                              TextEditingValue(
                                text: ele,
                              ),
                            ).value;
                          },
                        ))
                    .toList(),
              );
            },
          ),
        ],
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  // Function to build nested checklists for child attributes
  Widget _buildNestedChecklists(
    String parentCode,
    int parentIndex,
    String parentControllerValue,
    BuildContext context,
  ) {
    // Retrieve child items for the given parent code
    final childItems = getNextQuestions(
      parentCode,
      initialAttributes ?? [],
    );

    return Column(
      children: [
        // Build cards for each matching child attribute
        for (final matchingChildItem in childItems.where((childItem) =>
            childItem.code!.startsWith('$parentCode.$parentControllerValue.')))
          Card(
            margin: const EdgeInsets.only(bottom: 8.0, left: 4.0, right: 4.0),
            color:
                // countDots(matchingChildItem.code ?? '') % 4 == 2
                //     ? const Color.fromRGBO(238, 238, 238, 1)
                //     :
                const DigitColors().white,
            child: _buildChecklist(
              matchingChildItem,
              initialAttributes?.indexOf(matchingChildItem) ??
                  parentIndex, // Pass parentIndex here as we're building at the same level
              selectedServiceDefinition,
              context,
            ),
          ),
      ],
    );
  }

  // Function to get the next questions (child attributes) based on a parent code
  List<AttributesModel> getNextQuestions(
    String parentCode,
    List<AttributesModel> checklistItems,
  ) {
    final childCodePrefix = '$parentCode.';
    final nextCheckLists = checklistItems.where((item) {
      return item.code!.startsWith(childCodePrefix) &&
          item.code?.split('.').length == parentCode.split('.').length + 2;
    }).toList();

    return nextCheckLists;
  }

  // int countDots(String inputString) {
  //   int dotCount = 0;
  //   for (int i = 0; i < inputString.length; i++) {
  //     if (inputString[i] == '.') {
  //       dotCount++;
  //     }
  //   }

  //   return dotCount;
  // }

  Future<bool> _onBackPressed(BuildContext context) async {
    bool? shouldNavigateBack = await showDialog<bool>(
      context: context,
      builder: (context) => DigitDialog(
        options: DigitDialogOptions(
          titleText: localizations.translate(
            i18_local.checklist.checklistBackDialogLabel,
          ),
          content: Text(localizations.translate(
            i18_local.checklist.checklistBackDialogDescription,
          )),
          primaryAction: DigitDialogActions(
            label: localizations.translate(
                i18_local.checklist.checklistBackDialogPrimaryAction),
            action: (ctx) {
              Navigator.of(
                context,
                rootNavigator: true,
              ).pop(true);
            },
          ),
          secondaryAction: DigitDialogActions(
            label: localizations.translate(
                i18_local.checklist.checklistBackDialogSecondaryAction),
            action: (context) {
              Navigator.of(
                context,
                rootNavigator: true,
              ).pop(false);
            },
          ),
        ),
      ),
    );

    return shouldNavigateBack ?? false;
  }

  bool shouldShowVaccinePage(
    Map<String?, String> responses,
  ) {
    var showVaccinePage = false;
    var q1Key = "ZDAQ1";

    if (responses.isNotEmpty) {
      if (!showVaccinePage &&
          (responses.containsKey(q1Key) && responses[q1Key]!.isNotEmpty)) {
        showVaccinePage = responses[q1Key] == yes ? true : false;
      }
    }

    return showVaccinePage;
  }

  bool isZeroDose(
    Map<String?, String> responses,
  ) {
    var isZeroDose = false;
    var q2Key = "ZDAQ1.NO.Q2A";
    var q3Key = "ZDAQ1.NO.Q2A.YES.Q2AA";

    if (responses.isNotEmpty) {
      if (!isZeroDose &&
          (responses.containsKey(q2Key) && responses[q2Key]!.isNotEmpty)) {
        isZeroDose = responses[q2Key] == no ? true : false;
      }
      if (!isZeroDose &&
          (responses.containsKey(q3Key) && responses[q3Key]!.isNotEmpty)) {
        isZeroDose = responses[q3Key] == no ? true : false;
      }
    }

    return isZeroDose;
  }

  bool isIncompletementVaccine(
    Map<String?, String> responses,
  ) {
    var isIncomplete = false;
    var q3Key = "ZDAQ1.NO.Q2A.YES.Q2AA";

    if (responses.isNotEmpty) {
      if (!isIncomplete &&
          (responses.containsKey(q3Key) && responses[q3Key]!.isNotEmpty)) {
        isIncomplete = responses[q3Key] == yes ? true : false;
      }
    }

    return isIncomplete;
  }
}
