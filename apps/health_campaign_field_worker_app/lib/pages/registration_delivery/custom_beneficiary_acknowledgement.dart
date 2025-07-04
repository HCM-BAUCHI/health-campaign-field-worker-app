import 'package:auto_route/auto_route.dart';
import 'package:collection/collection.dart';
import 'package:digit_ui_components/digit_components.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:registration_delivery/blocs/search_households/search_households.dart'
    as registration_delivery;
import 'package:registration_delivery/models/entities/household.dart';

import 'package:registration_delivery/utils/i18_key_constants.dart' as i18;
import 'package:registration_delivery/widgets/localized.dart';
import 'package:registration_delivery/router/registration_delivery_router.gm.dart';

import '../../blocs/registration_delivery/custom_beneficairy_registration.dart';
import '../../blocs/registration_delivery/custom_search_household.dart';
import '../../models/entities/identifier_types.dart';
import '../../widgets/digit_ui_component/custom_panel_card.dart';
import '../../utils/i18_key_constants.dart' as i18_local;

enum AcknowledgementType { addHousehold, addMember }

@RoutePage()
class CustomBeneficiaryAcknowledgementPage extends LocalizedStatefulWidget {
  final bool? enableViewHousehold;
  final AcknowledgementType acknowledgementType;

  const CustomBeneficiaryAcknowledgementPage({
    super.key,
    super.appLocalizations,
    required this.acknowledgementType,
    this.enableViewHousehold,
  });

  @override
  State<CustomBeneficiaryAcknowledgementPage> createState() =>
      CustomBeneficiaryAcknowledgementPageState();
}

class CustomBeneficiaryAcknowledgementPageState
    extends LocalizedState<CustomBeneficiaryAcknowledgementPage> {
  @override
  void initState() {
    super.initState();
  }

  Map<String, String>? subtitleMap(
      registration_delivery.HouseholdMemberWrapper? householdMember,HouseholdModel? household) {
    if (widget.acknowledgementType == AcknowledgementType.addHousehold) {
      final householdId = household?.additionalFields?.fields.where((field) =>
              field.key == IdentifierTypes.uniqueBeneficiaryID.toValue()).first.value;
      return householdId == null
          ? null
          : {
              'id': localizations.translate(i18_local.beneficiaryDetails.householdId),
              'value': householdId,
            };
    } else {
      String? beneficiaryId = householdMember?.members?.lastOrNull?.identifiers
          ?.lastWhereOrNull((e) =>
              e.identifierType == IdentifierTypes.uniqueBeneficiaryID.toValue())
          ?.identifierId;
      return beneficiaryId == null
          ? null
          : {
              'id': localizations
                  .translate(i18_local.beneficiaryDetails.beneficiaryId),
              'value': beneficiaryId,
            };
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(spacer2),
        child: BlocConsumer<CustomSearchHouseholdsBloc,
            CustomSearchHouseholdsState>(
          listener: (context, searchHouseholdsState) {},
          builder: (context, searchHouseholdsState) {
            HouseholdMemberWrapper? i =
                searchHouseholdsState.householdMembers.lastOrNull;
            registration_delivery.HouseholdMemberWrapper?
                householdMemberWrapper;
            if (i == null) {
              householdMemberWrapper = null;
            } else {
              householdMemberWrapper =
                  registration_delivery.HouseholdMemberWrapper(
                household: i.household,
                headOfHousehold: i.headOfHousehold,
                members: i.members,
                projectBeneficiaries: i.projectBeneficiaries,
                distance: i.distance,
                tasks: i.tasks,
                sideEffects: i.sideEffects,
                referrals: i.referrals,
              );
            }

            return BlocBuilder<CustomBeneficiaryRegistrationBloc,
                BeneficiaryRegistrationState>(
              builder: (context, state) {
                return CustomPanelCard(
                  type: PanelType.success,
                  title: localizations.translate(
                      i18_local.acknowledgementSuccess.acknowledgementSuccessUpdateLabelText),
                  subTitle: subtitleMap(householdMemberWrapper, state.householdModel),
                  actions: [
                    if (householdMemberWrapper != null)
                      DigitButton(
                          label: localizations.translate(
                            i18.householdDetails.viewHouseHoldDetailsAction,
                          ),
                          onPressed: () {
                            context.router.popAndPush(
                              BeneficiaryWrapperRoute(
                                wrapper: householdMemberWrapper!,
                              ),
                            );
                          },
                          type: DigitButtonType.primary,
                          size: DigitButtonSize.large),
                    DigitButton(
                        label: localizations.translate(
                            i18.acknowledgementSuccess.actionLabelText),
                        onPressed: () {
                          context.router.maybePop();
                        },
                        type: DigitButtonType.secondary,
                        size: DigitButtonSize.large),
                  ],
                  description: localizations.translate(
                    i18.acknowledgementSuccess.acknowledgementDescriptionText,
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
