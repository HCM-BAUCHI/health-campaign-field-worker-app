// import 'dart:math';

import 'dart:async';
import 'dart:ffi';
import 'dart:math';

import 'package:collection/collection.dart';
import 'package:digit_components/widgets/atoms/digit_toaster.dart';
import 'package:digit_components/widgets/digit_checkbox_tile.dart';
import 'package:digit_components/widgets/digit_dialog.dart';
import 'package:digit_components/widgets/digit_elevated_button.dart';
import 'package:digit_data_model/data/local_store/sql_store/tables/service.dart';
import 'package:digit_ui_components/digit_components.dart';
import 'package:digit_ui_components/services/location_bloc.dart';
import 'package:digit_ui_components/widgets/molecules/digit_card.dart';
// import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:health_campaign_field_worker_app/blocs/app_initialization/app_initialization.dart';
import 'package:health_campaign_field_worker_app/data/local_store/no_sql/schema/app_configuration.dart';
import 'package:registration_delivery/registration_delivery.dart';
import 'package:registration_delivery/router/registration_delivery_router.gm.dart';
import '../../../blocs/localization/app_localization.dart';
import '../../../data/repositories/custom_task.dart';
import '../../../models/entities/additional_fields_type.dart';
import '../../../models/entities/roles_type.dart';
import 'package:registration_delivery/blocs/household_overview/household_overview.dart';
import 'package:survey_form/survey_form.dart';
import '../../../models/entities/status.dart';
import '../../../router/app_router.dart';
import '../../../utils/app_enums.dart';
import '../../../utils/constants.dart';
import '../../../utils/date_utils.dart';
import '../../../utils/utils.dart' show getIndividualAdditionalFields;
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
  List<String> noSelectedCodes = [];
  int currentIndex = 0;

  final String _yes = "YES";
  final String _no = "NO";

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
    fetchTasksData();
    super.initState();
  }

  Future<void> fetchTasksData() async {
    final taskDataRepository =
        context.read<LocalRepository<TaskModel, TaskSearchModel>>()
            as CustomTaskLocalRepository;

    List<TaskModel> tasksData = await taskDataRepository.search(
      TaskSearchModel(
        projectBeneficiaryClientReferenceId:
            widget.projectBeneficiaryClientReferenceId != null
                ? [widget.projectBeneficiaryClientReferenceId!]
                : null,
      ),
    );

    int lastCycle = context.selectedCycle!.id - 1;
    lastCycle = lastCycle < 0 ? 0 : lastCycle;
    List<TaskModel> lastVaccinationTask = tasksData.where(
      (task) {
        final fields = task.additionalFields?.fields;
        if (fields == null) return false;
        final hasCorrectCycle = fields.any(
          (e) =>
              e.key == AdditionalFieldsType.cycleIndex.toValue() &&
              int.tryParse(e.value) == lastCycle,
        );
        final hasZeroDoseStatus = fields.any(
          (e) =>
              e.key ==
              additional_fields_local.AdditionalFieldsType.zeroDoseStatus
                  .toValue(),
        );
        final hasSelectedVaccines = fields.any(
          (e) =>
              e.key ==
              additional_fields_local.AdditionalFieldsType.selectedVaccines
                  .toValue(),
        );
        final hasNoSelectedVaccines = fields.any(
          (e) =>
              e.key ==
              additional_fields_local.AdditionalFieldsType.noSelectedVaccines
                  .toValue(),
        );
        return hasCorrectCycle &&
            hasZeroDoseStatus &&
            (hasSelectedVaccines || hasNoSelectedVaccines);
      },
    ).toList();

    if (lastVaccinationTask.isNotEmpty) {
      List<String> yesSelectedVaccines = [];
      List<String> noSelectedVaccines = [];
      // ignore: avoid_dynamic_calls
      yesSelectedVaccines = lastVaccinationTask.last.additionalFields!.fields
          .firstWhereOrNull((e) =>
              e.key ==
              additional_fields_local.AdditionalFieldsType.selectedVaccines
                  .toValue())
          ?.value
          .split('.')
          .toList();
      // ignore: avoid_dynamic_calls
      noSelectedVaccines = lastVaccinationTask.last.additionalFields!.fields
          .firstWhereOrNull((e) =>
              e.key ==
              additional_fields_local.AdditionalFieldsType.noSelectedVaccines
                  .toValue())
          ?.value
          .split('.')
          .toList();
      setState(() {
        selectedCodes = yesSelectedVaccines;
        noSelectedCodes = noSelectedVaccines;
      });
    }
  }

  bool isVaccineAllowedToShow({
    required String vaccineCode,
    required List<String> allVaccineCodes,
  }) {
    final match = RegExp(r'^(.*?)([_-])(\d+)$').firstMatch(vaccineCode);

    // Vaccine code is not versioned (like just 'BCG'), allow by default
    if (match == null) {
      return true;
    }

    final base = match.group(1)!;
    final sep = match.group(2)!;
    final number = int.tryParse(match.group(3)!);

    // Either no number or first dose — allow
    if (number == null || number == 0) {
      return true;
    }

    final prevCode = '$base$sep${number - 1}';

    // If there's no previous code, allow by default
    if (allVaccineCodes.contains(prevCode) == false) {
      return true;
    }

    // Allow only if previous code was selected as "YES"
    return selectedCodes.contains(prevCode);
  }

  void saveResponses(Map<String, String?> responses) {
    final newlyNoSelected = <String>[];
    for (var entry in responses.entries) {
      final key = entry.key;
      final value = entry.value;

      if (value == _yes) {
        // Remove from "no" if present
        noSelectedCodes.remove(key);
        // Add to "yes" if not present
        if (!selectedCodes.contains(key)) {
          selectedCodes.add(key);
        }
      } else if (value == _no) {
        // Remove from "yes" if present
        if (selectedCodes.remove(key)) {
          // Moved from yes to no then add to newlyNoSeleced ones
          newlyNoSelected.add(key);
        }
        // Add to "no" if not present
        if (!noSelectedCodes.contains(key)) {
          noSelectedCodes.add(key);
        }
      }
    }

    // Now remove dependent vaccines of the changed ones from selectedCodes to noSelectedCodes
    for (final removedCode in newlyNoSelected) {
      final match = RegExp(r'^(.*?)([_-])(\d+)$').firstMatch(removedCode);
      if (match != null) {
        final base = match.group(1)!;
        final sep = match.group(2)!;
        final num = int.tryParse(match.group(3)!);
        if (num != null) {
          // Remove all higher versioned vaccines (e.g., VPO-1, VPO-2)
          final dependentCodesToRemove = selectedCodes.where((code) {
            final m = RegExp(r'^(.*?)([_-])(\d+)$').firstMatch(code);
            if (m == null) return false;
            final b = m.group(1);
            final s = m.group(2);
            final n = int.tryParse(m.group(3)!);
            return b == base && s == sep && n != null && n > num;
          }).toList();

          for (final dependent in dependentCodesToRemove) {
            selectedCodes.remove(dependent);
            if (!noSelectedCodes.contains(dependent)) {
              noSelectedCodes.add(dependent);
            }
          }
        }
      }
    }
  }

  bool isValid({
    required Map<String, String?> responses,
    required List<String> allVaccineCodes,
    required List<String> vaccineCodes,
  }) {
    for (int i = 0; i < vaccineCodes.length; i++) {
      String vaccineCode = vaccineCodes[i];
      if (isVaccineAllowedToShow(
          vaccineCode: vaccineCode, allVaccineCodes: allVaccineCodes)) {
        if (responses[vaccineCode] == null) {
          return false;
        }
      }
    }

    return true;
  }

  String _numberToWords(int number) {
    // Simple mapping for numbers 0-6, extend as needed
    const words = [
      'Zero',
      'One',
      'Two',
      'Three',
      'Four',
      'Five',
      'Six',
    ];
    if (number >= 0 && number < words.length) {
      return words[number];
    }
    return number.toString();
  }

  Widget _buildVaccineRadioChecklist({
    required int index,
    required BuildContext context,
    required Map<String, String> vaccineCodeToName,
    required Map<String, String?> vaccineResponses,
    required List<String> vaccineCodes,
  }) {
    final localizations = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return DigitCard(
      padding: const EdgeInsets.fromLTRB(spacer4, spacer4, spacer4, spacer8),
      margin: const EdgeInsets.fromLTRB(spacer3, spacer4, spacer3, spacer4),
      children: [
        Text(
            localizations.translate(
              '${i18_local.deliverIntervention.vaccinsSelectionLabelForGroup}_${_numberToWords(index).toUpperCase()}',
            ),
            style: theme.textTheme.headlineLarge),
        const SizedBox(height: spacer4),
        Column(
          children: [
            for (int i = 0; i < vaccineCodes.length; i++) ...{
              Container(
                height: 50,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.black,
                  ),
                ),
                child: StatefulBuilder(
                  builder: (context, setState) {
                    String vaccineCode = vaccineCodes[i];
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const SizedBox(
                          width: spacer3,
                        ),
                        Expanded(
                          child: Text(vaccineCodeToName[vaccineCode] ?? '',
                              style: theme.textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.w900,
                              )),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                vaccineResponses[vaccineCode] = _yes;
                              });
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Radio<String>(
                                  value: _yes,
                                  groupValue: vaccineResponses[vaccineCode],
                                  onChanged: (value) {
                                    setState(() {
                                      vaccineResponses[vaccineCode] = value!;
                                    });
                                  },
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  visualDensity: VisualDensity.compact,
                                ),
                                const SizedBox(
                                  width: spacer1,
                                ),
                                Flexible(
                                  child: Text(
                                    localizations.translate(i18_local
                                        .householdDetails.capitalYesLabelText),
                                    overflow: TextOverflow.ellipsis,
                                    softWrap: false,
                                    style:
                                        Theme.of(context).textTheme.titleMedium,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                vaccineResponses[vaccineCode] = _no;
                              });
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Radio<String>(
                                  value: _no,
                                  groupValue: vaccineResponses[vaccineCode],
                                  onChanged: (value) {
                                    setState(() {
                                      vaccineResponses[vaccineCode] = value!;
                                    });
                                  },
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  visualDensity: VisualDensity.compact,
                                ),
                                const SizedBox(
                                  width: spacer1,
                                ),
                                Flexible(
                                  child: Text(
                                    localizations.translate(i18_local
                                        .householdDetails.capitalNoLabelText),
                                    overflow: TextOverflow.ellipsis,
                                    softWrap: false,
                                    style:
                                        Theme.of(context).textTheme.titleMedium,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(
                height: spacer4,
              ),
            }
          ],
        ),
      ],
    );
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
              // setState(() {
              //   selectedCodes = selectedCodesString.split('.').toList();
              // });
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

        final allVaccineCodes = vaccineDataList.map((e) => e.code).toList();

        // final Map<String, int> vaccineAgeMap = {
        //   for (final v in vaccineDataList) v.code: v.ageInDays
        // };

        final Map<String, String> vaccineCodeToName = {
          for (final v in vaccineDataList) v.code: v.name
        };

        final List<int> ageList =
            vaccineDataList.map((e) => e.ageInDays).toSet().toList()..sort();

        int lastIndex = ageList.length - 1;
        for (int age in ageList) {
          if (age > ageInDays) {
            lastIndex = ageList.indexOf(age) - 1;
            break;
          }
        }

        final Map<int, List<String>> ageToVaccineCodes = {};
        for (final v in vaccineDataList) {
          ageToVaccineCodes.putIfAbsent(v.ageInDays, () => []);
          ageToVaccineCodes[v.ageInDays]!.add(v.code);
        }

        Map<String, String?> currentResponses = {};
        List<String> currentVaccineCodes = [];
        for (int i = 0;
            i < ageToVaccineCodes[ageList[currentIndex]]!.length;
            i++) {
          String vaccineCode = ageToVaccineCodes[ageList[currentIndex]]![i];
          if (isVaccineAllowedToShow(
              vaccineCode: vaccineCode, allVaccineCodes: allVaccineCodes)) {
            currentVaccineCodes.add(
              vaccineCode,
            );
          }
        }

        if (currentVaccineCodes.isEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            setState(() {
              currentIndex++;
            });
          });
          return const SizedBox.shrink();
        }

        for (int i = 0; i < currentVaccineCodes.length; i++) {
          String vaccineCode = currentVaccineCodes[i];
          if (selectedCodes.contains(vaccineCode)) {
            currentResponses[vaccineCode] = _yes;
          } else if (noSelectedCodes.contains(vaccineCode)) {
            currentResponses[vaccineCode] = _no;
          }
        }

        if (currentIndex < lastIndex) {
          return ScrollableContent(
            header: const Column(children: [
              CustomBackNavigationHelpHeaderWidget(
                showHelp: false,
              )
            ]),
            enableFixedDigitButton: true,
            footer: DigitCard(
              margin: const EdgeInsets.fromLTRB(0, kPadding, 0, 0),
              padding: const EdgeInsets.fromLTRB(kPadding, 0, kPadding, 0),
              children: [
                DigitElevatedButton(
                  onPressed: () async {
                    if (!isValid(
                        responses: currentResponses,
                        allVaccineCodes: allVaccineCodes,
                        vaccineCodes: currentVaccineCodes)) {
                      await DigitToast.show(
                        context,
                        options: DigitToastOptions(
                          localizations.translate(
                            i18.common.corecommonRequired,
                          ),
                          true,
                          theme,
                        ),
                      );
                      return;
                    }
                    saveResponses(currentResponses);
                    setState(() {
                      currentIndex++;
                    });
                  },
                  child: Text(
                    localizations.translate(i18.common.coreCommonNext),
                  ),
                )
              ],
            ),
            children: [
              _buildVaccineRadioChecklist(
                context: context,
                index: currentIndex,
                vaccineCodeToName: vaccineCodeToName,
                vaccineResponses: currentResponses,
                vaccineCodes: currentVaccineCodes,
              ),
            ],
          );
        }

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
                                    if (!isValid(
                                        responses: currentResponses,
                                        allVaccineCodes: allVaccineCodes,
                                        vaccineCodes: currentVaccineCodes)) {
                                      await DigitToast.show(
                                        context,
                                        options: DigitToastOptions(
                                          localizations.translate(
                                            i18.common.corecommonRequired,
                                          ),
                                          true,
                                          theme,
                                        ),
                                      );
                                      return;
                                    }
                                    saveResponses(currentResponses);

                                    submitTriggered = true;
                                    final itemsAttributes = initialAttributes;

                                    final nonEmptySelectedCodes = selectedCodes
                                        .where((e) => e.trim().isNotEmpty)
                                        .toList();

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
                                        controller[i].text =
                                            (nonEmptySelectedCodes.isNotEmpty
                                                ? nonEmptySelectedCodes
                                                    .join('.')
                                                : 'NOT_SELECTED');
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
                                    triggerLocalization = true;

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
                                          action: (ctx) {
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
                                                            // AdditionalField(
                                                            //   'vaccinationsuccessful',
                                                            //   isVaccinationSuccessful,
                                                            // ),
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
                                          if (selectedCodes.isNotEmpty)
                                            AdditionalField(
                                              additional_fields_local
                                                  .AdditionalFieldsType
                                                  .selectedVaccines
                                                  .toValue(),
                                              selectedCodes.join('.'),
                                            ),
                                          if (noSelectedCodes.isNotEmpty)
                                            AdditionalField(
                                              additional_fields_local
                                                  .AdditionalFieldsType
                                                  .noSelectedVaccines
                                                  .toValue(),
                                              noSelectedCodes.join('.'),
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
                                              AdditionalField(
                                                additional_fields_local
                                                    .AdditionalFieldsType
                                                    .selectedVaccines
                                                    .toValue(),
                                                selectedCodes.join('.'),
                                              ),
                                              AdditionalField(
                                                additional_fields_local
                                                    .AdditionalFieldsType
                                                    .noSelectedVaccines
                                                    .toValue(),
                                                noSelectedCodes.join('.'),
                                              ),
                                              ...getIndividualAdditionalFields(
                                                  widget.individual)
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
                              _buildVaccineRadioChecklist(
                                context: context,
                                index: currentIndex,
                                vaccineCodeToName: vaccineCodeToName,
                                vaccineResponses: currentResponses,
                                vaccineCodes: currentVaccineCodes,
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

int calculateAgeInDaysFromDob(String dobString) {
  final dob = DigitDateUtils.getFormattedDateToDateTime(dobString);
  if (dob == null) return 0;
  final now = DateTime.now();
  return now.difference(dob).inDays;
}
