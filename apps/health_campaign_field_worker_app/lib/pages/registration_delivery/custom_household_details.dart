import 'package:auto_route/auto_route.dart';
import 'package:digit_data_model/data_model.dart';
import 'package:digit_data_model/models/entities/household_type.dart';
import 'package:digit_ui_components/digit_components.dart';
import 'package:digit_ui_components/theme/digit_extended_theme.dart';
import 'package:digit_ui_components/widgets/atoms/text_block.dart';
import 'package:digit_ui_components/widgets/molecules/digit_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_campaign_field_worker_app/widgets/custom_back_navigation.dart';
import 'package:intl/intl.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:registration_delivery/blocs/household_overview/household_overview.dart';
import 'package:registration_delivery/blocs/search_households/search_households.dart';
import 'package:registration_delivery/models/entities/additional_fields_type.dart';
import 'package:registration_delivery/utils/extensions/extensions.dart';

import 'package:registration_delivery/models/entities/household.dart';
import 'package:registration_delivery/router/registration_delivery_router.gm.dart';
import 'package:registration_delivery/utils/constants.dart';
import 'package:registration_delivery/utils/i18_key_constants.dart' as i18;
import 'package:health_campaign_field_worker_app/utils/i18_key_constants.dart'
    as i18_local;
import 'package:registration_delivery/utils/utils.dart';
import 'package:registration_delivery/widgets/back_navigation_help_header.dart';
import 'package:registration_delivery/widgets/localized.dart';
import 'package:registration_delivery/widgets/showcase/config/showcase_constants.dart';
import 'package:registration_delivery/widgets/showcase/showcase_button.dart';

import '../../blocs/registration_delivery/custom_beneficairy_registration.dart';
import '../../models/entities/identifier_types.dart';
import '../../router/app_router.dart';
import '../../utils/registration_delivery/registration_delivery_utils.dart';

@RoutePage()
class CustomHouseHoldDetailsPage extends LocalizedStatefulWidget {
  const CustomHouseHoldDetailsPage({
    super.key,
    super.appLocalizations,
  });

  @override
  State<CustomHouseHoldDetailsPage> createState() =>
      CustomHouseHoldDetailsPageState();
}

class CustomHouseHoldDetailsPageState
    extends LocalizedState<CustomHouseHoldDetailsPage> {
  static const _dateOfRegistrationKey = 'dateOfRegistration';

  // Define controllers
  final TextEditingController _pregnantWomenController =
      TextEditingController();
  final TextEditingController _childrenController = TextEditingController();

  @override
  void dispose() {
    _pregnantWomenController.dispose();
    _childrenController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bloc = context.read<CustomBeneficiaryRegistrationBloc>();
    final router = context.router;
    final textTheme = theme.digitTextTheme(context);
    final bool isCommunity = RegistrationDeliverySingleton().householdType ==
        HouseholdType.community;

    Future<String> generateHouseholdId() async {
      final userId = RegistrationDeliverySingleton().loggedInUserUuid;

      final boundaryBloc = context.read<BoundaryBloc>().state;
      final code = boundaryBloc.boundaryList.first.code;
      final bname = boundaryBloc.boundaryList.first.name;

      final locality = (code == null || bname == null)
          ? null
          : LocalityModel(code: code, name: bname);

      final localityCode = locality!.code;

      final ids = await UniqueIdGeneration().generateUniqueId(
        localityCode: localityCode,
        loggedInUserId: userId!,
        returnCombinedIds: false,
      );

      return ids.first;
    }

    return Scaffold(
      body: ReactiveFormBuilder(
        form: () => buildForm(bloc.state),
        builder: (context, form, child) {
          return BlocConsumer<CustomBeneficiaryRegistrationBloc,
              BeneficiaryRegistrationState>(
            listener: (context, state) {
              if (state is BeneficiaryRegistrationPersistedState &&
                  state.isEdit) {
                final overviewBloc = context.read<HouseholdOverviewBloc>();

                overviewBloc.add(
                  HouseholdOverviewReloadEvent(
                    projectId:
                        RegistrationDeliverySingleton().projectId.toString(),
                    projectBeneficiaryType:
                        RegistrationDeliverySingleton().beneficiaryType ??
                            BeneficiaryType.household,
                  ),
                );
                HouseholdMemberWrapper memberWrapper =
                    overviewBloc.state.householdMemberWrapper;
                final route = router.parent() as StackRouter;
                route.popUntilRouteWithName(SearchBeneficiaryRoute.name);
                route.push(BeneficiaryWrapperRoute(wrapper: memberWrapper));
              }
            },
            builder: (context, registrationState) {
              return ScrollableContent(
                header: const Column(children: [
                  Padding(
                    padding: EdgeInsets.only(bottom: spacer2),
                    child: CustomBackNavigationHelpHeaderWidget(
                      showHelp: false,
                    ),
                  ),
                ]),
                enableFixedDigitButton: true,
                footer: DigitCard(
                    margin: const EdgeInsets.only(top: spacer2),
                    children: [
                      DigitButton(
                        label: registrationState.mapOrNull(
                              editHousehold: (value) => localizations
                                  .translate(i18.common.coreCommonSave),
                            ) ??
                            localizations
                                .translate(i18.householdDetails.actionLabel),
                        type: DigitButtonType.primary,
                        size: DigitButtonSize.large,
                        mainAxisSize: MainAxisSize.max,
                        onPressed: () {
                          form.markAllAsTouched();
                          if (!form.valid) return;

                          final dateOfRegistration = form
                              .control(_dateOfRegistrationKey)
                              .value as DateTime;

                          registrationState.maybeWhen(
                            orElse: () {
                              return;
                            },
                            create: (
                              addressModel,
                              householdModel,
                              individualModel,
                              projectBeneficiaryModel,
                              registrationDate,
                              searchQuery,
                              loading,
                              isHeadOfHousehold,
                            ) async {
                              final String householdid =
                                  await generateHouseholdId();
                              var household = householdModel;

                              household ??= HouseholdModel(
                                tenantId:
                                    RegistrationDeliverySingleton().tenantId,
                                clientReferenceId:
                                    householdModel?.clientReferenceId ??
                                        IdGen.i.identifier,
                                rowVersion: 1,
                                clientAuditDetails: ClientAuditDetails(
                                  createdBy: RegistrationDeliverySingleton()
                                      .loggedInUserUuid!,
                                  createdTime: context.millisecondsSinceEpoch(),
                                  lastModifiedBy:
                                      RegistrationDeliverySingleton()
                                          .loggedInUserUuid,
                                  lastModifiedTime:
                                      context.millisecondsSinceEpoch(),
                                ),
                                auditDetails: AuditDetails(
                                  createdBy: RegistrationDeliverySingleton()
                                      .loggedInUserUuid!,
                                  createdTime: context.millisecondsSinceEpoch(),
                                  lastModifiedBy:
                                      RegistrationDeliverySingleton()
                                          .loggedInUserUuid,
                                  lastModifiedTime:
                                      context.millisecondsSinceEpoch(),
                                ),
                              );

                              household = household.copyWith(
                                  memberCount: 5,
                                  rowVersion: 1,
                                  tenantId:
                                      RegistrationDeliverySingleton().tenantId,
                                  clientReferenceId:
                                      householdModel?.clientReferenceId ??
                                          IdGen.i.identifier,
                                  clientAuditDetails: ClientAuditDetails(
                                    createdBy: RegistrationDeliverySingleton()
                                        .loggedInUserUuid
                                        .toString(),
                                    createdTime:
                                        context.millisecondsSinceEpoch(),
                                    lastModifiedBy:
                                        RegistrationDeliverySingleton()
                                            .loggedInUserUuid
                                            .toString(),
                                    lastModifiedTime:
                                        context.millisecondsSinceEpoch(),
                                  ),
                                  auditDetails: AuditDetails(
                                    createdBy: RegistrationDeliverySingleton()
                                        .loggedInUserUuid
                                        .toString(),
                                    createdTime:
                                        context.millisecondsSinceEpoch(),
                                    lastModifiedBy:
                                        RegistrationDeliverySingleton()
                                            .loggedInUserUuid
                                            .toString(),
                                    lastModifiedTime:
                                        context.millisecondsSinceEpoch(),
                                  ),
                                  address: addressModel,
                                  // id: householdid,
                                  additionalFields: HouseholdAdditionalFields(
                                      version: 1, fields: [
                                        AdditionalField(IdentifierTypes.uniqueBeneficiaryID.toValue(), householdid)
                                      ]));

                              bloc.add(
                                BeneficiaryRegistrationSaveHouseholdDetailsEvent(
                                  household: household,
                                  registrationDate: dateOfRegistration,
                                ),
                              );
                              context.router.push(
                                CustomIndividualDetailsRoute(
                                    isHeadOfHousehold: true),
                              );
                            },
                            editHousehold: (
                              addressModel,
                              householdModel,
                              individuals,
                              registrationDate,
                              projectBeneficiaryModel,
                              loading,
                              isHeadOfHousehold,
                            ) {
                              var household = householdModel.copyWith(
                                  address: addressModel,
                                  clientAuditDetails: (householdModel
                                                  .clientAuditDetails
                                                  ?.createdBy !=
                                              null &&
                                          householdModel.clientAuditDetails
                                                  ?.createdTime !=
                                              null)
                                      ? ClientAuditDetails(
                                          createdBy: householdModel
                                              .clientAuditDetails!.createdBy,
                                          createdTime: householdModel
                                              .clientAuditDetails!.createdTime,
                                          lastModifiedBy:
                                              RegistrationDeliverySingleton()
                                                  .loggedInUserUuid,
                                          lastModifiedTime: DateTime.now()
                                              .millisecondsSinceEpoch,
                                        )
                                      : null,
                                  rowVersion: householdModel.rowVersion,
                                  additionalFields: HouseholdAdditionalFields(
                                      version: householdModel
                                              .additionalFields?.version ??
                                          1,
                                      fields: [
                                        //[TODO: Use pregnant women form value based on project config
                                      ]));

                              bloc.add(
                                BeneficiaryRegistrationUpdateHouseholdDetailsEvent(
                                  household: household.copyWith(
                                    clientAuditDetails: (addressModel
                                                    .clientAuditDetails
                                                    ?.createdBy !=
                                                null &&
                                            addressModel.clientAuditDetails
                                                    ?.createdTime !=
                                                null)
                                        ? ClientAuditDetails(
                                            createdBy: addressModel
                                                .clientAuditDetails!.createdBy,
                                            createdTime: addressModel
                                                .clientAuditDetails!
                                                .createdTime,
                                            lastModifiedBy:
                                                RegistrationDeliverySingleton()
                                                    .loggedInUserUuid,
                                            lastModifiedTime: context
                                                .millisecondsSinceEpoch(),
                                          )
                                        : null,
                                  ),
                                  addressModel: addressModel.copyWith(
                                    clientAuditDetails: (addressModel
                                                    .clientAuditDetails
                                                    ?.createdBy !=
                                                null &&
                                            addressModel.clientAuditDetails
                                                    ?.createdTime !=
                                                null)
                                        ? ClientAuditDetails(
                                            createdBy: addressModel
                                                .clientAuditDetails!.createdBy,
                                            createdTime: addressModel
                                                .clientAuditDetails!
                                                .createdTime,
                                            lastModifiedBy:
                                                RegistrationDeliverySingleton()
                                                    .loggedInUserUuid,
                                            lastModifiedTime: context
                                                .millisecondsSinceEpoch(),
                                          )
                                        : null,
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ]),
                slivers: [
                  SliverToBoxAdapter(
                    child: DigitCard(
                        margin: const EdgeInsets.all(spacer2),
                        children: [
                          DigitTextBlock(
                            padding: EdgeInsets.zero,
                            heading: (isCommunity)
                                ? localizations.translate(
                                    i18.householdDetails.clfDetailsLabel,
                                  )
                                : localizations.translate(
                                    i18_local.householdDetails.dateOfHouseholdRegistrationLabelUpdate,
                                  ),
                            headingStyle: textTheme.headingXl
                                .copyWith(color: theme.colorTheme.text.primary),
                          ),
                          householdDetailsShowcaseData.dateOfRegistration
                              .buildWith(
                            child: ReactiveWrapperField(
                              formControlName: _dateOfRegistrationKey,
                              builder: (field) => LabeledField(
                                label: localizations.translate(
                                  i18.householdDetails.dateOfRegistrationLabel,
                                ),
                                child: AbsorbPointer(
                                  absorbing: true,
                                  child: DigitDateFormInput(
                                    readOnly: false,
                                    confirmText: localizations.translate(
                                      i18.common.coreCommonOk,
                                    ),
                                    cancelText: localizations.translate(
                                      i18.common.coreCommonCancel,
                                    ),
                                    initialValue: DateFormat(
                                            Constants().dateMonthYearFormat)
                                        .format(form
                                            .control(_dateOfRegistrationKey)
                                            .value)
                                        .toString(),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          //[TODO: Use pregnant women form value based on project config
                        ]),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  FormGroup buildForm(BeneficiaryRegistrationState state) {
    final household = state.mapOrNull(editHousehold: (value) {
      return value.householdModel;
    }, create: (value) {
      return value.householdModel;
    });

    final registrationDate = state.mapOrNull(
      editHousehold: (value) {
        return value.registrationDate;
      },
      create: (value) => DateTime.now(),
    );

    return fb.group(<String, Object>{
      _dateOfRegistrationKey:
          FormControl<DateTime>(value: registrationDate, validators: []),
    });
  }
}