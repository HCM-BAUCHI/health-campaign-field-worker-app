import 'package:digit_ui_components/digit_components.dart';
import 'package:digit_ui_components/theme/ComponentTheme/back_button_theme.dart';
import 'package:digit_ui_components/theme/ComponentTheme/button_theme.dart';
import 'package:digit_ui_components/theme/digit_extended_theme.dart';
import 'package:digit_ui_components/widgets/atoms/digit_back_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_design_icons_flutter/icon_map.dart';
import 'showcase/showcase_button.dart';

import '../blocs/auth/auth.dart';
import '../../blocs/localization/app_localization.dart';
import '../../router/app_router.dart';
import '../../utils/i18_key_constants.dart' as i18;

class CustomBackNavigationHelpHeaderWidget extends StatelessWidget {
  final bool showHelp;
  final bool showBackNavigation;
  final bool showLogoutCTA;
  final VoidCallback? helpClicked;
  final VoidCallback? handleback;
  final bool defaultPopRoute;
  final ShowcaseButton? showcaseButton;

  const CustomBackNavigationHelpHeaderWidget({
    super.key,
    this.showHelp = true,
    this.showBackNavigation = true,
    this.showLogoutCTA = false,
    this.helpClicked,
    this.handleback,
    this.defaultPopRoute = true,
    this.showcaseButton,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                if (context.router.canPop() && showBackNavigation)
                  DigitBackButton(
                    digitBackButtonThemeData:
                        const DigitBackButtonThemeData().copyWith(
                          textColor: Theme.of(context)
                              .colorTheme.text.primary,
                      context: context,
                      backDigitButtonIcon: Icon(
                        Icons.arrow_left,
                        size: MediaQuery.of(context).size.width < 500
                            ? Theme.of(context).spacerTheme.spacer5
                            : Theme.of(context).spacerTheme.spacer6,
                        color: Theme.of(context).colorTheme.text.primary,
                      ),
                    ),
                    handleBack: () {
                      if (defaultPopRoute) {
                        context.router.maybePop();
                      }
                      handleback != null ? handleback!() : null;
                    },
                    label: AppLocalizations.of(context).translate(
                      i18.common.coreCommonBack,
                    ),
                  ),
                SizedBox(width: showBackNavigation ? 16 : 0),
                if (showLogoutCTA)
                  Flexible(
                    child: DigitButton(
                      capitalizeLetters: false,
                      onPressed: () {
                        context.read<AuthBloc>().add(const AuthLogoutEvent());
                      },
                      prefixIcon: Icons.logout_outlined,
                      label: AppLocalizations.of(context).translate(
                        i18.common.coreCommonLogout,
                      ),
                      type: DigitButtonType.tertiary,
                      size: DigitButtonSize.medium,
                      textColor: textTheme.colorTheme.primary.primary1,
                      iconColor: textTheme.colorTheme.primary.primary1, 
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(width: showHelp ? 16 : 0),
          if (showHelp)
            DigitButton(
              isDisabled: helpClicked == null,
              label: AppLocalizations.of(context)
                  .translate(i18.common.coreCommonHelp),
              type: DigitButtonType.tertiary,
              size: DigitButtonSize.medium,
              suffixIcon: Icons.help_outline_outlined,
              textColor: textTheme.colorTheme.primary.primary1,
              iconColor: textTheme.colorTheme.primary.primary1, 
              onPressed: () => helpClicked,
              ),
          SizedBox(width: showcaseButton != null ? spacer4 : 0),
          if (showcaseButton != null) showcaseButton!,
        ],
      ),
    );
  }
}
