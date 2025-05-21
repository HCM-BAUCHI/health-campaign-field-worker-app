import 'dart:convert';
import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:digit_data_model/data_model.dart';
import 'package:digit_ui_components/digit_components.dart';
import 'package:digit_ui_components/theme/digit_extended_theme.dart';
import 'package:digit_ui_components/widgets/molecules/digit_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_campaign_field_worker_app/data/repositories/local/inventory_management/custom_stock.dart';
import 'package:health_campaign_field_worker_app/utils/utils.dart';
import 'package:health_campaign_field_worker_app/widgets/action_card/min_number_card.dart';
import 'package:inventory_management/blocs/record_stock.dart';
import 'package:inventory_management/models/entities/stock.dart';
import 'package:inventory_management/utils/i18_key_constants.dart' as i18;
import 'package:inventory_management/utils/utils.dart';
import 'package:inventory_management/widgets/localized.dart';
import 'package:inventory_management/widgets/back_navigation_help_header.dart';
import '../../router/app_router.dart';
import 'package:logger/logger.dart';

import '../../widgets/custom_back_navigation.dart';

@RoutePage()
class CustomMinNumberPage extends LocalizedStatefulWidget {
  final dynamic type;
  const CustomMinNumberPage({
    super.key,
    super.appLocalizations,
    required this.type,
  });

  @override
  State<CustomMinNumberPage> createState() => CustomMinNumberPageState();
}

class CustomMinNumberPageState extends LocalizedState<CustomMinNumberPage> {
  List<StockModel> stockList = [];
  String? selectedMRN;
  List<StockModel> selectedStockList = [];

  @override
  void initState() {
    super.initState();
    loadLocalStockData();
    Logger().i(
        "Stock Type: ${widget.type == StockRecordEntryType.returned ? "RETURNED" : widget.type == StockRecordEntryType.receipt ? "RECEIVED" : "DISPATCHED"}");
  }

  Future<void> loadLocalStockData() async {
    final repository =
        context.read<LocalRepository<StockModel, StockSearchModel>>()
            as CustomStockLocalRepository;

    final result = await repository.search(StockSearchModel());

    // Define correct values
    String? transactionType;
    String? transactionReason;

    if (widget.type == StockRecordEntryType.returned) {
      transactionType = 'RECEIVED';
      transactionReason = 'RETURNED';
    } else if (widget.type == StockRecordEntryType.receipt) {
      transactionType = 'RECEIVED';
    } else if (widget.type == StockRecordEntryType.dispatch) {
      transactionType = 'DISPATCHED';
    }

    final filteredResult = result.where((stock) {
      if (transactionType == null) return false;

      if ((widget.type == StockRecordEntryType.dispatch) ||
          (widget.type == StockRecordEntryType.receipt)) {
        return stock.transactionType == transactionType;
      } else {
        return stock.transactionType == transactionType &&
            stock.transactionReason == transactionReason;
      }
    }).toList();

    Logger().i("Filtered Stock Count: ${filteredResult.length}");
    Logger().i(
        "First filtered stock: ${filteredResult.isNotEmpty ? filteredResult.first.toJson() : 'None'}");

    setState(() {
      stockList = filteredResult;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.digitTextTheme(context);

    // Group stockList by materialNoteNumber
    final Map<String, List<StockModel>> groupedStock = {};
    for (final stock in stockList) {
      final mrn = stock.additionalFields?.fields
          .firstWhere((f) => f.key == 'materialNoteNumber',
              orElse: () => const AdditionalField('', ''))
          .value;

      Logger().i('MRN: $mrn');

      if (mrn == null || mrn.isEmpty) continue;

      groupedStock.putIfAbsent(mrn, () => []);
      groupedStock[mrn]!.add(stock);
    }

    final groupedEntries = groupedStock.entries.toList();
    List<StockModel> finalStocks = [];

    return Scaffold(
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: ScrollableContent(
          header: const Column(
            children: [
              CustomBackNavigationHelpHeaderWidget(showHelp: false),
            ],
          ),
          footer: SizedBox(
            child: DigitCard(
              margin: const EdgeInsets.fromLTRB(0, spacer2, 0, 0),
              children: [
                DigitButton(
                  type: DigitButtonType.primary,
                  mainAxisSize: MainAxisSize.max,
                  size: DigitButtonSize.large,
                  label: localizations.translate(
                    i18.householdDetails.actionLabel,
                  ),
                  onPressed: () {
                    if (selectedMRN != null && selectedStockList.isNotEmpty) {
                      context.router.push(
                        ViewStockRecordsRoute(
                          mrnNumber: selectedMRN!,
                          stockRecords: selectedStockList,
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Please select a record"),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(spacer2),
              ),
              margin: const EdgeInsets.all(spacer2),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: groupedEntries.isEmpty
                    ? const Center(child: Text("No transactions found."))
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 16.0),
                          Text("Select the MRN number",
                              style: textTheme.headingL),
                          const SizedBox(height: 16.0),
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.7,
                            child: ListView.builder(
                              reverse: true,
                              itemCount: groupedEntries.length,
                              itemBuilder: (context, index) {
                                final mrn = groupedEntries[index].key;
                                finalStocks = [];
                                for (StockModel stockModel
                                    in groupedEntries[index].value) {
                                  finalStocks
                                      .add(condenseStockObject(stockModel));
                                }
                                final stocks = groupedEntries[index].value;
                                final isSelected = selectedMRN == mrn;
                                final jsonStr = jsonEncode(finalStocks);

                                final compressed =
                                    zlib.encode(utf8.encode(jsonStr));
                                final encoded = base64Url.encode(compressed);

                                return Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        if (selectedMRN == mrn) {
                                          selectedMRN = null;
                                          selectedStockList = [];
                                        } else {
                                          selectedMRN = mrn;
                                          selectedStockList = stocks;
                                        }
                                      });
                                    },
                                    child: MinNumberCard(
                                      data: encoded,
                                      minNumber: mrn,
                                      cddCode: InventorySingleton()
                                              .loggedInUser
                                              ?.name ??
                                          stocks.first.senderId ??
                                          "",
                                      date: formatDateFromMillis(stocks.first
                                              .auditDetails?.createdTime ??
                                          0),
                                      items: stocks.map((s) {
                                        final name = (s.additionalFields?.fields
                                                    .firstWhere(
                                                        (f) =>
                                                            f.key ==
                                                            'productName',
                                                        orElse: () =>
                                                            const AdditionalField(
                                                                '', ''))
                                                    .value ??
                                                'N/A')
                                            .toString();

                                        final quantity =
                                            (s.quantity ?? 0).toString();

                                        return {
                                          'name': name,
                                          'quantity': quantity,
                                        };
                                      }).toList(),
                                      waybillNumber: InventorySingleton()
                                              .isDistributor
                                          ? null
                                          : stocks.first.wayBillNumber ?? "",
                                      isSelected: isSelected,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  StockModel condenseStockObject(StockModel stockModel) {
    return stockModel.copyWith(
      auditDetails: null,
      clientAuditDetails: null,
      additionalFields: stockModel.additionalFields?.copyWith(
        fields: [
          ...(stockModel.additionalFields?.fields ?? []),
        ],
      ),
    );
  }
}
