import 'package:auto_route/auto_route.dart';
import 'package:collection/collection.dart';
import 'package:digit_components/widgets/atoms/digit_toaster.dart';
// import 'package:digit_ui_components/widgets/atoms/digit_reactive_dropdown.dart';
import 'package:digit_data_model/data_model.dart';
import 'package:digit_scanner/blocs/scanner.dart';
import './qr_scanner.dart';
import 'package:digit_ui_components/digit_components.dart';
import 'package:digit_ui_components/services/location_bloc.dart';
import 'package:digit_ui_components/theme/digit_extended_theme.dart';
import 'package:digit_ui_components/utils/component_utils.dart';
import 'package:digit_ui_components/widgets/atoms/input_wrapper.dart';
import 'package:digit_ui_components/widgets/atoms/pop_up_card.dart';
import 'package:digit_ui_components/widgets/molecules/digit_card.dart';
import 'package:digit_ui_components/widgets/molecules/show_pop_up.dart';
import 'package:digit_ui_components/widgets/atoms/digit_multiselect_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gs1_barcode_parser/gs1_barcode_parser.dart';
import 'package:health_campaign_field_worker_app/pages/inventory_management/custom_stock_details_in_tabs.dart';
import 'package:inventory_management/inventory_management.dart';
import 'package:inventory_management/router/inventory_router.gm.dart';
import 'package:inventory_management/utils/extensions/extensions.dart';
import 'package:logger/logger.dart';
import 'package:reactive_forms/reactive_forms.dart';

import 'package:inventory_management/utils/i18_key_constants.dart' as i18;
import 'package:inventory_management/widgets/localized.dart';
import 'package:inventory_management/blocs/product_variant.dart';
import 'package:inventory_management/blocs/record_stock.dart';
import 'package:inventory_management/widgets/back_navigation_help_header.dart';

import '../../blocs/auth/auth.dart';
import '../../blocs/inventory_management/stock_bloc.dart';
import '../../utils/constants.dart';
import '../../utils/extensions/extensions.dart';
import '../../utils/i18_key_constants.dart' as i18_local;

import 'package:multi_select_flutter/multi_select_flutter.dart';

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
  // static const _transactionQuantityKey = 'quantity';
  // static const _transactionPartialQuantityKey = 'partialQuantity';
  // static const _transactionReasonKey = 'transactionReason';
  // static const _waybillNumberKey = 'waybillNumber';
  // static const _waybillQuantityKey = 'waybillQuantity';
  // static const _batchNumberKey = 'batchNumberKey';
  static const _vehicleNumberKey = 'vehicleNumber';
  static const _typeOfTransportKey = 'typeOfTransport';
  // static const _commentsKey = 'comments';
  static const _deliveryTeamKey = 'deliveryTeam';
  bool deliveryTeamSelected = false;
  String? selectedFacilityId;
  List<InventoryTransportTypes> transportTypes = [];

  List<GS1Barcode> scannedResources = [];
  TextEditingController controller1 = TextEditingController();

  FormGroup _form(StockRecordEntryType stockType) {
    return fb.group({
      _productVariantKey: FormControl<List<ProductVariantModel>>(
        value: [],
        validators: [
          Validators.required,
        ],
      ),
      _secondaryPartyKey: FormControl<String>(
        validators: [Validators.required],
      ),
      // _transactionQuantityKey: FormControl<int>(validators: [
      //   Validators.number(),
      //   Validators.required,
      //   Validators.min(0),
      //   Validators.max(10000),
      // ]),
      // _transactionReasonKey: FormControl<String>(),
      // _waybillNumberKey: FormControl<String>(
      //   validators: [Validators.minLength(2), Validators.maxLength(200)],
      // ),
      // _waybillQuantityKey: FormControl<String>(),
      // _batchNumberKey: FormControl<String>(
      //   validators: [],
      // ),
      _vehicleNumberKey: FormControl<String>(),
      _typeOfTransportKey: FormControl<String>(),
      // _commentsKey: FormControl<String>(),
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
    final isHealthFacilitySupervisor = context.isHealthFacilitySupervisor;

    bool isWareHouseMgr = InventorySingleton().isWareHouseMgr;

    List<String> _selectedVariants = [];

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
                    // todo : verify this , not needed now as routing done from stock details tab page
                    // parent.replace(
                    //   InventoryAcknowledgementRoute(),
                    // );
                  },
                );
              },
              builder: (context, stockState) {
                StockRecordEntryType entryType = stockState.entryType;

                const module = i18.stockDetails;

                String pageTitleMain = module.transactionDetailsLabel;
                String pageTitle;
                String quantityCountLabel;
                String? quantityPartialCountLabel;
                String? transactionReasonLabel;
                String? transactionReason;
                String transactionType;

                List<String>? reasons;

                switch (entryType) {
                  case StockRecordEntryType.receipt:
                    pageTitle = module.receivedPageTitle;
                    quantityCountLabel =
                        i18.inventoryReportDetails.receiptQuantityLabel;
                    transactionType = TransactionType.received.toValue();

                    break;
                  case StockRecordEntryType.dispatch:
                    pageTitle = InventorySingleton().isDistributor
                        ? module.returnedPageTitle
                        : module.issuedPageTitle;
                    quantityCountLabel = InventorySingleton().isDistributor
                        ? module.returnedPageTitle
                        : i18.inventoryReportDetails.returnedQuantityLabel;
                    quantityPartialCountLabel = i18_local
                        .inventoryReportDetails.partialReturnedQuantityLabel;
                    transactionType = TransactionType.dispatched.toValue();

                    break;
                  case StockRecordEntryType.returned:
                    pageTitle = module.returnedPageTitle;
                    quantityCountLabel =
                        i18.inventoryReportDetails.returnedQuantityLabel;
                    quantityPartialCountLabel = i18_local
                        .inventoryReportDetails.partialReturnedQuantityLabel;
                    transactionType = TransactionType.received.toValue();

                    break;
                  case StockRecordEntryType.loss:
                    pageTitle = module.lostPageTitle;
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
                  form: () => _form(entryType),
                  builder: (context, form, child) {
                    return BlocBuilder<DigitScannerBloc, DigitScannerState>(
                        builder: (context, scannerState) {
                      if (scannerState.barCodes.isNotEmpty) {
                        scannedResources.clear();
                        scannedResources.addAll(scannerState.barCodes);
                      }

// TODO Nik move to next page
                      // if (entryType == StockRecordEntryType.returned) {
                      //   form
                      //       .control(_transactionPartialQuantityKey)
                      //       .setValidators([
                      //     Validators.required,
                      //     Validators.number(),
                      //     Validators.min(0),
                      //     Validators.max(10000),
                      //   ], autoValidate: true);
                      // } else {
                      //   form.control(_batchNumberKey).setValidators([
                      //     Validators.required,
                      //     Validators.minLength(2),
                      //     Validators.maxLength(200)
                      //   ], autoValidate: true);
                      // }

                      return ScrollableContent(
                        header: Column(children: [
                          BackNavigationHelpHeaderWidget(
                            showHelp: false,
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
                                onPressed: !form.valid
                                    ? () {}
                                    : () async {
                                        form.markAllAsTouched();
                                        if (!form.valid) {
                                          return;
                                        }
                                        if (form
                                            .control(_productVariantKey)
                                            .value
                                            .isEmpty) {
                                          Toast.showToast(
                                            context,
                                            type: ToastType.error,
                                            message: localizations.translate(
                                              i18_local
                                                  .stockDetails.productRequired,
                                            ),
                                          );
                                          return;
                                        }
                                        if (deliveryTeamSelected &&
                                            form
                                                .control(_deliveryTeamKey)
                                                .value
                                                .isEmpty) {
                                          Toast.showToast(
                                            context,
                                            type: ToastType.error,
                                            message: localizations.translate(
                                              i18.stockDetails.teamCodeRequired,
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
                                                    id: selectedFacilityId
                                                        .toString(),
                                                  )
                                                : null;
                                        final deliveryTeamName = form
                                            .control(_deliveryTeamKey)
                                            .value as String?;

                                        if (deliveryTeamSelected &&
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
                                          // Logger().d(
                                          //     "This is the form data ${form.control(_productVariantKey).value as List<ProductVariantModel>}");
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
                                          Future.delayed(
                                              const Duration(seconds: 2),
                                              () async {
                                            DigitComponentsUtils.hideDialog(
                                                context);
                                            final bloc =
                                                context.read<RecordStockBloc>();

                                            // todo nik to be moved to next page logic
                                            final productVariant = form
                                                    .control(_productVariantKey)
                                                    .value
                                                as List<ProductVariantModel>;

                                            switch (entryType) {
                                              case StockRecordEntryType.receipt:
                                                transactionReason =
                                                    TransactionReason.received
                                                        .toValue();
                                                break;
                                              case StockRecordEntryType
                                                    .dispatch:
                                                transactionReason = null;
                                                break;
                                              case StockRecordEntryType
                                                    .returned:
                                                transactionReason =
                                                    TransactionReason.returned
                                                        .toValue();
                                                break;
                                              default:
                                                transactionReason = null;
                                                // form
                                                //     .control(
                                                //       _transactionReasonKey,
                                                //     )
                                                //     .value as String?;
                                                break;
                                            }
                                            // todo nik to be moved to next page
                                            // final quantity = form
                                            //     .control(
                                            //         _transactionQuantityKey)
                                            //     .value;

                                            // final quantity = form
                                            //         .control(
                                            //             _transactionQuantityKey)
                                            //         .value ??
                                            //     0;
//
//                                             final partialQuantity = form
//                                                     .control(
//                                                         _transactionPartialQuantityKey)
//                                                     .value ??
//                                                 0;
//
//                                             final waybillNumber = form
//                                                 .control(_waybillNumberKey)
//                                                 .value as String?;
//
//                                             final waybillQuantity = form
//                                                 .control(_waybillQuantityKey)
//                                                 .value as String?;
//
//                                             final batchNumber = form
//                                                 .control(_batchNumberKey)
//                                                 .value as String?;

                                            final vehicleNumber = form
                                                .control(_vehicleNumberKey)
                                                .value as String?;

                                            final lat = locationState.latitude;
                                            final lng = locationState.longitude;

                                            final hasLocationData =
                                                lat != null && lng != null;

                                            // final comments = form
                                            //     .control(_commentsKey)
                                            //     .value as String?;

                                            final deliveryTeamName = form
                                                .control(_deliveryTeamKey)
                                                .value as String?;

                                            int spaq1 = 0;
                                            int spaq2 = 0;

                                            int totalQuantity = 0;
                                            int totalRemainingQuantityInMl =
                                                context.spaq1;

                                            int totalExpectedUnusedBottles =
                                                totalRemainingQuantityInMl ~/
                                                    Constants.mlPerBottle;

                                            int totalExpectedPartialQuantityInMl =
                                                totalRemainingQuantityInMl %
                                                    Constants.mlPerBottle;

                                            int totalExpectedPartialBottles =
                                                totalRemainingQuantityInMl %
                                                            Constants
                                                                .mlPerBottle !=
                                                        0
                                                    ? 1
                                                    : 0;

                                            // totalQuantity = quantity != null
                                            //     ? int.parse(
                                            //         quantity.toString(),
                                            //       )
                                            //     : 0;

                                            spaq1 = totalQuantity *
                                                Constants.mlPerBottle;

                                            // if (spaq1 >
                                            //         totalRemainingQuantityInMl &&
                                            //     isDistributor &&
                                            //     entryType ==
                                            //         StockRecordEntryType
                                            //             .dispatch) {
                                            //   DigitToast.show(
                                            //     context,
                                            //     options: DigitToastOptions(
                                            //       localizations
                                            //           .translate(
                                            //             i18_local.stockDetails
                                            //                 .quantityReturnedMaxError,
                                            //           )
                                            //           .replaceAll(
                                            //             "{1}",
                                            //             totalRemainingQuantityInMl
                                            //                 .toString(),
                                            //           )
                                            //           .replaceAll(
                                            //             "{2}",
                                            //             totalExpectedUnusedBottles
                                            //                 .toString(),
                                            //           ),
                                            //       true,
                                            //       theme,
                                            //     ),
                                            //   );

                                            //   return;
                                            // }

                                            String? senderId;
                                            String? senderType;
                                            String? receiverId;
                                            String? receiverType;

                                            final primaryType = BlocProvider.of<
                                                RecordStockBloc>(
                                              context,
                                            ).state.primaryType;

                                            final primaryId = BlocProvider.of<
                                                RecordStockBloc>(
                                              context,
                                            ).state.primaryId;

                                            switch (entryType) {
                                              case StockRecordEntryType.receipt:
                                              case StockRecordEntryType.loss:
                                              case StockRecordEntryType.damaged:
                                              case StockRecordEntryType
                                                    .returned:
                                                if (deliveryTeamSelected) {
                                                  senderId = deliveryTeamName;
                                                  senderType = "STAFF";
                                                } else {
                                                  senderId = secondaryParty?.id;
                                                  senderType = "WAREHOUSE";
                                                }
                                                receiverId = primaryId;
                                                receiverType = primaryType;

                                                break;
                                              case StockRecordEntryType
                                                    .dispatch:
                                                if (deliveryTeamSelected) {
                                                  receiverId = deliveryTeamName;
                                                  receiverType = "STAFF";
                                                } else {
                                                  receiverId =
                                                      secondaryParty?.id;
                                                  receiverType = "WAREHOUSE";
                                                }
                                                senderId = primaryId;
                                                senderType = primaryType;
                                                break;
                                            }
// todo nik to move to next page
//                                             final stockModel = StockModel(
//                                               clientReferenceId:
//                                                   IdGen.i.identifier,
//                                               productVariantId:
//                                                   productVariant.id,
//                                               transactionReason:
//                                                   transactionReason,
//                                               transactionType: transactionType,
//                                               referenceId: stockState.projectId,
//                                               referenceIdType: 'PROJECT',
//                                               quantity: quantity.toString(),
//                                               wayBillNumber: waybillNumber,
//                                               receiverId: receiverId,
//                                               receiverType: receiverType,
//                                               senderId: senderId,
//                                               senderType: senderType,
//                                               auditDetails: AuditDetails(
//                                                 createdBy: InventorySingleton()
//                                                     .loggedInUserUuid,
//                                                 createdTime: context
//                                                     .millisecondsSinceEpoch(),
//                                               ),
//                                               clientAuditDetails:
//                                                   ClientAuditDetails(
//                                                 createdBy: InventorySingleton()
//                                                     .loggedInUserUuid,
//                                                 createdTime: context
//                                                     .millisecondsSinceEpoch(),
//                                                 lastModifiedBy:
//                                                     InventorySingleton()
//                                                         .loggedInUserUuid,
//                                                 lastModifiedTime: context
//                                                     .millisecondsSinceEpoch(),
//                                               ),
//                                               additionalFields: [
//                                                         waybillQuantity,
//                                                         vehicleNumber,
//                                                         comments,
//                                                       ].any((element) =>
//                                                           element != null) ||
//                                                       hasLocationData
//                                                   ? StockAdditionalFields(
//                                                       version: 1,
//                                                       fields: [
//                                                         AdditionalField(
//                                                           InventoryManagementEnums
//                                                               .name
//                                                               .toValue(),
//                                                           InventorySingleton()
//                                                               .loggedInUser
//                                                               ?.name,
//                                                         ),
//                                                         if (waybillQuantity !=
//                                                                 null &&
//                                                             waybillQuantity
//                                                                 .trim()
//                                                                 .isNotEmpty)
//                                                           AdditionalField(
//                                                             'waybill_quantity',
//                                                             waybillQuantity,
//                                                           ),
//                                                         if (batchNumber !=
//                                                                 null &&
//                                                             batchNumber
//                                                                 .trim()
//                                                                 .isNotEmpty)
//                                                           AdditionalField(
//                                                             'batch_number',
//                                                             batchNumber,
//                                                           ),
//                                                         if (vehicleNumber !=
//                                                                 null &&
//                                                             vehicleNumber
//                                                                 .trim()
//                                                                 .isNotEmpty)
//                                                           AdditionalField(
//                                                             'vehicle_number',
//                                                             vehicleNumber,
//                                                           ),
//                                                         if (comments != null &&
//                                                             comments
//                                                                 .trim()
//                                                                 .isNotEmpty)
//                                                           AdditionalField(
//                                                             'comments',
//                                                             comments,
//                                                           ),
//                                                         if (deliveryTeamName !=
//                                                                 null &&
//                                                             deliveryTeamName
//                                                                 .trim()
//                                                                 .isNotEmpty)
//                                                           AdditionalField(
//                                                             'deliveryTeam',
//                                                             deliveryTeamName,
//                                                           ),
//                                                         if (hasLocationData) ...[
//                                                           AdditionalField(
//                                                             'lat',
//                                                             lat,
//                                                           ),
//                                                           AdditionalField(
//                                                             'lng',
//                                                             lng,
//                                                           ),
//                                                         ],
//                                                         if (scannerState
//                                                             .barCodes
//                                                             .isNotEmpty)
//                                                           addBarCodesToFields(
//                                                               scannerState
//                                                                   .barCodes),
//                                                         if (entryType ==
//                                                             StockRecordEntryType
//                                                                 .returned) ...[
//                                                           AdditionalField(
//                                                             'unused_quantity',
//                                                             quantity.toString(),
//                                                           ),
//                                                           AdditionalField(
//                                                             'partial_quantity',
//                                                             partialQuantity
//                                                                 .toString(),
//                                                           ),
//                                                         ]
//                                                       ],
//                                                     )
//                                                   : null,
//                                             );
//
                                            // bloc.add(
                                            //   RecordStockSaveStockDetailsEvent(
                                            //     stockModel: stockModel,
                                            //   ),
                                            // );

                                            if (form.valid) {
                                              final selectedProducts =
                                                  form
                                                          .control(
                                                              _productVariantKey)
                                                          .value
                                                      as List<
                                                          ProductVariantModel>;

                                              // Logger().d(
                                              //     "This is the selected products $selectedProducts");

                                              final receivedFrom = form
                                                  .control(_secondaryPartyKey)
                                                  .value as String;
                                              context.read<StockBloc>().add(
                                                    StockSelectedEvent(
                                                      selectedProducts:
                                                          selectedProducts,
                                                      secondaryPartyType:
                                                          deliveryTeamSelected
                                                              ? "STAFF"
                                                              : "WAREHOUSE",
                                                      receivedFrom:
                                                          (deliveryTeamSelected
                                                                  ? deliveryTeamName
                                                                  : selectedFacilityId) ??
                                                              "",
                                                    ),
                                                  );

                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (_) =>
                                                      BlocProvider.value(
                                                    value: context
                                                        .read<StockBloc>(),
                                                    child: DynamicTabsPage(),
                                                  ),
                                                ),
                                              );
                                            }

//  todo nik to be moved to next page

//                                             final submit =
//                                                 await showCustomPopup(
//                                               context: context,
//                                               builder: (popupContext) => Popup(
//                                                 title: localizations.translate(
//                                                   i18.stockDetails.dialogTitle,
//                                                 ),
//                                                 onOutsideTap: () {
//                                                   Navigator.of(popupContext)
//                                                       .pop(false);
//                                                 },
//                                                 description:
//                                                     localizations.translate(
//                                                   i18.stockDetails
//                                                       .dialogContent,
//                                                 ),
//                                                 type: PopUpType.simple,
//                                                 actions: [
//                                                   DigitButton(
//                                                     label:
//                                                         localizations.translate(
//                                                       i18.common
//                                                           .coreCommonSubmit,
//                                                     ),
//                                                     onPressed: () {
//                                                       Navigator.of(
//                                                         popupContext,
//                                                         rootNavigator: true,
//                                                       ).pop(true);

//                                                     },
//                                                     type:
//                                                         DigitButtonType.primary,
//                                                     size: DigitButtonSize.large,
//                                                   ),
//                                                   DigitButton(
//                                                     label:
//                                                         localizations.translate(
//                                                       i18.common
//                                                           .coreCommonCancel,
//                                                     ),
//                                                     onPressed: () {
//                                                       Navigator.of(
//                                                         popupContext,
//                                                         rootNavigator: true,
//                                                       ).pop(false);
//                                                     },
//                                                     type: DigitButtonType
//                                                         .secondary,
//                                                     size: DigitButtonSize.large,
//                                                   ),
//                                                 ],
//                                               ),
//                                             ) as bool;

//                                             if (submit ?? false) {
//                                               // todo nik just removed to test
// //                                               bloc.add(
// //                                                 const RecordStockCreateStockEntryEvent(),
// //                                               );

//                                               if (isDistributor) {
//                                                 totalQuantity = entryType ==
//                                                         StockRecordEntryType
//                                                             .dispatch
//                                                     ? totalRemainingQuantityInMl *
//                                                         -1
//                                                     : totalQuantity *
//                                                         Constants.mlPerBottle;

//                                                 spaq1 = totalQuantity;

//                                                 context.read<AuthBloc>().add(
//                                                       AuthAddSpaqCountsEvent(
//                                                         spaq1Count: spaq1,
//                                                         spaq2Count: spaq2,
//                                                       ),
//                                                     );
//                                               }
//                                             }
                                          });
                                        }
                                      },
                                // isDisabled: !form.valid,
                                label: localizations
                                    .translate(i18.common.coreCommonNext),
                              );
                            })
                          ],
                        ),
                        children: [
                          DigitCard(
                            margin: const EdgeInsets.all(spacer2),
                            children: [
                              Text(
                                localizations.translate(pageTitleMain),
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

                                            child: MultiSelectDropDown(
                                              // errorText: field.errorText,
                                              selectionType:
                                                  SelectionType.defaultSelect,
                                              options: productVariants
                                                  .map((variant) {
                                                return DropdownItem(
                                                  name: localizations.translate(
                                                      variant.sku ??
                                                          variant.id),
                                                  code: variant.id,
                                                );
                                              }).toList(),
                                              // selectedOptions: (form
                                              //                 .control(
                                              //                     _productVariantKey)
                                              //                 .value
                                              //             as List<
                                              //                 ProductVariantModel>?)
                                              //         ?.map((variant) =>
                                              //             DropdownItem(
                                              //               name: localizations
                                              //                   .translate(variant
                                              //                           .sku ??
                                              //                       variant.id),
                                              //               code: variant.id,
                                              //             ))
                                              //         .toList() ??
                                              //     [],
                                              onOptionSelected:
                                                  (List<DropdownItem>
                                                      selectedOptionsList) {
                                                final selectedVariants =
                                                    selectedOptionsList
                                                        .map((item) {
                                                  return productVariants
                                                      .firstWhere((variant) =>
                                                          variant.id ==
                                                          item.code);
                                                }).toList();
                                                field.control.value =
                                                    selectedVariants;
                                              },
                                            ),

                                            // child: DigitDropdown(
                                            //   errorMessage: field.errorText,
                                            //   emptyItemText:
                                            //       localizations.translate(
                                            //     i18.common.noMatchFound,
                                            //   ),
                                            //   items: productVariants
                                            //       .map((variant) {
                                            //     return DropdownItem(
                                            //       name: localizations.translate(
                                            //         variant.sku ?? variant.id,
                                            //       ),
                                            //       code: variant.id,
                                            //     );
                                            //   }).toList(),
                                            //   selectedOption: (form
                                            //               .control(
                                            //                   _productVariantKey)
                                            //               .value !=
                                            //           null)
                                            //       ? DropdownItem(
                                            //           name: localizations.translate((form
                                            //                           .control(
                                            //                               _productVariantKey)
                                            //                           .value
                                            //                       as ProductVariantModel)
                                            //                   .sku ??
                                            //               (form.control(_productVariantKey).value
                                            //                       as ProductVariantModel)
                                            //                   .id),
                                            //           code: (form.control(_productVariantKey).value
                                            //                   as ProductVariantModel)
                                            //               .id)
                                            //       : const DropdownItem(
                                            //           name: '', code: ''),
                                            //   onSelect: (value) {
                                            //     /// Find the selected product variant model by matching the id
                                            //     final selectedVariant =
                                            //         productVariants.firstWhere(
                                            //       (variant) =>
                                            //           variant.id == value.code,
                                            //     );

                                            //     /// Update the form control with the selected product variant model
                                            //     field.control.value =
                                            //         selectedVariant;
                                            //   },
                                            // ),
                                            // child:
                                            //     MultiSelectDialogField<String>(
                                            //   items: productVariants
                                            //       .map((variant) {
                                            //     return MultiSelectItem<String>(
                                            //       variant.id,
                                            //       localizations.translate(
                                            //           variant.sku ??
                                            //               variant.id),
                                            //     );
                                            //   }).toList(),
                                            //   decoration: BoxDecoration(
                                            //     border: Border.all(
                                            //         color: Colors.grey),
                                            //     borderRadius:
                                            //         BorderRadius.circular(5),
                                            //   ),
                                            //   onConfirm: (values) {
                                            //     _selectedVariants =
                                            //         List<String>.from(values);
                                            //   },
                                            //   validator: (values) {
                                            //     if (values == null ||
                                            //         values.isEmpty) {
                                            //       return "Please select at least one product.";
                                            //     }
                                            //     return null;
                                            //   },
                                            //   initialValue: _selectedVariants,
                                            //   onSelectionChanged:
                                            //       (selectedValues) {
                                            //     // Assuming only one value should be selected for the form control
                                            //     final selectedId =
                                            //         selectedValues.isNotEmpty
                                            //             ? selectedValues.first
                                            //             : null;

                                            //     final selectedVariant =
                                            //         productVariants
                                            //             .firstWhereOrNull(
                                            //       (variant) =>
                                            //           variant.id == selectedId,
                                            //     );

                                            //     form
                                            //         .control(_productVariantKey)
                                            //         .value = selectedVariant;
                                            //     setState(() {});
                                            //   },
                                            // ),
                                          );
                                        },
                                      );
                                    },
                                  );
                                },
                              ),

                              // todo nik move to next page
                              // if ([
                              //   StockRecordEntryType.loss,
                              //   StockRecordEntryType.damaged,
                              // ].contains(entryType))
                              //   ReactiveWrapperField(
                              //     formControlName: _transactionReasonKey,
                              //     builder: (field) {
                              //       return LabeledField(
                              //         label: localizations.translate(
                              //           transactionReasonLabel ?? 'Reason',
                              //         ),
                              //         isRequired: true,
                              //         child: DigitDropdown(
                              //           emptyItemText: localizations.translate(
                              //             i18.common.noMatchFound,
                              //           ),
                              //           items: reasons!.map((reason) {
                              //             return DropdownItem(
                              //               name:
                              //                   localizations.translate(reason),
                              //               code: reason.toString(),
                              //             );
                              //           }).toList(),
                              //           selectedOption: (form
                              //                       .control(
                              //                           _transactionReasonKey)
                              //                       .value !=
                              //                   null)
                              //               ? DropdownItem(
                              //                   name: localizations.translate(form
                              //                       .control(
                              //                           _transactionReasonKey)
                              //                       .value),
                              //                   code: form
                              //                       .control(
                              //                           _transactionReasonKey)
                              //                       .value)
                              //               : const DropdownItem(
                              //                   name: '', code: ''),
                              //           onSelect: (value) {
                              //             final selectedReason =
                              //                 reasons?.firstWhere(
                              //               (reason) =>
                              //                   reason.toString() == value.code,
                              //             );
                              //             field.control.value = selectedReason;
                              //           },
                              //         ),
                              //       );
                              //     },
                              //   ),

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
                                            Constants.stateBoundaryLevel) {
                                          filteredFacilities = entryType ==
                                                  StockRecordEntryType.receipt
                                              ? allFacilities
                                                  .where((element) =>
                                                      element.usage ==
                                                      Constants.centralFacility)
                                                  .toList()
                                              : facilities
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
                                                  ? facilities
                                                      .where((element) =>
                                                          element.usage ==
                                                          Constants.lgaFacility)
                                                      .toList()
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
                                                        InventoryFacilitySelectionRoute(
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
                                                        type: InputType.search,
                                                        isRequired: true,
                                                        label: (entryType ==
                                                                    StockRecordEntryType
                                                                        .dispatch &&
                                                                InventorySingleton()
                                                                    .isDistributor)
                                                            ? localizations
                                                                .translate(i18
                                                                    .stockDetails
                                                                    .selectTransactingPartyReturned)
                                                            : localizations
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
                                      final textController =
                                          TextEditingController(
                                        text: field.control.value?.toString() ??
                                            '',
                                      );
                                      field.control.valueChanges
                                          .listen((value) {
                                        if (textController.text != value) {
                                          textController.text = value ?? '';
                                        }
                                      });
                                      return InkWell(
                                        onTap: () async {
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
                                        child: IgnorePointer(
                                          child: InputField(
                                            type: InputType.search,
                                            label: localizations.translate(
                                              i18.stockReconciliationDetails
                                                  .teamCodeLabel,
                                            ),
                                            isRequired: deliveryTeamSelected,
                                            controller: textController,
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
                                              field.didChange(value);
                                            },
                                          ),
                                        ),
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
// todo nik removing the key
//                               ReactiveWrapperField(
//                                   formControlName: _transactionQuantityKey,
//                                   validationMessages: {
//                                     "number": (object) =>
//                                         localizations.translate(
//                                           '${quantityCountLabel}_ERROR',
//                                         ),
//                                     "max": (object) => localizations.translate(
//                                           '${quantityCountLabel}_MAX_ERROR',
//                                         ),
//                                     "min": (object) => localizations.translate(
//                                           '${quantityCountLabel}_MIN_ERROR',
//                                         ),
//                                   },
//                                   showErrors: (control) =>
//                                       control.invalid && control.touched,
//                                   builder: (field) {
//                                     return LabeledField(
//                                       label: localizations.translate(
//                                         quantityCountLabel,
//                                       ),
//                                       isRequired: true,
//                                       child: BaseDigitFormInput(
//                                         errorMessage: field.errorText,
//                                         keyboardType: const TextInputType
//                                             .numberWithOptions(
//                                           decimal: true,
//                                         ),
//                                         onChange: (val) {
//                                           field.control.markAsTouched();
//                                           if (int.parse(val) > 10000000000) {
//                                             field.control.value = 10000;
//                                           } else {
//                                             if (val != '') {
//                                               field.control.value =
//                                                   int.parse(val);
//                                             } else {
//                                               field.control.value = null;
//                                             }
//                                           }
//                                         },
//                                       ),
//                                     );
//                                   }),
//
//                               Visibility(
//                                 visible:
//                                     entryType == StockRecordEntryType.returned,
//                                 child: ReactiveWrapperField(
//                                     formControlName:
//                                         _transactionPartialQuantityKey,
//                                     validationMessages: {
//                                       "number": (object) =>
//                                           localizations.translate(
//                                             '${quantityCountLabel}_ERROR',
//                                           ),
//                                       "max": (object) =>
//                                           localizations.translate(
//                                             '${quantityCountLabel}_MAX_ERROR',
//                                           ),
//                                       "min": (object) =>
//                                           localizations.translate(
//                                             '${quantityCountLabel}_MIN_ERROR',
//                                           ),
//                                     },
//                                     showErrors: (control) =>
//                                         control.invalid && control.touched,
//                                     builder: (field) {
//                                       return LabeledField(
//                                         label: localizations.translate(
//                                           quantityPartialCountLabel ?? "",
//                                         ),
//                                         isRequired: true,
//                                         child: BaseDigitFormInput(
//                                           errorMessage: field.errorText,
//                                           keyboardType: const TextInputType
//                                               .numberWithOptions(
//                                             decimal: true,
//                                           ),
//                                           onChange: (val) {
//                                             field.control.markAsTouched();
//                                             if (int.parse(val) > 10000000000) {
//                                               field.control.value = 10000;
//                                             } else {
//                                               if (val != '') {
//                                                 field.control.value =
//                                                     int.parse(val);
//                                               } else {
//                                                 field.control.value = null;
//                                               }
//                                             }
//                                           },
//                                         ),
//                                       );
//                                     }),
//                               ),

//  todo nik move to next page
                              // if (isWareHouseMgr)
                              //   ReactiveWrapperField(
                              //       formControlName: _waybillNumberKey,
                              //       builder: (field) {
                              //         return InputField(
                              //           type: InputType.text,
                              //           label: localizations.translate(
                              //             i18.stockDetails.waybillNumberLabel,
                              //           ),
                              //           onChange: (val) {
                              //             field.control.value = val;
                              //           },
                              //         );
                              //       }),
                              // if (isWareHouseMgr)
                              //   ReactiveWrapperField(
                              //       formControlName: _waybillQuantityKey,
                              //       builder: (field) {
                              //         return InputField(
                              //           type: InputType.text,
                              //           label: localizations.translate(
                              //             i18.stockDetails
                              //                 .quantityOfProductIndicatedOnWaybillLabel,
                              //           ),
                              //           onChange: (val) {
                              //             if (val == '') {
                              //               field.control.value = '0';
                              //             } else {
                              //               field.control.value = val;
                              //             }
                              //           },
                              //         );
                              //       }),
                              // if (isWareHouseMgr &&
                              //     entryType != StockRecordEntryType.returned)
                              //   ReactiveWrapperField(
                              //       formControlName: _batchNumberKey,
                              //       builder: (field) {
                              //         return InputField(
                              //           type: InputType.text,
                              //           isRequired: true,
                              //           label: localizations.translate(
                              //             i18_local
                              //                 .stockDetails.batchNumberLabel,
                              //           ),
                              //           onChange: (val) {
                              //             if (val == '') {
                              //               field.control.value = '0';
                              //             } else {
                              //               field.control.value = val;
                              //             }
                              //           },
                              //         );
                              //       }),

                              if (isWareHouseMgr)
                                transportTypes.isNotEmpty
                                    ? ReactiveWrapperField(
                                        formControlName: _typeOfTransportKey,
                                        builder: (field) {
                                          return LabeledField(
                                            label: localizations.translate(
                                              i18_local.stockDetails
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
                                              onSelect: (value) {
                                                field.control.value =
                                                    value.name;
                                                form
                                                    .control(
                                                        _typeOfTransportKey)
                                                    .value = value.code;
                                                form
                                                    .control(
                                                        _typeOfTransportKey)
                                                    .updateValue(value.code);
                                                setState(() {});
                                              },
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
                                        type: InputType.text,
                                        label: localizations.translate(
                                          i18.stockDetails.vehicleNumberLabel,
                                        ),
                                        onChange: (val) {
                                          field.control.value = val;
                                        },
                                      );
                                    }),

                              //todo nik move to next page
                              // ReactiveWrapperField(
                              //     formControlName: _commentsKey,
                              //     builder: (field) {
                              //       return InputField(
                              //         type: InputType.textArea,
                              //         label: localizations.translate(
                              //           i18.stockDetails.commentsLabel,
                              //         ),
                              //         onChange: (val) {
                              //           field.control.value = val;
                              //         },
                              //       );
                              //     }),
                              //   scannerState.barCodes.isEmpty
                              //       ? DigitButton(
                              //           mainAxisSize: MainAxisSize.max,
                              //           size: DigitButtonSize.large,
                              //           type: DigitButtonType.secondary,
                              //           onPressed: () {
                              //             //[TODO: Add route to auto_route]
                              //             Navigator.of(context).push(
                              //               MaterialPageRoute(
                              //                 builder: (context) =>
                              //                     const DigitScannerPage(
                              //                   quantity: 5,
                              //                   isGS1code: true,
                              //                   singleValue: false,
                              //                 ),
                              //                 settings: const RouteSettings(
                              //                     name: '/qr-scanner'),
                              //               ),
                              //             );
                              //           },
                              //           prefixIcon: Icons.qr_code,
                              //           label: localizations.translate(
                              //             i18.common.scanBales,
                              //           ),
                              //         )
                              //       : Column(children: [
                              //           Row(
                              //             mainAxisAlignment:
                              //                 MainAxisAlignment.spaceBetween,
                              //             children: [
                              //               Align(
                              //                 alignment: Alignment.centerLeft,
                              //                 child: Text(
                              //                   localizations.translate(i18
                              //                       .stockDetails
                              //                       .scannedResources),
                              //                   style: DigitTheme
                              //                       .instance
                              //                       .mobileTheme
                              //                       .textTheme
                              //                       .labelSmall,
                              //                 ),
                              //               ),
                              //               Padding(
                              //                 padding: const EdgeInsets.only(
                              //                   bottom: spacer4,
                              //                 ),
                              //                 child: IconButton(
                              //                   alignment: Alignment.centerRight,
                              //                   color: theme
                              //                       .colorTheme.primary.primary1,
                              //                   icon: const Icon(Icons.edit),
                              //                   onPressed: () {
                              //                     //[TODO: Add route to auto_route]
                              //                     Navigator.of(context).push(
                              //                       MaterialPageRoute(
                              //                         builder: (context) =>
                              //                             const DigitScannerPage(
                              //                           quantity: 5,
                              //                           isGS1code: true,
                              //                           singleValue: false,
                              //                         ),
                              //                         settings:
                              //                             const RouteSettings(
                              //                                 name:
                              //                                     '/qr-scanner'),
                              //                       ),
                              //                     );
                              //                   },
                              //                 ),
                              //               ),
                              //             ],
                              //           ),
                              //           ...scannedResources.map((e) => Align(
                              //                 alignment: Alignment.centerLeft,
                              //                 child: Text(e
                              //                     .elements.values.first.data
                              //                     .toString()),
                              //               ))
                              //         ])
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

  // String? wastageQuantity(
  //   FormGroup form,
  //   BuildContext context,
  // ) {
  //   final quantity = form
  //       .control(
  //         _transactionQuantityKey,
  //       )
  //       .value;

  //   final partialBlisters = form
  //       .control(
  //         _transactionPartialQuantityKey,
  //       )
  //       .value;

  //   if (quantity == null || partialBlisters == null) {
  //     return null;
  //   }

  //   int totalQuantity = 0;
  //   int totalRemainingQuantityInMl = context.spaq1;

  //   int totalExpectedUnusedBottles =
  //       totalRemainingQuantityInMl ~/ Constants.mlPerBottle;

  //   int totalExpectedPartialQuantityInMl =
  //       totalRemainingQuantityInMl % Constants.mlPerBottle;

  //   int totalExpectedPartialBottles =
  //       totalRemainingQuantityInMl % Constants.mlPerBottle != 0 ? 1 : 0;

  //   totalQuantity = quantity != null
  //       ? int.parse(
  //           quantity.toString(),
  //         )
  //       : 0;

  //   return (((totalExpectedUnusedBottles - totalQuantity) *
  //               Constants.mlPerBottle) +
  //           ((totalExpectedPartialBottles >
  //                   (partialBlisters != null
  //                       ? int.parse(
  //                           partialBlisters.toString(),
  //                         )
  //                       : 0))
  //               ? totalExpectedPartialQuantityInMl
  //               : 0))
  //       .toString();
  // }

  num _getQuantityCount(Iterable<StockModel> stocks) {
    return stocks.fold<num>(
      0.0,
      (old, e) => (num.tryParse(e.quantity ?? '') ?? 0.0) + old,
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
