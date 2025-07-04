import 'dart:math';

import 'package:auto_route/auto_route.dart';
import 'package:collection/collection.dart';
import 'package:digit_components/widgets/digit_text_field.dart';
import 'package:digit_data_model/data_model.dart';
import 'package:digit_ui_components/digit_components.dart';
import 'package:digit_ui_components/models/RadioButtonModel.dart';
import 'package:digit_ui_components/theme/digit_extended_theme.dart';
import 'package:digit_ui_components/widgets/atoms/input_wrapper.dart';
import 'package:digit_ui_components/widgets/atoms/pop_up_card.dart';
import 'package:digit_ui_components/widgets/molecules/digit_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:referral_reconciliation/router/referral_reconciliation_router.gm.dart';
import 'package:health_campaign_field_worker_app/router/app_router.dart';
import 'package:referral_reconciliation/router/referral_reconciliation_router.gm.dart';
import 'package:referral_reconciliation/utils/constants.dart';
import 'package:referral_reconciliation/utils/extensions/extensions.dart';
import 'package:survey_form/survey_form.dart';

import 'package:referral_reconciliation/blocs/referral_recon_service_definition.dart';
import 'package:referral_reconciliation/utils/date_utils.dart';
import 'package:referral_reconciliation/utils/i18_key_constants.dart' as i18;
import 'package:survey_form/utils/i18_key_constants.dart' as i18_survey_form;
import '../../utils/i18_key_constants.dart' as i18_local;
import 'package:referral_reconciliation/utils/utils.dart';
import 'package:referral_reconciliation/widgets/localized.dart';

@RoutePage()
class CustomReferralReasonChecklistPage extends LocalizedStatefulWidget {
  final String? referralClientRefId;

  const CustomReferralReasonChecklistPage({
    super.key,
    this.referralClientRefId,
    super.appLocalizations,
  });

  @override
  State<CustomReferralReasonChecklistPage> createState() =>
      _CustomReferralReasonChecklistPageState();
}

class _CustomReferralReasonChecklistPageState
    extends LocalizedState<CustomReferralReasonChecklistPage> {
  String isStateChanged = '';
  var submitTriggered = false;
  List<TextEditingController> controller = [];
  List<TextEditingController> additionalController = [];
  List<AttributesModel>? initialAttributes;
  ServiceDefinitionModel? selectedServiceDefinition;
  bool isControllersInitialized = false;
  List<int> visibleChecklistIndexes = [];
  GlobalKey<FormState> checklistFormKey = GlobalKey<FormState>();
  String othersText = "OTHERS";
  String multiSelectionSeparator = ".";

  @override
  void initState() {
    context.read<ServiceBloc>().add(
          ServiceSurveyFormEvent(
            value: Random().nextInt(100).toString(),
            submitTriggered: true,
          ),
        );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.digitTextTheme(context);

    return PopScope(
      canPop: false,
      child: Scaffold(
        body: BlocBuilder<ReferralReconServiceDefinitionBloc,
            ReferralReconServiceDefinitionState>(
          builder: (context, state) {
            state.mapOrNull(
              serviceDefinitionFetch: (value) {
                selectedServiceDefinition = value.selectedServiceDefinition;
                initialAttributes = value.selectedServiceDefinition?.attributes;
                if (!isControllersInitialized) {
                  initialAttributes?.forEach((e) {
                    controller.add(TextEditingController());
                    additionalController.add(TextEditingController());
                  });

                  // Set the flag to true after initializing controllers
                  isControllersInitialized = true;
                }
              },
            );

            return state.maybeMap(
              orElse: () => Text(state.runtimeType.toString()),
              serviceDefinitionFetch: (value) {
                return ScrollableContent(
                  enableFixedDigitButton: true,
                  footer: DigitCard(
                      cardType: CardType.primary,
                      margin: const EdgeInsets.only(top: spacer2),
                      children: [
                        DigitButton(
                          size: DigitButtonSize.large,
                          label: localizations
                              .translate(i18.common.coreCommonSubmit),
                          type: DigitButtonType.primary,
                          mainAxisSize: MainAxisSize.max,
                          onPressed: () async {
                            final router = context.router;
                            submitTriggered = true;

                            context.read<ServiceBloc>().add(
                                  const ServiceSurveyFormEvent(
                                    value: '',
                                    submitTriggered: true,
                                  ),
                                );
                            final isValid =
                                checklistFormKey.currentState?.validate();
                            if (!isValid!) {
                              return;
                            }
                            final itemsAttributes = initialAttributes;
                            final parentIndexes = <int>[];
                            for (int i = 0;
                                i < initialAttributes!.length;
                                i++) {
                              if (initialAttributes![i]
                                      .code!
                                      .split('.')
                                      .length ==
                                  1) {
                                parentIndexes.add(i);
                              }
                            }

                            for (int i in parentIndexes) {
                              if (itemsAttributes?[i].required == true &&
                                  ((itemsAttributes?[i].dataType ==
                                              'SingleValueList' &&
                                          visibleChecklistIndexes
                                              .any((e) => e == i) &&
                                          (controller[i].text == '')) ||
                                      (itemsAttributes?[i].dataType !=
                                              'SingleValueList' &&
                                          (controller[i].text == '' &&
                                              (widget.referralClientRefId !=
                                                  null))))) {
                                return;
                              }
                            }

                            final shouldSubmit = await showDialog(
                                context: context,
                                builder: (BuildContext ctx) {
                                  return Popup(
                                    title: localizations.translate(
                                      i18.checklist.checklistDialogLabel,
                                    ),
                                    description: localizations.translate(
                                      i18.checklist.checklistDialogDescription,
                                    ),
                                    actions: [
                                      DigitButton(
                                        label: localizations.translate(
                                          i18.checklist
                                              .checklistDialogPrimaryAction,
                                        ),
                                        type: DigitButtonType.primary,
                                        size: DigitButtonSize.large,
                                        onPressed: () {
                                          List<ServiceAttributesModel>
                                              attributes = [];
                                          var referenceId = IdGen.i.identifier;
                                          for (int i = 0;
                                              i < controller.length;
                                              i++) {
                                            final attribute = initialAttributes;
                                            String? additionalDetailValue =
                                                ((attribute?[i]
                                                                .values
                                                                ?.firstWhereOrNull(
                                                                  (element) =>
                                                                      element
                                                                          .toUpperCase() ==
                                                                      othersText,
                                                                ) !=
                                                            null &&
                                                        controller[i]
                                                                .text
                                                                .split(
                                                                  multiSelectionSeparator,
                                                                )
                                                                .firstWhereOrNull(
                                                                  (element) =>
                                                                      element
                                                                          .toUpperCase() ==
                                                                      othersText,
                                                                ) !=
                                                            null))
                                                    ? additionalController[i]
                                                            .text
                                                            .toString()
                                                            .isEmpty
                                                        ? null
                                                        : additionalController[
                                                                i]
                                                            .text
                                                            .toString()
                                                    : null;
                                            attributes
                                                .add(ServiceAttributesModel(
                                              attributeCode:
                                                  '${attribute?[i].code}',
                                              dataType: attribute?[i].dataType,
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
                                                          .substring(1)
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
                                                                  .trim()
                                                                  .isNotEmpty
                                                              ? controller[i]
                                                                  .text
                                                                  .toString()
                                                              : i18_survey_form
                                                                  .surveyForm
                                                                  .notSelectedKey
                                                          : i18_survey_form
                                                              .surveyForm
                                                              .notSelectedKey,
                                              rowVersion: 1,
                                              additionalDetails:
                                                  additionalDetailValue,
                                              additionalFields:
                                                  additionalDetailValue != null
                                                      ? ServiceAttributesAdditionalFields(
                                                          version: 1,
                                                          fields: [
                                                              AdditionalField(
                                                                  'additionalValue',
                                                                  additionalDetailValue)
                                                            ])
                                                      : null,
                                              tenantId: attribute?[i].tenantId,
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
                                                        dateFormat:
                                                            defaultDateTimeFormat,
                                                      ),
                                                      tenantId: value
                                                          .selectedServiceDefinition!
                                                          .tenantId,
                                                      clientId: referenceId,
                                                      relatedClientReferenceId:
                                                          widget
                                                              .referralClientRefId,
                                                      serviceDefId: value
                                                          .selectedServiceDefinition
                                                          ?.id,
                                                      attributes: attributes,
                                                      rowVersion: 1,
                                                      accountId:
                                                          ReferralReconSingleton()
                                                              .projectId,
                                                      auditDetails:
                                                          AuditDetails(
                                                        createdBy:
                                                            ReferralReconSingleton()
                                                                .userUUid,
                                                        createdTime: context
                                                            .millisecondsSinceEpoch(),
                                                        lastModifiedBy:
                                                            ReferralReconSingleton()
                                                                .userUUid,
                                                        lastModifiedTime: context
                                                            .millisecondsSinceEpoch(),
                                                      ),
                                                      clientAuditDetails:
                                                          ClientAuditDetails(
                                                        createdBy:
                                                            ReferralReconSingleton()
                                                                .userUUid,
                                                        createdTime: context
                                                            .millisecondsSinceEpoch(),
                                                        lastModifiedBy:
                                                            ReferralReconSingleton()
                                                                .userUUid,
                                                        lastModifiedTime: context
                                                            .millisecondsSinceEpoch(),
                                                      ),
                                                      additionalFields:
                                                          ServiceAdditionalFields(
                                                              version: 1,
                                                              fields: [
                                                            AdditionalField(
                                                                'relatedClientReferenceId',
                                                                widget
                                                                    .referralClientRefId),
                                                            AdditionalField(
                                                                'boundaryCode',
                                                                SurveyFormSingleton()
                                                                    .boundary
                                                                    ?.code)
                                                          ])),
                                                ),
                                              );

                                          Navigator.of(
                                            context,
                                            rootNavigator: true,
                                          ).pop(true);
                                        },
                                      ),
                                      DigitButton(
                                        label: localizations.translate(
                                          i18.checklist
                                              .checklistDialogSecondaryAction,
                                        ),
                                        type: DigitButtonType.secondary,
                                        size: DigitButtonSize.large,
                                        onPressed: () {
                                          Navigator.of(
                                            context,
                                            rootNavigator: true,
                                          ).pop(false);
                                        },
                                      )
                                    ],
                                  );
                                });

                            if (shouldSubmit ?? false) {
                              router.maybePop();
                              router.push(ReferralReconAcknowledgementRoute());
                            }
                          },
                        ),
                      ]),
                  children: [
                    Form(
                      key: checklistFormKey, //assigning key to form
                      child: DigitCard(
                          cardType: CardType.primary,
                          margin: const EdgeInsets.all(spacer2),
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Text(
                                '${localizations.translate(
                                  value.selectedServiceDefinition!.code
                                      .toString(),
                                )} ${localizations.translate(i18.checklist.checklist)}',
                                style: textTheme.headingXl,
                                textAlign: TextAlign.left,
                              ),
                            ),
                            ...initialAttributes!.map((
                              e,
                            ) {
                              int index = (initialAttributes ?? []).indexOf(e);

                              return Column(children: [
                                if (e.dataType == 'String' &&
                                    !(e.code ?? '').contains('.')) ...[
                                  FormField<String>(validator: (value) {
                                    if (((controller[index].text == '') &&
                                        e.required == true)) {
                                      return localizations
                                          .translate("${e.code}_REQUIRED");
                                    }
                                    if (e.regex != null) {
                                      return (RegExp(e.regex!)
                                              .hasMatch(controller[index].text))
                                          ? null
                                          : localizations
                                              .translate("${e.code}_REGEX");
                                    }

                                    return null;
                                  }, builder: (FormFieldState<String> field) {
                                    return InputField(
                                      onChange: (value) {
                                        controller[index].text = value;
                                        checklistFormKey.currentState
                                            ?.validate();
                                      },
                                      errorMessage: field.errorText,
                                      isRequired: false,
                                      controller: controller[index],
                                      inputFormatters: [
                                        FilteringTextInputFormatter.allow(
                                            RegExp(
                                          "[a-zA-Z0-9]",
                                        )),
                                      ],
                                      type: InputType.text,
                                      label: localizations.translate(
                                        '${value.selectedServiceDefinition?.code}.${e.code}',
                                      ),
                                    );
                                  })
                                ] else if (e.dataType == 'Number' &&
                                    !(e.code ?? '').contains('.')) ...[
                                  FormField<String>(validator: (value) {
                                    if (((controller[index].text == '') &&
                                        e.required == true)) {
                                      return localizations.translate(
                                        i18.common.corecommonRequired,
                                      );
                                    }
                                    if (e.regex != null) {
                                      return (RegExp(e.regex!)
                                              .hasMatch(controller[index].text))
                                          ? null
                                          : localizations
                                              .translate("${e.code}_REGEX");
                                    }

                                    return null;
                                  }, builder: (FormFieldState<String> field) {
                                    return InputField(
                                      onChange: (value) {
                                        controller[index].text = value;
                                        checklistFormKey.currentState
                                            ?.validate();
                                      },
                                      controller: controller[index],
                                      errorMessage: field.errorText,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.allow(
                                            RegExp(
                                          "[0-9]",
                                        )),
                                      ],
                                      type: InputType.text,
                                      keyboardType: TextInputType.number,
                                      label: '${localizations.translate(
                                            '${value.selectedServiceDefinition?.code}.${e.code}',
                                          ).trim()} ${e.required == true ? '*' : ''}',
                                    );
                                  })
                                ] else if (e.dataType == 'MultiValueList' &&
                                    !(e.code ?? '').contains('.')) ...[
                                  Align(
                                    alignment: Alignment.topLeft,
                                    child: Padding(
                                      padding: const EdgeInsets.all(8),
                                      child: Column(
                                        children: [
                                          Text(
                                            '${localizations.translate(
                                              '${value.selectedServiceDefinition?.code}.${e.code}',
                                            )} ${e.required == true ? '*' : ''}',
                                            style: textTheme.headingS,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  BlocBuilder<ServiceBloc, ServiceState>(
                                    builder: (context, state) {
                                      return Column(
                                        children: e.values!
                                            .where((e1) =>
                                                e1 !=
                                                i18_survey_form
                                                    .surveyForm.notSelectedKey)
                                            .toList()
                                            .map((e) => Column(
                                                  children: [
                                                    DigitCheckbox(
                                                      label: localizations
                                                          .translate(e),
                                                      value: controller[index]
                                                          .text
                                                          .split('.')
                                                          .contains(e),
                                                      onChanged: (value) {
                                                        context
                                                            .read<ServiceBloc>()
                                                            .add(
                                                              ServiceSurveyFormEvent(
                                                                value: e
                                                                    .toString(),
                                                                submitTriggered:
                                                                    submitTriggered,
                                                              ),
                                                            );
                                                        final String ele;
                                                        var val =
                                                            controller[index]
                                                                .text
                                                                .split('.');
                                                        if (val.contains(e)) {
                                                          val.remove(e);
                                                          ele = val.join(".");
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
                                                    ),
                                                    SizedBox(
                                                      height: theme
                                                          .spacerTheme.spacer3,
                                                    )
                                                  ],
                                                ))
                                            .toList(),
                                      );
                                    },
                                  ),
                                  BlocBuilder<ServiceBloc, ServiceState>(
                                    builder: (context, state) {
                                      return (e.values?.firstWhereOrNull(
                                                    (element) =>
                                                        element.toUpperCase() ==
                                                        othersText,
                                                  ) !=
                                                  null &&
                                              controller[index]
                                                  .text
                                                  .contains(othersText))
                                          ? Padding(
                                              padding: const EdgeInsets.only(
                                                left: 4.0,
                                                right: 4.0,
                                                bottom: 16,
                                              ),
                                              child: DigitTextField(
                                                maxLength: 1000,
                                                controller:
                                                    additionalController[index],
                                                label:
                                                    '${localizations.translate(
                                                  '${selectedServiceDefinition?.code}.${e.code}.ADDITIONAL_FIELD',
                                                )}*',
                                                validator: (value1) {
                                                  if (value1 == null ||
                                                      value1 == '') {
                                                    return localizations
                                                        .translate(
                                                      i18_local.common
                                                          .coreCommonOthersRequired,
                                                    );
                                                  }

                                                  return null;
                                                },
                                              ),
                                            )
                                          : const SizedBox();
                                    },
                                  ),
                                  BlocBuilder<ServiceBloc, ServiceState>(
                                    builder: (context, state) {
                                      final hasError = (e.required == true &&
                                          controller[index].text.isEmpty &&
                                          submitTriggered);

                                      return Offstage(
                                        offstage: !hasError,
                                        child: Align(
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            localizations.translate(
                                              i18.common.corecommonRequired,
                                            ),
                                            style: TextStyle(
                                              color: theme.colorScheme.error,
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ] else if (e.dataType == 'SingleValueList') ...[
                                  if (!(e.code ?? '').contains('.'))
                                    DigitCard(
                                        cardType: CardType.primary,
                                        children: [
                                          _buildChecklist(
                                            e,
                                            index,
                                            value.selectedServiceDefinition,
                                            context,
                                          ),
                                        ]),
                                ],
                              ]);
                            }),
                            const SizedBox(
                              height: 15,
                            ),
                          ]),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildChecklist(
    AttributesModel item,
    int index,
    ServiceDefinitionModel? selectedServiceDefinition,
    BuildContext context,
  ) {
    final theme = Theme.of(context);
    final textTheme = theme.digitTextTheme(context);

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
              padding: const EdgeInsets.all(16.0), // Add padding here
              child: Text(
                '${localizations.translate(
                  '${selectedServiceDefinition?.code}.${item.code}',
                )} ${item.required == true ? '*' : ''}',
                style: textTheme.headingS,
              ),
            ),
          ),
          Column(
            children: [
              BlocBuilder<ServiceBloc, ServiceState>(
                builder: (context, state) {
                  return Align(
                    alignment: Alignment.topLeft,
                    child: Padding(
                      padding: EdgeInsets.only(left: theme.spacerTheme.spacer2),
                      child: RadioList(
                        radioDigitButtons: item.values != null
                            ? item.values!
                                .where((e) => e != i18.checklist.notSelectedKey)
                                .map((e) => RadioButtonModel(
                                      code: e,
                                      name: localizations.translate(
                                          'CORE_COMMON_${e.trim().toUpperCase()}'),
                                    ))
                                .toList()
                            : [],
                        groupValue: controller[index].text.trim(),
                        onChanged: (selectedValue) {
                          context.read<ServiceBloc>().add(
                                ServiceSurveyFormEvent(
                                  value: Random().nextInt(100).toString(),
                                  submitTriggered: submitTriggered,
                                ),
                              );
                          setState(() {
                            controller[index].value =
                                TextEditingController.fromValue(
                              TextEditingValue(
                                text: selectedValue.code,
                              ),
                            ).value;
                          });
                        },
                        isDisabled: false, // Set this based on your logic
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
                      child: Padding(
                        padding: EdgeInsets.only(
                            left: theme.spacerTheme.spacer4,
                            bottom: theme.spacerTheme.spacer3),
                        child: Text(
                          localizations.translate(
                            i18.common.corecommonRequired,
                          ),
                          style: TextStyle(
                            color: theme.colorTheme.alert.error,
                          ),
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
        child: FormField<String>(
          validator: (value) {
            // Custom validation logic
            if (((controller[index].text == '') && item.required == true)) {
              return localizations.translate("${item.code}_REQUIRED");
            }
            if (item.regex != null) {
              return (RegExp(item.regex!).hasMatch(controller[index].text))
                  ? null
                  : localizations.translate("${item.code}_REGEX");
            }

            return null;
          },
          builder: (FormFieldState<String> field) {
            return InputField(
              onChange: (value) {
                controller[index].text = value;
                checklistFormKey.currentState?.validate();
              },
              errorMessage: field.errorText,
              isRequired: item.required ?? true,
              type: InputType.text,
              label: localizations.translate(
                '${selectedServiceDefinition?.code}.${item.code}',
              ),
              controller: controller[index],
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(
                  "[a-zA-Z0-9 ]",
                )),
              ],
            );
          },
        ),
      );
    } else if (item.dataType == 'Number') {
      return FormField<String>(validator: (value) {
        if (((controller[index].text == '') && item.required == true)) {
          return localizations.translate(
            i18.common.corecommonRequired,
          );
        }
        if (item.regex != null) {
          return (RegExp(item.regex!).hasMatch(controller[index].text))
              ? null
              : localizations.translate("${item.code}_REGEX");
        }

        return null;
      }, builder: (FormFieldState<String> field) {
        return InputField(
          onChange: (value) {
            controller[index].text = value;
            checklistFormKey.currentState?.validate();
          },
          controller: controller[index],
          errorMessage: field.errorText,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(
              "[0-9]",
            )),
          ],
          type: InputType.text,
          keyboardType: TextInputType.number,
          label: '${localizations.translate(
                '${selectedServiceDefinition?.code}.${item.code}',
              ).trim()} ${item.required == true ? '*' : ''}',
        );
      });
    } else if (item.dataType == 'MultiValueList') {
      return Column(children: [
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
                  style: textTheme.headingS,
                ),
              ],
            ),
          ),
        ),
        BlocBuilder<ServiceBloc, ServiceState>(builder: (context, state) {
          return Column(
            children: item.values!
                .where((e1) => e1 != i18_survey_form.surveyForm.notSelectedKey)
                .toList()
                .map((e) => Column(
                      children: [
                        DigitCheckbox(
                          label: e,
                          value: controller[index].text.split('.').contains(e),
                          onChanged: (value) {
                            context.read<ServiceBloc>().add(
                                  ServiceSurveyFormEvent(
                                    value: e.toString(),
                                    submitTriggered: submitTriggered,
                                  ),
                                );
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
                        ),
                        SizedBox(
                          height: theme.spacerTheme.spacer3,
                        )
                      ],
                    ))
                .toList(),
          );
        }),
        BlocBuilder<ServiceBloc, ServiceState>(
          builder: (context, state) {
            return item.values?.firstWhereOrNull(
                          (element) => element.toUpperCase() == othersText,
                        ) !=
                        null &&
                    controller[index].text.contains(othersText)
                ? Padding(
                    padding: const EdgeInsets.only(
                      left: 4.0,
                      right: 4.0,
                      bottom: 16,
                    ),
                    child: DigitTextField(
                      maxLength: 1000,
                      controller: additionalController[index],
                      label: '${localizations.translate(
                        '${selectedServiceDefinition?.code}.${item.code}.ADDITIONAL_FIELD',
                      )}*',
                      validator: (value1) {
                        if (value1 == null || value1 == '') {
                          return localizations.translate(
                            i18_local.common.coreCommonOthersRequired,
                          );
                        }

                        return null;
                      },
                    ),
                  )
                : const SizedBox();
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
                    i18.common.corecommonRequired,
                  ),
                  style: TextStyle(
                    color: theme.colorScheme.error,
                  ),
                ),
              ),
            );
          },
        ),
      ]);
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

    final theme = Theme.of(context);

    return Column(
      children: [
        // Build cards for each matching child attribute
        for (final matchingChildItem in childItems.where((childItem) =>
            childItem.code!.startsWith('$parentCode.$parentControllerValue.')))
          Card(
            margin: const EdgeInsets.only(bottom: 8.0, left: 4.0, right: 4.0),
            color: countDots(matchingChildItem.code ?? '') % 4 == 2
                ? const Color.fromRGBO(238, 238, 238, 1)
                : theme.colorTheme.paper.secondary,
            child: _buildChecklist(
              matchingChildItem,
              initialAttributes?.indexOf(matchingChildItem) ?? parentIndex,
              // Pass parentIndex here as we're building at the same level
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

  int countDots(String inputString) {
    int dotCount = 0;
    for (int i = 0; i < inputString.length; i++) {
      if (inputString[i] == '.') {
        dotCount++;
      }
    }

    return dotCount;
  }
}
