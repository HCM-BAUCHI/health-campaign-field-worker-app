// import 'dart:math';

import 'dart:ffi';
import 'dart:math';

import 'package:digit_components/widgets/atoms/digit_toaster.dart';
import 'package:digit_components/widgets/digit_checkbox_tile.dart';
import 'package:digit_components/widgets/digit_dialog.dart';
import 'package:digit_components/widgets/digit_elevated_button.dart';
import 'package:digit_data_model/data/local_store/sql_store/tables/service.dart';
import 'package:digit_ui_components/digit_components.dart';
import 'package:digit_ui_components/services/location_bloc.dart';
import 'package:digit_ui_components/widgets/molecules/digit_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:health_campaign_field_worker_app/blocs/app_initialization/app_initialization.dart';
import 'package:health_campaign_field_worker_app/data/local_store/no_sql/schema/app_configuration.dart';
import 'package:registration_delivery/registration_delivery.dart';
import 'package:registration_delivery/router/registration_delivery_router.gm.dart';
import '../../../blocs/localization/app_localization.dart';
import '../../../models/entities/additional_fields_type.dart';
import '../../../models/entities/roles_type.dart';
import 'package:registration_delivery/blocs/household_overview/household_overview.dart';
import 'package:survey_form/survey_form.dart';
import '../../../models/entities/status.dart';
import '../../../router/app_router.dart';
import '../../../utils/app_enums.dart';
import '../../../utils/constants.dart';
import '../../../utils/date_utils.dart';
import '../../../utils/environment_config.dart';
import '../../../utils/extensions/extensions.dart';
import '../../../widgets/localized.dart';
import 'package:digit_data_model/data_model.dart';

import '../../../models/entities/additional_fields_type.dart'
    as additional_fields_local;
import '../../../models/entities/assessment_checklist/status.dart'
    as status_local;
import '../../../widgets/custom_back_navigation.dart';
import '../../../widgets/showcase/showcase_wrappers.dart';
import 'package:registration_delivery/utils/i18_key_constants.dart' as i18;
import '../../../utils/i18_key_constants.dart' as i18_local;
import 'package:digit_components/widgets/atoms/checkbox_icon.dart';
import 'package:survey_form/utils/i18_key_constants.dart' as i18_survey_form;

//  Add this import for the radio button component.
import 'package:group_radio_button/group_radio_button.dart';

@RoutePage()
class VaccineSelectionPage extends LocalizedStatefulWidget {
  final bool isAdministration;
  final EligibilityAssessmentType eligibilityAssessmentType;
  final bool isChecklistAssessmentDone;
  final String? projectBeneficiaryClientReferenceId;
  final IndividualModel? individual;
  final TaskModel task;
  final bool? hasSideEffects;
  final SideEffectModel sideEffect;
  final bool isZeroDoseAlreadyDone;

  const VaccineSelectionPage({
    super.key,
    super.appLocalizations,
    required this.isAdministration,
    required this.eligibilityAssessmentType,
    required this.isChecklistAssessmentDone,
    this.projectBeneficiaryClientReferenceId,
    this.individual,
    required this.task,
    this.hasSideEffects = false,
    required this.sideEffect,
    this.isZeroDoseAlreadyDone = false,
  });

  @override
  State<VaccineSelectionPage> createState() => _VaccineSelectionPageState();
}

class _VaccineSelectionPageState extends LocalizedState<VaccineSelectionPage> {
  String isStateChanged = '';
  var submitTriggered = false;
  List<TextEditingController> controller = [];
  List<TextEditingController> additionalController = [];
  List<AttributesModel>? initialAttributes;
  ServiceAttributesModel? selectedAttribute;
  ServiceDefinitionModel? selectedServiceDefinition;
  bool isControllersInitialized = false;
  List<int> visibleChecklistIndexes = [];
  GlobalKey<FormState> checklistFormKey = GlobalKey<FormState>();
  Map<String?, String> responses = {};
  bool triggerLocalization = false;
  Set<String> selectedVaccines = {};
  List<String> selectedCodes = [];

  // List<AttributesModel>? initialAttributes;
  // ServiceDefinitionModel? selectedServiceDefinition;
  // bool isControllersInitialized = false;
  // GlobalKey<FormState> checklistFormKey = GlobalKey<FormState>();

  // [ADDED] Use a map to store controllers for each vaccine code for better management.
  // This will store "YES" or "NO" for each vaccine.
  final Map<String, TextEditingController> _vaccineControllers = {};
  final String _yes = "YES";
  final String _no = "NO";
  // --- [MODIFICATION END] ---

  @override
  void initState() {
    context.read<LocationBloc>().add(const LocationEvent.load());
    if (!widget.isZeroDoseAlreadyDone) {
      context.read<ServiceBloc>().add(ServiceSurveyFormEvent(
            value: Random().nextInt(100).toString(),
            submitTriggered: true,
          ));
    } else {
      context.read<ServiceBloc>().add(ServiceSearchEvent(
            serviceSearchModel: ServiceSearchModel(
              relatedClientReferenceId:
                  widget.projectBeneficiaryClientReferenceId,
            ),
          ));
    }
    super.initState();
  }

  // [ADDED] This function checks if all *enabled* vaccines have "YES" selected.
  bool _isVaccinationSuccessful({
    required List<String> allVaccineCodes,
    required Map<String, int> vaccineAgeMap,
    required int ageInDays,
  }) {
    // Loop through every vaccine defined in the checklist.
    for (final code in allVaccineCodes) {
      // First, determine if the current vaccine is enabled (age-appropriate).
      final isEnabled = !(vaccineAgeMap.containsKey(code)
          ? vaccineAgeMap[code]! >= ageInDays
          : true);

      // We only care about the response for vaccines that are enabled.
      if (isEnabled) {
        final response = _vaccineControllers[code]?.text;
        // If an enabled vaccine was NOT answered "YES" (it's "NO" or empty),
        // then the overall result is false.
        if (response != _yes) {
          return false;
        }
      }
    }

    // If we finished the loop without returning false, it means all
    // enabled vaccines were answered "YES".
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final dob = context
        .read<HouseholdOverviewBloc>()
        .state
        .selectedIndividual
        ?.dateOfBirth;
    final theme = Theme.of(context);
    final ageInDays = calculateAgeInDaysFromDob(dob!);
    return BlocListener<ServiceBloc, ServiceState>(listener: (context, state) {
      state.maybeWhen(
        orElse: () {},
        serviceSearch: (serviceList, selectedService, loading) {
          if (serviceList.isNotEmpty) {
            final service = serviceList.last;
            if (service.attributes != null && service.attributes!.isNotEmpty) {
              selectedAttribute = service.attributes!
                  .where((e) => e.dataType == 'MultiValueList')
                  .toList()
                  .firstOrNull;
              final selectedCodesString = selectedAttribute?.value as String;
              setState(() {
                selectedCodes = selectedCodesString.split('.').toList();
              });
            }
          }
        },
      );
    }, child: BlocBuilder<AppInitializationBloc, AppInitializationState>(
      builder: (context, appInitState) {
        List<VaccineData> vaccineDataList = [];
        if (appInitState is AppInitialized) {
          vaccineDataList = appInitState.appConfiguration.vaccinationData ?? [];
        }

        final Map<String, int> vaccineAgeMap = {
          for (final v in vaccineDataList) v.code: v.ageInDays
        };

        final Map<String, String> vaccineCodeToName = {
          for (final v in vaccineDataList) v.code: v.name
        };
        return PopScope(
            canPop: true,
            child: Scaffold(body: BlocBuilder<LocationBloc, LocationState>(
                builder: (context, locationState) {
              return BlocBuilder<HouseholdOverviewBloc, HouseholdOverviewState>(
                builder: (context, householdOverviewState) {
                  double? latitude = locationState.latitude;
                  double? longitude = locationState.longitude;
                  String vaccineSelection = "ZERO_DOSE_ASSESSMENT";
                  return BlocBuilder<ServiceDefinitionBloc,
                      ServiceDefinitionState>(
                    builder: (context, state) {
                      state.maybeMap(
                        orElse: () {},
                        serviceDefinitionFetch: (value) {
                          selectedServiceDefinition = value
                              .serviceDefinitionList
                              .where(
                                  (element) => element.code.toString().contains(
                                        '${context.selectedProject.name}.$vaccineSelection.${context.isCommunityDistributor ? RolesType.communityDistributor.toValue() : RolesType.healthFacilitySupervisor.toValue()}',
                                      ))
                              .toList()
                              .firstOrNull;
                          initialAttributes =
                              selectedServiceDefinition?.attributes!;
                          if (!isControllersInitialized) {
                            initialAttributes?.forEach((e) {
                              if (e.dataType == 'MultiValueList') {
                                controller.add(TextEditingController(
                                    text: selectedCodes.join('.')));
                                selectedVaccines = selectedCodes.toSet();
                              } else {
                                controller.add(TextEditingController());
                              }
                            });
                            isControllersInitialized = true;
                          }
                        },
                      );

                      return state.maybeMap(
                        orElse: () => Text(state.runtimeType.toString()),
                        serviceDefinitionFetch: (value) {
                          return ScrollableContent(
                            header: const Column(children: [
                              CustomBackNavigationHelpHeaderWidget(
                                showHelp: false,
                              )
                            ]),
                            enableFixedDigitButton: true,
                            footer: DigitCard(
                              margin:
                                  const EdgeInsets.fromLTRB(0, kPadding, 0, 0),
                              padding: const EdgeInsets.fromLTRB(
                                  kPadding, 0, kPadding, 0),
                              children: [
                                DigitElevatedButton(
                                  onPressed: () async {
                                    /*submitTriggered = true;
                                    final isValid = checklistFormKey
                                        .currentState
                                        ?.validate();
                                    if (!isValid!) {
                                      return;
                                    }
                                    final itemsAttributes = initialAttributes;
                                    for (int i = 0;
                                        i < initialAttributes!.length;
                                        i++) {
                                      if (itemsAttributes?[i].dataType ==
                                          'SingleValueList') {
                                        controller[i].text = 'NOT_SELECTED';
                                      }
                                      if (itemsAttributes?[i].dataType ==
                                              'MultiValueList' &&
                                          controller[i].text == '') {
                                        controller[i].text = 'NOT_SELECTED';
                                      }
                                      if (itemsAttributes?[i].required ==
                                              true &&
                                          ((itemsAttributes?[i].dataType ==
                                                      'SingleValueList' &&
                                                  (controller[i].text == '')) ||
                                              (itemsAttributes?[i].dataType !=
                                                      'SingleValueList' &&
                                                  (controller[i].text == '' ||
                                                      !(widget.projectBeneficiaryClientReferenceId !=
                                                          null))))) {
                                        return;
                                      }
                                    }
                                    for (final code in selectedCodes) {
                                      final match =
                                          RegExp(r'^(.*?)([_-])(\d+)$')
                                              .firstMatch(code);
                                      if (match != null) {
                                        final base = match.group(1);
                                        final sep =
                                            match.group(2); // '_' or '-'
                                        final num =
                                            int.tryParse(match.group(3) ?? '');
                                        if (num != null && num > 1) {
                                          final prevCode =
                                              '$base$sep${num - 1}';
                                          if (!selectedCodes
                                              .contains(prevCode)) {
                                            DigitToast.show(
                                              context,
                                              options: DigitToastOptions(
                                                'You have not selected ${vaccineCodeToName[prevCode] ?? prevCode}.',
                                                true,
                                                theme,
                                              ),
                                            );
                                            return;
                                          }
                                        }
                                      }
                                    }
                                    triggerLocalization = true;*/
                                    // NEW BLOCK
                                    final multiValueAttribute =
                                        initialAttributes?.firstWhere((e) =>
                                            e.dataType == 'MultiValueList');

                                    final allVaccineCodes = multiValueAttribute
                                            ?.values
                                            ?.where((v) => v != 'NOT_SELECTED')
                                            .toList() ??
                                        [];

                                    // [MODIFIED] Get a list of codes where the user selected "YES".
                                    final selectedCodes = allVaccineCodes
                                        .where((code) =>
                                            _vaccineControllers[code]?.text ==
                                            _yes)
                                        .toList();

                                    // The original sequential check logic remains the same, using our new `selectedCodes` list.
                                    for (final code in selectedCodes) {
                                      final match =
                                          RegExp(r'^(.*?)([_-])(\d+)$')
                                              .firstMatch(code);
                                      if (match != null) {
                                        final base = match.group(1);
                                        final sep =
                                            match.group(2); // '_' or '-'
                                        final num =
                                            int.tryParse(match.group(3) ?? '');
                                        if (num != null && num > 1) {
                                          final prevCode =
                                              '$base$sep${num - 1}';
                                          if (!selectedCodes
                                              .contains(prevCode)) {
                                            DigitToast.show(
                                              context,
                                              options: DigitToastOptions(
                                                'You have not selected ${vaccineCodeToName[prevCode] ?? prevCode}.',
                                                true,
                                                theme,
                                              ),
                                            );
                                            return;
                                          }
                                        }
                                      }
                                    }

                                    // [ADDED] Call our new function to determine if the vaccination was successful.
                                    final isVaccinationSuccessful =
                                        _isVaccinationSuccessful(
                                      allVaccineCodes: allVaccineCodes,
                                      vaccineAgeMap: vaccineAgeMap,
                                      ageInDays: ageInDays,
                                    );
                                    // +++ END of NEW Block 1 +++

                                    final shouldSubmit = await DigitDialog.show(
                                      context,
                                      options: DigitDialogOptions(
                                        titleText: localizations.translate(
                                          i18.deliverIntervention.dialogTitle,
                                        ),
                                        contentText: localizations.translate(
                                          i18.deliverIntervention.dialogContent,
                                        ),
                                        primaryAction: DigitDialogActions(
                                          label: localizations.translate(
                                            i18.common.coreCommonSubmit,
                                          ),
                                          /* action: (ctx) {
                                            final referenceId =
                                                IdGen.i.identifier;
                                            List<ServiceAttributesModel>
                                                attributes = [];
                                            for (int i = 0;
                                                i < controller.length;
                                                i++) {
                                              final attribute =
                                                  initialAttributes;

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
                                                dataType:
                                                    attribute?[i].dataType,
                                                clientReferenceId:
                                                    IdGen.i.identifier,
                                                referenceId: referenceId,
                                                value: attribute?[i].dataType ==
                                                        'MultiValueList'
                                                    ? controller[i]
                                                            .text
                                                            .toString()
                                                            .isNotEmpty
                                                        ? controller[i]
                                                            .text
                                                            .toString()
                                                        : i18_survey_form
                                                            .surveyForm
                                                            .notSelectedKey
                                                    : attribute?[i].dataType !=
                                                            'SingleValueList'
                                                        ? controller[i]
                                                                .text
                                                                .toString()
                                                                .trim()
                                                                .isNotEmpty
                                                            ? controller[i]
                                                                .text
                                                                .toString()
                                                            : (attribute?[i]
                                                                        .dataType !=
                                                                    'Number'
                                                                ? i18_survey_form
                                                                    .surveyForm
                                                                    .notSelectedKey
                                                                : '0')
                                                        : visibleChecklistIndexes
                                                                .contains(i)
                                                            ? controller[i]
                                                                .text
                                                                .toString()
                                                            : i18_survey_form
                                                                .surveyForm
                                                                .notSelectedKey,
                                                rowVersion: 1,
                                                tenantId:
                                                    attribute?[i].tenantId,
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
                                            }*/
                                          action: (ctx) {
                                            final referenceId =
                                                IdGen.i.identifier;

                                            // [MODIFIED] A simpler way to build the attributes payload.
                                            final attributes = initialAttributes
                                                    ?.map((attribute) {
                                                  String value;
                                                  if (attribute.dataType ==
                                                      'MultiValueList') {
                                                    // Join the codes of vaccines marked "YES"
                                                    value =
                                                        selectedCodes.isEmpty
                                                            ? i18_survey_form
                                                                .surveyForm
                                                                .notSelectedKey
                                                            : selectedCodes
                                                                .join('.');
                                                  } else {
                                                    // For any other attribute type, we are not collecting data on this page.
                                                    value = i18_survey_form
                                                        .surveyForm
                                                        .notSelectedKey;
                                                  }

                                                  return ServiceAttributesModel(
                                                    auditDetails: AuditDetails(
                                                      createdBy: context
                                                          .loggedInUserUuid,
                                                      createdTime: context
                                                          .millisecondsSinceEpoch(),
                                                    ),
                                                    attributeCode:
                                                        '${attribute.code}',
                                                    dataType:
                                                        attribute.dataType,
                                                    clientReferenceId:
                                                        IdGen.i.identifier,
                                                    referenceId: referenceId,
                                                    value: value,
                                                    rowVersion: 1,
                                                    tenantId:
                                                        attribute.tenantId,
                                                    additionalFields:
                                                        ServiceAttributesAdditionalFields(
                                                      version: 1,
                                                      fields: [
                                                        AdditionalField(
                                                            'latitude',
                                                            latitude),
                                                        AdditionalField(
                                                            'longitude',
                                                            longitude),
                                                      ],
                                                    ),
                                                  );
                                                }).toList() ??
                                                [];

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
                                                        relatedClientReferenceId:
                                                            widget
                                                                .projectBeneficiaryClientReferenceId,
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
                                                            AdditionalField(
                                                              'vaccinationsuccessful',
                                                              isVaccinationSuccessful,
                                                            ),
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
                                            i18.common.coreCommonGoback,
                                          ),
                                          action: (ctx) {
                                            Navigator.of(ctx,
                                                    rootNavigator: true)
                                                .pop(false);
                                          },
                                        ),
                                      ),
                                    );
                                    if (shouldSubmit ?? false) {
                                      final router = context.router;
                                      submitTriggered = true;

                                      context.read<ServiceBloc>().add(
                                            const ServiceSurveyFormEvent(
                                              value: '',
                                              submitTriggered: true,
                                            ),
                                          );

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
                                            ZeroDoseStatus.done.name,
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
                                            router.popAndPush(
                                              CustomHouseholdAcknowledgementRoute(
                                                enableViewHousehold: true,
                                                eligibilityAssessmentType: widget
                                                    .eligibilityAssessmentType,
                                              ),
                                            );
                                          }
                                        } else {
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
                                        TaskModel task = TaskModel(
                                          projectBeneficiaryClientReferenceId:
                                              widget
                                                  .projectBeneficiaryClientReferenceId,
                                          clientReferenceId: clientReferenceId,
                                          tenantId:
                                              envConfig.variables.tenantId,
                                          rowVersion: 1,
                                          auditDetails: AuditDetails(
                                            createdBy: context.loggedInUserUuid,
                                            createdTime: context
                                                .millisecondsSinceEpoch(),
                                          ),
                                          projectId: context.projectId,
                                          status: status_local
                                              .Status.beneficiaryInEligible
                                              .toValue(),
                                          clientAuditDetails:
                                              ClientAuditDetails(
                                            createdBy: context.loggedInUserUuid,
                                            createdTime: context
                                                .millisecondsSinceEpoch(),
                                            lastModifiedBy:
                                                context.loggedInUserUuid,
                                            lastModifiedTime: context
                                                .millisecondsSinceEpoch(),
                                          ),
                                          additionalFields:
                                              TaskAdditionalFields(
                                            version: 1,
                                            fields: [
                                              AdditionalField(
                                                AdditionalFieldsType.cycleIndex
                                                    .toValue(),
                                                "0${context.selectedCycle?.id}",
                                              ),
                                              if (widget.hasSideEffects ==
                                                  false) ...[
                                                AdditionalField(
                                                  'ineligibleReasons',
                                                  ineligibilityReasons
                                                      .join(","),
                                                ),
                                                AdditionalField(
                                                  'ageBelow3Months',
                                                  true.toString(),
                                                ),
                                              ] else ...[
                                                AdditionalField(
                                                    'ineligibleReasons',
                                                    ["SIDE_EFFECTS"].join(",")),
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
                                                ZeroDoseStatus.done.name,
                                              ),
                                            ],
                                          ),
                                          address: widget
                                              .individual?.address?.first
                                              .copyWith(
                                            relatedClientReferenceId:
                                                clientReferenceId,
                                            id: null,
                                          ),
                                        );
                                        context
                                            .read<DeliverInterventionBloc>()
                                            .add(
                                              DeliverInterventionSubmitEvent(
                                                task: task,
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
                                        final searchBloc = context
                                            .read<SearchHouseholdsBloc>();
                                        searchBloc.add(
                                          const SearchHouseholdsClearEvent(),
                                        );
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
                                  },
                                  child: Text(
                                    localizations
                                        .translate(i18.common.coreCommonSubmit),
                                  ),
                                )
                              ],
                            ),
                            children: [
                              Form(
                                key: checklistFormKey, //assigning key to form
                                child: DigitCard(
                                  padding: const EdgeInsets.all(spacer5),
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: spacer5, vertical: spacer3),
                                  children: [
                                    Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            localizations.translate(
                                              i18_local.deliverIntervention
                                                  .vaccinsSelectionLabel,
                                            ),
                                            style:
                                                theme.textTheme.headlineLarge,
                                          ),
                                          const SizedBox(height: spacer5),
                                          /* ...initialAttributes!.map((e) {
                                            int index =
                                                (initialAttributes ?? [])
                                                    .indexOf(e);

                                            return Column(children: [
                                              if (e.dataType ==
                                                  'MultiValueList') ...[
                                                Align(
                                                  alignment: Alignment.topLeft,
                                                  child: Column(
                                                    children: [
                                                      Text(
                                                        '${localizations.translate(
                                                          '${selectedServiceDefinition?.code}.${e.code}',
                                                        )} ',
                                                        style: theme.textTheme
                                                            .headlineSmall,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                const SizedBox(height: spacer4),
                                                BlocBuilder<ServiceBloc,
                                                    ServiceState>(
                                                  builder: (context, state) {
                                                    return buildTwoColumnCheckboxes(
                                                      selectedCodes:
                                                          selectedCodes,
                                                      values: e.values!,
                                                      index: index,
                                                      vaccineCodeToName:
                                                          vaccineCodeToName,
                                                      vaccineAgeMap:
                                                          vaccineAgeMap,
                                                      ageInDays: ageInDays,
                                                      controller:
                                                          controller[index],
                                                      onChanged: (code, value) {
                                                        setState(() {
                                                          if (value) {
                                                            selectedCodes
                                                                .add(code);
                                                          } else {
                                                            selectedCodes
                                                                .remove(code);
                                                          }
                                                          // If you still need to update the controller for submission:
                                                          controller[index]
                                                                  .text =
                                                              selectedCodes
                                                                  .join('.');
                                                        });
                                                      },
                                                    );
                                                  },
                                                ),
                                              ]
                                            ]);
                                          }).toList(),*/
                                          //New implementation for radio buttons
                                          ...initialAttributes!
                                              .where((e) =>
                                                  e.dataType ==
                                                  'MultiValueList')
                                              .map((e) {
                                            final vaccineCodes = e.values!
                                                .where(
                                                    (v) => v != 'NOT_SELECTED')
                                                .toList();
                                            return Column(
                                              children:
                                                  vaccineCodes.map((code) {
                                                final isDisabled = vaccineAgeMap
                                                        .containsKey(code)
                                                    ? vaccineAgeMap[code]! >=
                                                        ageInDays
                                                    : true;

                                                // This logic should now be inside your initState or serviceDefinitionFetch callback,
                                                // but we ensure the controller exists here as a fallback.
                                                if (!_vaccineControllers
                                                    .containsKey(code)) {
                                                  _vaccineControllers[code] =
                                                      TextEditingController();
                                                }

                                                return _buildVaccineRadioRow(
                                                  context: context,
                                                  vaccineName:
                                                      vaccineCodeToName[code] ??
                                                          code,
                                                  isDisabled: isDisabled,
                                                  controller:
                                                      _vaccineControllers[
                                                          code]!,
                                                );
                                              }).toList(),
                                            );
                                          }).toList(),

                                          const SizedBox(
                                            height: 15,
                                          ),
                                        ])
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
            })));
      },
    ));
  }
}

/*class CustomDigitCheckboxTile extends StatelessWidget {
  final bool value;
  final String label;
  final ValueChanged<bool>? onChanged;
  final EdgeInsets? margin;
  final EdgeInsets? padding;
  final bool isDisabled;

  const CustomDigitCheckboxTile({
    this.value = false,
    required this.label,
    this.onChanged,
    this.padding,
    this.margin,
    this.isDisabled = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? const EdgeInsets.all(0),
      child: InkWell(
        onTap:
            isDisabled ? null : () => onChanged?.call(!value), // 3. Disable tap
        child: Padding(
          padding: const EdgeInsets.only(left: 0, bottom: kPadding * 2),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              value
                  ? const CheckboxIcon(
                      value: true,
                    )
                  : const CheckboxIcon(),
              const SizedBox(width: kPadding * 2),
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: isDisabled
                            ? Colors.grey
                            : Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget buildTwoColumnCheckboxes({
  required List<String> values,
  required int index,
  required Map<String, String> vaccineCodeToName,
  required Map<String, int> vaccineAgeMap,
  required int ageInDays,
  required TextEditingController controller,
  required void Function(String code, bool value) onChanged,
  required List<String> selectedCodes,
}) {
  final filtered = values.where((e) => e != 'NOT_SELECTED').toList();
  final mid = (filtered.length / 2).ceil();
  final firstCol = filtered.sublist(0, mid);
  final secondCol = filtered.sublist(mid);

  Widget buildCol(List<String> col) => Column(
        children: col
            .map((code) => CustomDigitCheckboxTile(
                  label: vaccineCodeToName.containsKey(code)
                      ? vaccineCodeToName[code] ?? code
                      : code,
                  isDisabled: vaccineAgeMap.containsKey(code)
                      ? vaccineAgeMap[code]! >= ageInDays
                      : true,
                  // value: controller.text.split('.').contains(code),
                  value: selectedCodes.contains(code),
                  onChanged: (value) => onChanged(code, value),
                ))
            .toList(),
      );

  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Expanded(child: buildCol(firstCol)),
      const SizedBox(width: 16),
      Expanded(child: buildCol(secondCol)),
    ],
  );
}*/

// [ADDED] This new helper builds a row with a vaccine name and Yes/No radio buttons.
Widget _buildVaccineRadioRow({
  required BuildContext context,
  required String vaccineName,
  required bool isDisabled,
  required TextEditingController controller,
}) {
  final theme = Theme.of(context);
  final localizations = AppLocalizations.of(context);

// [ADDED] Wrap the entire content in a DigitCard for consistent UI.

  return DigitCard(
    margin: const EdgeInsets.only(top: kPadding, bottom: kPadding),
    children: [
      Padding(
        padding: const EdgeInsets.all(kPadding), // Add some internal padding
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              vaccineName,
              style: theme.textTheme.headlineSmall?.copyWith(
                color: isDisabled ? theme.disabledColor : null,
              ),
            ),
            const SizedBox(height: 8),
            RadioGroup<String>.builder(
              direction: Axis.vertical,
              groupValue: controller.text,
              onChanged: isDisabled
                  ? null // Disable selection if the vaccine is not age-appropriate
                  : (value) {
                      // We need to use setState here to update the UI when a radio button is clicked.
                      // This is a small but important detail. We find the State object to call setState.
                      (context as Element).markNeedsBuild();
                      controller.text = value ?? '';
                    },
              items: const ["YES", "NO"],
              itemBuilder: (item) => RadioButtonBuilder(
                localizations.translate(
                  'CORE_COMMON_${item.trim().toUpperCase()}',
                ),
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

int calculateAgeInDaysFromDob(String dobString) {
  final dob = DigitDateUtils.getFormattedDateToDateTime(dobString);
  if (dob == null) return 0;
  final now = DateTime.now();
  return now.difference(dob).inDays;
}
