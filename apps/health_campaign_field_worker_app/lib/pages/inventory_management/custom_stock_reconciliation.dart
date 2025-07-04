import 'package:auto_route/auto_route.dart';
import 'package:digit_components/widgets/atoms/digit_toaster.dart';
import 'package:digit_data_model/data_model.dart';
import 'package:digit_ui_components/digit_components.dart';
import 'package:digit_ui_components/theme/digit_extended_theme.dart';
import 'package:digit_ui_components/widgets/atoms/digit_divider.dart';
import 'package:digit_ui_components/widgets/atoms/input_wrapper.dart';
import 'package:digit_ui_components/widgets/atoms/label_value_list.dart';
import 'package:digit_ui_components/widgets/atoms/pop_up_card.dart';
import 'package:digit_ui_components/widgets/molecules/digit_card.dart';
import 'package:digit_ui_components/widgets/molecules/show_pop_up.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:inventory_management/inventory_management.dart'
    hide CustomValidator;
import 'package:inventory_management/router/inventory_router.gm.dart';
import 'package:reactive_forms/reactive_forms.dart';

import 'package:inventory_management/utils/i18_key_constants.dart' as i18;
import '../../utils/i18_key_constants.dart' as i18_local;
import 'package:inventory_management/widgets/inventory/no_facilities_assigned_dialog.dart';
import 'package:inventory_management/widgets/localized.dart';
import 'package:inventory_management/blocs/product_variant.dart';
import 'package:inventory_management/blocs/stock_reconciliation.dart';
import 'package:inventory_management/widgets/back_navigation_help_header.dart';
import 'package:inventory_management/widgets/component_wrapper/facility_bloc_wrapper.dart';
import 'package:inventory_management/widgets/component_wrapper/product_variant_bloc_wrapper.dart';

import '../../utils/constants.dart';
import '../../utils/extensions/extensions.dart';
import '../../utils/utils.dart' show CustomValidator;

@RoutePage()
class CustomStockReconciliationPage extends LocalizedStatefulWidget {
  const CustomStockReconciliationPage({
    super.key,
    super.appLocalizations,
  });

  @override
  State<CustomStockReconciliationPage> createState() =>
      CustomStockReconciliationPageState();
}

class CustomStockReconciliationPageState
    extends LocalizedState<CustomStockReconciliationPage> {
  static const _facilityKey = 'facility';
  static const _productVariantKey = 'productVariant';
  static const _manualCountKey = 'manualCountKey';
  static const _reconciliationCommentsKey = 'reconciliationCommentsKey';
  String? selectedFacilityId;
  TextEditingController controller1 = TextEditingController();

  FormGroup _form(bool isDistributor, num stockInHand) {
    return fb.group({
      _facilityKey: FormControl<String>(
        validators: isDistributor ? [] : [Validators.required],
      ),
      _productVariantKey: FormControl<ProductVariantModel>(),
      _manualCountKey: FormControl<String>(
        value: '0',
        validators: [
          Validators.number(),
          Validators.required,
          Validators.delegate(CustomValidator.validStockCountUpdated),
        ],
      ),
      _reconciliationCommentsKey: FormControl<String>(),
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InventorySingleton().projectId.isEmpty
        ? Center(
            child: Text(localizations
                .translate(i18.stockReconciliationDetails.noProjectSelected)),
          )
        : FacilityBlocWrapper(
            projectId: InventorySingleton().projectId,
            child: ProductVariantBlocWrapper(
              projectId: InventorySingleton().projectId,
              child: BlocProvider(
                create: (context) => StockReconciliationBloc(
                  StockReconciliationState(
                    projectId: InventorySingleton().projectId,
                    dateOfReconciliation: DateTime.now(),
                  ),
                  stockRepository:
                      context.repository<StockModel, StockSearchModel>(),
                  stockReconciliationRepository: context.repository<
                      StockReconciliationModel,
                      StockReconciliationSearchModel>(),
                ),
                child: BlocConsumer<StockReconciliationBloc,
                    StockReconciliationState>(
                  listener: (context, stockState) {
                    if (!stockState.persisted) return;

                    context.router.replace(
                      InventoryAcknowledgementRoute(),
                    );
                  },
                  builder: (context, stockState) {
                    return ReactiveFormBuilder(
                      form: () => _form(
                          InventorySingleton().isDistributor! &&
                              !InventorySingleton().isWareHouseMgr!,
                          stockState.stockInHand),
                      builder: (ctx, form, child) {
                        return Scaffold(
                          body: ScrollableContent(
                            enableFixedDigitButton: true,
                            header: const BackNavigationHelpHeaderWidget(
                              showHelp: false,
                            ),
                            footer: SizedBox(
                              child: DigitCard(
                                  margin: const EdgeInsets.fromLTRB(
                                      0, spacer2, 0, 0),
                                  children: [
                                    ReactiveFormConsumer(
                                      builder: (ctx, form, child) =>
                                          DigitButton(
                                        mainAxisSize: MainAxisSize.max,
                                        size: DigitButtonSize.large,
                                        type: DigitButtonType.primary,
                                        onPressed: () async {
                                          if (int.tryParse(form
                                                      .control(_manualCountKey)
                                                      .value) !=
                                                  stockState.stockInHand &&
                                              (form
                                                          .control(
                                                            _reconciliationCommentsKey,
                                                          )
                                                          .value ==
                                                      null ||
                                                  form
                                                          .control(
                                                            _reconciliationCommentsKey,
                                                          )
                                                          .value
                                                          .length <
                                                      2)) {
                                            // ignore: avoid_dynamic_calls
                                            DigitToast.show(
                                              context,
                                              options: DigitToastOptions(
                                                localizations.translate(
                                                    i18_local
                                                        .inventoryReportDetails
                                                        .commentIsRequiredText),
                                                true,
                                                theme,
                                              ),
                                            );
                                            return;
                                          }
                                          if (!form.valid ||
                                              (form
                                                      .control(
                                                          _productVariantKey)
                                                      .value ==
                                                  null)) {
                                            return;
                                          }
                                          form.markAllAsTouched();
                                          FocusManager.instance.primaryFocus
                                              ?.unfocus();
                                          if (!form.valid) return;

                                          final bloc = ctx
                                              .read<StockReconciliationBloc>();

                                          final facilityId =
                                              InventorySingleton()
                                                          .isDistributor! &&
                                                      !InventorySingleton()
                                                          .isWareHouseMgr!
                                                  ? FacilityModel(
                                                      id: InventorySingleton()
                                                          .loggedInUserUuid!,
                                                    )
                                                  : FacilityModel(
                                                      id: selectedFacilityId
                                                          .toString(),
                                                    );

                                          final productVariant = form
                                              .control(_productVariantKey)
                                              .value as ProductVariantModel;

                                          final calculatedCount = form
                                              .control(_manualCountKey)
                                              .value as String;

                                          final comments = form
                                              .control(
                                                _reconciliationCommentsKey,
                                              )
                                              .value as String?;

                                          final model =
                                              StockReconciliationModel(
                                            clientReferenceId:
                                                IdGen.i.identifier,
                                            dateOfReconciliation: stockState
                                                .dateOfReconciliation
                                                .millisecondsSinceEpoch,
                                            facilityId: facilityId.id,
                                            productVariantId: productVariant.id,
                                            calculatedCount:
                                                stockState.stockInHand.toInt(),
                                            commentsOnReconciliation: comments,
                                            physicalCount: int.tryParse(
                                                  calculatedCount,
                                                ) ??
                                                0,
                                            auditDetails: AuditDetails(
                                              createdBy: InventorySingleton()
                                                  .loggedInUserUuid,
                                              createdTime:
                                                  ContextUtilityExtensions(
                                                          context)
                                                      .millisecondsSinceEpoch(),
                                            ),
                                            clientAuditDetails:
                                                ClientAuditDetails(
                                              createdBy: InventorySingleton()
                                                  .loggedInUserUuid,
                                              createdTime:
                                                  ContextUtilityExtensions(
                                                          context)
                                                      .millisecondsSinceEpoch(),
                                              lastModifiedBy:
                                                  InventorySingleton()
                                                      .loggedInUserUuid,
                                              lastModifiedTime:
                                                  ContextUtilityExtensions(
                                                          context)
                                                      .millisecondsSinceEpoch(),
                                            ),
                                          );

                                          final submit = await showCustomPopup(
                                            context: context,
                                            builder: (popupContext) => Popup(
                                              title: localizations.translate(
                                                i18.stockReconciliationDetails
                                                    .dialogTitle,
                                              ),
                                              onOutsideTap: () {
                                                Navigator.of(
                                                  popupContext,
                                                  rootNavigator: true,
                                                ).pop(false);
                                              },
                                              description:
                                                  localizations.translate(
                                                i18.stockReconciliationDetails
                                                    .dialogContent,
                                              ),
                                              type: PopUpType.simple,
                                              actions: [
                                                DigitButton(
                                                  label:
                                                      localizations.translate(
                                                    i18.common.coreCommonSubmit,
                                                  ),
                                                  onPressed: () {
                                                    Navigator.of(
                                                      popupContext,
                                                      rootNavigator: true,
                                                    ).pop(true);
                                                  },
                                                  type: DigitButtonType.primary,
                                                  size: DigitButtonSize.large,
                                                ),
                                                DigitButton(
                                                  label:
                                                      localizations.translate(
                                                    i18.common.coreCommonCancel,
                                                  ),
                                                  onPressed: () {
                                                    Navigator.of(
                                                      popupContext,
                                                      rootNavigator: true,
                                                    ).pop(false);
                                                  },
                                                  type:
                                                      DigitButtonType.secondary,
                                                  size: DigitButtonSize.large,
                                                ),
                                              ],
                                            ),
                                          ) as bool;

                                          if (submit) {
                                            bloc.add(
                                              StockReconciliationCreateEvent(
                                                model,
                                              ),
                                            );
                                          }
                                        },
                                        label: localizations.translate(
                                          i18.common.coreCommonSubmit,
                                        ),
                                      ),
                                    ),
                                  ]),
                            ),
                            children: [
                              DigitCard(
                                margin: const EdgeInsets.all(spacer2),
                                children: [
                                  Text(
                                    localizations.translate(
                                      i18.stockReconciliationDetails
                                          .reconciliationPageTitle,
                                    ),
                                    style: Theme.of(context)
                                        .digitTextTheme(context)
                                        .headingXl,
                                  ),
                                  if (InventorySingleton().isWareHouseMgr!)
                                    BlocConsumer<FacilityBloc, FacilityState>(
                                      listener: (context, state) =>
                                          state.whenOrNull(
                                        empty: () =>
                                            NoFacilitiesAssignedDialog.show(
                                          context,
                                          localizations,
                                        ),
                                      ),
                                      builder: (context, state) {
                                        return state.maybeWhen(
                                            orElse: () => const Offstage(),
                                            loading: () => const Center(
                                                  child:
                                                      CircularProgressIndicator(),
                                                ),
                                            fetched:
                                                (facilities, allFacilities) {
                                              if (context.selectedProject
                                                      .address?.boundaryType ==
                                                  Constants
                                                      .stateBoundaryLevel) {
                                                List<FacilityModel>
                                                    filteredFacilities =
                                                    facilities
                                                        .where(
                                                          (element) =>
                                                              element.usage ==
                                                              Constants
                                                                  .stateFacility,
                                                        )
                                                        .toList();
                                                facilities =
                                                    filteredFacilities.isEmpty
                                                        ? facilities
                                                        : filteredFacilities;
                                              } else if (context.selectedProject
                                                      .address?.boundaryType ==
                                                  Constants.lgaBoundaryLevel) {
                                                List<FacilityModel>
                                                    filteredFacilities =
                                                    facilities
                                                        .where(
                                                          (element) =>
                                                              element.usage ==
                                                              Constants
                                                                  .lgaFacility,
                                                        )
                                                        .toList();
                                                facilities =
                                                    filteredFacilities.isEmpty
                                                        ? facilities
                                                        : filteredFacilities;
                                              } else {
                                                List<FacilityModel>
                                                    filteredFacilities =
                                                    facilities
                                                        .where(
                                                          (element) =>
                                                              element.usage ==
                                                              Constants
                                                                  .healthFacility,
                                                        )
                                                        .toList();
                                                facilities =
                                                    filteredFacilities.isEmpty
                                                        ? facilities
                                                        : filteredFacilities;
                                              }
                                              final teamFacilities = [
                                                FacilityModel(
                                                  id: 'Delivery Team',
                                                  name: 'Delivery Team',
                                                ),
                                              ];
                                              teamFacilities.addAll(
                                                facilities,
                                              );
                                              return Column(
                                                children: [
                                                  InkWell(
                                                    onTap: () async {
                                                      final stockReconciliationBloc =
                                                          context.read<
                                                              StockReconciliationBloc>();
                                                      final facility = await context
                                                              .router
                                                              .push(InventoryFacilitySelectionRoute(
                                                                  facilities:
                                                                      facilities))
                                                          as FacilityModel?;

                                                      if (facility == null)
                                                        return;
                                                      form
                                                              .control(_facilityKey)
                                                              .value =
                                                          localizations
                                                              .translate(
                                                        'FAC_${facility.id}',
                                                      );
                                                      controller1.text =
                                                          localizations
                                                              .translate(
                                                        'FAC_${facility.id}',
                                                      );
                                                      setState(() {
                                                        selectedFacilityId =
                                                            facility.id;
                                                      });
                                                      stockReconciliationBloc
                                                          .add(
                                                        StockReconciliationSelectFacilityEvent(
                                                          facility,
                                                        ),
                                                      );
                                                    },
                                                    child: IgnorePointer(
                                                      child:
                                                          ReactiveWrapperField(
                                                        formControlName:
                                                            _facilityKey,
                                                        builder: (field) {
                                                          return InputField(
                                                            type: InputType
                                                                .search,
                                                            isRequired: true,
                                                            controller:
                                                                controller1,
                                                            label: localizations
                                                                .translate(
                                                              i18.stockReconciliationDetails
                                                                  .facilityLabel,
                                                            ),
                                                          );
                                                        },
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              );
                                            });
                                      },
                                    ),
                                  BlocBuilder<InventoryProductVariantBloc,
                                      InventoryProductVariantState>(
                                    builder: (context, state) {
                                      return state.maybeWhen(
                                        orElse: () => const Offstage(),
                                        loading: () => const Center(
                                          child: CircularProgressIndicator(),
                                        ),
                                        empty: () => Center(
                                          child: Text(
                                            i18.stockDetails.noProductsFound,
                                          ),
                                        ),
                                        fetched: (productVariants) {
                                          return ReactiveWrapperField(
                                            formControlName: _productVariantKey,
                                            validationMessages: {
                                              'required': (error) =>
                                                  localizations.translate(i18
                                                      .common
                                                      .corecommonRequired),
                                            },
                                            showErrors: (control) =>
                                                control.invalid &&
                                                control.touched,
                                            builder: (field) {
                                              return LabeledField(
                                                isRequired: true,
                                                label: localizations.translate(
                                                  i18.stockReconciliationDetails
                                                      .productLabel,
                                                ),
                                                child: DigitDropdown(
                                                  emptyItemText:
                                                      localizations.translate(
                                                    i18.common.noMatchFound,
                                                  ),
                                                  sentenceCaseEnabled: false,
                                                  items: productVariants
                                                      .map((variant) {
                                                    return DropdownItem(
                                                      name: localizations
                                                          .translate(
                                                            variant.sku ??
                                                                variant.id,
                                                          )
                                                          .toUpperCase(),
                                                      code: variant.id,
                                                    );
                                                  }).toList(),
                                                  selectedOption: (field
                                                              .control.value !=
                                                          null)
                                                      ? DropdownItem(
                                                          name: localizations
                                                              .translate(
                                                                (field.control.value
                                                                            as ProductVariantModel)
                                                                        .sku ??
                                                                    (field.control.value
                                                                            as ProductVariantModel)
                                                                        .id,
                                                              )
                                                              .toUpperCase(),
                                                          code: (field.control
                                                                      .value
                                                                  as ProductVariantModel)
                                                              .id)
                                                      : const DropdownItem(
                                                          name: '', code: ''),
                                                  onSelect: (value) {
                                                    field.control
                                                        .markAsTouched();
                                                    final selectedVariant =
                                                        productVariants
                                                            .firstWhere(
                                                      (variant) =>
                                                          variant.id ==
                                                          value.code,
                                                    );
                                                    field.control.value =
                                                        selectedVariant;
                                                    ctx
                                                        .read<
                                                            StockReconciliationBloc>()
                                                        .add(
                                                          StockReconciliationSelectProductEvent(
                                                            value.code,
                                                            isDistributor: InventorySingleton()
                                                                    .isDistributor! &&
                                                                !InventorySingleton()
                                                                    .isWareHouseMgr!,
                                                          ),
                                                        );
                                                  },
                                                ),
                                              );
                                            },
                                          );
                                        },
                                      );
                                    },
                                  ),
                                  LabelValueItem(
                                    label: localizations.translate(i18
                                        .stockReconciliationDetails
                                        .dateOfReconciliation),
                                    value: DateFormat('dd MMMM yyyy').format(
                                        stockState.dateOfReconciliation),
                                    labelFlex: 5,
                                  ),
                                  const DigitDivider(),
                                  LabelValueItem(
                                    label: localizations.translate(
                                      i18.stockReconciliationDetails
                                          .stockReceived,
                                    ),
                                    value: stockState.stockReceived
                                        .toStringAsFixed(0),
                                    labelFlex: 5,
                                  ),
                                  const DigitDivider(),
                                  LabelValueItem(
                                    label: localizations.translate(
                                      i18.stockReconciliationDetails
                                          .stockIssued,
                                    ),
                                    value: stockState.stockIssued >
                                            stockState.stockReceived
                                        ? stockState.stockReceived
                                            .toStringAsFixed(0)
                                        : stockState.stockIssued
                                            .toStringAsFixed(0),
                                    labelFlex: 5,
                                  ),
                                  const DigitDivider(),
                                  LabelValueItem(
                                    label: localizations.translate(
                                      i18.stockReconciliationDetails
                                          .stockReturned,
                                    ),
                                    value: stockState.stockReturned
                                        .toStringAsFixed(0),
                                    labelFlex: 5,
                                  ),
                                  const DigitDivider(),
                                  LabelValueItem(
                                    label: localizations.translate(i18
                                        .stockReconciliationDetails
                                        .stockOnHand),
                                    value: stockState.stockInHand < 0
                                        ? 0.toStringAsFixed(0)
                                        : stockState.stockInHand
                                            .toStringAsFixed(0),
                                    labelFlex: 5,
                                  ),
                                  InfoCard(
                                    type: InfoType.info,
                                    description: localizations.translate(
                                      i18.stockReconciliationDetails
                                          .infoCardContent,
                                    ),
                                    title: localizations.translate(
                                      i18.stockReconciliationDetails
                                          .infoCardTitle,
                                    ),
                                  ),
                                  const DigitDivider(),
                                  ReactiveWrapperField(
                                      formControlName: _manualCountKey,
                                      validationMessages: {
                                        "required": (object) =>
                                            localizations.translate(i18
                                                .stockReconciliationDetails
                                                .manualCountRequiredError),
                                        "number": (object) =>
                                            localizations.translate(i18
                                                .stockReconciliationDetails
                                                .manualCountInvalidType),
                                        "min": (object) =>
                                            localizations.translate(i18
                                                .stockReconciliationDetails
                                                .manualCountMinError),
                                        "max": (object) =>
                                            localizations.translate(i18_local
                                                .stockReconciliationDetails
                                                .manualCountMaxErrorUpdated),
                                      },
                                      showErrors: (control) =>
                                          control.invalid && control.touched,
                                      builder: (field) {
                                        return LabeledField(
                                          label: localizations.translate(
                                            i18.stockReconciliationDetails
                                                .manualCountLabel,
                                          ),
                                          isRequired: true,
                                          child: BaseDigitFormInput(
                                            errorMessage: field.errorText,
                                            keyboardType: const TextInputType
                                                .numberWithOptions(
                                              decimal: false,
                                            ),
                                            initialValue: '0',
                                            onChange: (value) {
                                              field.control.markAsTouched();
                                              field.control.value = value;
                                              form
                                                  .control(
                                                      _reconciliationCommentsKey)
                                                  .updateValueAndValidity();
                                            },
                                          ),
                                        );
                                      }),
                                  ReactiveWrapperField<String>(
                                    formControlName: _reconciliationCommentsKey,
                                    builder: (field) {
                                      return InputField(
                                        errorMessage: field.errorText,
                                        type: InputType.textArea,
                                        label: localizations.translate(
                                          i18.stockReconciliationDetails
                                              .commentsLabel,
                                        ),
                                        textAreaScroll: TextAreaScroll.smart,
                                        onChange: (value) {
                                          field.control.value = value;
                                        },
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          );
  }
}
