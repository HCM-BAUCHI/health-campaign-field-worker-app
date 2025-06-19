import 'package:auto_route/auto_route.dart';
import 'package:digit_data_model/data_model.dart';
import 'package:digit_ui_components/digit_components.dart';
import 'package:digit_ui_components/widgets/atoms/input_wrapper.dart';
import 'package:digit_ui_components/widgets/molecules/digit_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inventory_management/blocs/record_stock.dart';
import 'package:inventory_management/models/entities/stock.dart';
import 'package:inventory_management/models/entities/transaction_reason.dart';
import 'package:inventory_management/models/entities/transaction_type.dart';
import 'package:inventory_management/utils/i18_key_constants.dart' as i18;
import 'package:inventory_management/utils/utils.dart';
import 'package:registration_delivery/widgets/localized.dart';
import 'package:reactive_forms/reactive_forms.dart';

import '../../blocs/auth/auth.dart';
import '../../router/app_router.dart';
import '../../utils/constants.dart';
import '../../utils/extensions/extensions.dart';
import 'package:collection/collection.dart';

import '../../widgets/custom_back_navigation.dart';

@RoutePage()
class ViewStockRecordsLGAPage extends LocalizedStatefulWidget {
  final String mrnNumber;
  final List<StockModel> stockRecords;

  const ViewStockRecordsLGAPage({
    super.key,
    super.appLocalizations,
    required this.mrnNumber,
    required this.stockRecords,
  });

  @override
  State<ViewStockRecordsLGAPage> createState() =>
      _ViewStockRecordsLGAPageState();
}

class _ViewStockRecordsLGAPageState
    extends LocalizedState<ViewStockRecordsLGAPage> {
  late final FormGroup _form;
  late final Map<String, int> _issuedQuantities;
  bool _commentsRequired = false;

  @override
  void initState() {
    super.initState();
    _issuedQuantities = {
      for (final stock in widget.stockRecords)
        stock.additionalFields?.fields
                .firstWhereOrNull((f) => f.key == 'productName')
                ?.value
                .toString() ??
            '': int.tryParse(stock.quantity ?? '0') ?? 0
    };
    _form = FormGroup({
      'quantityReceived': FormControl<int>(
        validators: [
          Validators.required,
          Validators.min(1),
          Validators.delegate((control) {
            final productName = widget
                    .stockRecords.first.additionalFields?.fields
                    .firstWhereOrNull((f) => f.key == 'productName')
                    ?.value
                    .toString() ??
                '';
            final issued = _issuedQuantities[productName] ?? 0;
            final received = control.value ?? 0;
            if (received > issued) {
              return {'maxIssued': true};
            }
            return null;
          })
        ],
      ),
      'comments': FormControl<String>(),
    });
    _form.control('quantityReceived').valueChanges.listen((value) {
      final received = value ?? 0;
      final productName = widget.stockRecords.first.additionalFields?.fields
              .firstWhereOrNull((f) => f.key == 'productName')
              ?.value
              .toString() ??
          '';
      final issued = _issuedQuantities[productName] ?? 0;
      final required = received < issued;
      if (_commentsRequired != required) {
        setState(() {
          _commentsRequired = required;
        });
      }
    });
    _form.control('comments').setValidators([
      Validators.delegate((control) {
        final received = _form.control('quantityReceived').value ?? 0;
        final productName = widget.stockRecords.first.additionalFields?.fields
                .firstWhereOrNull((f) => f.key == 'productName')
                ?.value
                .toString() ??
            '';
        final issued = _issuedQuantities[productName] ?? 0;
        if (received < issued &&
            (control.value == null || control.value.isEmpty)) {
          control.markAllAsTouched();
          return {'requiredIfShort': true};
        }
        return null;
      })
    ]);
    _form.control('quantityReceived').valueChanges.listen((value) {
      _form.control('comments').updateValueAndValidity();
    });
    final recordStockBloc = BlocProvider.of<RecordStockBloc>(context);
  }

  @override
  void dispose() {
    _form.dispose();
    super.dispose();
  }

  Future<void> _handleSubmission() async {
    if (_form.valid) {
      final updatedStocks = widget.stockRecords.map((stock) {
        final additionalFields = stock.additionalFields?.fields ?? [];

        final newFields = [
          ...additionalFields.where((field) =>
              field.key != 'quantityReceived' && field.key != 'comments'),
          AdditionalField('quantityReceived',
              _form.control('quantityReceived').value.toString()),
          AdditionalField(
            'quantitySent',
            stock.quantity ?? '',
          ),
          if (_form.control('comments').value != null)
            AdditionalField('comments', _form.control('comments').value),
        ];

        return stock.copyWith(
          id: null,
          rowVersion: 1,
          clientReferenceId: IdGen.i.identifier,
          referenceId: context.selectedProject.id,
          transactionType: TransactionType.received.toValue(),
          transactionReason: TransactionReason.received.toValue(),
          quantity: _form.control('quantityReceived').value.toString(),
          additionalFields: stock.additionalFields?.copyWith(
            fields: newFields,
          ),
          auditDetails: AuditDetails(
            createdBy: InventorySingleton().loggedInUserUuid,
            createdTime: context.millisecondsSinceEpoch(),
            lastModifiedBy: InventorySingleton().loggedInUserUuid,
            lastModifiedTime: context.millisecondsSinceEpoch(),
          ),
          clientAuditDetails: ClientAuditDetails(
            createdBy: InventorySingleton().loggedInUserUuid,
            createdTime: context.millisecondsSinceEpoch(),
            lastModifiedBy: InventorySingleton().loggedInUserUuid,
            lastModifiedTime: context.millisecondsSinceEpoch(),
          ),
        );
      }).toList();

      for (final stock in updatedStocks) {
        context.read<RecordStockBloc>().add(
              RecordStockSaveStockDetailsEvent(
                stockModel: stock,
              ),
            );
        context.read<RecordStockBloc>().add(
              const RecordStockCreateStockEntryEvent(),
            );
        // if (InventorySingleton().isDistributor) {
        final totalQty =
            int.parse(_form.control('quantityReceived').value.toString());

        int spaq1Count = context.spaq1;
        int spaq2Count = context.spaq2;

        int blueVasCount = context.blueVas;
        int redVasCount = context.redVas;
        String productName = stock.additionalFields?.fields
            .firstWhereOrNull((element) => element.key == "productName")
            ?.value;
        // Custom logic based on productName
        if (productName == Constants.spaq1) {
          spaq1Count = totalQty;
          spaq2Count = 0;
          redVasCount = 0;
          blueVasCount = 0;
        } else if (productName == Constants.spaq2) {
          spaq2Count = totalQty;
          spaq1Count = 0;
          redVasCount = 0;
          blueVasCount = 0;
        } else if (productName == Constants.blueVAS) {
          blueVasCount = totalQty;
          spaq1Count = 0;
          spaq2Count = 0;
          redVasCount = 0;
        } else {
          blueVasCount = 0;
          spaq1Count = 0;
          spaq2Count = 0;
          redVasCount = totalQty;
        }
        context.read<AuthBloc>().add(
              AuthAddSpaqCountsEvent(
                spaq1Count: spaq1Count,
                spaq2Count: spaq2Count,
                blueVasCount: blueVasCount,
                redVasCount: redVasCount,
              ),
            );
        await Future.delayed(const Duration(milliseconds: 500));
        // _tabController.animateTo(_tabController.index + 1);

        context.read<RecordStockBloc>().add(
              const RecordStockCreateStockEntryEvent(),
            );
        // }
      }

      context.router.push(
        CustomAcknowledgementRoute(
            mrnNumber: widget.mrnNumber,
            stockRecords: updatedStocks,
            entryType: StockRecordEntryType.receipt),
      );
    } else {
      _form.markAllAsTouched();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Assumption sender receiver Id not changed ,
    //using the same as downloaded stock data
    // and this flow is for stock receipt for LGA
    final senderIdToShowOnTab = widget.stockRecords.first.senderId;
    bool commentRequired = false;

    return Scaffold(
      body: ScrollableContent(
        header: const Column(
          children: [
            CustomBackNavigationHelpHeaderWidget(),
          ],
        ),
        children: [
          ReactiveForm(
            formGroup: _form,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  DigitCard(
                    padding: const EdgeInsets.all(16),
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Stock Receipt Details',
                            style: TextStyle(
                                fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              const Expanded(child: Text('MIN Number')),
                              Expanded(child: Text(widget.mrnNumber)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Expanded(child: Text('Received from')),
                              // TODO : verify this , showing senderId here
                              Expanded(
                                child: Text(localizations
                                    .translate('FAC_$senderIdToShowOnTab')),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  ...widget.stockRecords.map((stock) {
                    final productName = stock.additionalFields?.fields
                            .firstWhere(
                              (field) => field.key == 'productName',
                              orElse: () => AdditionalField('productName', ''),
                            )
                            .value
                            ?.toString() ??
                        '';

                    return Column(
                      children: [
                        DigitCard(
                          padding: const EdgeInsets.all(16),
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  productName,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: productName == 'SPAQ 1' ||
                                            productName == 'SPAQ 2'
                                        ? Colors.orange
                                        : productName == 'Red VAS'
                                            ? Colors.red
                                            : productName == 'Blue VAS'
                                                ? Colors.blue
                                                : Theme.of(context)
                                                    .primaryColor,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                InputField(
                                  type: InputType.text,
                                  label: 'Waybill Number *',
                                  initialValue: stock.wayBillNumber ?? '',
                                  isDisabled: true,
                                  readOnly: true,
                                ),
                                const SizedBox(height: 12),
                                InputField(
                                  type: InputType.text,
                                  label: 'Batch Number',
                                  initialValue: stock.additionalFields?.fields
                                          .firstWhere(
                                            (field) =>
                                                field.key == 'batchNumber',
                                            orElse: () => AdditionalField(
                                                'batchNumber', ''),
                                          )
                                          .value
                                          ?.toString() ??
                                      '',
                                  isDisabled: true,
                                  readOnly: true,
                                ),
                                const SizedBox(height: 12),
                                InputField(
                                  type: InputType.text,
                                  label: 'Quantity Sent by Warehouse *',
                                  initialValue: stock.quantity ?? '',
                                  isDisabled: true,
                                  readOnly: true,
                                ),
                                const SizedBox(height: 12),
                                ReactiveWrapperField(
                                  formControlName: 'quantityReceived',
                                  builder: (field) => InputField(
                                    type: InputType.text,
                                    label: 'Actual Quantity Received *',
                                    errorMessage: field.errorText,
                                    keyboardType: TextInputType.number,
                                    onChange: (value) {
                                      if (value != null && value.isNotEmpty) {
                                        field.control.value =
                                            int.tryParse(value);
                                      } else {
                                        field.control.value = null;
                                      }
                                    },
                                  ),
                                  validationMessages: {
                                    'required': (_) => 'Quantity is required',
                                    'min': (_) => 'Must be at least 1',
                                    'number': (_) => 'Must be a valid number',
                                    'maxIssued': (_) =>
                                        'Received quantity cannot be more than issued quantity',
                                  },
                                ),
                                const SizedBox(height: 12),
                                ReactiveWrapperField(
                                  formControlName: 'comments',
                                  validationMessages: {
                                    'requiredIfShort': (_) =>
                                        'Comments are required if quantity received is less than issued',
                                  },
                                  builder: (field) => InputField(
                                    isRequired: _commentsRequired,
                                    type: InputType.textArea,
                                    label: 'Comments',
                                    errorMessage: field.errorText,
                                    onChange: (value) =>
                                        field.control.value = value,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                      ],
                    );
                  }).toList(),
                  const SizedBox(height: 24),
                  DigitButton(
                    label: localizations.translate(i18.common.coreCommonSubmit),
                    onPressed: _handleSubmission,
                    type: DigitButtonType.primary,
                    size: DigitButtonSize.large,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
