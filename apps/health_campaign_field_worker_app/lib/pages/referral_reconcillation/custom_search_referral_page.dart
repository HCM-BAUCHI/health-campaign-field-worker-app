import 'package:auto_route/auto_route.dart';
import 'package:digit_data_model/data_model.dart';
import 'package:digit_scanner/blocs/scanner.dart';
import 'package:digit_scanner/router/digit_scanner_router.gm.dart';
import 'package:digit_ui_components/enum/app_enums.dart';
import 'package:digit_ui_components/theme/digit_extended_theme.dart';
import 'package:digit_ui_components/widgets/atoms/digit_button.dart';
import 'package:digit_ui_components/widgets/atoms/digit_info_card.dart';
import 'package:digit_ui_components/widgets/atoms/digit_search_bar.dart';
import 'package:digit_ui_components/widgets/scrollable_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:health_campaign_field_worker_app/widgets/custom_back_navigation.dart';
import 'package:referral_reconciliation/utils/extensions/extensions.dart';
import 'package:survey_form/survey_form.dart';

import 'package:referral_reconciliation/blocs/search_referral_reconciliations.dart';
import 'package:referral_reconciliation/models/entities/hf_referral.dart';
// import 'package:referral_reconciliation/router/referral_reconciliation_router.gm.dart';
import 'package:health_campaign_field_worker_app/router/app_router.dart';
import 'package:referral_reconciliation/utils/i18_key_constants.dart' as i18;
import 'package:referral_reconciliation/utils/utils.dart';
import 'package:referral_reconciliation/widgets/localized.dart';
import 'package:referral_reconciliation/widgets/view_referral_card.dart';

@RoutePage()
class CustomSearchReferralReconciliationsPage extends LocalizedStatefulWidget {
  const CustomSearchReferralReconciliationsPage({
    super.key,
    super.appLocalizations,
  });

  @override
  State<CustomSearchReferralReconciliationsPage> createState() =>
      _CustomSearchReferralReconciliationsPageState();
}

class _CustomSearchReferralReconciliationsPageState
    extends LocalizedState<CustomSearchReferralReconciliationsPage> {
  final TextEditingController searchController = TextEditingController();
  bool isProximityEnabled = false;
  SearchReferralsBloc? searchReferralsBloc;

  @override
  void initState() {
    searchReferralsBloc = SearchReferralsBloc(
      const SearchReferralsState(),
      referralReconDataRepository:
          context.repository<HFReferralModel, HFReferralSearchModel>(context),
    );
    context.read<DigitScannerBloc>().add(
          const DigitScannerEvent.handleScanner(),
        );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.digitTextTheme(context);
    return KeyboardVisibilityBuilder(
        builder: (context, isKeyboardVisible) => BlocProvider<
                SearchReferralsBloc>(
            create: (context) => searchReferralsBloc!
              ..add(
                const SearchReferralsClearEvent(),
              ),
            child: Scaffold(
              body: BlocListener<DigitScannerBloc, DigitScannerState>(
                  listener: (context, scannerState) {
                    if (scannerState.qrCodes.isNotEmpty) {
                      context
                          .read<SearchReferralsBloc>()
                          .add(SearchReferralsEvent.searchByTag(
                            tag: scannerState.qrCodes.last,
                          ));
                    }
                  },
                  child: BlocProvider(
                      create: (_) => ServiceBloc(
                            const ServiceEmptyState(),
                            serviceDataRepository: context.repository<
                                ServiceModel, ServiceSearchModel>(context),
                          ),
                      child: BlocBuilder<SearchReferralsBloc,
                          SearchReferralsState>(
                        builder: (context, searchState) {
                          return ScrollableContent(
                            header: const Column(children: [
                              CustomBackNavigationHelpHeaderWidget(showHelp: true,),
                            ]),
                            slivers: [
                              SliverToBoxAdapter(
                                child: Padding(
                                  padding:
                                      EdgeInsets.all(theme.spacerTheme.spacer2),
                                  child: Column(
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.all(
                                            theme.spacerTheme.spacer2),
                                        child: Align(
                                          alignment: Alignment.topLeft,
                                          child: Text(
                                            localizations.translate(
                                              i18.referralReconciliation
                                                  .searchReferralsHeader,
                                            ),
                                            style: textTheme.headingXl.copyWith(color: theme.colorTheme.text.primary),
                                            textAlign: TextAlign.left,
                                          ),
                                        ),
                                      ),
                                      Column(
                                        children: [
                                          DigitSearchBar(
                                            controller: searchController,
                                            hintText: localizations.translate(
                                              i18.referralReconciliation
                                                  .referralSearchHintText,
                                            ),
                                            textCapitalization:
                                                TextCapitalization.words,
                                            onChanged: (value) {
                                              final bloc = context
                                                  .read<SearchReferralsBloc>();
                                              if (value.trim().length < 2) {
                                                bloc.add(
                                                  const SearchReferralsClearEvent(),
                                                );

                                                return;
                                              } else {
                                                bloc.add(
                                                    SearchReferralsByNameEvent(
                                                  searchText: value.trim(),
                                                ));
                                              }
                                            },
                                          ),
                                        ],
                                      ),
                                      SizedBox(
                                          height:
                                              theme.spacerTheme.spacer2 * 2),
                                      if (searchState.resultsNotFound &&
                                          searchController.text.isNotEmpty)
                                        InfoCard(
                                          title: localizations.translate(i18
                                              .referralReconciliation
                                              .beneficiaryInfoTitle),
                                          type: InfoType.info,
                                          description: localizations.translate(
                                            i18.referralReconciliation
                                                .referralInfoDescription,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                              SliverList(
                                delegate: SliverChildBuilderDelegate(
                                  (ctx, index) {
                                    final i =
                                        searchState.referrals.elementAt(index);

                                    return Container(
                                      margin: EdgeInsets.only(
                                          bottom: theme.spacerTheme.spacer2),
                                      child: ViewReferralCard(
                                        hfReferralModel: i,
                                        onOpenPressed: () {
                                          context.read<ServiceBloc>().add(
                                                ServiceSearchEvent(
                                                  serviceSearchModel:
                                                      ServiceSearchModel(
                                                    relatedClientReferenceId:
                                                        i.clientReferenceId,
                                                  ),
                                                ),
                                              );
                                          context.router.push(
                                            CustomHFCreateReferralWrapperRoute(
                                              viewOnly: true,
                                              referralReconciliation: i,
                                              projectId:
                                                  ReferralReconSingleton()
                                                      .projectId,
                                              cycles: ReferralReconSingleton()
                                                  .cycles,
                                            ),
                                          );
                                        },
                                      ),
                                    );
                                  },
                                  childCount: searchState.referrals.length,
                                ),
                              ),
                            ],
                          );
                        },
                      ))),
              bottomNavigationBar: Card(
                margin: const EdgeInsets.all(0),
                child: Container(
                  padding: EdgeInsets.all(theme.spacerTheme.spacer2),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      BlocBuilder<SearchReferralsBloc, SearchReferralsState>(
                        builder: (context, state) {
                          final router = context.router;

                          VoidCallback? onPressed;

                          onPressed = () {
                            FocusManager.instance.primaryFocus?.unfocus();
                            final bloc = context.read<SearchReferralsBloc>();
                            router.push(
                              CustomHFCreateReferralWrapperRoute(
                                viewOnly: false,
                                referralReconciliation: HFReferralModel(
                                  clientReferenceId: IdGen.i.identifier,
                                  name: state.searchQuery,
                                  beneficiaryId: state.tag,
                                ),
                                projectId: ReferralReconSingleton().projectId,
                                cycles: ReferralReconSingleton().cycles,
                              ),
                            );
                            searchController.clear();
                            bloc.add(
                              const SearchReferralsClearEvent(),
                            );
                          };
                          return DigitButton(
                            size: DigitButtonSize.large,
                            label: localizations.translate(
                              i18.referralReconciliation.createReferralLabel,
                            ),
                            mainAxisSize: MainAxisSize.max,
                            onPressed: () {
                              if (onPressed != null) {
                                onPressed();
                              }
                            },
                            type: DigitButtonType.primary,
                          );
                        },
                      ),
                      SizedBox(
                        height: theme.spacerTheme.spacer2,
                      )
                    ],
                  ),
                ),
              ),
            )));
  }
}
