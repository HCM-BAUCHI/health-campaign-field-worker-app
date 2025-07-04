import 'package:digit_data_model/data_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_campaign_field_worker_app/data/repositories/local/inventory_management/custom_stock.dart';
import 'package:inventory_management/models/entities/stock.dart';
import 'package:logger/logger.dart';

import '../../blocs/inventory_management/stock_bloc.dart';
import '../../router/app_router.dart';
import 'view_stock_records.dart'; // Import your view stock page

@RoutePage()
class ViewTransactionsScreen extends StatefulWidget {
  const ViewTransactionsScreen({super.key});

  @override
  State<ViewTransactionsScreen> createState() => _ViewTransactionsScreenState();
}

class _ViewTransactionsScreenState extends State<ViewTransactionsScreen> {
  @override
  void initState() {
    super.initState();
    loadLocalStockData();
  }

  List<StockModel> stockList = [];

  Future<void> loadLocalStockData() async {
    final repository =
        context.read<LocalRepository<StockModel, StockSearchModel>>()
            as CustomStockLocalRepository;

    final result = await repository.search(StockSearchModel());

    setState(() {
      stockList = result;
    });

    Logger().i("Stock List: $stockList");
  }

  Map<String, List<StockModel>> groupStockByMrn(List<StockModel> stocks) {
    final Map<String, List<StockModel>> grouped = {};
    for (final stock in stocks) {
      final mrn = stock.additionalFields?.fields
              .firstWhere(
                (f) => f.key == 'materialNoteNumber',
                orElse: () => AdditionalField('materialNoteNumber', ''),
              )
              .value
              ?.toString() ??
          'UNKNOWN';
      grouped.putIfAbsent(mrn, () => []).add(stock);
    }
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<StockBloc, StockState>(
        builder: (context, state) {
          Map<String, List<StockModel>> groupedData = {};

          if (state is StockLoadedState && state.groupedStocks.isNotEmpty) {
            groupedData = state.groupedStocks;
          } else if (stockList.isNotEmpty) {
            groupedData = groupStockByMrn(stockList);
          }

          if (groupedData.isEmpty) {
            return const Center(child: Text('No transactions available.'));
          }

          return ListView.builder(
            itemCount: groupedData.length,
            itemBuilder: (context, index) {
              final mrnGroup = groupedData.values.elementAt(index);
              final firstStock = mrnGroup.first;

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                elevation: 2,
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ViewStockRecordsPage(
                          mrnNumber: firstStock.additionalFields?.fields
                                  .firstWhere(
                                    (field) =>
                                        field.key == 'materialNoteNumber',
                                    orElse: () => AdditionalField(
                                        'materialNoteNumber', ''),
                                  )
                                  .value
                                  ?.toString() ??
                              'N/A',
                          stockRecords: mrnGroup,
                        ),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header with MRN and Date
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'MRN: ${firstStock.additionalFields?.fields.firstWhere(
                                    (field) =>
                                        field.key == 'materialNoteNumber',
                                    orElse: () => AdditionalField(
                                        'materialNoteNumber', ''),
                                  ).value?.toString() ?? 'N/A'}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              'Date: ${firstStock.dateOfEntryTime?.toLocal().toString().split(' ')[0] ?? 'N/A'}',
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'From: ${firstStock.senderId ?? firstStock.facilityId ?? 'N/A'}',
                          style: const TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 12),

                        const Divider(),
                        const Text(
                          'Commodities Received:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        ...mrnGroup.map((stock) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    stock.additionalFields?.fields
                                            .firstWhere(
                                              (field) =>
                                                  field.key == 'productName',
                                              orElse: () => AdditionalField(
                                                  'productName', 'N/A'),
                                            )
                                            .value
                                            ?.toString() ??
                                        'N/A',
                                  ),
                                  Text(
                                    'Qty: ${stock.quantity ?? 'N/A'}',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            )),
                        const Divider(),
                        Text(
                          'Waybill: ${firstStock.wayBillNumber ?? 'N/A'}',
                          style: const TextStyle(fontStyle: FontStyle.italic),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
