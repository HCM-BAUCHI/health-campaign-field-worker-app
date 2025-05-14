import 'package:digit_components/digit_components.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:registration_delivery/blocs/household_overview/household_overview.dart';
import 'package:registration_delivery/router/registration_delivery_router.gm.dart';

import '../../../router/app_router.dart';
import '../../../utils/i18_key_constants.dart' as i18_local;
import '../../../widgets/localized.dart';

@RoutePage()
class CustomHouseholdAcknowledgementSMCPage extends LocalizedStatefulWidget {
  final bool? enableViewHousehold;
  final bool? isReferral;

  const CustomHouseholdAcknowledgementSMCPage({
    super.key,
    super.appLocalizations,
    this.enableViewHousehold,
    this.isReferral,
  });

  @override
  State<CustomHouseholdAcknowledgementSMCPage> createState() =>
      CustomHouseholdAcknowledgementSMCPageState();
}

class CustomHouseholdAcknowledgementSMCPageState
    extends LocalizedState<CustomHouseholdAcknowledgementSMCPage> {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        body: BlocBuilder<HouseholdOverviewBloc, HouseholdOverviewState>(
          builder: (context, householdState) {
            return DigitAcknowledgement.success(
              action: () {
                final parent = context.router.parent() as StackRouter;
                // Pop twice to navigate back to the previous screen
                parent
                  ..pop()
                  ..pop();
              },
              secondaryAction: () {
                final wrapper = context
                    .read<HouseholdOverviewBloc>()
                    .state
                    .householdMemberWrapper;

                context.router.popAndPush(
                  BeneficiaryWrapperRoute(wrapper: wrapper),
                );
              },
              enableViewHousehold: widget.enableViewHousehold ?? false,
              secondaryLabel: localizations.translate(
                i18_local.householdDetails.viewHouseHoldDetailsActionSMC,
              ),
              actionLabel: localizations
                  .translate(i18_local.acknowledgementSuccess.actionLabelText),
              description: localizations.translate(
                i18_local.acknowledgementSuccess.acknowledgementDescriptionText,
              ),
              label: localizations.translate(widget.isReferral == true
                  ? i18_local
                      .acknowledgementSuccess.referAcknowledgementLabelText
                  : i18_local.acknowledgementSuccess.acknowledgementLabelText),
            );
          },
        ),
      ),
    );
  }
}
