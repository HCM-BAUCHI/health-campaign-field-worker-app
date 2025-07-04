import 'package:collection/collection.dart';
import 'package:digit_components/widgets/atoms/digit_reactive_dropdown.dart';
// import 'package:digit_components/digit_components.dart';
import 'package:digit_components/widgets/atoms/digit_toaster.dart';
import 'package:digit_components/widgets/digit_dialog.dart' as digit_dialog;
import 'package:digit_components/widgets/digit_elevated_button.dart';
import 'package:digit_components/widgets/digit_text_field.dart';
import 'package:digit_data_model/data_model.dart';
import 'package:digit_ui_components/enum/app_enums.dart';
import 'package:digit_ui_components/utils/component_utils.dart';
import 'package:digit_ui_components/widgets/atoms/digit_numeric_form_input.dart';
import 'package:digit_ui_components/widgets/atoms/digit_text_form_input.dart';
import 'package:digit_ui_components/widgets/atoms/labelled_fields.dart';
import 'package:digit_ui_components/widgets/atoms/reactive_fields.dart';
import 'package:digit_ui_components/widgets/molecules/digit_card.dart';
import 'package:digit_ui_components/widgets/scrollable_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:registration_delivery/blocs/delivery_intervention/deliver_intervention.dart';
import 'package:registration_delivery/blocs/household_overview/household_overview.dart';
import 'package:registration_delivery/models/entities/status.dart';
import 'package:registration_delivery/models/entities/task.dart';
import 'package:registration_delivery/models/entities/task_resource.dart';
import 'package:registration_delivery/router/registration_delivery_router.gm.dart';
import 'package:registration_delivery/utils/utils.dart';
import 'package:registration_delivery/widgets/beneficiary/resource_beneficiary_card.dart';
import 'package:registration_delivery/widgets/component_wrapper/product_variant_bloc_wrapper.dart';

import 'package:registration_delivery/utils/i18_key_constants.dart' as i18;
import 'package:registration_delivery/widgets/showcase/showcase_wrappers.dart';

import '../../../blocs/app_initialization/app_initialization.dart';
import '../../../blocs/auth/auth.dart';
import '../../../blocs/project/project.dart';
import '../../../data/local_store/no_sql/schema/app_configuration.dart';
import '../../../router/app_router.dart';
import '../../../utils/app_enums.dart';
import '../../../utils/environment_config.dart';
import '../../../utils/i18_key_constants.dart' as i18_local;
import '../../../utils/utils.dart';
import '../../../widgets/header/back_navigation_help_header.dart';
import '../../../widgets/localized.dart';
import '../../../widgets/registration_delivery/custom_resourse_beneficiary_card.dart';

@RoutePage()
class RecordRedosePage extends LocalizedStatefulWidget {
  final bool isEditing;
  final List<TaskModel> tasks;

  const RecordRedosePage({
    super.key,
    super.appLocalizations,
    this.isEditing = false,
    required this.tasks,
  });

  @override
  State<RecordRedosePage> createState() => _RecordRedosePageState();
}

class _RecordRedosePageState extends LocalizedState<RecordRedosePage> {
  // Constants for form control keys
  static const _resourceDeliveredKey = 'resourceDelivered';
  static const _quantityDistributedKey = 'quantityDistributed';
  static const _doseAdministrationKey = 'doseAdministered';
  static const _dateOfAdministrationKey = 'dateOfAdministration';
  static const _doseAdministeredByKey = 'doseAdministeredBy';
  static const _deliveryCommentKey = 'deliveryComment';
  static const _otherDeliveryCommentKey = 'otherDeliveryComment';
  //static key for recording redose
  static const _reDoseQuantityKey = Constants.reDoseQuantityKey;

  bool otherDeliveryComment = false;

  // Variable to track dose administration status
  bool doseAdministered = true;

  bool isSubmitClicked = false;

  // List of controllers for form elements
  final List _controllers = [];

  // toggle doseAdministered
  void checkDoseAdministration(bool newValue) {
    setState(() {
      doseAdministered = newValue;
    });
  }

  void checkOtherDeliveryComment(bool newValue) {
    setState(() {
      otherDeliveryComment = newValue;
    });
  }

// Initialize the currentStep variable to keep track of the current step in a process.
  int currentStep = 0;

  List<ProductVariantsModel> _fetchProductVariant(
      ProjectState projectState,
      HouseholdOverviewState householdOverviewState,
      DeliverInterventionState deliveryInterventionstate) {
    DeliveryModel? deliveryModel = projectState
        .projectType!
        .cycles![deliveryInterventionstate.cycle - 1]
        .deliveries![deliveryInterventionstate.dose - 1];
    List<DeliveryProductVariant>? productVariants = fetchProductVariant(
      ProjectCycleDelivery(
        id: deliveryModel.id,
        deliveryStrategy: deliveryModel.deliveryStrategy!,
        doseCriteria: deliveryModel.doseCriteria
            ?.map((DoseCriteriaModel e) => DeliveryDoseCriteria(
                  condition: e.condition,
                  productVariants: e.productVariants
                      ?.map((e) => DeliveryProductVariant(
                            productVariantId: e.productVariantId!,
                            quantity: e.quantity,
                          ))
                      .toList(),
                ))
            .toList(),
        mandatoryWaitSinceLastDeliveryInDays: int.parse(
            deliveryModel.mandatoryWaitSinceLastDeliveryInDays ?? '0'),
      ),
      householdOverviewState.selectedIndividual,
      null,
    )?.productVariants;
    if (productVariants == null) {
      return [];
    }
    return productVariants
        .map((e) => ProductVariantsModel(
            productVariantId: e.productVariantId, quantity: e.quantity))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ProductVariantBlocWrapper(
      child: BlocBuilder<HouseholdOverviewBloc, HouseholdOverviewState>(
        builder: (context, householdOverviewState) {
          final projectState = context.read<ProjectBloc>().state;

          return Scaffold(
            body: householdOverviewState.loading
                ? const Center(child: CircularProgressIndicator())
                : BlocBuilder<DeliverInterventionBloc,
                    DeliverInterventionState>(
                    builder: (context, deliveryInterventionstate) {
                      List<ProductVariantsModel>? productVariants =
                          projectState.projectType?.cycles?.isNotEmpty == true
                              ? (_fetchProductVariant(
                                  projectState,
                                  householdOverviewState,
                                  deliveryInterventionstate))
                              : projectState.projectType?.resources;

                      return BlocBuilder<ProductVariantBloc,
                          ProductVariantState>(
                        builder: (context, productState) {
                          return productState.maybeWhen(
                            orElse: () => const Offstage(),
                            fetched: (productVariantsvalue) {
                              final variant = productState.whenOrNull(
                                fetched: (productVariants) {
                                  return productVariants;
                                },
                              );

                              return ReactiveFormBuilder(
                                form: () => buildForm(
                                  context,
                                  productVariants,
                                  variant,
                                ),
                                builder: (context, form, child) {
                                  return ScrollableContent(
                                    // enableFixedButton: true,
                                    footer: BlocBuilder<DeliverInterventionBloc,
                                        DeliverInterventionState>(
                                      builder: (context, state) {
                                        return DigitCard(
                                            margin: const EdgeInsets.fromLTRB(
                                                0, kPadding, 0, 0),
                                            padding: const EdgeInsets.fromLTRB(
                                                kPadding, 0, kPadding, 0),
                                            children: [
                                              DigitElevatedButton(
                                                onPressed: () async {
                                                  form.markAllAsTouched();

                                                  if (form
                                                              .control(
                                                                  _deliveryCommentKey)
                                                              .value ==
                                                          "Others" &&
                                                      (form
                                                                  .control(
                                                                      _otherDeliveryCommentKey)
                                                                  .value ==
                                                              null ||
                                                          form
                                                                  .control(
                                                                      _otherDeliveryCommentKey)
                                                                  .value ==
                                                              "")) {
                                                    await DigitToast.show(
                                                      context,
                                                      options:
                                                          DigitToastOptions(
                                                        localizations.translate(
                                                            i18_local
                                                                .deliverIntervention
                                                                .enterReasonForRedoseLabel),
                                                        true,
                                                        theme,
                                                      ),
                                                    );
                                                    return;
                                                  }
                                                  if (!form.valid) {
                                                    return;
                                                  }
                                                  if (((form.control(
                                                    _resourceDeliveredKey,
                                                  ) as FormArray)
                                                              .value
                                                          as List<
                                                              ProductVariantModel?>)
                                                      .any((ele) =>
                                                          ele?.productId ==
                                                          null)) {
                                                    await DigitToast.show(
                                                      context,
                                                      options:
                                                          DigitToastOptions(
                                                        localizations.translate(i18
                                                            .deliverIntervention
                                                            .resourceDeliveredValidation),
                                                        true,
                                                        theme,
                                                      ),
                                                    );
                                                  } else if ((((form.control(
                                                            _quantityDistributedKey,
                                                          ) as FormArray)
                                                              .value) ??
                                                          [])
                                                      .any((e) => e == 0)) {
                                                    await DigitToast.show(
                                                      context,
                                                      options:
                                                          DigitToastOptions(
                                                        localizations.translate(i18
                                                            .deliverIntervention
                                                            .resourceCannotBeZero),
                                                        true,
                                                        theme,
                                                      ),
                                                    );
                                                  } else {
                                                    // get the latest successful task
                                                    if (!isSubmitClicked) {
                                                      isSubmitClicked = true;
                                                      // get the latest successful task
                                                      var successfulTask = widget
                                                          .tasks
                                                          .where((element) =>
                                                              element.status ==
                                                              Status
                                                                  .administeredSuccess
                                                                  .toValue())
                                                          .lastOrNull;
                                                      // Extract productvariantList from the form
                                                      final productvariantList =
                                                          ((form.control(_resourceDeliveredKey)
                                                                      as FormArray)
                                                                  .value
                                                              as List<
                                                                  ProductVariantModel?>);

                                                      var quantityDistributedFormArray =
                                                          form.control(
                                                        _quantityDistributedKey,
                                                      ) as FormArray?;

                                                      if (successfulTask !=
                                                              null &&
                                                          quantityDistributedFormArray !=
                                                              null) {
                                                        var updatedTask =
                                                            updateTask(
                                                          successfulTask,
                                                          productvariantList,
                                                          quantityDistributedFormArray,
                                                          form,
                                                        );
                                                        var newTask =
                                                            getNewTask(
                                                          context,
                                                          updatedTask,
                                                        );

                                                        if (true) {
                                                          if (context.mounted) {
                                                            int spaq1 = 0;
                                                            int spaq2 = 0;
                                                            int blueVas = 0;
                                                            int redVas = 0;

                                                            var productVariantId =
                                                                updatedTask
                                                                    .resources!
                                                                    .first
                                                                    .productVariantId;
                                                            final productVariant =
                                                                productvariantList
                                                                    .where((element) =>
                                                                        element
                                                                            ?.id ==
                                                                        productVariantId)
                                                                    .firstOrNull;

                                                            var quantityIndex =
                                                                productvariantList
                                                                    .indexOf(
                                                              productVariant,
                                                            );

                                                            final quantity = quantityIndex <
                                                                    0
                                                                ? 0
                                                                : quantityDistributedFormArray
                                                                    .value![
                                                                        quantityIndex]
                                                                    .toString()
                                                                    .split(
                                                                        " ")[0];

                                                            if (productVariant!
                                                                    ?.sku! ==
                                                                'SPAQ 1') {
                                                              spaq1 = quantity !=
                                                                      'null'
                                                                  ? int.parse(quantity
                                                                          .toString()) *
                                                                      -1
                                                                  : 0;
                                                            } else if (productVariant
                                                                    ?.sku! ==
                                                                'SPAQ 2') {
                                                              spaq2 = quantity !=
                                                                      'null'
                                                                  ? int.parse(quantity
                                                                          .toString()) *
                                                                      -1
                                                                  : 0;
                                                            } else if (productVariant
                                                                    ?.sku! ==
                                                                'Blue VAS') {
                                                              blueVas = quantity !=
                                                                      'null'
                                                                  ? int.parse(quantity
                                                                          .toString()) *
                                                                      -1
                                                                  : 0;
                                                            } else {
                                                              redVas = quantity !=
                                                                      'null'
                                                                  ? int.parse(quantity
                                                                          .toString()) *
                                                                      -1
                                                                  : 0;
                                                            }

                                                            // spaq1 = quantity !=
                                                            //         'null'
                                                            //     ? int.parse(quantity
                                                            //             .toString()) *
                                                            //         -1
                                                            //     : 0;

                                                            context
                                                                .read<
                                                                    AuthBloc>()
                                                                .add(
                                                                  AuthAddSpaqCountsEvent(
                                                                    spaq1Count:
                                                                        spaq1,
                                                                    spaq2Count:
                                                                        spaq2,
                                                                    // TODO: need to work here [pitabash]
                                                                    blueVasCount:
                                                                        blueVas,
                                                                    redVasCount:
                                                                        redVas,
                                                                  ),
                                                                );
                                                            final reloadState =
                                                                context.read<
                                                                    HouseholdOverviewBloc>();
                                                            // submit the updated task

                                                            context
                                                                .read<
                                                                    DeliverInterventionBloc>()
                                                                .add(
                                                                  DeliverInterventionSubmitEvent(
                                                                    task:
                                                                        updatedTask,
                                                                    isEditing:
                                                                        true,
                                                                    boundaryModel:
                                                                        context
                                                                            .boundary,
                                                                  ),
                                                                );
                                                            // submit the newly created task
                                                            context
                                                                .read<
                                                                    DeliverInterventionBloc>()
                                                                .add(
                                                                  DeliverInterventionSubmitEvent(
                                                                    task:
                                                                        newTask,
                                                                    isEditing:
                                                                        false,
                                                                    boundaryModel:
                                                                        context
                                                                            .boundary,
                                                                  ),
                                                                );

                                                            Future.delayed(
                                                              const Duration(
                                                                milliseconds:
                                                                    300,
                                                              ),
                                                              () {
                                                                reloadState.add(
                                                                  HouseholdOverviewReloadEvent(
                                                                    projectId:
                                                                        context
                                                                            .projectId,
                                                                    projectBeneficiaryType:
                                                                        context
                                                                            .beneficiaryType,
                                                                  ),
                                                                );
                                                              },
                                                            ).then((value) => {
                                                                  context.router
                                                                      .push(
                                                                    CustomHouseholdAcknowledgementRoute(
                                                                      enableViewHousehold:
                                                                          true,
                                                                      eligibilityAssessmentType:
                                                                          EligibilityAssessmentType
                                                                              .smc,
                                                                    ),
                                                                  ),
                                                                });
                                                          }
                                                        }
                                                      }
                                                    }
                                                  }
                                                },
                                                child: Center(
                                                  child: Text(
                                                    localizations.translate(
                                                      i18.common
                                                          .coreCommonSubmit,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ]);
                                      },
                                    ),
                                    header: const Column(children: [
                                      BackNavigationHelpHeaderWidget(
                                        showHelp: false,
                                      ),
                                    ]),
                                    children: [
                                      Column(
                                        children: [
                                          DigitCard(children: [
                                            Padding(
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                kPadding * 2,
                                                kPadding,
                                                kPadding * 2,
                                                0,
                                              ),
                                              child: Row(
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      localizations.translate(
                                                        i18_local
                                                            .deliverIntervention
                                                            .recordRedoseLabel,
                                                      ),
                                                      style: theme.textTheme
                                                          .displayMedium,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ]),
                                          const SizedBox(height: 16),
                                          DigitCard(children: [
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text(
                                                  localizations.translate(
                                                    i18.deliverIntervention
                                                        .deliverInterventionResourceLabel,
                                                  ),
                                                  style: theme
                                                      .textTheme.headlineLarge,
                                                ),
                                                ..._controllers
                                                    .map((e) =>
                                                        CustomResourceBeneficiaryCard(
                                                          form: form,
                                                          cardIndex:
                                                              _controllers
                                                                  .indexOf(
                                                            e,
                                                          ),
                                                          totalItems:
                                                              _controllers
                                                                  .length,
                                                          isAdministered:
                                                              doseAdministered,
                                                          onDelete: (index) {
                                                            (form.control(
                                                              _resourceDeliveredKey,
                                                            ) as FormArray)
                                                                .removeAt(
                                                              index,
                                                            );
                                                            (form.control(
                                                              _quantityDistributedKey,
                                                            ) as FormArray)
                                                                .removeAt(
                                                              index,
                                                            );
                                                            _controllers
                                                                .removeAt(
                                                              index,
                                                            );
                                                            setState(() {
                                                              _controllers;
                                                            });
                                                          },
                                                        ))
                                                    .toList(),
                                              ],
                                            ),
                                          ]),
                                          DigitCard(children: [
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                BlocBuilder<
                                                    AppInitializationBloc,
                                                    AppInitializationState>(
                                                  builder: (context, state) {
                                                    if (state
                                                        is! AppInitialized) {
                                                      return const Offstage();
                                                    }

                                                    final deliveryCommentOptions = state
                                                            .appConfiguration
                                                            .deliveryCommentOptions ??
                                                        <DeliveryCommentOptions>[];

                                                    // return DigitReactiveDropdown<
                                                    //     String>(
                                                    //   label: localizations
                                                    //       .translate(
                                                    //     i18_local
                                                    //         .deliverIntervention
                                                    //         .reasonForRedoseLabel,
                                                    //   ),
                                                    //   isDisabled: false,
                                                    //   isRequired: true,
                                                    //   validationMessages: {
                                                    //     'required': (object) =>
                                                    //         localizations
                                                    //             .translate(
                                                    //           i18_local
                                                    //               .deliverIntervention
                                                    //               .selectReasonForRedoseLabel,
                                                    //         ),
                                                    //   },
                                                    //   valueMapper: (value) =>
                                                    //       localizations
                                                    //           .translate(
                                                    //     value,
                                                    //   ),
                                                    //   initialValue:
                                                    //       deliveryCommentOptions
                                                    //           .firstOrNull
                                                    //           ?.name,
                                                    //   menuItems:
                                                    //       deliveryCommentOptions
                                                    //           .map((e) {
                                                    //     return e.code;
                                                    //   }).toList(),
                                                    //   formControlName:
                                                    //       _deliveryCommentKey,
                                                    // );

                                                    return Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        DigitReactiveDropdown<
                                                            String>(
                                                          label: localizations
                                                              .translate(
                                                            i18_local
                                                                .deliverIntervention
                                                                .reasonForRedoseLabel,
                                                          ),
                                                          isDisabled: false,
                                                          isRequired: true,
                                                          validationMessages: {
                                                            'required': (object) =>
                                                                localizations
                                                                    .translate(
                                                                  i18_local
                                                                      .deliverIntervention
                                                                      .selectReasonForRedoseLabel,
                                                                ),
                                                          },
                                                          valueMapper: (value) =>
                                                              localizations
                                                                  .translate(
                                                                      value),
                                                          initialValue:
                                                              deliveryCommentOptions
                                                                  .firstOrNull
                                                                  ?.name,
                                                          onChanged: (value) {
                                                            if (value != null) {
                                                              if (value ==
                                                                  "Others") {
                                                                checkOtherDeliveryComment(
                                                                    true);
                                                              } else {
                                                                checkOtherDeliveryComment(
                                                                    false);
                                                              }
                                                            }
                                                          },
                                                          menuItems:
                                                              deliveryCommentOptions
                                                                  .map((e) {
                                                            return e.code;
                                                          }).toList(),
                                                          formControlName:
                                                              _deliveryCommentKey,
                                                        ),
                                                        Offstage(
                                                            offstage:
                                                                !otherDeliveryComment,
                                                            child: Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .only(
                                                                        top:
                                                                            12.0),
                                                                child:
                                                                    ReactiveWrapperField<
                                                                        String>(
                                                                  formControlName:
                                                                      _otherDeliveryCommentKey,
                                                                  showErrors: (control) =>
                                                                      control
                                                                          .touched ||
                                                                      control
                                                                          .invalid,
                                                                  validationMessages: {
                                                                    'required': (object) =>
                                                                        localizations.translate(i18_local
                                                                            .deliverIntervention
                                                                            .enterReasonForRedoseLabel),
                                                                    'minLength': (object) =>
                                                                        localizations.translate(i18_local
                                                                            .deliverIntervention
                                                                            .enterReasonForRedoseLabelMinLength),
                                                                    'maxLength': (object) =>
                                                                        localizations.translate(i18_local
                                                                            .deliverIntervention
                                                                            .enterReasonForRedoseLabelMaxLength),
                                                                  },
                                                                  builder:
                                                                      (field) {
                                                                    return LabeledField(
                                                                      isRequired:
                                                                          true,
                                                                      label: localizations
                                                                          .translate(
                                                                        i18_local
                                                                            .deliverIntervention
                                                                            .otherReasonLabel,
                                                                      ),
                                                                      child:
                                                                          DigitTextFormInput(
                                                                        isRequired:
                                                                            true,
                                                                        readOnly:
                                                                            false,
                                                                        onChange:
                                                                            (val) =>
                                                                                {
                                                                          form
                                                                              .control(
                                                                                _otherDeliveryCommentKey,
                                                                              )
                                                                              .markAllAsTouched(),
                                                                          form
                                                                              .control(
                                                                                _otherDeliveryCommentKey,
                                                                              )
                                                                              .value = val,
                                                                        },
                                                                        initialValue: form
                                                                            .control(
                                                                              _otherDeliveryCommentKey,
                                                                            )
                                                                            .value,
                                                                        errorMessage:
                                                                            field.errorText,
                                                                      ),
                                                                    );
                                                                  },
                                                                ))),
                                                      ],
                                                    );
                                                  },
                                                ),
                                              ],
                                            ),
                                          ]),
                                        ],
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
          );
        },
      ),
    );
  }

  addController(FormGroup form) {
    (form.control(_resourceDeliveredKey) as FormArray)
        .add(FormControl<ProductVariantModel>());
    (form.control(_quantityDistributedKey) as FormArray)
        .add(FormControl<String>(validators: [Validators.required]));
  }

  TaskModel updateTask(
    TaskModel oldTask,
    List<ProductVariantModel?> productvariantList,
    FormArray quantityDistributedFormArray,
    FormGroup form,
  ) {
    final taskResources = oldTask.resources ?? [];
    List<TaskResourceModel> updatedTaskResources = [];
    if (taskResources.isNotEmpty) {
      for (var resource in taskResources) {
        var productVariantId = resource.productVariantId;
        var productVariant = productvariantList
            .where((element) => element?.id == productVariantId)
            .firstOrNull;
        String quantity = "0";

        if (productVariant == null) {
          updatedTaskResources.add(resource);
          continue;
        }
        var quantityIndex = productvariantList.indexOf(productVariant);
        TaskResourceModel updatedResource;

        if (resource.additionalFields == null) {
          quantity = quantityDistributedFormArray.value![quantityIndex]
              .toString()
              .split(" ")[0];
          updatedResource = resource.copyWith(
            additionalFields: TaskResourceAdditionalFields(
              version: 1,
              fields: [
                const AdditionalField(Constants.reAdministeredKey, true),
                AdditionalField(_reDoseQuantityKey, quantity.toString()),
              ],
            ),
          );
        } else {
          List<AdditionalField> newAdditionalFields = [
            const AdditionalField(Constants.reAdministeredKey, true),
            AdditionalField(_reDoseQuantityKey, quantity.toString()),
          ];
          updatedResource = resource.additionalFields!.fields.isEmpty
              ? resource.copyWith(
                  additionalFields: resource.additionalFields!
                      .copyWith(fields: newAdditionalFields),
                )
              : resource.copyWith(
                  additionalFields: resource.additionalFields!.copyWith(
                    fields: [
                      ...resource.additionalFields!.fields,
                      ...newAdditionalFields,
                    ],
                  ),
                );
        }
        if (form.control(_deliveryCommentKey).value != null &&
            form.control(_deliveryCommentKey).value != "Others") {
          updatedResource = updatedResource.copyWith(
            deliveryComment: form.control(_deliveryCommentKey).value,
          );
        }
        if (form.control(_deliveryCommentKey).value != null &&
            form.control(_deliveryCommentKey).value == "Others" &&
            form.control(_otherDeliveryCommentKey).value != null) {
          updatedResource = updatedResource.copyWith(
            deliveryComment: form.control(_otherDeliveryCommentKey).value,
          );
        }
        updatedTaskResources.add(updatedResource);
      }
    }
    oldTask = oldTask.copyWith(
      resources: updatedTaskResources,
    );
    var updatedTask = oldTask.copyWith(
      additionalFields: oldTask.additionalFields != null
          ? TaskAdditionalFields(
              version: oldTask.additionalFields!.version,
              fields: [
                ...oldTask.additionalFields!.fields,
                const AdditionalField(Constants.reAdministeredKey, true),
              ],
            )
          : TaskAdditionalFields(
              version: 1,
              fields: [
                const AdditionalField(Constants.reAdministeredKey, true),
              ],
            ),
    );

    return updatedTask;
  }

  TaskModel getNewTask(
    BuildContext context,
    TaskModel? oldTask,
  ) {
    // Initialize task with oldTask if available, or create a new one
    var task = oldTask;
    var clientReferenceId = IdGen.i.identifier;

    // update the task with latest clientauditDetails and auditdetails

    task = oldTask!.copyWith(
      id: null,
      clientReferenceId: clientReferenceId,
      tenantId: envConfig.variables.tenantId,
      rowVersion: 1,
      auditDetails: AuditDetails(
        createdBy: context.loggedInUserUuid,
        createdTime: context.millisecondsSinceEpoch(),
      ),
      clientAuditDetails: ClientAuditDetails(
        createdBy: context.loggedInUserUuid,
        createdTime: context.millisecondsSinceEpoch(),
      ),
      // setting the status here as visited to separate this task from other successful task
      status: Status.visited.toValue(),
    );
    // update the task resources with latest clientauditDetails and auditdetails

    List<TaskResourceModel> newTaskResources = [];

    for (var resource in task.resources!) {
      newTaskResources.add(
        TaskResourceModel(
          taskclientReferenceId: clientReferenceId,
          clientReferenceId: IdGen.i.identifier,
          productVariantId: resource.productVariantId,
          isDelivered: true,
          taskId: task?.id,
          tenantId: envConfig.variables.tenantId,
          rowVersion: task?.rowVersion ?? 1,
          quantity: resource.quantity,
          additionalFields: resource.additionalFields,
          deliveryComment: resource.deliveryComment,
          clientAuditDetails: ClientAuditDetails(
            createdBy: context.loggedInUserUuid,
            createdTime: context.millisecondsSinceEpoch(),
          ),
          auditDetails: AuditDetails(
            createdBy: context.loggedInUserUuid,
            createdTime: context.millisecondsSinceEpoch(),
          ),
        ),
      );
    }

    task = task.copyWith(
      resources: newTaskResources,
    );

    return task;
  }

// This method builds a form used for delivering interventions.

  FormGroup buildForm(
    BuildContext context,
    List<ProductVariantsModel>? productVariants,
    List<ProductVariantModel>? variants,
  ) {
    final bloc = context.read<DeliverInterventionBloc>().state;

    // Add controllers for each product variant to the _controllers list.

    _controllers
        .addAll(productVariants!.map((e) => productVariants.indexOf(e)));

    return fb.group(<String, Object>{
      _doseAdministrationKey: FormControl<String>(
        value:
            '${localizations.translate(i18.deliverIntervention.cycle)} ${bloc.cycle == 0 ? (bloc.cycle + 1) : bloc.cycle}'
                .toString(),
        validators: [],
      ),
      _dateOfAdministrationKey:
          FormControl<DateTime>(value: DateTime.now(), validators: []),
      _resourceDeliveredKey: FormArray<ProductVariantModel>(
        [
          ..._controllers.map((e) => FormControl<ProductVariantModel>(
                value: variants != null &&
                        _controllers.indexOf(e) < variants.length
                    ? variants.firstWhereOrNull(
                        (element) =>
                            element.id ==
                            productVariants
                                .elementAt(_controllers.indexOf(e))
                                .productVariantId,
                      )
                    : null,
              )),
        ],
      ),
      _quantityDistributedKey: FormArray<String>([
        ..._controllers.map(
          (e) => FormControl<String>(
            validators: [
              Validators.required,
            ],
            value:
                "${productVariants[0].quantity ?? 0} ${localizations.translate(i18_local.beneficiaryDetails.beneficiaryDoseUnit)}",
            // value: productVariants[0].quantity ?? 0,
          ),
        ),
      ]),
      _deliveryCommentKey: FormControl<String>(
        validators: [
          Validators.required,
        ],
      ),
      _otherDeliveryCommentKey: FormControl<String>(
        validators: otherDeliveryComment
            ? [
                Validators.required,
                Validators.minLength(3),
                Validators.maxLength(100),
              ]
            : [],
      ),
      _doseAdministeredByKey: FormControl<String>(
        validators: [],
        value: context.loggedInUser.userName,
      ),
    });
  }
}

class CustomResourceBeneficiaryCard extends LocalizedStatefulWidget {
  final void Function(int) onDelete;
  final int cardIndex;
  final FormGroup form;
  final int totalItems;
  final bool isAdministered;
  final EligibilityAssessmentType eligibilityAssessmentType;

  const CustomResourceBeneficiaryCard({
    super.key,
    super.appLocalizations,
    required this.onDelete,
    required this.cardIndex,
    required this.form,
    required this.totalItems,
    required this.isAdministered,
    this.eligibilityAssessmentType = EligibilityAssessmentType.smc,
  });

  @override
  State<CustomResourceBeneficiaryCard> createState() =>
      CustomResourceBeneficiaryCardState();
}

class CustomResourceBeneficiaryCardState
    extends LocalizedState<CustomResourceBeneficiaryCard> {
  CustomResourceBeneficiaryCardState();
  @override
  Widget build(BuildContext context) {
    return DigitCard(cardType: CardType.secondary, children: [
      BlocBuilder<ProductVariantBloc, ProductVariantState>(
        builder: (context, productState) {
          return productState.maybeWhen(
              orElse: () => const Offstage(),
              fetched: (productVariants) {
                var variant = widget.form
                    .control('resourceDelivered.${widget.cardIndex}')
                    .value;
                return LabeledField(
                  label: localizations.translate(
                    i18_local
                        .deliverIntervention.selectTheResourceDeliveredLabel,
                  ),
                  isRequired: true,
                  child: DigitTextFormInput(
                    suffixIcon: Icons.arrow_drop_down,
                    readOnly: true,
                    initialValue: widget.eligibilityAssessmentType ==
                            EligibilityAssessmentType.smc
                        ? variant.sku ?? variant.id
                        : 'VAS - ${(variant.sku ?? variant.id) == "SPAQ 1" ? "Blue" : "Red"} Capsule',
                  ),
                );
              });
        },
      ),
      IgnorePointer(
        child: ReactiveWrapperField(
          formControlName: 'quantityDistributed.${widget.cardIndex}',
          builder: (field) => LabeledField(
            label: localizations.translate(
              i18_local.deliverIntervention.quantityAdministratedLabel,
            ),
            isRequired: true,
            child: DigitNumericFormInput(
              minValue: 1,
              step: 1,
              initialValue: "1",
              onChange: (value) {
                widget.form
                    .control('quantityDistributed.${widget.cardIndex}')
                    .value = int.parse(value);
              },
            ),
          ),
        ),
      ),
    ]);
  }
}
