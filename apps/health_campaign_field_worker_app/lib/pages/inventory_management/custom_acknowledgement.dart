import 'package:auto_route/auto_route.dart';
import 'package:digit_ui_components/digit_components.dart';
import 'package:digit_ui_components/theme/digit_extended_theme.dart';
import 'package:digit_ui_components/widgets/molecules/panel_cards.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inventory_management/blocs/record_stock.dart';
import 'package:inventory_management/models/entities/stock.dart';
import 'package:registration_delivery/registration_delivery.dart';
import 'package:registration_delivery/router/registration_delivery_router.gm.dart';
import 'package:registration_delivery/utils/i18_key_constants.dart' as i18;
import 'package:registration_delivery/widgets/localized.dart';
import '../../../utils/app_enums.dart';
import '../../router/app_router.dart';
import '../../utils/extensions/extensions.dart';
import '../../utils/i18_key_constants.dart' as i18_local;
import '../../widgets/digit_ui_component/custom_panel_card.dart';

@RoutePage()
class CustomAcknowledgementPage extends LocalizedStatefulWidget {
  final String mrnNumber;
  final List<StockModel> stockRecords;
  final StockRecordEntryType entryType;

  const CustomAcknowledgementPage({
    super.key,
    super.appLocalizations,
    required this.mrnNumber,
    required this.stockRecords,
    required this.entryType,
  });

  @override
  State<CustomAcknowledgementPage> createState() =>
      CustomAcknowledgementPageState();
}

class CustomAcknowledgementPageState
    extends LocalizedState<CustomAcknowledgementPage> {
  @override
  Widget build(BuildContext context) {
    var showLabel = localizations
        .translate(i18_local.acknowledgementSuccess.mrnNumberLabel);
    var showDescription = localizations
        .translate(i18_local.acknowledgementSuccess.mrrnNumberDescription);
    var showHeading = localizations
        .translate(i18_local.acknowledgementSuccess.mrrnNumberHeading);

    if (widget.entryType == StockRecordEntryType.dispatch && context.isCDD) {
      showLabel = localizations
          .translate(i18_local.acknowledgementSuccess.mrnNumberLabel);
      showDescription = localizations
          .translate(i18_local.acknowledgementSuccess.mrnNumberDescription);
      showHeading = localizations
          .translate(i18_local.acknowledgementSuccess.mrnNumberHeading);
    } else if (widget.entryType == StockRecordEntryType.dispatch) {
      showLabel = localizations
          .translate(i18_local.acknowledgementSuccess.minNumberLabel);
      showDescription = localizations
          .translate(i18_local.acknowledgementSuccess.minNumberDescription);
      showHeading = localizations
          .translate(i18_local.acknowledgementSuccess.minNumberHeading);
    } else if (widget.entryType == StockRecordEntryType.returned) {
      showLabel = localizations
          .translate(i18_local.acknowledgementSuccess.mrnNumberLabel);
      showDescription = localizations
          .translate(i18_local.acknowledgementSuccess.mrnNumberDescription);
      showHeading = localizations
          .translate(i18_local.acknowledgementSuccess.mrnNumberHeading);
    }

    Map<String, String> mrnnumber = {
      'id': showLabel,
      'value': widget.mrnNumber
    };
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(spacer2),
          child: CustomPanelCard(
            type: PanelType.success,
            subTitle: mrnnumber,
            title: showHeading,
            description: showDescription,
            actions: [
              DigitButton(
                label: localizations.translate(
                  i18_local.acknowledgementSuccess.viewtransactions,
                ),
                onPressed: () {
                  context.router.push(
                    ViewStockRecordsRoute(
                      mrnNumber: widget.mrnNumber,
                      stockRecords: widget.stockRecords,
                    ),
                  );
                },
                type: DigitButtonType.primary,
                size: DigitButtonSize.large,
              ),
              DigitButton(
                label: localizations.translate(
                  i18_local.acknowledgementSuccess.createNewTransactions,
                ),
                onPressed: () {
                  // context
                  //     .read<RecordStockBloc>()
                  //     .add(const RecordStockEvent.reset());
                  context.router
                      .popUntilRouteWithName(CustomManageStocksRoute.name);
                },
                type: DigitButtonType.secondary,
                size: DigitButtonSize.large,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
