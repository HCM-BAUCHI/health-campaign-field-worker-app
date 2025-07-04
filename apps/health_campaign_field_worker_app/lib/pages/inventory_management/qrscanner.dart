import 'dart:convert';
import 'dart:io';
import 'package:collection/collection.dart';
import 'package:digit_data_model/data_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inventory_management/models/entities/transaction_reason.dart';
import 'package:inventory_management/models/entities/transaction_type.dart';
import 'package:logger/logger.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:inventory_management/blocs/record_stock.dart';
import 'package:inventory_management/models/entities/stock.dart';
import 'package:inventory_management/widgets/localized.dart';
import '../../data/repositories/local/inventory_management/custom_stock.dart';
import '../../router/app_router.dart';
import '../../utils/extensions/extensions.dart';
import 'package:digit_components/widgets/digit_dialog.dart' as dialog;
import 'package:registration_delivery/utils/i18_key_constants.dart' as i18;

@RoutePage()
class QRScannerPage extends LocalizedStatefulWidget {
  const QRScannerPage({
    super.key,
    super.appLocalizations,
  });

  @override
  State<QRScannerPage> createState() => _QRScannerPageState();
}

class _QRScannerPageState extends LocalizedState<QRScannerPage> {
  MobileScannerController cameraController = MobileScannerController();
  bool _isScanning = true;
  final TextEditingController _qrDataController = TextEditingController();

  @override
  void dispose() {
    cameraController.dispose();
    _qrDataController.dispose();
    super.dispose();
  }

  Future<void> _processScannedData(String? code) async {
    if (!_isScanning || code == null || code.isEmpty) return;

    setState(() => _isScanning = false);

    Logger().d('📦 Scanned: $code');

    final repository =
        context.read<LocalRepository<StockModel, StockSearchModel>>()
            as CustomStockLocalRepository;

    List<StockModel> receivedResult;
    List<StockModel> result = [];

    try {
      // if (!Platform.isAndroid && !Platform.isIOS && code == 'test') {
      //   code = _generateTestQRData();
      // }
      final compressed = base64Url.decode(code);

      final decompressed = utf8.decode(zlib.decode(compressed));
      final decodedJson = jsonDecode(decompressed);
      Logger().d('📦 Decompressed: $decodedJson');
      List<StockModel> stockList = [];

      for (String item in decodedJson) {
        StockModel model = StockModelMapper.fromJson(item);
        if (model.receiverId != context.loggedInUserUuid) {
          _showError('This QR code is not applicable for your account');
          return;
        }
        // dssfsf
        stockList.add(model);
      }

      final mrnNumber = stockList.first.additionalFields?.fields
              .firstWhere(
                (field) => field.key == 'materialNoteNumber',
                orElse: () => const AdditionalField('materialNoteNumber', ''),
              )
              .value
              ?.toString() ??
          'N/A';

      receivedResult = await repository.search(StockSearchModel(
          transactionType: [TransactionType.received.toValue()],
          transactionReason: [TransactionReason.received.toValue()],
          receiverId: [context.loggedInUserUuid]));

      for (StockModel stockModel in receivedResult) {
        String minStock = stockModel.additionalFields?.fields
                .firstWhere(
                  (field) => field.key == 'materialNoteNumber',
                  orElse: () => const AdditionalField('materialNoteNumber', ''),
                )
                .value
                ?.toString() ??
            'N/A';
        if (minStock == mrnNumber) {
          _showError('Stock already received');
          return;
        }
      }

      if (stockList.isNotEmpty) {
        final shouldSubmit = await dialog.DigitDialog.show<bool>(
          context,
          options: dialog.DigitDialogOptions(
            titleText: localizations.translate(
              i18.deliverIntervention.dialogTitle,
            ),
            contentText: localizations.translate(
              i18.deliverIntervention.dialogContent,
            ),
            primaryAction: dialog.DigitDialogActions(
              label: localizations.translate(
                i18.common.coreCommonSubmit,
              ),
              action: (ctx) {
                Navigator.of(ctx, rootNavigator: true).pop(true);
              },
            ),
            secondaryAction: dialog.DigitDialogActions(
              label: localizations.translate(
                i18.common.coreCommonGoback,
              ),
              action: (ctx) {
                Navigator.of(ctx, rootNavigator: true).pop(false);
              },
            ),
          ),
        );
        if (shouldSubmit ?? false) {
          Logger().d("This is the list $stockList");
          context.router.push(
            ViewStockRecordsCDDRoute(
              mrnNumber: stockList.first.additionalFields?.fields
                      .firstWhere((f) => f.key == 'materialNoteNumber',
                          orElse: () => const AdditionalField('', ''))
                      .value ??
                  "",
              stockRecords: stockList,
            ),
          );
        }
      }
    } catch (e) {
      _showError('Invalid QR code format: ${e.toString()}');
    } finally {
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) setState(() => _isScanning = true);
      });
    }
  }

  String _generateTestQRData() {
    final testData = {
      "additionalFields": {
        "schema": "Stock",
        "version": 1,
        "fields": [
          {"key": "productName", "value": "SPAQ 1"},
          {"key": "variation", "value": "SPAQ 1"},
          {"key": "batchNumber", "value": "BATCH-TEST-001"}
        ]
      },
      "receiverId": context.loggedInUserUuid,
      "wayBillNumber": "WB-TEST-001",
      "quantity": "100"
    };
    return base64Url
        .encode(zlib.encode(utf8.encode(jsonEncode([jsonEncode(testData)]))));
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          // title: Text(localizations.translate('qr_scanner_title')),
          actions: [
            IconButton(
              icon: const Icon(Icons.flash_on),
              onPressed: () {
                cameraController.toggleTorch();
              },
              tooltip: 'Toggle Torch',
            ),
          ],
        ),
        body: Stack(
          children: [
            MobileScanner(
              controller: cameraController,
              onDetect: (capture) {
                final barcode = capture.barcodes.firstOrNull;
                if (barcode != null && barcode.rawValue != null) {
                  _processScannedData(barcode.rawValue);
                }
              },
            ),
            Align(
              alignment: Alignment.center,
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.green, width: 3),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            if (!Platform.isAndroid && !Platform.isIOS)
              Positioned(
                bottom: 32,
                left: 32,
                right: 32,
                child: ElevatedButton(
                  onPressed: () => _processScannedData('test'),
                  child: const Text('Test with Sample QR Data'),
                ),
              ),
          ],
        ));
  }
}
