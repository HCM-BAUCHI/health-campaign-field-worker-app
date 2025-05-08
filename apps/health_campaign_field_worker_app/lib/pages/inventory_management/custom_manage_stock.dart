import 'package:auto_route/auto_route.dart';
import 'package:digit_components/widgets/digit_dialog.dart';
import 'package:digit_ui_components/digit_components.dart';
import 'package:digit_ui_components/theme/digit_extended_theme.dart';
import 'package:digit_ui_components/widgets/atoms/menu_card.dart';
import 'package:digit_ui_components/widgets/scrollable_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:inventory_management/router/inventory_router.gm.dart';

import 'package:inventory_management/utils/i18_key_constants.dart' as i18;
import 'package:inventory_management/widgets/localized.dart';
import 'package:inventory_management/blocs/record_stock.dart';
import 'package:inventory_management/widgets/back_navigation_help_header.dart';

import '../../utils/utils.dart';

@RoutePage()
class CustomManageStocksPage extends LocalizedStatefulWidget {
  const CustomManageStocksPage({
    super.key,
    super.appLocalizations,
  });

  @override
  State<CustomManageStocksPage> createState() => CustomManageStocksPageState();
}

class CustomManageStocksPageState
    extends LocalizedState<CustomManageStocksPage> {
  @override
  initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.digitTextTheme(context);

    return Scaffold(
      body: ScrollableContent(
        header: const BackNavigationHelpHeaderWidget(
          showHelp: true,
        ),
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.only(
                    left: spacer2, right: spacer2, bottom: spacer4),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    localizations.translate(i18.manageStock.label),
                    style: textTheme.headingXl,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              Column(children: [
                Padding(
                  padding: const EdgeInsets.only(left: spacer2, right: spacer2),
                  child: MenuCard(
                    heading: localizations
                        .translate(i18.manageStock.recordStockReceiptLabel),
                    description: localizations.translate(
                        i18.manageStock.recordStockReceiptDescription),
                    icon: Icons.file_download_outlined,
                    onTap: () {
                      showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      context.router.push(
                                        RecordStockWrapperRoute(
                                          type: StockRecordEntryType.receipt,
                                        ),
                                      );
                                      Navigator.of(context).pop();
                                    },
                                    child: Container(
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: Colors.orange[800]!,
                                          width: 1,
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                        color: Colors.white,
                                      ),
                                      padding: const EdgeInsets.all(16),
                                      child: Center(
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.file_download_outlined,
                                              size: 24,
                                              color: Colors.orange[800],
                                            ),
                                            SizedBox(width: 8),
                                            Text(
                                              "Create New Transaction",
                                              style: TextStyle(
                                                fontSize: 20,
                                                color: Colors.orange[800],
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                      height:
                                          16), // Add spacing between buttons
                                  Container(
                                    width: 400,
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Colors.orange[800]!,
                                        width: 1,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                      color: Colors.white,
                                    ),
                                    padding: const EdgeInsets.all(16),
                                    child: Center(
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.remove_red_eye,
                                            size: 24,
                                            color: Colors.orange[800],
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            "View Create Transaction",
                                            style: TextStyle(
                                              fontSize: 20,
                                              color: Colors.orange[800],
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          });
                      // context.router.push(
                      //   RecordStockWrapperRoute(
                      //     type: StockRecordEntryType.receipt,
                      //   ),
                      // );
                    },
                  ),
                ),
                if (!context.isCDD)
                  const SizedBox(
                    height: spacer4,
                  ),
                if (!context.isCDD)
                  Padding(
                    padding:
                        const EdgeInsets.only(left: spacer2, right: spacer2),
                    child: MenuCard(
                        heading: localizations
                            .translate(i18.manageStock.recordStockIssuedLabel),
                        description: localizations.translate(
                            i18.manageStock.recordStockIssuedDescription),
                        icon: Icons.file_upload_outlined,
                        onTap: () => context.router.push(
                              RecordStockWrapperRoute(
                                type: StockRecordEntryType.dispatch,
                              ),
                            )),
                  ),
                const SizedBox(
                  height: spacer4,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: spacer2, right: spacer2),
                  child: MenuCard(
                      heading: localizations
                          .translate(i18.manageStock.recordStockReturnedLabel),
                      description: localizations.translate(
                        i18.manageStock.recordStockReturnedDescription,
                      ),
                      icon: Icons.settings_backup_restore,
                      onTap: () => context.router.push(
                            RecordStockWrapperRoute(
                              type: StockRecordEntryType.returned,
                            ),
                          )),
                ),
                // const SizedBox(
                //   height: spacer4,
                // ),
                // Padding(
                //   padding: const EdgeInsets.only(left: spacer2, right: spacer2),
                //   child: MenuCard(
                //       heading: localizations
                //           .translate(i18.manageStock.recordStockDamagedLabel),
                //       description: localizations.translate(
                //         i18.manageStock.recordStockDamagedDescription,
                //       ),
                //       icon: Icons.store,
                //       onTap: () => context.router.push(
                //             RecordStockWrapperRoute(
                //               type: StockRecordEntryType.damaged,
                //             ),
                //           )),
                // ),
                // const SizedBox(
                //   height: spacer4,
                // ),
                // Padding(
                //   padding: const EdgeInsets.only(left: spacer2, right: spacer2),
                //   child: MenuCard(
                //       heading: localizations
                //           .translate(i18.manageStock.recordStockLossLabel),
                //       description: localizations.translate(
                //         i18.manageStock.recordStockDamagedDescription,
                //       ),
                //       icon: Icons.store,
                //       onTap: () => context.router.push(
                //             RecordStockWrapperRoute(
                //               type: StockRecordEntryType.loss,
                //             ),
                //           )),
                // ),
              ]),
              const SizedBox(height: spacer4),
            ],
          ),
        ],
      ),
    );
  }
}
