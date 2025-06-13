import 'package:auto_route/auto_route.dart';
import 'package:collection/collection.dart';
import 'package:digit_components/widgets/digit_dialog.dart' as dialog;
// import 'package:digit_components/digit_components.dart';
import 'package:digit_data_model/data_model.dart';
import 'package:digit_ui_components/digit_components.dart';
import 'package:digit_ui_components/services/location_bloc.dart';
import 'package:digit_ui_components/theme/digit_extended_theme.dart';
import 'package:digit_ui_components/utils/component_utils.dart';
import 'package:digit_ui_components/widgets/atoms/digit_stepper.dart';
import 'package:digit_ui_components/widgets/atoms/pop_up_card.dart';
import 'package:digit_ui_components/widgets/molecules/digit_card.dart';
import 'package:digit_ui_components/widgets/molecules/show_pop_up.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_campaign_field_worker_app/blocs/auth/auth.dart';
import 'package:health_campaign_field_worker_app/utils/constants.dart';
import 'package:intl/intl.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:registration_delivery/models/entities/deliver_strategy_type.dart';
import 'package:registration_delivery/registration_delivery.dart';
import 'package:registration_delivery/router/registration_delivery_router.gm.dart';
import 'package:registration_delivery/utils/extensions/extensions.dart';
import 'package:registration_delivery/utils/utils.dart';

import 'package:registration_delivery/models/entities/additional_fields_type.dart';
import 'package:registration_delivery/models/entities/status.dart';
import 'package:registration_delivery/utils/i18_key_constants.dart' as i18;
import 'package:registration_delivery/widgets/back_navigation_help_header.dart';
import 'package:registration_delivery/widgets/beneficiary/resource_beneficiary_card.dart';
import 'package:registration_delivery/widgets/component_wrapper/product_variant_bloc_wrapper.dart';
import 'package:registration_delivery/widgets/localized.dart';

import '../../../router/app_router.dart';
import '../../../utils/app_enums.dart';
import '../../../utils/i18_key_constants.dart' as i18_local;
import '../../../models/entities/additional_fields_type.dart'
    as additional_fields_local;
import '../../../widgets/custom_back_navigation.dart';

@RoutePage()
class CustomDeliverInterventionPage extends LocalizedStatefulWidget {
  final EligibilityAssessmentType eligibilityAssessmentType;
  final bool isEditing;

  const CustomDeliverInterventionPage({
    super.key,
    super.appLocalizations,
    required this.eligibilityAssessmentType,
    this.isEditing = false,
  });

  @override
  State<CustomDeliverInterventionPage> createState() =>
      CustomDeliverInterventionPageState();
}

class CustomDeliverInterventionPageState
    extends LocalizedState<CustomDeliverInterventionPage> {
  // Constants for form control keys
  static const _resourceDeliveredKey = 'resourceDelivered';
  static const _quantityDistributedKey = 'quantityDistributed';
  static const _doseAdministrationKey = 'doseAdministered';
  static const _dateOfAdministrationKey = 'dateOfAdministration';
  final clickedStatus = ValueNotifier<bool>(false);
  bool? shouldSubmit = false;

  // Variable to track dose administration status
  bool doseAdministered = false;

  // List of controllers for form elements
  final List _controllers = [];

// Initialize the currentStep variable to keep track of the current step in a process.
  int currentStep = 0;

  @override
  void initState() {
    context.read<LocationBloc>().add(const LoadLocationEvent());
    super.initState();
  }

  Future<void> handleCapturedLocationState(
      LocationState locationState,
      BuildContext context,
      DeliverInterventionState deliverInterventionState,
      FormGroup form,
      HouseholdMemberWrapper householdMember,
      ProjectBeneficiaryModel projectBeneficiary) async {
    final lat = locationState.latitude;
    final long = locationState.longitude;
    TaskModel taskModel = _getTaskModel(
      context,
      form: form,
      oldTask: RegistrationDeliverySingleton().beneficiaryType ==
              BeneficiaryType.household
          ? deliverInterventionState.tasks?.lastOrNull
          : null,
      projectBeneficiaryClientReferenceId: projectBeneficiary.clientReferenceId,
      dose: deliverInterventionState.dose,
      cycle: deliverInterventionState.cycle,
      deliveryStrategy: DeliverStrategyType.direct.toValue(),
      address: householdMember.members?.first.address?.first,
      latitude: lat,
      longitude: long,
    );
    context.read<DeliverInterventionBloc>().add(
          DeliverInterventionSubmitEvent(
              task: taskModel,
              isEditing: (deliverInterventionState.tasks ?? []).isNotEmpty &&
                      RegistrationDeliverySingleton().beneficiaryType ==
                          BeneficiaryType.household
                  ? true
                  : false,
              boundaryModel: RegistrationDeliverySingleton().boundary!,
              navigateToSummary: true,
              householdMemberWrapper: householdMember),
        );

    final productvariantList =
        ((form.control(_resourceDeliveredKey) as FormArray).value
            as List<ProductVariantModel?>);

    final qty =
        (((form.control(_quantityDistributedKey) as FormArray).value)?[0])
            .toString();

    int spaq1 = 0;
    int spaq2 = 0;
    int blueVas = 0;
    int redVas = 0;

    if (productvariantList!.first?.sku! == Constants.spaq1) {
      spaq1 = int.parse(qty) * -1;
    } else if (productvariantList!.first?.sku! == Constants.spaq2) {
      spaq2 = int.parse(qty) * -1;
    } else if (productvariantList!.first?.sku! == Constants.blueVAS) {
      blueVas = int.parse(qty) * -1;
    } else {
      redVas = int.parse(qty) * -1;
    }

    context.read<AuthBloc>().add(
          AuthAddSpaqCountsEvent(
            spaq1Count: spaq1,
            spaq2Count: spaq2,
            blueVasCount: blueVas,
            redVasCount: redVas,
          ),
        );

    await handleSubmit(context, taskModel, deliverInterventionState);
  }

  void handleLocationState(
      LocationState locationState,
      BuildContext context,
      DeliverInterventionState deliverInterventionState,
      FormGroup form,
      HouseholdMemberWrapper householdMember,
      ProjectBeneficiaryModel projectBeneficiary) {
    if (context.mounted) {
      DigitComponentsUtils.showDialog(
        context,
        localizations.translate(i18.common.locationCapturing),
        DialogType.inProgress,
      );

      Future.delayed(const Duration(seconds: 0), () {
        // After delay, hide the initial dialog
        DigitComponentsUtils.hideDialog(context);
        handleCapturedLocationState(
            locationState,
            context,
            deliverInterventionState,
            form,
            householdMember,
            projectBeneficiary);
      });
    }
  }

  Future<void> handleSubmit(
    BuildContext context,
    TaskModel taskModel,
    DeliverInterventionState deliverState,
  ) async {
    context.read<DeliverInterventionBloc>().add(
          DeliverInterventionSubmitEvent(
            task: deliverState.oldTask ?? taskModel,
            isEditing: (deliverState.tasks ?? []).isNotEmpty &&
                    RegistrationDeliverySingleton().beneficiaryType ==
                        BeneficiaryType.household
                ? true
                : false,
            boundaryModel: RegistrationDeliverySingleton().boundary!,
          ),
        );

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

    if (deliverState.futureDeliveries != null &&
        deliverState.futureDeliveries!.isNotEmpty &&
        projectTypeModel?.cycles?.isNotEmpty == true) {
      context.router.popUntilRouteWithName(BeneficiaryWrapperRoute.name);
      context.router.push(
        CustomSplashAcknowledgementRoute(
            enableBackToSearch: false,
            eligibilityAssessmentType: widget.eligibilityAssessmentType),
      );
    } else {
      final reloadState = context.read<HouseholdOverviewBloc>();

      reloadState.add(
        HouseholdOverviewReloadEvent(
          projectId: RegistrationDeliverySingleton().projectId!,
          projectBeneficiaryType:
              RegistrationDeliverySingleton().beneficiaryType!,
        ),
      );
      context.router.popAndPush(
        CustomHouseholdAcknowledgementRoute(
          enableViewHousehold: true,
          eligibilityAssessmentType: widget.eligibilityAssessmentType,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.digitTextTheme(context);

    List<StepperData> generateSteps(int numberOfDoses) {
      return List.generate(numberOfDoses, (index) {
        return StepperData(
          title:
              '${localizations.translate(i18.deliverIntervention.dose)}${index + 1}',
        );
      });
    }

    return ProductVariantBlocWrapper(
      child: BlocBuilder<HouseholdOverviewBloc, HouseholdOverviewState>(
        builder: (context, state) {
          final householdMemberWrapper = state.householdMemberWrapper;

          final projectBeneficiary =
              RegistrationDeliverySingleton().beneficiaryType !=
                      BeneficiaryType.individual
                  ? [householdMemberWrapper.projectBeneficiaries!.first]
                  : householdMemberWrapper.projectBeneficiaries
                      ?.where(
                        (element) =>
                            element.beneficiaryClientReferenceId ==
                            state.selectedIndividual?.clientReferenceId,
                      )
                      .toList();

          return Scaffold(
            body: state.loading
                ? const Center(child: CircularProgressIndicator())
                : BlocBuilder<DeliverInterventionBloc,
                    DeliverInterventionState>(
                    builder: (context, deliveryInterventionState) {
                      ProjectTypeModel? projectTypeModel =
                          widget.eligibilityAssessmentType ==
                                  EligibilityAssessmentType.smc
                              ? RegistrationDeliverySingleton()
                                  .selectedProject
                                  ?.additionalDetails
                                  ?.projectType
                              : RegistrationDeliverySingleton()
                                  .selectedProject
                                  ?.additionalDetails
                                  ?.additionalProjectType;
                      List<DeliveryProductVariant>? productVariants =
                          projectTypeModel?.cycles?.isNotEmpty == true
                              ? (fetchProductVariant(
                                      projectTypeModel
                                              ?.cycles![
                                                  deliveryInterventionState
                                                          .cycle -
                                                      1]
                                              .deliveries?[
                                          deliveryInterventionState.dose - 1],
                                      state.selectedIndividual,
                                      state.householdMemberWrapper.household)
                                  ?.productVariants)
                              : projectTypeModel?.resources
                                  ?.map((r) => DeliveryProductVariant(
                                      productVariantId: r.productVariantId))
                                  .toList();

                      final int numberOfDoses = (projectTypeModel
                                  ?.cycles?.isNotEmpty ==
                              true)
                          ? (projectTypeModel
                                  ?.cycles?[deliveryInterventionState.cycle - 1]
                                  .deliveries
                                  ?.length) ??
                              0
                          : 0;

                      final steps = generateSteps(numberOfDoses);
                      if ((productVariants ?? []).isEmpty && context.mounted) {
                        SchedulerBinding.instance.addPostFrameCallback((_) {
                          showCustomPopup(
                              context: context,
                              builder: (popUpContext) => Popup(
                                      title: localizations.translate(
                                        i18.common.noResultsFound,
                                      ),
                                      description: localizations.translate(
                                        i18.deliverIntervention
                                            .checkForProductVariantsConfig,
                                      ),
                                      type: PopUpType.alert,
                                      actions: [
                                        DigitButton(
                                          label: localizations.translate(
                                            i18.common.coreCommonOk,
                                          ),
                                          onPressed: () {
                                            context.router.maybePop();
                                            Navigator.of(popUpContext).pop();
                                          },
                                          type: DigitButtonType.primary,
                                          size: DigitButtonSize.large,
                                        ),
                                      ]));
                        });
                      }

                      return BlocBuilder<ProductVariantBloc,
                          ProductVariantState>(
                        builder: (context, productState) {
                          return productState.maybeWhen(
                            orElse: () => const Offstage(),
                            fetched: (productVariantsValue) {
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
                                    enableFixedDigitButton: true,
                                    footer: BlocBuilder<DeliverInterventionBloc,
                                        DeliverInterventionState>(
                                      builder: (context, state) {
                                        return DigitCard(
                                            margin: const EdgeInsets.only(
                                                top: spacer2),
                                            children: [
                                              ValueListenableBuilder(
                                                valueListenable: clickedStatus,
                                                builder: (context,
                                                    bool isClicked, _) {
                                                  return BlocBuilder<
                                                          LocationBloc,
                                                          LocationState>(
                                                      builder: (context,
                                                          locationState) {
                                                    return DigitButton(
                                                      label: localizations
                                                          .translate(
                                                        i18.common
                                                            .coreCommonSubmit,
                                                      ),
                                                      type: DigitButtonType
                                                          .primary,
                                                      size:
                                                          DigitButtonSize.large,
                                                      mainAxisSize:
                                                          MainAxisSize.max,
                                                      isDisabled: isClicked,
                                                      onPressed: () async {
                                                        final deliveredProducts =
                                                            ((form.control(_resourceDeliveredKey)
                                                                        as FormArray)
                                                                    .value
                                                                as List<
                                                                    ProductVariantModel?>);
                                                        final hasEmptyResources =
                                                            hasEmptyOrNullResources(
                                                                deliveredProducts);
                                                        final hasZeroQuantity =
                                                            hasEmptyOrZeroQuantity(
                                                                form);
                                                        final hasDuplicates =
                                                            hasDuplicateResources(
                                                                deliveredProducts,
                                                                form);

                                                        if (hasEmptyResources) {
                                                          Toast.showToast(
                                                              context,
                                                              message: localizations
                                                                  .translate(i18
                                                                      .deliverIntervention
                                                                      .resourceDeliveredValidation),
                                                              type: ToastType
                                                                  .error);
                                                        } else if (hasDuplicates) {
                                                          Toast.showToast(
                                                              context,
                                                              message: localizations
                                                                  .translate(i18
                                                                      .deliverIntervention
                                                                      .resourceDuplicateValidation),
                                                              type: ToastType
                                                                  .error);
                                                        } else if (hasZeroQuantity) {
                                                          Toast.showToast(
                                                              context,
                                                              message: localizations
                                                                  .translate(i18
                                                                      .deliverIntervention
                                                                      .resourceCannotBeZero),
                                                              type: ToastType
                                                                  .error);
                                                        } else {
                                                          final shouldSubmit =
                                                              await dialog
                                                                      .DigitDialog
                                                                  .show<bool>(
                                                            context,
                                                            options: dialog
                                                                .DigitDialogOptions(
                                                              titleText:
                                                                  localizations
                                                                      .translate(
                                                                i18.deliverIntervention
                                                                    .dialogTitle,
                                                              ),
                                                              contentText:
                                                                  localizations
                                                                      .translate(
                                                                i18.deliverIntervention
                                                                    .dialogContent,
                                                              ),
                                                              primaryAction: dialog
                                                                  .DigitDialogActions(
                                                                label: localizations
                                                                    .translate(
                                                                  i18.common
                                                                      .coreCommonSubmit,
                                                                ),
                                                                action: (ctx) {
                                                                  Navigator.of(
                                                                          ctx,
                                                                          rootNavigator:
                                                                              true)
                                                                      .pop(
                                                                          true);
                                                                },
                                                              ),
                                                              secondaryAction:
                                                                  dialog
                                                                      .DigitDialogActions(
                                                                label: localizations
                                                                    .translate(
                                                                  i18.common
                                                                      .coreCommonGoback,
                                                                ),
                                                                action: (ctx) {
                                                                  Navigator.of(
                                                                          ctx,
                                                                          rootNavigator:
                                                                              true)
                                                                      .pop(
                                                                          false);
                                                                },
                                                              ),
                                                            ),
                                                          );

                                                          // Check the result of the dialog
                                                          if (shouldSubmit ??
                                                              false) {
                                                            if (context
                                                                .mounted) {
                                                              // vas

                                                              context
                                                                  .read<
                                                                      LocationBloc>()
                                                                  .add(
                                                                      const LoadLocationEvent());
                                                              handleLocationState(
                                                                locationState,
                                                                context,
                                                                deliveryInterventionState,
                                                                form,
                                                                householdMemberWrapper,
                                                                projectBeneficiary!
                                                                    .first,
                                                              );
                                                            }
                                                          }
                                                        }
                                                      },
                                                    );
                                                  });
                                                },
                                              ),
                                            ]);
                                      },
                                    ),
                                    header: const Column(children: [
                                      Padding(
                                        padding:
                                            EdgeInsets.only(bottom: spacer2),
                                        child:
                                            CustomBackNavigationHelpHeaderWidget(
                                          showHelp: false,
                                        ),
                                      ),
                                    ]),
                                    children: [
                                      Column(
                                        children: [
                                          DigitCard(
                                              margin:
                                                  const EdgeInsets.all(spacer2),
                                              children: [
                                                Text(
                                                  widget.eligibilityAssessmentType ==
                                                          EligibilityAssessmentType
                                                              .smc
                                                      ? localizations.translate(
                                                          i18_local
                                                              .deliverIntervention
                                                              .deliverInterventionSMCLabel,
                                                        )
                                                      : localizations.translate(
                                                          i18_local
                                                              .deliverIntervention
                                                              .deliverInterventionVASLabel,
                                                        ),
                                                  style: textTheme.headingL
                                                      .copyWith(
                                                          color: theme
                                                              .colorTheme
                                                              .text
                                                              .primary),
                                                ),
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
                                                if (widget.eligibilityAssessmentType ==
                                                        EligibilityAssessmentType
                                                            .smc &&
                                                    numberOfDoses > 1)
                                                  SizedBox(
                                                    height: MediaQuery.sizeOf(
                                                                context)
                                                            .height *
                                                        0.07,
                                                    child: DigitStepper(
                                                      activeIndex:
                                                          deliveryInterventionState
                                                                  .dose -
                                                              1,
                                                      stepperList: steps,
                                                      inverted: true,
                                                    ),
                                                  ),
                                                ReactiveWrapperField(
                                                  formControlName:
                                                      _dateOfAdministrationKey,
                                                  builder: (field) =>
                                                      LabeledField(
                                                    label:
                                                        localizations.translate(
                                                      // widget.eligibilityAssessmentType ==
                                                      //         EligibilityAssessmentType
                                                      //             .smc
                                                      // ? i18.householdDetails
                                                      //     .dateOfRegistrationLabel:
                                                      i18_local.householdDetails
                                                          .dateOfAdministrationLabel,
                                                    ),
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
                                                          .translate(
                                                        i18.common.coreCommonOk,
                                                      ),
                                                      cancelText: localizations
                                                          .translate(
                                                        i18.common
                                                            .coreCommonCancel,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                LabeledField(
                                                  label:
                                                      localizations.translate(
                                                    i18_local
                                                        .deliverIntervention
                                                        .doseadministeredby,
                                                  ),
                                                  child: DigitTextFormInput(
                                                    suffixIcon:
                                                        Icons.arrow_drop_down,
                                                    readOnly: true,
                                                    initialValue:
                                                        RegistrationDeliverySingleton()
                                                                .loggedInUser
                                                                ?.name ??
                                                            '',
                                                  ),
                                                ),
                                              ]),
                                          DigitCard(
                                              margin:
                                                  const EdgeInsets.all(spacer2),
                                              children: [
                                                Text(
                                                  localizations.translate(
                                                    i18.deliverIntervention
                                                        .deliverInterventionResourceLabel,
                                                  ),
                                                  style: textTheme.headingL
                                                      .copyWith(
                                                          color: theme
                                                              .colorTheme
                                                              .text
                                                              .primary),
                                                ),
                                                ..._controllers.map((e) =>
                                                    CustomResourceBeneficiaryCard(
                                                      form: form,
                                                      eligibilityAssessmentType:
                                                          widget
                                                              .eligibilityAssessmentType,
                                                      cardIndex: _controllers
                                                          .indexOf(e),
                                                      totalItems:
                                                          _controllers.length,
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
                                                        _controllers.removeAt(
                                                          index,
                                                        );
                                                        setState(() {
                                                          _controllers;
                                                        });
                                                      },
                                                    )),
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
        .add(FormControl<int>(value: 0, validators: [Validators.min(1)]));
  }

  bool hasEmptyOrZeroQuantity(FormGroup form) {
    final quantityDistributedArray =
        form.control(_quantityDistributedKey) as FormArray;

    // Check if any quantity is zero or null
    return quantityDistributedArray.value?.any((e) => e == 0 || e == null) ??
        true;
  }

  bool hasEmptyOrNullResources(List<ProductVariantModel?> deliveredProducts) {
    final Map<String?, List<ProductVariantModel?>> groupedVariants = {};
    if (deliveredProducts.isNotEmpty) {
      for (final variant in deliveredProducts) {
        final productId = variant?.productId;
        if (productId != null) {
          groupedVariants.putIfAbsent(productId, () => []);
          groupedVariants[productId]?.add(variant);
        }
      }
      bool hasDuplicateProductIdOrNoProductId =
          deliveredProducts.any((ele) => ele?.productId == null);

      return hasDuplicateProductIdOrNoProductId;
    }

    return true;
  }

  bool hasDuplicateResources(
      List<ProductVariantModel?> deliveredProducts, FormGroup form) {
    final resourceDeliveredArray =
        form.control(_resourceDeliveredKey) as FormArray;
    final Set<String?> uniqueProductIds = {};

    for (int i = 0; i < resourceDeliveredArray.value!.length; i++) {
      final productId = deliveredProducts[i]?.id;
      if (productId != null) {
        if (uniqueProductIds.contains(productId)) {
          // Duplicate found
          return true;
        } else {
          uniqueProductIds.add(productId);
        }
      }
    }
    return false;
  }

  // ignore: long-parameter-list
  TaskModel _getTaskModel(
    BuildContext context, {
    required FormGroup form,
    TaskModel? oldTask,
    int? cycle,
    int? dose,
    String? deliveryStrategy,
    String? projectBeneficiaryClientReferenceId,
    AddressModel? address,
    double? latitude,
    double? longitude,
  }) {
    // Initialize task with oldTask if available, or create a new one
    var task = oldTask;
    var clientReferenceId = task?.clientReferenceId ?? IdGen.i.identifier;
    task ??= TaskModel(
      projectBeneficiaryClientReferenceId: projectBeneficiaryClientReferenceId,
      clientReferenceId: clientReferenceId,
      address: address?.copyWith(
        relatedClientReferenceId: clientReferenceId,
      ),
      tenantId: RegistrationDeliverySingleton().tenantId,
      rowVersion: 1,
      auditDetails: AuditDetails(
        createdBy: RegistrationDeliverySingleton().loggedInUserUuid!,
        createdTime: context.millisecondsSinceEpoch(),
      ),
      clientAuditDetails: ClientAuditDetails(
        createdBy: RegistrationDeliverySingleton().loggedInUserUuid!,
        createdTime: context.millisecondsSinceEpoch(),
      ),
    );

    // Extract productvariantList from the form
    final productvariantList =
        ((form.control(_resourceDeliveredKey) as FormArray).value
            as List<ProductVariantModel?>);
    // Update the task with information from the form and other context
    task = task.copyWith(
      projectId: RegistrationDeliverySingleton().projectId,
      resources: productvariantList
          .map((e) => TaskResourceModel(
                taskclientReferenceId: clientReferenceId,
                clientReferenceId: IdGen.i.identifier,
                productVariantId: e?.id,
                isDelivered: true,
                taskId: task?.id,
                tenantId: RegistrationDeliverySingleton().tenantId,
                rowVersion: oldTask?.rowVersion ?? 1,
                quantity: (((form.control(_quantityDistributedKey) as FormArray)
                        .value)?[productvariantList.indexOf(e)])
                    .toString(),
                clientAuditDetails: ClientAuditDetails(
                  createdBy: RegistrationDeliverySingleton().loggedInUserUuid!,
                  createdTime: context.millisecondsSinceEpoch(),
                ),
                auditDetails: AuditDetails(
                  createdBy: RegistrationDeliverySingleton().loggedInUserUuid!,
                  createdTime: context.millisecondsSinceEpoch(),
                ),
              ))
          .toList(),
      address: address?.copyWith(
        relatedClientReferenceId: clientReferenceId,
        id: null,
      ),
      status: Status.administeredSuccess.toValue(),
      additionalFields: TaskAdditionalFields(
        version: task.additionalFields?.version ?? 1,
        fields: [
          AdditionalField(
            RegistrationDeliveryEnums.name.toValue(),
            RegistrationDeliverySingleton().loggedInUser?.name,
          ),
          AdditionalField(
            AdditionalFieldsType.dateOfDelivery.toValue(),
            DateTime.now().millisecondsSinceEpoch.toString(),
          ),
          AdditionalField(
            AdditionalFieldsType.dateOfAdministration.toValue(),
            DateTime.now().millisecondsSinceEpoch.toString(),
          ),
          AdditionalField(
            AdditionalFieldsType.dateOfVerification.toValue(),
            DateTime.now().millisecondsSinceEpoch.toString(),
          ),
          AdditionalField(
            AdditionalFieldsType.cycleIndex.toValue(),
            "0${cycle ?? 1}",
          ),
          AdditionalField(
            AdditionalFieldsType.doseIndex.toValue(),
            "0${dose ?? 1}",
          ),
          AdditionalField(
            AdditionalFieldsType.deliveryStrategy.toValue(),
            deliveryStrategy,
          ),
          if (latitude != null)
            AdditionalField(
              AdditionalFieldsType.latitude.toValue(),
              latitude,
            ),
          if (longitude != null)
            AdditionalField(
              AdditionalFieldsType.longitude.toValue(),
              longitude,
            ),
          AdditionalField(
            additional_fields_local.AdditionalFieldsType.deliveryType.toValue(),
            widget.eligibilityAssessmentType == EligibilityAssessmentType.smc
                ? EligibilityAssessmentStatus.smcDone.name
                : EligibilityAssessmentStatus.vasDone.name,
          ),
        ],
      ),
    );

    return task;
  }

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
      _resourceDeliveredKey: FormArray<ProductVariantModel>(
        [
          ..._controllers.map((e) => FormControl<ProductVariantModel>(
                value: variants != null && variants.length < _controllers.length
                    ? variants.last
                    : (variants != null &&
                            _controllers.indexOf(e) < variants.length
                        ? variants.firstWhereOrNull(
                            (element) =>
                                element.id ==
                                productVariants
                                    ?.elementAt(_controllers.indexOf(e))
                                    .productVariantId,
                          )
                        : null),
              )),
        ],
      ),
      _quantityDistributedKey: FormArray<int>([
        ..._controllers.mapIndexed(
          (i, e) => FormControl<int>(
            value: RegistrationDeliverySingleton().beneficiaryType !=
                    BeneficiaryType.individual
                ? int.tryParse(
                    bloc.tasks?.lastOrNull?.resources?.elementAt(i).quantity ??
                        '1',
                  )
                : 1,
            validators: [Validators.min(1)],
          ),
        ),
      ]),
    });
  }
}

class CustomResourceBeneficiaryCard extends LocalizedStatefulWidget {
  final void Function(int) onDelete;
  final int cardIndex;
  final FormGroup form;
  final int totalItems;
  final EligibilityAssessmentType eligibilityAssessmentType;

  const CustomResourceBeneficiaryCard({
    super.key,
    super.appLocalizations,
    required this.onDelete,
    required this.cardIndex,
    required this.form,
    required this.totalItems,
    required this.eligibilityAssessmentType,
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
              final selectedVariant = widget.form
                  .control('resourceDelivered.${widget.cardIndex}')
                  .value as ProductVariantModel?;
              return Column(
                children: [
                  LabeledField(
                    isRequired: true,
                    label: localizations.translate(
                      i18_local
                          .deliverIntervention.selectTheResourcDeliveredLabel,
                    ),
                    labelStyle: TextStyle(
                      color: Theme.of(context).colorTheme.text.secondary,
                      fontSize: 16,
                    ),
                    child: DigitDropdown(
                      isDisabled: true,
                      readOnly: true,
                      sentenceCaseEnabled: false,
                      selectedOption: DropdownItem(
                        code: getFormattedSku(
                            selectedVariant?.sku ?? selectedVariant?.id ?? ''),
                        name: getFormattedSku(selectedVariant?.sku ??
                                selectedVariant?.id ??
                                '')
                            .toUpperCase(),
                      ),
                      items: productVariants
                          .map((variant) => DropdownItem(
                                code:
                                    getFormattedSku(variant.sku ?? variant.id),
                                name: getFormattedSku(variant.sku ?? variant.id)
                                    .toUpperCase(),
                              ))
                          .toList(),
                    ),
                  ),
                  const SizedBox(height: spacer4),
                  ReactiveWrapperField(
                    formControlName: 'quantityDistributed.${widget.cardIndex}',
                    builder: (field) => LabeledField(
                      isRequired: true,
                      label: localizations.translate(
                        i18_local
                            .deliverIntervention.quantityAdministratedLabel,
                      ),
                      child: DigitNumericFormInput(
                        isDisabled: true,
                        minValue: 1,
                        step: 1,
                        initialValue: "1",
                        onChange: (value) {
                          widget.form
                              .control(
                                  'quantityDistributed.${widget.cardIndex}')
                              .value = int.parse(value);
                        },
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    ]);
  }

  String getFormattedSku(String sku) {
    if (sku == 'Red VAS') {
      return 'VAS - Red Capsule';
    } else if (sku == 'Blue VAS') {
      return 'VAS - Blue Capsule';
    }
    return sku; // Fallback to original if no match
  }
}
