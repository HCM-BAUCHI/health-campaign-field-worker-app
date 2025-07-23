import 'package:auto_route/auto_route.dart';
import 'package:digit_components/widgets/atoms/digit_toaster.dart';
import 'package:digit_data_model/data_model.dart';
import 'package:digit_scanner/blocs/scanner.dart';
import 'package:flutter/services.dart';
import '../../utils/upper_case.dart';
import '../../utils/utils.dart';
import './qr_scanner.dart';
import 'package:digit_ui_components/digit_components.dart';
import 'package:digit_ui_components/services/location_bloc.dart';
import 'package:digit_ui_components/theme/digit_extended_theme.dart';
import 'package:digit_ui_components/utils/component_utils.dart';
import 'package:digit_ui_components/widgets/atoms/input_wrapper.dart';
import 'package:digit_ui_components/widgets/atoms/pop_up_card.dart';
import 'package:digit_ui_components/widgets/molecules/digit_card.dart';
import 'package:digit_ui_components/widgets/molecules/show_pop_up.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gs1_barcode_parser/gs1_barcode_parser.dart';
import 'package:inventory_management/inventory_management.dart';
import 'package:reactive_forms/reactive_forms.dart';

import 'package:inventory_management/utils/i18_key_constants.dart' as i18;
import 'package:inventory_management/widgets/localized.dart';
import 'package:inventory_management/blocs/product_variant.dart';
import 'package:inventory_management/blocs/record_stock.dart';
import 'package:inventory_management/widgets/back_navigation_help_header.dart';

import '../../blocs/auth/auth.dart';
import '../../router/app_router.dart';
import '../../utils/constants.dart';
import '../../utils/extensions/extensions.dart';
import '../../utils/i18_key_constants.dart' as i18_local;

@RoutePage()
class CustomStockDetailsPage extends LocalizedStatefulWidget {
  const CustomStockDetailsPage({
    super.key,
    super.appLocalizations,
  });

  @override
  State<CustomStockDetailsPage> createState() => CustomStockDetailsPageState();
}

class CustomStockDetailsPageState
    extends LocalizedState<CustomStockDetailsPage> {
  static const _productVariantKey = 'productVariant';
  static const _secondaryPartyKey = 'secondaryParty';
  static const _transactionQuantityKey = 'quantity';
  // static const _partialBlistersKey = 'partialBlistersReturned';
  // static const _wastedBlistersKey = 'wastedBlistersReturned';
  static const _transactionReasonKey = 'transactionReason';
  static const _waybillNumberKey = 'waybillNumber';
  static const _waybillQuantityKey = 'waybillQuantity';
  static const _vehicleNumberKey = 'vehicleNumber';
  static const _typeOfTransportKey = 'typeOfTransport';
  static const _batchNumberKey = 'batchNumber';

  static const _commentsKey = 'comments';
  static const _deliveryTeamKey = 'deliveryTeam';
  static const _supervisorKey = 'supervisor';

  static int maxQuantity = 100000000;
  static int minQuantity = 0;
  bool deliveryTeamSelected = false;
  String? selectedFacilityId;
  bool isSpaq1 = true;
  List<InventoryTransportTypes> transportTypes = [];

  List<GS1Barcode> scannedResources = [];
  TextEditingController controller1 = TextEditingController();

  List<ValidatorFunction> partialBlistersQuantityValidator = [];
  List<ValidatorFunction> batchNumberValidators = [];
  List<ValidatorFunction> wastedBlistersQuantityValidator = [];

  FormGroup _form(bool isDistributor, bool isHealthFacilitySupervisor,
      StockRecordEntryType entryType) {
    deliveryTeamSelected = context.isHealthFacilitySupervisor &&
        entryType != StockRecordEntryType.receipt;
    return fb.group({
      _productVariantKey: FormControl<ProductVariantModel>(),
      _secondaryPartyKey: FormControl<String>(
        validators: [],
      ),
      _transactionQuantityKey: FormControl<int>(validators: [
        Validators.number(),
        Validators.required,
        Validators.min(1),
        Validators.max(100000000),
      ]),
      _transactionReasonKey: FormControl<String>(),
      _waybillNumberKey: FormControl<String>(
        validators: [Validators.minLength(0), Validators.maxLength(200)],
      ),
      _waybillQuantityKey: FormControl<String>(),
      _batchNumberKey: FormControl<String>(),
      _vehicleNumberKey: FormControl<String>(),
      _typeOfTransportKey: FormControl<String>(),
      _commentsKey: FormControl<String>(),
      _deliveryTeamKey: FormControl<String>(
        validators: deliveryTeamSelected ? [Validators.required] : [],
      ),
    });
  }

  @override
  void initState() {
    clearQRCodes();
    transportTypes = InventorySingleton().transportType;
    context.read<LocationBloc>().add(const LoadLocationEvent());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.digitTextTheme(context);
    final isDistributor = context.isDistributor;

    bool isWareHouseMgr = InventorySingleton().isWareHouseMgr;
    final isHealthFacilitySupervisor = context.isHealthFacilitySupervisor;

    return PopScope(
      onPopInvoked: (didPop) {
        final stockState = context.read<RecordStockBloc>().state;
        if (stockState.primaryId != null) {
          context.read<DigitScannerBloc>().add(
                DigitScannerEvent.handleScanner(
                  barCode: [],
                  qrCode: [stockState.primaryId.toString()],
                ),
              );
        }
      },
      child: Scaffold(
        body: BlocBuilder<LocationBloc, LocationState>(
          builder: (context, locationState) {
            return BlocConsumer<RecordStockBloc, RecordStockState>(
              listener: (context, stockState) {
                stockState.mapOrNull(
                  persisted: (value) {
                    final parent = context.router.parent() as StackRouter;
                    // parent.replace(
                    //   CustomInventoryAcknowledgementRoute(),
                    // );
                  },
                );
              },
              builder: (context, stockState) {
                StockRecordEntryType entryType = stockState.entryType;

                const module = i18.stockDetails;
                final isWarehouseMgr = context.isWarehouseMgr;
                deliveryTeamSelected = context.isHealthFacilitySupervisor &&
                    entryType != StockRecordEntryType.receipt;

                String pageTitle;
                String quantityCountLabel;
                String transactionPartyLabel;
                String? transactionReasonLabel;
                String? transactionReason;
                String transactionType;

                List<String>? reasons;

                switch (entryType) {
                  case StockRecordEntryType.receipt:
                    pageTitle = module.receivedPageTitle;
                    transactionPartyLabel =
                        module.selectTransactingPartyReceived;
                    quantityCountLabel = module.quantityReceivedLabel;
                    transactionType = TransactionType.received.toValue();

                    break;
                  case StockRecordEntryType.dispatch:
                    pageTitle = isDistributor
                        ? module.returnedPageTitle
                        : module.issuedPageTitle;
                    // quantityCountLabel = module.quantitySentLabel;
                    transactionPartyLabel = isDistributor
                        ? module.selectTransactingPartyReturned
                        : module.selectTransactingPartyIssued;
                    quantityCountLabel = isDistributor
                        ? module.quantityReturnedLabel
                        : module.quantitySentLabel;
                    transactionType = TransactionType.dispatched.toValue();

                    if (context.isDistributor) {
                      wastedBlistersQuantityValidator = [
                        Validators.required,
                        Validators.min(minQuantity),
                        Validators.max(maxQuantity),
                      ];

                      partialBlistersQuantityValidator = [
                        Validators.required,
                        Validators.min(minQuantity),
                        Validators.max(maxQuantity),
                      ];

                      batchNumberValidators = [];
                    }

                    break;
                  case StockRecordEntryType.returned:
                    pageTitle = module.returnedPageTitle;
                    transactionPartyLabel =
                        module.selectTransactingPartyReturned;
                    quantityCountLabel = module.quantityReturnedLabel;
                    transactionType = TransactionType.received.toValue();
                    partialBlistersQuantityValidator = [
                      Validators.required,
                      Validators.min(minQuantity),
                      Validators.max(maxQuantity),
                    ];
                    break;
                  case StockRecordEntryType.loss:
                    pageTitle = module.lostPageTitle;
                    transactionPartyLabel =
                        module.selectTransactingPartyReceivedFromLost;
                    quantityCountLabel = module.quantityLostLabel;
                    transactionReasonLabel = module.transactionReasonLost;
                    transactionType = TransactionType.dispatched.toValue();

                    reasons = [
                      TransactionReason.lostInStorage.toValue(),
                      TransactionReason.lostInTransit.toValue(),
                    ];
                    break;
                  case StockRecordEntryType.damaged:
                    pageTitle = module.damagedPageTitle;
                    transactionPartyLabel =
                        module.selectTransactingPartyReceivedFromDamaged;
                    quantityCountLabel = module.quantityDamagedLabel;
                    transactionReasonLabel = module.transactionReasonDamaged;
                    transactionType = TransactionType.dispatched.toValue();

                    reasons = [
                      TransactionReason.damagedInStorage.toValue(),
                      TransactionReason.damagedInTransit.toValue(),
                    ];
                    break;
                }

                transactionReasonLabel ??= '';

                return ReactiveFormBuilder(
                  form: () => _form(
                      isDistributor, isHealthFacilitySupervisor, entryType),
                  builder: (context, form, child) {
                    return BlocBuilder<DigitScannerBloc, DigitScannerState>(
                        builder: (context, scannerState) {
                      if (scannerState.barCodes.isNotEmpty) {
                        scannedResources.clear();
                        scannedResources.addAll(scannerState.barCodes);
                      }

                      return ScrollableContent(
                        header: Column(children: [
                          BackNavigationHelpHeaderWidget(
                            handleBack: () {
                              final stockState =
                                  context.read<RecordStockBloc>().state;
                              if (stockState.primaryId != null) {
                                context.read<DigitScannerBloc>().add(
                                      DigitScannerEvent.handleScanner(
                                        barCode: [],
                                        qrCode: [
                                          stockState.primaryId.toString()
                                        ],
                                      ),
                                    );
                              }
                            },
                          ),
                        ]),
                        enableFixedDigitButton: true,
                        footer: DigitCard(
                          margin: const EdgeInsets.fromLTRB(0, spacer2, 0, 0),
                          children: [
                            ReactiveFormConsumer(
                                builder: (context, form, child) {
                              if (form
                                      .control(_deliveryTeamKey)
                                      .value
                                      .toString()
                                      .isEmpty ||
                                  form.control(_deliveryTeamKey).value ==
                                      null ||
                                  scannerState.qrCodes.isNotEmpty) {
                                form.control(_deliveryTeamKey).value =
                                    scannerState.qrCodes.isNotEmpty
                                        ? scannerState.qrCodes.last
                                        : '';
                              }
                              return DigitButton(
                                type: DigitButtonType.primary,
                                size: DigitButtonSize.large,
                                mainAxisSize: MainAxisSize.max,
                                onPressed: () async {
                                  form.markAllAsTouched();
                                  if (!form.valid) {
                                    Toast.showToast(
                                      context,
                                      type: ToastType.error,
                                      message: localizations.translate(
                                        i18_local
                                            .common.pleaseEnterRequiredDetails,
                                      ),
                                    );
                                    return;
                                  }
                                  final primaryId =
                                      BlocProvider.of<RecordStockBloc>(
                                    context,
                                  ).state.primaryId;
                                  final secondaryParty =
                                      selectedFacilityId != null
                                          ? FacilityModel(
                                              id: selectedFacilityId.toString(),
                                            )
                                          : null;

                                  final deliveryTeamName = form
                                      .control(_deliveryTeamKey)
                                      .value as String?;
                                  if ((form.control(_productVariantKey).value ==
                                      null)) {
                                    Toast.showToast(
                                      context,
                                      type: ToastType.error,
                                      message: localizations.translate(
                                        i18.stockDetails.selectProductLabel,
                                      ),
                                    );
                                  } else if ([
                                        StockRecordEntryType.loss,
                                        StockRecordEntryType.damaged,
                                      ].contains(entryType) &&
                                      form
                                              .control(_transactionReasonKey)
                                              .value ==
                                          null) {
                                    Toast.showToast(
                                      context,
                                      type: ToastType.error,
                                      message: localizations.translate(
                                        i18_local
                                            .common.pleaseEnterRequiredDetails,
                                      ),
                                    );
                                  } else if (controller1.text.isEmpty) {
                                    Toast.showToast(context,
                                        type: ToastType.error,
                                        message: '${localizations.translate(
                                          '${pageTitle}_${i18.stockReconciliationDetails.stockLabel}',
                                        )} ?');
                                  } else if (deliveryTeamSelected &&
                                      (form
                                                  .control(
                                                    _deliveryTeamKey,
                                                  )
                                                  .value ==
                                              null ||
                                          form
                                              .control(_deliveryTeamKey)
                                              .value
                                              .toString()
                                              .trim()
                                              .isEmpty)) {
                                    Toast.showToast(
                                      context,
                                      type: ToastType.error,
                                      message: localizations.translate(
                                        i18.stockDetails.teamCodeRequired,
                                      ),
                                    );
                                  } else if ((primaryId ==
                                          secondaryParty?.id) ||
                                      (primaryId == deliveryTeamName)) {
                                    Toast.showToast(
                                      context,
                                      type: ToastType.error,
                                      message: localizations.translate(
                                        i18.stockDetails
                                            .senderReceiverValidation,
                                      ),
                                    );
                                  } else {
                                    FocusManager.instance.primaryFocus
                                        ?.unfocus();
                                    context
                                        .read<LocationBloc>()
                                        .add(const LoadLocationEvent());
                                    DigitComponentsUtils.showDialog(
                                        context,
                                        localizations.translate(
                                            i18.common.locationCapturing),
                                        DialogType.inProgress);
                                    Future.delayed(const Duration(seconds: 2),
                                        () async {
                                      DigitComponentsUtils.hideDialog(context);
                                      final bloc =
                                          context.read<RecordStockBloc>();

                                      final productVariant = form
                                          .control(_productVariantKey)
                                          .value as ProductVariantModel;

                                      switch (entryType) {
                                        case StockRecordEntryType.receipt:
                                          transactionReason = TransactionReason
                                              .received
                                              .toValue();
                                          break;
                                        case StockRecordEntryType.dispatch:
                                          transactionReason = null;
                                          break;
                                        case StockRecordEntryType.returned:
                                          transactionReason = TransactionReason
                                              .returned
                                              .toValue();
                                          break;
                                        default:
                                          transactionReason = form
                                              .control(
                                                _transactionReasonKey,
                                              )
                                              .value as String?;
                                          break;
                                      }

                                      final quantity = form
                                          .control(_transactionQuantityKey)
                                          .value;

                                      final waybillNumber = form
                                          .control(_waybillNumberKey)
                                          .value as String?;

                                      final waybillQuantity = form
                                          .control(_waybillQuantityKey)
                                          .value as String?;

                                      final batchNumber = form
                                          .control(_waybillQuantityKey)
                                          .value as String?;

                                      final vehicleNumber = form
                                          .control(_vehicleNumberKey)
                                          .value as String?;

                                      final lat = locationState.latitude;
                                      final lng = locationState.longitude;

                                      final hasLocationData =
                                          lat != null && lng != null;

                                      final transportType = form
                                          .control(
                                            _typeOfTransportKey,
                                          )
                                          .value as String?;

                                      // final partialBlisters = form
                                      //     .control(
                                      //       _partialBlistersKey,
                                      //     )
                                      //     .value;

                                      // final wastedBlisters = form
                                      //     .control(
                                      //       _wastedBlistersKey,
                                      //     )
                                      //     .value;

                                      final comments = form
                                          .control(_commentsKey)
                                          .value as String?;

                                      final deliveryTeamName = form
                                          .control(_deliveryTeamKey)
                                          .value as String?;

                                      if ((entryType ==
                                                  StockRecordEntryType
                                                      .returned &&
                                              isHealthFacilitySupervisor &&
                                              quantity == 0) ||
                                          (entryType ==
                                                  StockRecordEntryType
                                                      .dispatch &&
                                              isDistributor &&
                                              quantity == 0)) {
                                        DigitToast.show(
                                          context,
                                          options: DigitToastOptions(
                                            localizations.translate(
                                              i18.common.minValue,
                                            ),
                                            true,
                                            theme,
                                          ),
                                        );

                                        return;
                                      }

                                      String secondaryKey = form
                                          .control(_secondaryPartyKey)
                                          .value;

                                      String? senderId;
                                      String? senderType;
                                      String? receiverId;
                                      String? receiverType;

                                      final primaryType =
                                          BlocProvider.of<RecordStockBloc>(
                                        context,
                                      ).state.primaryType;

                                      final primaryId =
                                          BlocProvider.of<RecordStockBloc>(
                                        context,
                                      ).state.primaryId;

                                      switch (entryType) {
                                        case StockRecordEntryType.receipt:
                                        // case StockRecordEntryType.loss:
                                        // case StockRecordEntryType.damaged:
                                        case StockRecordEntryType.returned:
                                          if (deliveryTeamSelected) {
                                            // senderId = deliveryTeamName;
                                            senderType = "STAFF";
                                            senderId = secondaryKey
                                                .split(Constants.pipeSeparator)
                                                .last;
                                            if (deliveryTeamName != null &&
                                                deliveryTeamName
                                                    .trim()
                                                    .isNotEmpty) {
                                              senderId = deliveryTeamName
                                                  .toLowerCase();
                                            }

                                            receiverId = primaryId;
                                            receiverType = primaryType;
                                          } else {
                                            senderId = secondaryParty?.id;
                                            senderType = "WAREHOUSE";
                                          }
                                          receiverId = primaryId!
                                              .split(Constants.pipeSeparator)
                                              .last;
                                          ;
                                          receiverType = primaryType;
                                          break;
                                        case StockRecordEntryType.dispatch:
                                        case StockRecordEntryType.loss:
                                        case StockRecordEntryType.damaged:
                                          if (deliveryTeamSelected) {
                                            // receiverId = deliveryTeamName;
                                            // receiverType = "STAFF";
                                            receiverId = secondaryKey
                                                .split(Constants.pipeSeparator)
                                                .last;
                                            if (deliveryTeamName != null &&
                                                deliveryTeamName
                                                    .trim()
                                                    .isNotEmpty) {
                                              receiverId = deliveryTeamName
                                                  .toLowerCase();
                                            }
                                            receiverType = "STAFF";
                                            senderId = primaryId;
                                            senderType = primaryType;
                                          } else {
                                            receiverId = secondaryParty?.id;
                                            receiverType = "WAREHOUSE";
                                          }
                                          senderId = primaryId!
                                              .split(Constants.pipeSeparator)
                                              .last;
                                          senderType = primaryType;
                                          break;
                                      }

                                      final stockModel = StockModel(
                                        clientReferenceId: IdGen.i.identifier,
                                        productVariantId: productVariant.id,
                                        transactionReason: transactionReason,
                                        transactionType: transactionType,
                                        referenceId: stockState.projectId,
                                        referenceIdType: 'PROJECT',
                                        quantity: quantity.toString(),
                                        wayBillNumber: waybillNumber,
                                        receiverId: receiverId,
                                        receiverType: receiverType,
                                        senderId: senderId,
                                        senderType: senderType,
                                        auditDetails: AuditDetails(
                                          createdBy: InventorySingleton()
                                              .loggedInUserUuid,
                                          createdTime:
                                              context.millisecondsSinceEpoch(),
                                        ),
                                        clientAuditDetails: ClientAuditDetails(
                                          createdBy: InventorySingleton()
                                              .loggedInUserUuid,
                                          createdTime:
                                              context.millisecondsSinceEpoch(),
                                          lastModifiedBy: InventorySingleton()
                                              .loggedInUserUuid,
                                          lastModifiedTime:
                                              context.millisecondsSinceEpoch(),
                                        ),
                                        additionalFields: [
                                                  waybillQuantity,
                                                  batchNumber,
                                                  vehicleNumber,
                                                  comments,
                                                ].any((element) =>
                                                    element != null) ||
                                                hasLocationData
                                            ? StockAdditionalFields(
                                                version: 1,
                                                fields: [
                                                  AdditionalField(
                                                    InventoryManagementEnums
                                                        .name
                                                        .toValue(),
                                                    InventorySingleton()
                                                        .loggedInUser
                                                        ?.name,
                                                  ),
                                                  if (waybillQuantity != null &&
                                                      waybillQuantity
                                                          .trim()
                                                          .isNotEmpty)
                                                    AdditionalField(
                                                      'waybill_quantity',
                                                      waybillQuantity,
                                                    ),
                                                  if (batchNumber != null &&
                                                      batchNumber
                                                          .trim()
                                                          .isNotEmpty)
                                                    AdditionalField(
                                                      'batch_number',
                                                      batchNumber,
                                                    ),
                                                  if (vehicleNumber != null &&
                                                      vehicleNumber
                                                          .trim()
                                                          .isNotEmpty)
                                                    AdditionalField(
                                                      'vehicle_number',
                                                      vehicleNumber,
                                                    ),
                                                  if (comments != null &&
                                                      comments
                                                          .trim()
                                                          .isNotEmpty)
                                                    AdditionalField(
                                                      'comments',
                                                      comments,
                                                    ),
                                                  if (deliveryTeamName !=
                                                          null &&
                                                      deliveryTeamName
                                                          .trim()
                                                          .isNotEmpty)
                                                    AdditionalField(
                                                      'deliveryTeam',
                                                      deliveryTeamName
                                                          .toLowerCase(),
                                                    ),
                                                  if (hasLocationData) ...[
                                                    AdditionalField(
                                                      'lat',
                                                      lat,
                                                    ),
                                                    AdditionalField(
                                                      'lng',
                                                      lng,
                                                    ),
                                                  ],
                                                  if (scannerState
                                                      .barCodes.isNotEmpty)
                                                    addBarCodesToFields(
                                                        scannerState.barCodes),
                                                ],
                                              )
                                            : null,
                                      );

                                      bloc.add(
                                        RecordStockSaveStockDetailsEvent(
                                          stockModel: stockModel,
                                        ),
                                      );

                                      final submit = await showCustomPopup(
                                        context: context,
                                        builder: (popupContext) => Popup(
                                          title: localizations.translate(
                                            i18.stockDetails.dialogTitle,
                                          ),
                                          onOutsideTap: () {
                                            Navigator.of(popupContext)
                                                .pop(false);
                                          },
                                          description: localizations.translate(
                                            i18.stockDetails.dialogContent,
                                          ),
                                          type: PopUpType.simple,
                                          actions: [
                                            DigitButton(
                                              label: localizations.translate(
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
                                              label: localizations.translate(
                                                i18.common.coreCommonCancel,
                                              ),
                                              onPressed: () {
                                                Navigator.of(
                                                  popupContext,
                                                  rootNavigator: true,
                                                ).pop(false);
                                              },
                                              type: DigitButtonType.secondary,
                                              size: DigitButtonSize.large,
                                            ),
                                          ],
                                        ),
                                      ) as bool;

                                      if (submit && context.mounted) {
                                        if (isDistributor) {
                                          int spaq1 = 0;
                                          int spaq2 = 0;

                                          int totalQuantity = 0;

                                          totalQuantity = entryType ==
                                                      StockRecordEntryType
                                                          .dispatch ||
                                                  entryType ==
                                                      StockRecordEntryType
                                                          .loss ||
                                                  entryType ==
                                                      StockRecordEntryType
                                                          .damaged
                                              ? ((quantity != null
                                                      ? int.parse(
                                                          quantity.toString(),
                                                        )
                                                      : 0)) *
                                                  -1
                                              : quantity != null
                                                  ? int.parse(
                                                      quantity.toString(),
                                                    )
                                                  : 0;

                                          if (isSpaq1) {
                                            spaq1 = totalQuantity;
                                          } else {
                                            spaq2 = totalQuantity;
                                          }

                                          if (entryType ==
                                              StockRecordEntryType.dispatch) {
                                            if (productVariant.sku ==
                                                    Constants.spaq1 &&
                                                (spaq1 + totalQuantity < 0)) {
                                              await DigitToast.show(
                                                context,
                                                options: DigitToastOptions(
                                                    localizations.translate(context
                                                            .isCDD
                                                        ? i18_local
                                                            .beneficiaryDetails
                                                            .validationForExcessStockReturn
                                                        : i18_local
                                                            .beneficiaryDetails
                                                            .validationForExcessStockDispatch),
                                                    true,
                                                    theme),
                                              );
                                              return;
                                            } else if (productVariant.sku ==
                                                    Constants.spaq2 &&
                                                (spaq2 + totalQuantity < 0)) {
                                              await DigitToast.show(
                                                context,
                                                options: DigitToastOptions(
                                                    localizations.translate(context
                                                            .isCDD
                                                        ? i18_local
                                                            .beneficiaryDetails
                                                            .validationForExcessStockReturn
                                                        : i18_local
                                                            .beneficiaryDetails
                                                            .validationForExcessStockDispatch),
                                                    true,
                                                    theme),
                                              );
                                              return;
                                            }
                                          }

                                          if (entryType ==
                                                  StockRecordEntryType.loss ||
                                              entryType ==
                                                  StockRecordEntryType
                                                      .damaged ||
                                              entryType ==
                                                  StockRecordEntryType
                                                      .returned) {
                                            if (isSpaq1 &&
                                                quantity > context.spaq1) {
                                              await DigitToast.show(
                                                context,
                                                options: DigitToastOptions(
                                                    localizations.translate(context
                                                                .isCDD ||
                                                            entryType ==
                                                                StockRecordEntryType
                                                                    .returned
                                                        ? i18_local
                                                            .beneficiaryDetails
                                                            .validationForExcessStockReturn
                                                        : i18_local
                                                            .beneficiaryDetails
                                                            .validationForExcessStockDispatch),
                                                    true,
                                                    theme),
                                              );
                                              return;
                                            } else if (!isSpaq1 &&
                                                quantity > context.spaq2) {
                                              await DigitToast.show(
                                                context,
                                                options: DigitToastOptions(
                                                    localizations.translate(context
                                                                .isCDD ||
                                                            entryType ==
                                                                StockRecordEntryType
                                                                    .returned
                                                        ? i18_local
                                                            .beneficiaryDetails
                                                            .validationForExcessStockReturn
                                                        : i18_local
                                                            .beneficiaryDetails
                                                            .validationForExcessStockDispatch),
                                                    true,
                                                    theme),
                                              );
                                              return;
                                            }
                                          }

                                          context.read<AuthBloc>().add(
                                                AuthAddSpaqCountsEvent(
                                                  spaq1Count: spaq1,
                                                  spaq2Count: spaq2,
                                                ),
                                              );
                                        } else {
                                          final now = DateTime.now();
                                          final startOfToday = DateTime(
                                                  now.year, now.month, now.day)
                                              .millisecondsSinceEpoch;
                                          final endOfToday = DateTime(
                                                  now.year,
                                                  now.month,
                                                  now.day,
                                                  23,
                                                  59,
                                                  59,
                                                  999)
                                              .millisecondsSinceEpoch;
                                          List<StockModel> sentStocks =
                                              await context
                                                  .repository<StockModel,
                                                      StockSearchModel>()
                                                  .search(
                                                    StockSearchModel(
                                                      // ignore: avoid_dynamic_calls
                                                      productVariantId: form
                                                          .control(
                                                              _productVariantKey)
                                                          .value
                                                          .id,
                                                      senderId: primaryId!
                                                          .split(Constants
                                                              .pipeSeparator)
                                                          .last,
                                                      // receiverId: [
                                                      //   deliveryTeamSelected
                                                      //       ? "FAC_Delivery Team"
                                                      //       : selectedFacilityId!
                                                      // ],
                                                      transactionType: [
                                                        TransactionType
                                                            .dispatched
                                                            .toValue()
                                                      ],
                                                    ),
                                                  );
                                          int sentStocksCount = sentStocks
                                              .where((element) =>
                                                  element.transactionReason ==
                                                      null &&
                                                  element.auditDetails !=
                                                      null &&
                                                  element.receiverId ==
                                                      (deliveryTeamSelected
                                                          ? 'FAC_${selectedFacilityId}'
                                                          : selectedFacilityId) &&
                                                  element.auditDetails
                                                          ?.createdBy ==
                                                      InventorySingleton()
                                                          .loggedInUserUuid &&
                                                  element.auditDetails!
                                                          .createdTime >=
                                                      startOfToday &&
                                                  element.auditDetails!
                                                          .createdTime <=
                                                      endOfToday)
                                              .fold<int>(
                                                  0,
                                                  (sum, element) =>
                                                      sum +
                                                      int.tryParse(
                                                          element.quantity ?? '0')!);

                                          List<StockModel>
                                              receivedFromReturnStocks =
                                              await context
                                                  .repository<StockModel,
                                                      StockSearchModel>()
                                                  .search(
                                                    StockSearchModel(
                                                      // ignore: avoid_dynamic_calls
                                                      productVariantId: form
                                                          .control(
                                                              _productVariantKey)
                                                          .value
                                                          .id,
                                                      // receiverId: [
                                                      //   primaryId!
                                                      //       .split(Constants
                                                      //           .pipeSeparator)
                                                      //       .last
                                                      // ],
                                                      senderId: deliveryTeamSelected
                                                          ? 'FAC_${selectedFacilityId}'
                                                          : selectedFacilityId,
                                                      transactionType: [
                                                        TransactionType.received
                                                            .toValue()
                                                      ],
                                                    ),
                                                  );
                                          int receivedFromReturnStocksCount =
                                              receivedFromReturnStocks
                                                  .where((element) =>
                                                      element.transactionReason ==
                                                          TransactionReason
                                                              .returned
                                                              .toValue() &&
                                                      element.auditDetails !=
                                                          null &&
                                                      element.receiverId ==
                                                          primaryId!
                                                              .split(Constants
                                                                  .pipeSeparator)
                                                              .last &&
                                                      // element.auditDetails
                                                      //         ?.createdBy ==
                                                      //     InventorySingleton()
                                                      //         .loggedInUserUuid &&
                                                      element.auditDetails!
                                                              .createdTime >=
                                                          startOfToday &&
                                                      element.auditDetails!
                                                              .createdTime <=
                                                          endOfToday)
                                                  .fold<int>(
                                                      0,
                                                      (sum, element) =>
                                                          sum +
                                                          int.tryParse(element
                                                                  .quantity ??
                                                              '0')!);

                                          if (entryType ==
                                              StockRecordEntryType.dispatch) {
                                            if (isSpaq1 &&
                                                quantity > context.spaq1) {
                                              await DigitToast.show(
                                                context,
                                                options: DigitToastOptions(
                                                    localizations.translate(context
                                                            .isCDD
                                                        ? i18_local
                                                            .beneficiaryDetails
                                                            .validationForExcessStockReturn
                                                        : i18_local
                                                            .beneficiaryDetails
                                                            .validationForExcessStockDispatch),
                                                    true,
                                                    theme),
                                              );
                                              return;
                                            } else if (!isSpaq1 &&
                                                entryType ==
                                                    StockRecordEntryType
                                                        .dispatch &&
                                                quantity > context.spaq2) {
                                              await DigitToast.show(
                                                context,
                                                options: DigitToastOptions(
                                                    localizations.translate(context
                                                            .isCDD
                                                        ? i18_local
                                                            .beneficiaryDetails
                                                            .validationForExcessStockReturn
                                                        : i18_local
                                                            .beneficiaryDetails
                                                            .validationForExcessStockDispatch),
                                                    true,
                                                    theme),
                                              );
                                              return;
                                            }
                                          }
                                          if (entryType ==
                                              StockRecordEntryType.receipt) {
                                            int spaqL1 = context.spaq1;
                                            int spaqL2 = context.spaq2;
                                            if (isSpaq1) {
                                              context.read<AuthBloc>().add(
                                                    AuthAddSpaqCountsEvent(
                                                      spaq1Count: int.parse(
                                                        quantity.toString(),
                                                      ),
                                                      spaq2Count: 0,
                                                    ),
                                                  );
                                            } else {
                                              context.read<AuthBloc>().add(
                                                    AuthAddSpaqCountsEvent(
                                                      spaq1Count: 0,
                                                      spaq2Count: int.parse(
                                                        quantity.toString(),
                                                      ),
                                                    ),
                                                  );
                                            }
                                          } else if (entryType ==
                                              StockRecordEntryType.returned) {
                                            int? spaq1Quantity = sentStocksCount -
                                                receivedFromReturnStocksCount;
                                            int? spaq2Quantity = sentStocksCount -
                                                receivedFromReturnStocksCount;
                                            int spaqLocal1 = spaq1Quantity > 0
                                                ? spaq1Quantity
                                                : 0;
                                            int spaqLocal2 = spaq2Quantity > 0
                                                ? spaq2Quantity
                                                : 0;

                                            if (isSpaq1 &&
                                                quantity > spaq1Quantity) {
                                              await DigitToast.show(
                                                context,
                                                options: DigitToastOptions(
                                                    localizations.translate(
                                                        i18_local
                                                            .beneficiaryDetails
                                                            .validationForExcessStockAcceptReturn),
                                                    true,
                                                    theme),
                                              );
                                              return;
                                            } else if (!isSpaq1 &&
                                                quantity > spaq2Quantity) {
                                              await DigitToast.show(
                                                context,
                                                options: DigitToastOptions(
                                                    localizations.translate(
                                                        i18_local
                                                            .beneficiaryDetails
                                                            .validationForExcessStockAcceptReturn),
                                                    true,
                                                    theme),
                                              );
                                              return;
                                            }

                                            if (isSpaq1) {
                                              spaqLocal1 = int.parse(
                                                quantity.toString(),
                                              );
                                              spaqLocal2 = 0;
                                            } else {
                                              spaqLocal2 = int.parse(
                                                quantity.toString(),
                                              );
                                              spaqLocal1 = 0;
                                            }

                                            context.read<AuthBloc>().add(
                                                  AuthAddSpaqCountsEvent(
                                                      spaq1Count: spaqLocal1,
                                                      spaq2Count: spaqLocal2),
                                                );
                                          } else if (entryType ==
                                                  StockRecordEntryType
                                                      .dispatch ||
                                              entryType ==
                                                  StockRecordEntryType.loss ||
                                              entryType ==
                                                  StockRecordEntryType
                                                      .damaged) {
                                            int spaqLocal1 = context.spaq1;
                                            int spaqLocal2 = context.spaq2;

                                            if (isSpaq1) {
                                              spaqLocal1 = int.parse(
                                                    quantity.toString(),
                                                  ) *
                                                  -1;
                                              spaqLocal2 = 0;
                                            } else {
                                              spaqLocal2 = int.parse(
                                                    quantity.toString(),
                                                  ) *
                                                  -1;
                                              spaqLocal1 = 0;
                                            }

                                            // add validation to check stock loss or damage
                                            if (entryType ==
                                                    StockRecordEntryType.loss ||
                                                entryType ==
                                                    StockRecordEntryType
                                                        .damaged ||
                                                entryType ==
                                                    StockRecordEntryType
                                                        .dispatch ||
                                                entryType ==
                                                    StockRecordEntryType
                                                        .returned) {
                                              if (isSpaq1 &&
                                                  quantity > context.spaq1) {
                                                await DigitToast.show(
                                                  context,
                                                  options: DigitToastOptions(
                                                      localizations.translate(
                                                          i18_local
                                                              .beneficiaryDetails
                                                              .validationForExcessStockDispatch),
                                                      true,
                                                      theme),
                                                );
                                                return;
                                              } else if (!isSpaq1 &&
                                                  quantity > context.spaq2) {
                                                await DigitToast.show(
                                                  context,
                                                  options: DigitToastOptions(
                                                      localizations.translate(
                                                          i18_local
                                                              .beneficiaryDetails
                                                              .validationForExcessStockDispatch),
                                                      true,
                                                      theme),
                                                );
                                                return;
                                              }
                                            }

                                            context.read<AuthBloc>().add(
                                                  AuthAddSpaqCountsEvent(
                                                      spaq1Count: spaqLocal1,
                                                      spaq2Count: spaqLocal2),
                                                );
                                          }
                                        }

                                        bloc.add(
                                          const RecordStockCreateStockEntryEvent(),
                                        );
                                        String descriptionText;
                                        switch (entryType) {
                                          case StockRecordEntryType.receipt:
                                            descriptionText = i18_local
                                                .acknowledgementSuccess
                                                .acknowledgementDescriptionTextReceipt;
                                            break;
                                          case StockRecordEntryType.dispatch:
                                            descriptionText = i18_local
                                                .acknowledgementSuccess
                                                .acknowledgementDescriptionTextDispatch;
                                            break;
                                          case StockRecordEntryType.returned:
                                            descriptionText = i18_local
                                                .acknowledgementSuccess
                                                .acknowledgementDescriptionTextReturned;
                                            break;
                                          case StockRecordEntryType.loss:
                                            descriptionText = i18_local
                                                .acknowledgementSuccess
                                                .acknowledgementDescriptionTextLoss;
                                            break;
                                          case StockRecordEntryType.damaged:
                                            descriptionText = i18_local
                                                .acknowledgementSuccess
                                                .acknowledgementDescriptionTextDamaged;
                                            break;
                                          default:
                                            descriptionText = i18
                                                .acknowledgementSuccess
                                                .acknowledgementDescriptionText;
                                        }

                                        (context.router.parent() as StackRouter)
                                            .maybePop();

                                        context.router.push(
                                            CustomInventoryAcknowledgementRoute(
                                                description: descriptionText));
                                      }
                                    });
                                  }
                                },
                                // isDisabled: !form.valid,
                                label: localizations
                                    .translate(i18.common.coreCommonSubmit),
                              );
                            })
                          ],
                        ),
                        children: [
                          DigitCard(
                            margin: const EdgeInsets.all(spacer2),
                            children: [
                              Text(
                                localizations.translate(pageTitle),
                                style: textTheme.headingXl,
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
                                      child: Text(localizations.translate(
                                        i18.stockDetails.noProductsFound,
                                      )),
                                    ),
                                    fetched: (productVariants) {
                                      return ReactiveWrapperField(
                                        formControlName: _productVariantKey,
                                        validationMessages: {
                                          'required': (object) =>
                                              '${module.selectProductLabel}_IS_REQUIRED',
                                        },
                                        showErrors: (control) =>
                                            control.invalid && control.touched,
                                        builder: (field) {
                                          return LabeledField(
                                            label: localizations.translate(
                                              module.selectProductLabel,
                                            ),
                                            isRequired: true,
                                            child: DigitDropdown(
                                              errorMessage: field.errorText,
                                              emptyItemText:
                                                  localizations.translate(
                                                i18.common.noMatchFound,
                                              ),
                                              items: productVariants
                                                  .map((variant) {
                                                return DropdownItem(
                                                  name: localizations
                                                      .translate(getSpaqName(
                                                        variant.sku ??
                                                            variant.id,
                                                      ))
                                                      .toUpperCase(),
                                                  code: variant.id,
                                                );
                                              }).toList(),
                                              onSelect: (value) {
                                                /// Find the selected product variant model by matching the id
                                                final selectedVariant =
                                                    productVariants.firstWhere(
                                                  (variant) =>
                                                      variant.id == value.code,
                                                );

                                                /// Update the form control with the selected product variant model
                                                field.control.value =
                                                    selectedVariant;
                                                isSpaq1 = selectedVariant.sku !=
                                                        null &&
                                                    selectedVariant.sku!
                                                        .contains(
                                                      Constants.spaq1,
                                                    );
                                              },
                                              sentenceCaseEnabled: false,
                                              selectedOption: (form
                                                          .control(
                                                              _productVariantKey)
                                                          .value !=
                                                      null)
                                                  ? DropdownItem(
                                                      name: localizations
                                                          .translate(getSpaqName(
                                                              (form.control(_productVariantKey).value as ProductVariantModel)
                                                                      .sku ??
                                                                  (form.control(_productVariantKey).value
                                                                          as ProductVariantModel)
                                                                      .id))
                                                          .toUpperCase(),
                                                      code: (form
                                                                  .control(
                                                                      _productVariantKey)
                                                                  .value
                                                              as ProductVariantModel)
                                                          .id)
                                                  : const DropdownItem(
                                                      name: '', code: ''),
                                            ),
                                          );
                                        },
                                      );
                                    },
                                  );
                                },
                              ),
                              if ([
                                StockRecordEntryType.loss,
                                StockRecordEntryType.damaged,
                              ].contains(entryType))
                                ReactiveWrapperField(
                                  formControlName: _transactionReasonKey,
                                  builder: (field) {
                                    return LabeledField(
                                      label: localizations.translate(
                                        transactionReasonLabel ?? 'Reason',
                                      ),
                                      isRequired: true,
                                      child: DigitDropdown(
                                        emptyItemText: localizations.translate(
                                          i18.common.noMatchFound,
                                        ),
                                        items: reasons!.map((reason) {
                                          return DropdownItem(
                                            name:
                                                localizations.translate(reason),
                                            code: reason.toString(),
                                          );
                                        }).toList(),
                                        onSelect: (value) {
                                          final selectedReason =
                                              reasons?.firstWhere(
                                            (reason) =>
                                                reason.toString() == value.code,
                                          );
                                          field.control.value = selectedReason;
                                        },
                                        selectedOption: (form
                                                    .control(
                                                        _transactionReasonKey)
                                                    .value !=
                                                null)
                                            ? DropdownItem(
                                                name: localizations.translate(form
                                                    .control(
                                                        _transactionReasonKey)
                                                    .value),
                                                code: form
                                                    .control(
                                                        _transactionReasonKey)
                                                    .value)
                                            : const DropdownItem(
                                                name: '', code: ''),
                                      ),
                                    );
                                  },
                                ),
                              BlocBuilder<FacilityBloc, FacilityState>(
                                builder: (context, state) {
                                  return state.maybeWhen(
                                      orElse: () => const Offstage(),
                                      loading: () => const Center(
                                            child: CircularProgressIndicator(),
                                          ),
                                      fetched: (facilities, allFacilities) {
                                        List<FacilityModel> filteredFacilities =
                                            [];

                                        if (context.selectedProject.address
                                                ?.boundaryType ==
                                            Constants.countryBoundaryLevel) {
                                          filteredFacilities = entryType ==
                                                  StockRecordEntryType.receipt
                                              ? allFacilities
                                                  .where((element) =>
                                                      element.usage ==
                                                      Constants.centralFacility)
                                                  .toList()
                                              : allFacilities
                                                  .where((element) =>
                                                      element.usage ==
                                                      Constants.lgaFacility)
                                                  .toList();
                                        } else if (context.selectedProject
                                                .address?.boundaryType ==
                                            Constants.stateBoundaryLevel) {
                                          filteredFacilities = entryType ==
                                                  StockRecordEntryType.receipt
                                              ? allFacilities
                                                  .where((element) =>
                                                      element.usage ==
                                                      Constants.centralFacility)
                                                  .toList()
                                              : allFacilities
                                                  .where((element) =>
                                                      element.usage ==
                                                      Constants.lgaFacility)
                                                  .toList();
                                        } else if (context.selectedProject
                                                .address?.boundaryType ==
                                            Constants.lgaBoundaryLevel) {
                                          filteredFacilities = entryType ==
                                                  StockRecordEntryType.receipt
                                              ? facilities
                                                  .where((element) =>
                                                      element.usage ==
                                                      Constants.stateFacility)
                                                  .toList()
                                              : facilities
                                                  .where((element) =>
                                                      element.usage ==
                                                      Constants.healthFacility)
                                                  .toList();
                                        } else {
                                          filteredFacilities = context
                                                  .isDistributor
                                              ? facilities
                                                  .where((element) =>
                                                      element.usage ==
                                                      Constants.healthFacility)
                                                  .toList()
                                              : entryType ==
                                                      StockRecordEntryType
                                                          .receipt
                                                  ? allFacilities
                                                      .where((element) =>
                                                          element.usage ==
                                                          Constants.lgaFacility)
                                                      .toList()
                                                  // +
                                                  // facilities
                                                  //     .where((element) =>
                                                  //         element.usage ==
                                                  //         Constants
                                                  //             .healthFacility)
                                                  //     .toList()
                                                  : [];
                                        }

                                        facilities =
                                            context.isHealthFacilitySupervisor &&
                                                    entryType !=
                                                        StockRecordEntryType
                                                            .receipt
                                                ? []
                                                : filteredFacilities.isEmpty
                                                    ? facilities
                                                    : filteredFacilities;

                                        final teamFacilities = [
                                          FacilityModel(
                                            id: 'Delivery Team',
                                            name: 'CDD Team',
                                          ),
                                        ];
                                        teamFacilities.addAll(
                                          facilities,
                                        );

                                        return Column(
                                          children: [
                                            const SizedBox(
                                              height: spacer4,
                                            ),
                                            InkWell(
                                              onTap: () async {
                                                clearQRCodes();
                                                form
                                                    .control(_deliveryTeamKey)
                                                    .value = '';

                                                final facility =
                                                    await context.router.push(
                                                        CustomInventoryFacilitySelectionRoute(
                                                  facilities:
                                                      (isHealthFacilitySupervisor &&
                                                              entryType !=
                                                                  StockRecordEntryType
                                                                      .receipt)
                                                          ? teamFacilities
                                                          : facilities,
                                                )) as FacilityModel?;

                                                if (facility == null) return;
                                                form
                                                        .control(_secondaryPartyKey)
                                                        .value =
                                                    localizations.translate(
                                                  'FAC_${facility.id}',
                                                );
                                                controller1.text =
                                                    localizations.translate(
                                                        'FAC_${facility.id}');
                                                setState(() {
                                                  selectedFacilityId =
                                                      facility.id;
                                                });
                                                if (facility.id ==
                                                    'Delivery Team') {
                                                  setState(() {
                                                    deliveryTeamSelected = true;
                                                  });
                                                } else {
                                                  setState(() {
                                                    deliveryTeamSelected =
                                                        false;
                                                  });
                                                }
                                              },
                                              child: IgnorePointer(
                                                child: ReactiveWrapperField(
                                                    formControlName:
                                                        _secondaryPartyKey,
                                                    validationMessages: {
                                                      'required': (object) =>
                                                          localizations
                                                              .translate(
                                                            '${i18.individualDetails.nameLabelText}_IS_REQUIRED',
                                                          ),
                                                    },
                                                    showErrors: (control) =>
                                                        control.invalid &&
                                                        control.touched,
                                                    builder: (field) {
                                                      return InputField(
                                                        inputFormatters: [
                                                          UpperCaseTextFormatter(),
                                                        ],
                                                        type: InputType.search,
                                                        isRequired: true,
                                                        label: localizations
                                                            .translate(
                                                          '${pageTitle}_${i18.stockReconciliationDetails.stockLabel}',
                                                        ),
                                                        onChange: (value) {
                                                          field.control
                                                              .markAsTouched();
                                                        },
                                                        controller: controller1,
                                                        errorMessage:
                                                            field.errorText,
                                                      );
                                                    }),
                                              ),
                                            ),
                                          ],
                                        );
                                      });
                                },
                              ),
                              // TODO: as this case i need to set when occurring
                              Visibility(
                                visible: deliveryTeamSelected,
                                child: ReactiveWrapperField(
                                    formControlName: _deliveryTeamKey,
                                    builder: (field) {
                                      return InputField(
                                        inputFormatters: [
                                          UpperCaseTextFormatter(),
                                        ],
                                        keyboardType: TextInputType.none,
                                        type: InputType.search,
                                        label: localizations.translate(
                                          i18.stockReconciliationDetails
                                              .teamCodeLabel,
                                        ),
                                        initialValue: form
                                            .control(_deliveryTeamKey)
                                            .value,
                                        isRequired: deliveryTeamSelected,
                                        suffixIcon: Icons.qr_code_2,
                                        onSuffixTap: (value) {
                                          //[TODO: Add route to auto_route]
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  const DigitScannerPage(
                                                quantity: 5,
                                                isGS1code: false,
                                                singleValue: false,
                                              ),
                                              settings: const RouteSettings(
                                                  name: '/qr-scanner'),
                                            ),
                                          );
                                        },
                                        onChange: (val) {
                                          String? value = val;
                                          if (value != null &&
                                              value.trim().isNotEmpty) {
                                            context
                                                .read<DigitScannerBloc>()
                                                .add(
                                                  DigitScannerEvent
                                                      .handleScanner(
                                                    barCode: [],
                                                    qrCode: [value],
                                                    manualCode: value,
                                                  ),
                                                );
                                          } else {
                                            clearQRCodes();
                                          }
                                        },
                                      );
                                    }),
                                // DigitTextFormField(
                                //   label: localizations.translate(
                                //     i18.stockReconciliationDetails
                                //         .teamCodeLabel,
                                //   ),
                                //   onChanged: (val) {
                                //     String? value = val.value as String?;
                                //     if (value != null &&
                                //         value.trim().isNotEmpty) {
                                //       context.read<DigitScannerBloc>().add(
                                //             DigitScannerEvent.handleScanner(
                                //               barCode: [],
                                //               qrCode: [value],
                                //               manualCode: value,
                                //             ),
                                //           );
                                //     } else {
                                //       clearQRCodes();
                                //     }
                                //   },
                                //   suffix: IconButton(
                                //     onPressed: () {
                                //       //[TODO: Add route to auto_route]
                                //       Navigator.of(context).push(
                                //         MaterialPageRoute(
                                //           builder: (context) =>
                                //               const DigitScannerPage(
                                //             quantity: 5,
                                //             isGS1code: false,
                                //             singleValue: false,
                                //           ),
                                //           settings: const RouteSettings(
                                //               name: '/qr-scanner'),
                                //         ),
                                //       );
                                //     },
                                //     icon: Icon(
                                //       Icons.qr_code_2,
                                //       color: theme.colorScheme.secondary,
                                //     ),
                                //   ),
                                //   isRequired: deliveryTeamSelected,
                                //   maxLines: 3,
                                //   formControlName: _deliveryTeamKey,
                                // ),
                              ),
                              ReactiveWrapperField(
                                  formControlName: _transactionQuantityKey,
                                  validationMessages: {
                                    "number": (object) =>
                                        localizations.translate(
                                          '${quantityCountLabel}_ERROR',
                                        ),
                                    "max": (object) => localizations.translate(
                                          '${quantityCountLabel}_MAX_ERROR',
                                        ),
                                    "min": (object) => localizations.translate(
                                          '${quantityCountLabel}_MIN_ERROR',
                                        ),
                                    "required": (object) =>
                                        localizations.translate(
                                          i18.common.corecommonRequired,
                                        ),
                                  },
                                  showErrors: (control) =>
                                      control.invalid && control.touched,
                                  builder: (field) {
                                    String label;
                                    if (entryType ==
                                        StockRecordEntryType.returned) {
                                      label = i18_local.stockDetails
                                          .quantityUnusedBlistersReturnedLabel;
                                    } else {
                                      label = quantityCountLabel;
                                    }

                                    return LabeledField(
                                      label: localizations.translate(
                                        label,
                                      ),
                                      isRequired: true,
                                      child: BaseDigitFormInput(
                                        inputFormatters: [
                                          FilteringTextInputFormatter.digitsOnly
                                        ],
                                        errorMessage: field.errorText,
                                        keyboardType: const TextInputType
                                            .numberWithOptions(
                                          decimal: true,
                                        ),
                                        onChange: (val) {
                                          if (val.isEmpty || val.trim() == '') {
                                            field.control.value = null;
                                          } else {
                                            if (int.parse(val) > 10000000000) {
                                              field.control.value = 10000;
                                              field.control.markAsTouched();
                                            } else {
                                              field.control.value =
                                                  int.parse(val);
                                              field.control.markAsTouched();
                                            }
                                          }
                                        },
                                      ),
                                    );
                                  }),

                              if (entryType ==
                                  StockRecordEntryType.returned) ...[
                                // Wasted blisters field
                                // ReactiveWrapperField(
                                //   formControlName: _wastedBlistersKey,
                                //   validationMessages: {
                                //     "required": (object) =>
                                //         localizations.translate(
                                //           '${i18_local.stockDetails.quantityWastedBlistersReturnedLabel}_ERROR',
                                //         ),
                                //   },
                                //   builder: (field) {
                                //     return LabeledField(
                                //       label: localizations.translate(
                                //         i18_local.stockDetails
                                //             .quantityWastedBlistersReturnedLabel,
                                //       ),
                                //       isRequired: true,
                                //       child: BaseDigitFormInput(
                                //         errorMessage: field.errorText,
                                //         keyboardType: const TextInputType
                                //             .numberWithOptions(
                                //           decimal: true,
                                //         ),
                                //         onChange: (val) {
                                //           field.control.markAsTouched();
                                //           if (int.parse(val) > 10000000000) {
                                //             field.control.value = 10000;
                                //           } else {
                                //             if (val != '') {
                                //               field.control.value =
                                //                   int.parse(val);
                                //             } else {
                                //               field.control.value = null;
                                //             }
                                //           }
                                //         },
                                //       ),
                                //     );
                                //   },
                                // ),

                                // Partial blisters field
                                // ReactiveWrapperField(
                                //   formControlName: _partialBlistersKey,
                                //   validationMessages: {
                                //     "required": (object) =>
                                //         localizations.translate(
                                //           '${i18_local.stockDetails.quantityPartialBlistersReturnedLabel}_ERROR',
                                //         ),
                                //   },
                                //   builder: (field) {
                                //     return LabeledField(
                                //       label: localizations.translate(
                                //         i18_local.stockDetails
                                //             .quantityPartialBlistersReturnedLabel,
                                //       ),
                                //       isRequired: true,
                                //       child: BaseDigitFormInput(
                                //         errorMessage: field.errorText,
                                //         keyboardType: const TextInputType
                                //             .numberWithOptions(
                                //           decimal: true,
                                //         ),
                                //         onChange: (val) {
                                //           field.control.markAsTouched();
                                //           if (int.parse(val) > 10000000000) {
                                //             field.control.value = 10000;
                                //           } else {
                                //             if (val != '') {
                                //               field.control.value =
                                //                   int.parse(val);
                                //             } else {
                                //               field.control.value = null;
                                //             }
                                //           }
                                //         },
                                //       ),
                                //     );
                                //   },
                                // ),
                              ],

                              if (isWareHouseMgr)
                                ReactiveWrapperField(
                                    formControlName: _waybillNumberKey,
                                    builder: (field) {
                                      return InputField(
                                        inputFormatters: [
                                          UpperCaseTextFormatter(),
                                          FilteringTextInputFormatter.allow(
                                              RegExp(
                                            r"[a-zA-Z0-9\s\-]",
                                          )),
                                        ],
                                        keyboardType: const TextInputType
                                            .numberWithOptions(
                                          decimal: true,
                                        ),
                                        type: InputType.text,
                                        label: localizations.translate(
                                          i18.stockDetails.waybillNumberLabel,
                                        ),
                                        onChange: (val) {
                                          field.control.value = val;
                                        },
                                      );
                                    }),
                              if (isWareHouseMgr)
                                ReactiveWrapperField(
                                    formControlName: _waybillQuantityKey,
                                    builder: (field) {
                                      return InputField(
                                        inputFormatters: [
                                          FilteringTextInputFormatter
                                              .digitsOnly, // This is key
                                          // UpperCaseTextFormatter(), // Remove this if you only want numbers
                                        ],
                                        keyboardType: const TextInputType
                                            .numberWithOptions(
                                          decimal: false,
                                        ),
                                        type: InputType.text,
                                        label: localizations.translate(
                                          i18.stockDetails
                                              .quantityOfProductIndicatedOnWaybillLabel,
                                        ),
                                        onChange: (val) {
                                          if (val == '') {
                                            field.control.value = '0';
                                          } else {
                                            field.control.value = val;
                                          }
                                        },
                                      );
                                    }),
                              if (isWareHouseMgr)
                                ReactiveWrapperField(
                                    formControlName: _batchNumberKey,
                                    builder: (field) {
                                      return InputField(
                                        inputFormatters: [
                                          UpperCaseTextFormatter(),
                                          FilteringTextInputFormatter.allow(
                                              RegExp(
                                            r"[a-zA-Z0-9\s\-]",
                                          )),
                                        ],
                                        keyboardType: const TextInputType
                                            .numberWithOptions(
                                          decimal: true,
                                        ),
                                        type: InputType.text,
                                        label: localizations.translate(
                                          i18_local
                                              .stockDetails.batchNumberLabel,
                                        ),
                                        onChange: (val) {
                                          if (val == '') {
                                            field.control.value = '0';
                                          } else {
                                            field.control.value = val;
                                          }
                                        },
                                      );
                                    }),
                              if (isWareHouseMgr)
                                transportTypes.isNotEmpty
                                    ? ReactiveWrapperField(
                                        formControlName: _typeOfTransportKey,
                                        builder: (field) {
                                          return LabeledField(
                                            label: localizations.translate(
                                              i18.stockDetails
                                                  .transportTypeLabel,
                                            ),
                                            child: DigitDropdown(
                                              emptyItemText:
                                                  localizations.translate(
                                                i18.common.noMatchFound,
                                              ),
                                              items: transportTypes.map((type) {
                                                return DropdownItem(
                                                  name: localizations
                                                      .translate(type.name),
                                                  code: type.code,
                                                );
                                              }).toList(),
                                              onSelect: (value) {
                                                field.control.value =
                                                    value.name;
                                              },
                                              selectedOption: (form
                                                          .control(
                                                              _typeOfTransportKey)
                                                          .value !=
                                                      null)
                                                  ? DropdownItem(
                                                      name: localizations
                                                          .translate(form
                                                              .control(
                                                                  _typeOfTransportKey)
                                                              .value),
                                                      code: form
                                                          .control(
                                                              _typeOfTransportKey)
                                                          .value)
                                                  : const DropdownItem(
                                                      name: '', code: ''),
                                            ),
                                          );
                                        },
                                      )
                                    : const Offstage(),
                              if (isWareHouseMgr)
                                ReactiveWrapperField(
                                    formControlName: _vehicleNumberKey,
                                    builder: (field) {
                                      return InputField(
                                        inputFormatters: [
                                          UpperCaseTextFormatter(),
                                          FilteringTextInputFormatter.allow(
                                              RegExp(
                                            r"[a-zA-Z0-9\s\-.,\/!@#\$%\^&\*\(\)]",
                                          )),
                                        ],
                                        type: InputType.text,
                                        label: localizations.translate(
                                          i18.stockDetails.vehicleNumberLabel,
                                        ),
                                        onChange: (val) {
                                          field.control.value = val;
                                        },
                                      );
                                    }),
                              ReactiveWrapperField(
                                  formControlName: _commentsKey,
                                  builder: (field) {
                                    return InputField(
                                      inputFormatters: [
                                        UpperCaseTextFormatter(),
                                      ],
                                      type: InputType.text,
                                      label: localizations.translate(
                                        i18.stockDetails.commentsLabel,
                                      ),
                                      onChange: (val) {
                                        field.control.value = val;
                                      },
                                    );
                                  }),
                            ],
                          ),
                        ],
                      );
                    });
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }

  void clearQRCodes() {
    context.read<DigitScannerBloc>().add(const DigitScannerEvent.handleScanner(
          barCode: [],
          qrCode: [],
        ));
  }

  /// This function processes a list of GS1 barcodes and returns a map where the keys and values are joined by '|'.
  ///
  /// It takes a list of GS1Barcode objects as a parameter. Each GS1Barcode object represents a barcode that has been scanned.
  ///
  /// The function first initializes two empty lists: one for the keys and one for the values.
  ///
  /// It then iterates over each barcode in the list. For each barcode, it iterates over each element in the barcode.
  /// Each element is a MapEntry object, where the key is the identifier of the data field and the value is the data itself.
  ///
  /// The function adds the key and value of each element to the respective lists. The key and value are both converted to strings.
  ///
  /// After all barcodes have been processed, the function returns a map where the keys and values are joined by '|'.
  ///
  /// @param barCodes The list of GS1Barcode objects to be processed.
  /// @return A map where the keys and values are joined by '|'.
  AdditionalField addBarCodesToFields(List<GS1Barcode> barCodes) {
    List<String> keys = [];
    List<String> values = [];
    for (var element in barCodes) {
      for (var e in element.elements.entries) {
        keys.add(e.key.toString());
        values.add(e.value.data.toString());
      }
    }
    return AdditionalField(keys.join('|'), values.join('|'));
  }
}
