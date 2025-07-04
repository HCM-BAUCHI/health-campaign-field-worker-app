import 'package:auto_route/auto_route.dart';
import 'package:digit_ui_components/digit_components.dart';
import 'package:digit_ui_components/theme/digit_extended_theme.dart';
import 'package:digit_ui_components/widgets/atoms/digit_divider.dart';
import 'package:digit_ui_components/widgets/molecules/digit_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_campaign_field_worker_app/router/app_router.dart';
import 'package:health_campaign_field_worker_app/widgets/custom_back_navigation.dart';
import 'package:intl/intl.dart';
import 'package:referral_reconciliation/utils/constants.dart';
import 'package:survey_form/survey_form.dart';

import 'package:referral_reconciliation/blocs/referral_recon_service_definition.dart';
// import 'package:referral_reconciliation/router/referral_reconciliation_router.gm.dart';
import 'package:referral_reconciliation/utils/i18_key_constants.dart' as i18;
import 'package:referral_reconciliation/widgets/back_navigation_help_header.dart';
import 'package:referral_reconciliation/widgets/localized.dart';

@RoutePage()
class CustomReferralReasonChecklistPreviewPage extends LocalizedStatefulWidget {
  const CustomReferralReasonChecklistPreviewPage({
    super.key,
    super.appLocalizations,
  });

  @override
  State<CustomReferralReasonChecklistPreviewPage> createState() =>
      _CustomReferralReasonChecklistPreviewPageState();
}

class _CustomReferralReasonChecklistPreviewPageState
    extends LocalizedState<CustomReferralReasonChecklistPreviewPage> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.digitTextTheme(context);

    return Scaffold(
      body: ScrollableContent(
        header: const Column(children: [
          CustomBackNavigationHelpHeaderWidget(
            showHelp: false,
          ),
        ]),
        footer: BlocBuilder<ServiceBloc, ServiceState>(
          builder: (context, state) {
            return state.maybeWhen(
              orElse: () => const Offstage(),
              serviceSearch: (serviceList, selectedService, loading) {
                return selectedService != null
                    ? DigitCard(
                        cardType: CardType.primary,
                        padding: EdgeInsets.all(theme.spacerTheme.spacer2),
                        children: [
                            DigitButton(
                              size: DigitButtonSize.large,
                              label: localizations
                                  .translate(i18.common.corecommonclose),
                              mainAxisSize: MainAxisSize.max,
                              onPressed: () {
                                context.read<ServiceBloc>().add(
                                      ServiceResetEvent(
                                          serviceList: serviceList),
                                    );
                                context.router.popUntil((route) =>
                                    route.settings.name ==
                                    CustomSearchReferralReconciliationsRoute
                                        .name);
                                context.router.maybePop();
                              },
                              type: DigitButtonType.primary,
                            )
                          ])
                    : const Offstage();
              },
            );
          },
        ),
        children: [
          BlocBuilder<ServiceBloc, ServiceState>(builder: (context, state) {
            return state.maybeWhen(
              orElse: () => const Offstage(),
              serviceSearch: (value1, value2, value3) {
                return value2 == null
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ...value1.map((e) => e.serviceDefId != null
                              ? DigitCard(
                                  margin:
                                      EdgeInsets.all(theme.spacerTheme.spacer2),
                                  cardType: CardType.primary,
                                  children: [
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Align(
                                            alignment: Alignment.centerLeft,
                                            child: Text(
                                              DateFormat(defaultDateFormat)
                                                  .format(
                                                DateFormat(defaultDateFormat)
                                                    .parse(
                                                  e.createdAt.toString(),
                                                ),
                                              ),
                                              style: textTheme.headingM,
                                            ),
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              SizedBox(
                                                child: Text(
                                                  localizations.translate(
                                                    '${e.tenantId}',
                                                  ),
                                                ),
                                              ),
                                              DigitButton(
                                                label: localizations.translate(
                                                  i18.referralReconciliation
                                                      .iconLabel,
                                                ),
                                                onPressed: () {
                                                  context
                                                      .read<ServiceBloc>()
                                                      .add(
                                                        ServiceSelectionEvent(
                                                          service: e,
                                                        ),
                                                      );
                                                },
                                                type: DigitButtonType.secondary,
                                                size: DigitButtonSize.large,
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ])
                              : const Offstage()),
                        ],
                      )
                    : BlocBuilder<ReferralReconServiceDefinitionBloc,
                            ReferralReconServiceDefinitionState>(
                        builder: (context, state) {
                        return state.maybeWhen(
                          serviceDefinitionFetch: (
                            item1,
                            item2,
                          ) {
                            return DigitCard(
                              cardType: CardType.primary,
                              children: [
                                Column(
                                  children: [
                                    Container(
                                      width: MediaQuery.of(context).size.width,
                                      margin: const EdgeInsets.all(8),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Align(
                                            alignment: Alignment.centerLeft,
                                            child: Text(
                                              localizations.translate(
                                                item2?.code ?? '',
                                              ),
                                              style: textTheme.headingXl,
                                            ),
                                          ),
                                          ...(value2.attributes ?? [])
                                              .where((a) =>
                                                  a.value !=
                                                      i18.checklist
                                                          .notSelectedKey &&
                                                  a.value != '')
                                              .map(
                                                (e) => Padding(
                                                  padding:
                                                      const EdgeInsets.all(8),
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    children: [
                                                      Align(
                                                        alignment: Alignment
                                                            .centerLeft,
                                                        child: Text(
                                                          localizations
                                                              .translate(
                                                            "${item2?.code ?? ''}.${e.attributeCode!}",
                                                          ),
                                                          style: textTheme
                                                              .headingS,
                                                        ),
                                                      ),
                                                      Container(
                                                        margin: const EdgeInsets
                                                                .only()
                                                            .copyWith(
                                                          top: theme.spacerTheme
                                                              .spacer2,
                                                          bottom: theme
                                                              .spacerTheme
                                                              .spacer2,
                                                        ),
                                                        child: Align(
                                                          alignment: Alignment
                                                              .centerLeft,
                                                          child: Text(
                                                            e.value != null &&
                                                                    e.dataType ==
                                                                        'MultiValueList'
                                                                ? getMultiValueString(e
                                                                    .value
                                                                    .toString()
                                                                    .split('.'))
                                                                : e.dataType ==
                                                                        'SingleValueList'
                                                                    ? localizations
                                                                        .translate(
                                                                        e.value
                                                                            .toString()
                                                                            .toUpperCase(),
                                                                      )
                                                                    : e.value ??
                                                                        "",
                                                          ),
                                                        ),
                                                      ),
                                                      e.additionalDetails !=
                                                                  '' &&
                                                              e.additionalDetails !=
                                                                  null
                                                          ? Container(
                                                              margin:
                                                                  const EdgeInsets
                                                                          .only()
                                                                      .copyWith(
                                                                top: theme
                                                                    .spacerTheme
                                                                    .spacer2,
                                                                bottom: theme
                                                                    .spacerTheme
                                                                    .spacer2,
                                                              ),
                                                              child: Column(
                                                                children: [
                                                                  Align(
                                                                    alignment:
                                                                        Alignment
                                                                            .centerLeft,
                                                                    child: Text(
                                                                      localizations
                                                                          .translate(
                                                                        "${item2?.code ?? ''}.${e.attributeCode!}.ADDITIONAL_FIELD",
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  Align(
                                                                    alignment:
                                                                        Alignment
                                                                            .centerLeft,
                                                                    child: Text(
                                                                      localizations
                                                                          .translate(
                                                                        e.additionalDetails,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            )
                                                          : const Offstage(),
                                                      const DigitDivider(),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                        ].toList(),
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            );
                          },
                          orElse: () => const Offstage(),
                        );
                      });
              },
            );
          }),
        ],
      ),
    );
  }

  String getMultiValueString(List<String> list) {
    String multiValueText = '';

    for (var i = 0; i < list.length; i++) {
      multiValueText =
          '$multiValueText${localizations.translate(list[i].toUpperCase())},';
    }

    return multiValueText.substring(0, multiValueText.length - 1);
  }
}
