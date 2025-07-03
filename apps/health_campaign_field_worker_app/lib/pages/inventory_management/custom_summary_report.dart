import 'package:collection/collection.dart';
import 'package:digit_components/digit_components.dart';
import 'package:digit_components/utils/date_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_campaign_field_worker_app/widgets/localized.dart';
import 'package:health_campaign_field_worker_app/widgets/reports/readonly_pluto_grid.dart';
import 'package:intl/intl.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:registration_delivery/models/entities/household.dart';
import 'package:registration_delivery/registration_delivery.dart';
import 'package:registration_delivery/widgets/back_navigation_help_header.dart';

import '../../../router/app_router.dart';
import '../../../utils/utils.dart';
import '../../../utils/i18_key_constants.dart' as i18Local;
import '../../blocs/inventory_management/custom_summary_report_bloc.dart';

@RoutePage()
class CustomSummaryReportPage extends LocalizedStatefulWidget {
  const CustomSummaryReportPage({
    Key? key,
    super.appLocalizations,
  }) : super(key: key);

  @override
  State<CustomSummaryReportPage> createState() => _CustomSummaryReportState();
}

class _CustomSummaryReportState
    extends LocalizedState<CustomSummaryReportPage> {
  @override
  void initState() {
    super.initState();
    // Load data when the page is initialized
    _loadData();
  }

  void _loadData() {
    final bloc = BlocProvider.of<SummaryReportBloc>(context);
    bloc.add(const SummaryReportLoadingEvent());
    Future.delayed(const Duration(milliseconds: 500), () {
      bloc.add(SummaryReportLoadDataEvent(
        userId: context.loggedInUserUuid,
      ));
    });
  }

  static const _dateKey = 'dateKey';
  static const _registeredChildrenKey = 'registeredChildren';
  static const _administeredChildrenKey = 'administeredChildren';
  static const _refusalsCasesKey = 'refusalsCases';
  static const _usedTablet_3_11monthKey = 'usedTablet3_11month';
  static const _usedTablet_12_59monthKey = 'usedTablet12s_59month';
  static const _zeroDoseChildrenKey = 'zeroDoseChildren';
  static const _spaqRedoseCount = 'spaqRedoseCount';
  static const _childrenTreatedPrecKey = 'childrenTreatedPercKey';
  static const _drugUsedKey = 'drugUsedKey';
  static const _drugBalanceKey = 'drugBalanceKey';

  String _calculatePercentage(dynamic value, int total) {
    if (value == null) return "0%";

    final quantity = value is num ? value : int.tryParse(value.toString()) ?? 0;

    final percent = (quantity / total) * 100;
    return "${percent.toStringAsFixed(1)}%";
  }

  String _calculateDrugBalance(
      MapEntry<String, Map<String, int>> entry, int previousDayBalance) {
    int drugReceivedBalance = (entry.value[Constants.spaq1] ?? 0) +
        (entry.value[Constants.spaq2] ?? 0) +
        (entry.value[Constants.redVAS] ?? 0) +
        (entry.value[Constants.blueVAS] ?? 0);
    int drugReturnBalance = (entry.value[Constants.returnStock] ?? 0);
    int drugUsedBalance = (entry.value[Constants.administered] ?? 0) +
        (entry.value[Constants.reDoseQuantityKey] ?? 0);
    int currentDrugBalance = drugReceivedBalance -
        drugReturnBalance -
        drugUsedBalance +
        previousDayBalance;

    return currentDrugBalance.toString();
  }

  FormGroup _form() {
    return fb.group({});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<SummaryReportBloc, SummaryReportState>(
        builder: (context, sumamryReportState) {
          if (sumamryReportState is SummaryReportLoadingState) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          return ScrollableContent(
            footer: Padding(
              padding: const EdgeInsets.fromLTRB(kPadding, 0, kPadding, 0),
              child: DigitElevatedButton(
                child: Text(localizations
                    .translate(i18Local.acknowledgementSuccess.goToHome)),
                onPressed: () {
                  context.router.popUntilRouteWithName(HomeRoute.name);
                },
              ),
            ),
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const BackNavigationHelpHeaderWidget(),
              Container(
                padding: const EdgeInsets.all(kPadding),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    localizations
                        .translate(i18Local.homeShowcase.summaryReport),
                    maxLines: 1,
                    style: Theme.of(context).textTheme.displayMedium,
                  ),
                ),
              ),
              if (sumamryReportState is SummaryReportDataState)
                ReactiveFormBuilder(
                  form: _form,
                  builder: (ctx, form, child) {
                    return SizedBox(
                      height: 400,
                      child: _ReportDetailsContent(
                        title: localizations
                            .translate(i18Local.homeShowcase.summaryReport),
                        data: DigitGridData(
                          columns: [
                            DigitGridColumn(
                              label: localizations.translate(
                                  i18Local.homeShowcase.summaryReportDate),
                              key: _dateKey,
                              width: 120,
                            ),
                            DigitGridColumn(
                              label: localizations.translate(i18Local
                                  .homeShowcase
                                  .summaryReportRegistredHousehold),
                              key: _registeredChildrenKey,
                              width: 180,
                            ),
                            DigitGridColumn(
                              label: localizations.translate(i18Local
                                  .homeShowcase
                                  .summaryReportAdministredChildren),
                              key: _administeredChildrenKey,
                              width: 180,
                            ),
                            DigitGridColumn(
                              label: localizations.translate(i18Local
                                      .homeShowcase
                                      .summaryReportAdministredChildren) +
                                  '(%)',
                              key: _childrenTreatedPrecKey,
                              width: 180,
                            ),
                            DigitGridColumn(
                              label: localizations.translate(
                                  i18Local.homeShowcase.summaryReportSPAQ1),
                              key: _usedTablet_3_11monthKey,
                              width: 180,
                            ),
                            DigitGridColumn(
                              label: localizations.translate(
                                  i18Local.homeShowcase.summaryReportSPAQ2),
                              key: _usedTablet_12_59monthKey,
                              width: 180,
                            ),
                            DigitGridColumn(
                              label: localizations.translate(
                                  i18Local.homeShowcase.summaryReportRedVas),
                              key: _zeroDoseChildrenKey,
                              width: 180,
                            ),
                            DigitGridColumn(
                              label: localizations.translate(
                                  i18Local.homeShowcase.summaryReportBlueVas),
                              key: _refusalsCasesKey,
                              width: 180,
                            ),
                            DigitGridColumn(
                              label: localizations.translate(i18Local
                                  .homeShowcase.summaryReportSPAQRedoseCount),
                              key: _spaqRedoseCount,
                              width: 180,
                            ),
                            DigitGridColumn(
                              label: localizations.translate(
                                  i18Local.homeShowcase.summaryReportDrugUsed),
                              key: _drugUsedKey,
                              width: 180,
                            ),
                            DigitGridColumn(
                              label: localizations.translate(i18Local
                                  .homeShowcase.summaryReportDrugBalance),
                              key: _drugBalanceKey,
                              width: 180,
                            ),
                          ],
                          rows: [
                            ...() {
                              int previousDayBalance = 0;
                              List<DigitGridRow> rows = [];

                              for (final entry
                                  in sumamryReportState.data.entries) {
                                final currentBalance = _calculateDrugBalance(
                                    entry, previousDayBalance);
                                previousDayBalance =
                                    int.tryParse(currentBalance) ?? 0;

                                rows.add(
                                  DigitGridRow(
                                    [
                                      DigitGridCell(
                                        key: _dateKey,
                                        value: entry.key,
                                      ),
                                      DigitGridCell(
                                        key: _registeredChildrenKey,
                                        value: (entry.value[
                                                    Constants.registered] ??
                                                0)
                                            .toString(),
                                      ),
                                      DigitGridCell(
                                        key: _administeredChildrenKey,
                                        value: (entry.value[
                                                    Constants.administered] ??
                                                0)
                                            .toString(),
                                      ),
                                      DigitGridCell(
                                        key: _childrenTreatedPrecKey,
                                        value: _calculatePercentage(
                                            entry.value[Constants.administered],
                                            70),
                                      ),
                                      DigitGridCell(
                                        key: _usedTablet_3_11monthKey,
                                        value:
                                            (entry.value[Constants.spaq1] ?? 0)
                                                .toString(),
                                      ),
                                      DigitGridCell(
                                        key: _usedTablet_12_59monthKey,
                                        value:
                                            (entry.value[Constants.spaq2] ?? 0)
                                                .toString(),
                                      ),
                                      DigitGridCell(
                                        key: _zeroDoseChildrenKey,
                                        value:
                                            (entry.value[Constants.redVAS] ?? 0)
                                                .toString(),
                                      ),
                                      DigitGridCell(
                                        key: _refusalsCasesKey,
                                        value:
                                            (entry.value[Constants.blueVAS] ??
                                                    0)
                                                .toString(),
                                      ),
                                      DigitGridCell(
                                        key: _spaqRedoseCount,
                                        value: (entry.value[Constants
                                                    .reDoseQuantityKey] ??
                                                0)
                                            .toString(),
                                      ),
                                      DigitGridCell(
                                        key: _drugUsedKey,
                                        value: ((entry.value[Constants
                                                        .administered] ??
                                                    0) +
                                                (entry.value[Constants
                                                        .reDoseQuantityKey] ??
                                                    0))
                                            .toString(),
                                      ),
                                      DigitGridCell(
                                        key: _drugBalanceKey,
                                        value: currentBalance,
                                      ),
                                    ],
                                  ),
                                );
                              }
                              return rows.reversed.toList();
                            }(),
                          ],
                        ),
                      ),
                    );
                  },
                ),
            ],
          );
        },
      ),
    );
  }
}

class _ReportDetailsContent extends StatelessWidget {
  final String title;
  final DigitGridData data;

  const _ReportDetailsContent({
    Key? key,
    required this.title,
    required this.data,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(kPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: kPadding * 2),
          Flexible(
            child: ReadonlyDigitGrid(
              data: data,
            ),
          ),
        ],
      ),
    );
  }
}

class _NoReportContent extends StatelessWidget {
  final String title;
  final String message;

  const _NoReportContent({
    Key? key,
    required this.title,
    required this.message,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(
          height: kPadding * 2,
          width: double.maxFinite,
        ),
        Center(
          child: Text(
            message,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.disabledColor,
            ),
          ),
        ),
      ],
    );
  }
}
