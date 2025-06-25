import 'package:auto_route/auto_route.dart';
import 'package:collection/collection.dart';
import 'package:dart_mappable/dart_mappable.dart';
// import 'package:digit_components/utils/date_utils.dart' as digits;
import '../../utils/date_utils.dart' as digits;
import 'package:digit_components/widgets/atoms/digit_toaster.dart';
import 'package:digit_ui_components/theme/ComponentTheme/checkbox_theme.dart';
import '../../widgets/custom_back_navigation.dart';
import 'package:digit_data_model/data_model.dart';
import 'package:digit_data_model/models/entities/household_type.dart';
import 'package:digit_scanner/blocs/scanner.dart';
import 'package:digit_scanner/pages/qr_scanner.dart';
import 'package:digit_ui_components/digit_components.dart';
import 'package:digit_ui_components/theme/digit_extended_theme.dart';
import 'package:digit_ui_components/utils/date_utils.dart';
import 'package:digit_ui_components/widgets/atoms/digit_dob_picker.dart';
import 'package:digit_ui_components/widgets/atoms/pop_up_card.dart';
import 'package:digit_ui_components/widgets/atoms/selection_card.dart';
import 'package:digit_ui_components/widgets/molecules/digit_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:digit_components/widgets/atoms/digit_dropdown.dart' as dropdown;
import 'package:health_campaign_field_worker_app/blocs/app_initialization/app_initialization.dart';
import 'package:health_campaign_field_worker_app/models/app_config/app_config_model.dart';
import 'package:health_campaign_field_worker_app/widgets/date/custom_digit_dob_picker.dart';
// import 'package:health_campaign_field_worker_app/widgets/header/custom_back_button.dart';
import 'package:intl/intl.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:registration_delivery/blocs/search_households/search_bloc_common_wrapper.dart';
import 'package:registration_delivery/blocs/search_households/search_households.dart';
import 'package:registration_delivery/models/entities/household.dart';
import 'package:registration_delivery/utils/constants.dart';
import 'package:registration_delivery/utils/extensions/extensions.dart';

import 'package:registration_delivery/blocs/household_overview/household_overview.dart';
import 'package:registration_delivery/router/registration_delivery_router.gm.dart';
import 'package:registration_delivery/utils/i18_key_constants.dart' as i18;
import '../../utils/i18_key_constants.dart' as i18_local;
import 'package:registration_delivery/utils/utils.dart';
// import 'package:registration_delivery/widgets/back_navigation_help_header.dart';
import 'package:registration_delivery/widgets/localized.dart';
import 'package:registration_delivery/widgets/showcase/config/showcase_constants.dart';
import 'package:registration_delivery/widgets/showcase/showcase_button.dart';

import '../../blocs/registration_delivery/custom_beneficairy_registration.dart';
import '../../blocs/registration_delivery/custom_search_household.dart';
import '../../models/entities/identifier_types.dart';
import '../../router/app_router.dart';
import '../../utils/utils.dart' as local_utils;
import '../../utils/registration_delivery/registration_delivery_utils.dart';
import 'custom_beneficiary_acknowledgement.dart';

@RoutePage()
class CustomIndividualDetailsPage extends LocalizedStatefulWidget {
  final bool isHeadOfHousehold;

  const CustomIndividualDetailsPage({
    super.key,
    super.appLocalizations,
    this.isHeadOfHousehold = false,
  });

  @override
  State<CustomIndividualDetailsPage> createState() =>
      CustomIndividualDetailsPageState();
}

class CustomIndividualDetailsPageState
    extends LocalizedState<CustomIndividualDetailsPage> {
  static const _individualNameKey = 'individualName';
  static const _dobKey = 'dob';
  static const _genderKey = 'gender';
  static const _mobileNumberKey = 'mobileNumber';
  bool isDuplicateTag = false;
  static const maxLength = 200;
  final clickedStatus = ValueNotifier<bool>(false);
  DateTime now = DateTime.now();

  bool isEditIndividual = false;
  bool isAddIndividual = false;

  final beneficiaryType = RegistrationDeliverySingleton().beneficiaryType!;
  Set<String>? beneficiaryId;

  late final CustomSearchHouseholdsBloc customSearchHouseholdsBloc;

  @override
  void initState() {
    customSearchHouseholdsBloc = context.read<CustomSearchHouseholdsBloc>();
    super.initState();
  }

  onSubmit(name, bool isCreate) async {
    final bloc = context.read<CustomBeneficiaryRegistrationBloc>();
    final router = context.router;

    if (context.mounted) {
      if (isCreate) {
        bloc.add(
          BeneficiaryRegistrationCreateEvent(
              projectId: RegistrationDeliverySingleton().projectId!,
              userUuid: RegistrationDeliverySingleton().loggedInUserUuid!,
              boundary: RegistrationDeliverySingleton().boundary!,
              tag: null,
              navigateToSummary: false),
        );
      }
      router.popUntil(
          (route) => route.settings.name == SearchBeneficiaryRoute.name);
      customSearchHouseholdsBloc.add(const CustomSearchHouseholdsEvent.clear());
      customSearchHouseholdsBloc.add(
        CustomSearchHouseholdsEvent.searchByHouseholdHead(
          searchText: name.trim(),
          projectId: RegistrationDeliverySingleton().projectId!,
          isProximityEnabled: false,
          maxRadius: RegistrationDeliverySingleton().maxRadius,
          limit: customSearchHouseholdsBloc.state.limit,
          offset: 0,
        ),
      );
      router.push(CustomBeneficiaryAcknowledgementRoute(
        enableViewHousehold: true,
        acknowledgementType: isCreate
            ? AcknowledgementType.addHousehold
            : AcknowledgementType.addMember,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<CustomBeneficiaryRegistrationBloc>();
    final router = context.router;
    final theme = Theme.of(context);
    DateTime before150Years = DateTime(now.year - 150, now.month, now.day);
    final textTheme = theme.digitTextTheme(context);

    return Scaffold(
      body: ReactiveFormBuilder(
        form: () => buildForm(bloc.state),
        builder: (context, form, child) => BlocConsumer<
            CustomBeneficiaryRegistrationBloc, BeneficiaryRegistrationState>(
          listener: (context, state) {},
          builder: (context, state) {
            return ScrollableContent(
              enableFixedDigitButton: true,
              header: Column(children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: spacer2),
                  child: CustomBackNavigationHelpHeaderWidget(
                    showHelp: false,
                    handleback: () {
                      if (isEditIndividual) {
                        final parent = context.router.parent() as StackRouter;
                        parent.maybePop();
                      } else {
                        context.router.maybePop();
                      }
                    },
                  ),
                ),
              ]),
              footer: DigitCard(
                  margin: const EdgeInsets.only(top: spacer2),
                  children: [
                    ValueListenableBuilder(
                      valueListenable: clickedStatus,
                      builder: (context, bool isClicked, _) {
                        return DigitButton(
                          label: state.mapOrNull(
                                editIndividual: (value) => localizations
                                    .translate(i18.common.coreCommonSave),
                              ) ??
                              localizations
                                  .translate(i18.common.coreCommonSubmit),
                          type: DigitButtonType.primary,
                          size: DigitButtonSize.large,
                          mainAxisSize: MainAxisSize.max,
                          onPressed: () async {
                            final submit = await showDialog(
                              context: context,
                              builder: (ctx) => Popup(
                                title: localizations.translate(
                                  i18.deliverIntervention.dialogTitle,
                                ),
                                description: localizations.translate(
                                  i18.deliverIntervention.dialogContent,
                                ),
                                actions: [
                                  DigitButton(
                                      label: localizations.translate(
                                        i18.common.coreCommonSubmit,
                                      ),
                                      onPressed: () {
                                        clickedStatus.value = true;
                                        Navigator.of(
                                          context,
                                          rootNavigator: true,
                                        ).pop(true);
                                      },
                                      type: DigitButtonType.primary,
                                      size: DigitButtonSize.large),
                                  DigitButton(
                                      label: localizations.translate(
                                        i18.common.coreCommonCancel,
                                      ),
                                      onPressed: () => Navigator.of(
                                            context,
                                            rootNavigator: true,
                                          ).pop(false),
                                      type: DigitButtonType.secondary,
                                      size: DigitButtonSize.large)
                                ],
                              ),
                            );

                            if (submit ?? false) {
                              if (form.control(_dobKey).value == null) {
                                setState(() {
                                  widget.isHeadOfHousehold
                                      ? form.control(_dobKey).removeError('')
                                      : form
                                          .control(_dobKey)
                                          .setErrors({'': true});
                                });
                              }
                              if (form.control(_genderKey).value == null) {
                                setState(() {
                                  form
                                      .control(_genderKey)
                                      .setErrors({'': true});
                                });
                              }
                              final userId = RegistrationDeliverySingleton()
                                  .loggedInUserUuid;
                              final projectId =
                                  RegistrationDeliverySingleton().projectId;
                              form.markAllAsTouched();
                              if (!form.valid) return;
                              FocusManager.instance.primaryFocus?.unfocus();

                              final age = (form.control(_dobKey).value != null)
                                  ? digits.DigitDateUtils.calculateAge(
                                      form.control(_dobKey).value as DateTime,
                                    )
                                  : digits.DigitDateUtils.calculateAge(
                                      DateTime.now(),
                                    );

                              if (age.years < 18 && widget.isHeadOfHousehold) {
                                await DigitToast.show(
                                  context,
                                  options: DigitToastOptions(
                                    localizations.translate(i18_local
                                        .individualDetails.headAgeValidError),
                                    true,
                                    theme,
                                  ),
                                );

                                return;
                              }
                              // Check if months value is valid (0-11)
                              if (age.months > 11) {
                                // Since MonthsValueValidator already restricts input to 0-11,
                                // this is just an extra check for form submission
                                form.control(_dobKey).setErrors({'monthsRange': true});
                                return;
                              }
                              
                              final ageInMonthsForChild =
                                  age.years * 12 + age.months;
                              if ((ageInMonthsForChild < 3 ||
                                      ageInMonthsForChild > 59) &&
                                  !widget.isHeadOfHousehold) {
                                await DigitToast.show(
                                  context,
                                  options: DigitToastOptions(
                                    localizations.translate(i18_local
                                        .individualDetails.childAgeValidError),
                                    true,
                                    theme,
                                  ),
                                );

                                return;
                              }

                              final boundaryBloc =
                                  context.read<BoundaryBloc>().state;
                              final code = boundaryBloc.boundaryList.first.code;
                              final bname =
                                  boundaryBloc.boundaryList.first.name;

                              final locality = code == null || bname == null
                                  ? null
                                  : LocalityModel(code: code, name: bname);

                              String localityCode = locality!.code;

                              beneficiaryId =
                                  await UniqueIdGeneration().generateUniqueId(
                                localityCode: localityCode,
                                loggedInUserId: userId!,
                                returnCombinedIds: false,
                              );

                              isEditIndividual = false;
                              isAddIndividual = false;
                              state.maybeWhen(
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
                                  final individual = _getIndividualModel(
                                    context,
                                    form: form,
                                    oldIndividual: null,
                                    beneficiaryId: beneficiaryId?.first,
                                  );

                                  final boundary =
                                      RegistrationDeliverySingleton().boundary;

                                  bloc.add(
                                    BeneficiaryRegistrationSaveIndividualDetailsEvent(
                                      model: individual,
                                      isHeadOfHousehold:
                                          widget.isHeadOfHousehold,
                                    ),
                                  );
                                  final scannerBloc =
                                      context.read<DigitScannerBloc>();
                                  scannerBloc.add(
                                    const DigitScannerEvent.handleScanner(),
                                  );

                                  if (scannerBloc.state.duplicate) {
                                    Toast.showToast(context,
                                        message: localizations.translate(
                                          i18.deliverIntervention
                                              .resourceAlreadyScanned,
                                        ),
                                        type: ToastType.error);
                                  } else {
                                    clickedStatus.value = true;
                                    final scannerBloc =
                                        context.read<DigitScannerBloc>();
                                    scannerBloc.add(
                                      const DigitScannerEvent.handleScanner(),
                                    );
                                    bloc.add(
                                      BeneficiaryRegistrationSummaryEvent(
                                        projectId: projectId!,
                                        userUuid: userId!,
                                        boundary: boundary!,
                                        tag: scannerBloc
                                                .state.qrCodes.isNotEmpty
                                            ? scannerBloc.state.qrCodes.first
                                            : null,
                                      ),
                                    );
                                    // router.push(CustomSummaryRoute());
                                    await onSubmit(
                                        individual.name?.givenName ?? "", true);
                                  }
                                },
                                editIndividual: (
                                  householdModel,
                                  individualModel,
                                  addressModel,
                                  projectBeneficiaryModel,
                                  loading,
                                ) {
                                  isEditIndividual = true;
                                  final scannerBloc =
                                      context.read<DigitScannerBloc>();
                                  scannerBloc.add(
                                    const DigitScannerEvent.handleScanner(),
                                  );
                                  final individual = _getIndividualModel(
                                    context,
                                    form: form,
                                    oldIndividual: individualModel,
                                    beneficiaryId: beneficiaryId?.first,
                                  );
                                  final tag =
                                      scannerBloc.state.qrCodes.isNotEmpty
                                          ? scannerBloc.state.qrCodes.first
                                          : null;

                                  if (tag != null &&
                                      tag != projectBeneficiaryModel?.tag &&
                                      scannerBloc.state.duplicate) {
                                    Toast.showToast(context,
                                        message: localizations.translate(
                                          i18.deliverIntervention
                                              .resourceAlreadyScanned,
                                        ),
                                        type: ToastType.error);
                                  } else {
                                    bloc.add(
                                      BeneficiaryRegistrationUpdateIndividualDetailsEvent(
                                        addressModel: addressModel,
                                        householdModel: householdModel,
                                        model: individual.copyWith(
                                          clientAuditDetails: (individual
                                                          .clientAuditDetails
                                                          ?.createdBy !=
                                                      null &&
                                                  individual.clientAuditDetails
                                                          ?.createdTime !=
                                                      null)
                                              ? ClientAuditDetails(
                                                  createdBy: individual
                                                      .clientAuditDetails!
                                                      .createdBy,
                                                  createdTime: individual
                                                      .clientAuditDetails!
                                                      .createdTime,
                                                  lastModifiedBy:
                                                      RegistrationDeliverySingleton()
                                                          .loggedInUserUuid,
                                                  lastModifiedTime:
                                                      ContextUtilityExtensions(
                                                              context)
                                                          .millisecondsSinceEpoch(),
                                                )
                                              : null,
                                        ),
                                        tag: scannerBloc
                                                .state.qrCodes.isNotEmpty
                                            ? scannerBloc.state.qrCodes.first
                                            : null,
                                      ),
                                    );
                                    onSubmit(individual.name?.givenName ?? "",
                                        false);
                                  }
                                },
                                addMember: (
                                  addressModel,
                                  householdModel,
                                  loading,
                                ) {
                                  isAddIndividual = true;
                                  final individual = _getIndividualModel(
                                    context,
                                    form: form,
                                    beneficiaryId: beneficiaryId?.first,
                                  );

                                  if (context.mounted) {
                                    final scannerBloc =
                                        context.read<DigitScannerBloc>();
                                    scannerBloc.add(
                                      const DigitScannerEvent.handleScanner(),
                                    );
                                    if (scannerBloc.state.duplicate) {
                                      Toast.showToast(
                                        context,
                                        message: localizations.translate(
                                          i18.deliverIntervention
                                              .resourceAlreadyScanned,
                                        ),
                                        type: ToastType.error,
                                      );
                                    } else {
                                      bloc.add(
                                        BeneficiaryRegistrationAddMemberEvent(
                                          beneficiaryType:
                                              RegistrationDeliverySingleton()
                                                  .beneficiaryType!,
                                          householdModel: householdModel,
                                          individualModel: individual,
                                          addressModel: addressModel,
                                          userUuid:
                                              RegistrationDeliverySingleton()
                                                  .loggedInUserUuid!,
                                          projectId:
                                              RegistrationDeliverySingleton()
                                                  .projectId!,
                                          tag: scannerBloc
                                                  .state.qrCodes.isNotEmpty
                                              ? scannerBloc.state.qrCodes.first
                                              : null,
                                        ),
                                      );
                                      onSubmit(individual.name?.givenName ?? "",
                                          false);
                                    }
                                  }
                                },
                              );
                            }
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
                        Text(
                          localizations.translate(
                            widget.isHeadOfHousehold
                                ? i18_local
                                    .individualDetails.caregiverDetailsLabelText
                                : i18_local.individualDetails
                                    .individualsDetailsLabelTextNewUpdate,
                          ),
                          style: textTheme.headingXl.copyWith(
                            color: theme.colorTheme.text.primary,
                          ),
                        ),
                        Column(
                          children: [
                            individualDetailsShowcaseData.nameOfIndividual
                                .buildWith(
                              child: ReactiveWrapperField(
                                formControlName: _individualNameKey,
                                validationMessages: {
                                  'required': (object) =>
                                      localizations.translate(
                                        '${widget.isHeadOfHousehold ? i18_local.individualDetails.caregiverNameLabelText : i18.individualDetails.nameLabelText}_IS_REQUIRED',
                                      ),
                                  'maxLength': (object) => localizations
                                      .translate(i18.common.maxCharsRequired)
                                      .replaceAll('{}', maxLength.toString()),
                                  'onlyAlphabets': (object) =>
                                      localizations.translate(
                                        i18_local.individualDetails
                                            .onlyAlphabetsValidationMessage,
                                      ),
                                },
                                builder: (field) => LabeledField(
                                  label: localizations.translate(
                                    widget.isHeadOfHousehold
                                        ? i18_local.individualDetails
                                            .caregiverNameLabelText
                                        : i18_local.individualDetails
                                            .nameLabelTextNewUpdate,
                                  ),
                                  isRequired: true,
                                  child: DigitTextFormInput(
                                    initialValue:
                                        form.control(_individualNameKey).value,
                                    onChange: (value) {
                                      form.control(_individualNameKey).value =
                                          value;
                                    },
                                    errorMessage: field.errorText,
                                  ),
                                ),
                              ),
                            ),
                            if (widget.isHeadOfHousehold)
                              const SizedBox(
                                height: spacer2,
                              ),
                            Offstage(
                              offstage: !widget.isHeadOfHousehold,
                              child: DigitCheckbox(
                                capitalizeFirstLetter: false,
                                label: (RegistrationDeliverySingleton()
                                            .householdType ==
                                        HouseholdType.community)
                                    ? localizations.translate(i18
                                        .individualDetails.clfCheckboxLabelText)
                                    : localizations.translate(
                                        i18_local.individualDetails
                                            .checkboxLabelTextUpdate,
                                      ),
                                value: widget.isHeadOfHousehold,
                                readOnly: widget.isHeadOfHousehold,
                                checkboxThemeData: DigitCheckboxThemeData(
                                    disabledIconColor:
                                        theme.colorTheme.primary.primary1),
                                onChanged: (_) {},
                              ),
                            ),
                          ],
                        ),
                        individualDetailsShowcaseData.dateOfBirth.buildWith(
                          child: CustomDigitDobPicker(
                            datePickerFormControl: _dobKey,
                            datePickerLabel: localizations.translate(
                              i18.individualDetails.dobLabelText,
                            ),
                            ageFieldLabel: localizations.translate(
                              i18.individualDetails.ageLabelText,
                            ),
                            yearsHintLabel: localizations.translate(
                              i18.individualDetails.yearsHintText,
                            ),
                            separatorLabel: localizations.translate(
                              i18.individualDetails.separatorLabelText,
                            ),
                            yearsAndMonthsErrMsg: localizations.translate(
                              i18_local.individualDetails
                                  .yearsAndMonthsErrorTextUpdate,
                            ),
                            initialDate: before150Years,
                            onChangeOfFormControl: (formControl) {
                              // Handle changes to the control's value here
                              final value = formControl.value;
                              
                              if (value != null) {
                                digits.DigitDOBAge age =
                                    digits.DigitDateUtils.calculateAge(value);
                                // Check if months is valid (0-11)
                                if (age.months > 11) {
                                  formControl.setErrors({'monthsRange': true});
                                  return;
                                }
                                
                                // Allow only between 3 to 59 months for cycle 1
                                final ageInMonths = age.years * 12 + age.months;
                                if (ageInMonths < 3 || ageInMonths > 59) {
                                  widget.isHeadOfHousehold
                                      ? formControl.removeError('')
                                      : formControl.setErrors({'': true});
                                } else {
                                  formControl.removeError('');
                                }
                              }
                            },
                            cancelText: localizations
                                .translate(i18.common.coreCommonCancel),
                            confirmText: localizations
                                .translate(i18.common.coreCommonOk),
                            monthsHintLabel: 'Month',
                          ),
                        ),
                        dropdown.DigitDropdown<String>(
                          label: localizations.translate(
                            i18.individualDetails.genderLabelText,
                          ),
                          valueMapper: (value) =>
                              localizations.translate(value),
                          initialValue: form.control(_genderKey).value,
                          menuItems: RegistrationDeliverySingleton()
                              .genderOptions!
                              .map((e) => e)
                              .toList(),
                          formControlName: _genderKey,
                          isRequired: true,
                          validationMessages: {
                            'required': (_) => localizations.translate(
                                  i18.common.corecommonRequired,
                                ),
                          },
                          onChanged: (value) {
                            if (value != null && value.isNotEmpty) {
                              form.control(_genderKey).value = value;
                            } else {
                              form.control(_genderKey).value = null;
                              form.control(_genderKey).setErrors({'': true});
                            }
                          },
                        ),
                        individualDetailsShowcaseData.mobile.buildWith(
                          child: Offstage(
                            offstage: !widget.isHeadOfHousehold,
                            child: ReactiveWrapperField(
                              formControlName: _mobileNumberKey,
                              validationMessages: {
                                'required': (_) => localizations.translate(
                                      i18.common.corecommonRequired,
                                    ),
                                'mobileNumber': (object) =>
                                    localizations.translate(i18_local
                                        .individualDetails
                                        .mobileNumberLengthValidationMessage),
                                'minLength': (object) =>
                                    localizations.translate(i18_local
                                        .individualDetails
                                        .mobileNumberLengthValidationMessage),
                                'maxLength': (object) => localizations
                                    .translate(i18_local.individualDetails
                                        .mobileNumberLengthValidationMessage)
                                    .replaceAll('{}', '11'),
                              },
                              builder: (field) => LabeledField(
                                label: localizations.translate(
                                  i18.individualDetails.mobileNumberLabelText,
                                ),
                                isRequired: widget.isHeadOfHousehold,
                                child: DigitTextFormInput(
                                  keyboardType: TextInputType.number,
                                  maxLength: 11,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                  ],
                                  initialValue:
                                      form.control(_mobileNumberKey).value,
                                  onChange: (value) {
                                    form.control(_mobileNumberKey).value =
                                        value;
                                  },
                                  errorMessage: field.errorText,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ]),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  IndividualModel _getIndividualModel(
    BuildContext context, {
    required FormGroup form,
    IndividualModel? oldIndividual,
    String? beneficiaryId,
  }) {
    final dob = form.control(_dobKey).value as DateTime?;
    String? dobString;
    if (dob != null) {
      dobString = DateFormat(Constants().dateFormat).format(dob);
    }

    var individual = oldIndividual;
    individual ??= IndividualModel(
      clientReferenceId: IdGen.i.identifier,
      tenantId: RegistrationDeliverySingleton().tenantId,
      rowVersion: 1,
      auditDetails: AuditDetails(
        createdBy: RegistrationDeliverySingleton().loggedInUserUuid!,
        createdTime: ContextUtilityExtensions(context).millisecondsSinceEpoch(),
        lastModifiedBy: RegistrationDeliverySingleton().loggedInUserUuid,
        lastModifiedTime:
            ContextUtilityExtensions(context).millisecondsSinceEpoch(),
      ),
      clientAuditDetails: ClientAuditDetails(
        createdBy: RegistrationDeliverySingleton().loggedInUserUuid!,
        createdTime: ContextUtilityExtensions(context).millisecondsSinceEpoch(),
        lastModifiedBy: RegistrationDeliverySingleton().loggedInUserUuid,
        lastModifiedTime:
            ContextUtilityExtensions(context).millisecondsSinceEpoch(),
      ),
    );

    var name = individual.name;
    name ??= NameModel(
      individualClientReferenceId: individual.clientReferenceId,
      tenantId: RegistrationDeliverySingleton().tenantId,
      rowVersion: 1,
      auditDetails: AuditDetails(
        createdBy: RegistrationDeliverySingleton().loggedInUserUuid!,
        createdTime: ContextUtilityExtensions(context).millisecondsSinceEpoch(),
        lastModifiedBy: RegistrationDeliverySingleton().loggedInUserUuid,
        lastModifiedTime:
            ContextUtilityExtensions(context).millisecondsSinceEpoch(),
      ),
      clientAuditDetails: ClientAuditDetails(
        createdBy: RegistrationDeliverySingleton().loggedInUserUuid!,
        createdTime: ContextUtilityExtensions(context).millisecondsSinceEpoch(),
        lastModifiedBy: RegistrationDeliverySingleton().loggedInUserUuid,
        lastModifiedTime:
            ContextUtilityExtensions(context).millisecondsSinceEpoch(),
      ),
    );

    var identifier = (individual.identifiers?.isNotEmpty ?? false)
        ? individual.identifiers!.first
        : null;

    identifier ??= IdentifierModel(
      clientReferenceId: individual.clientReferenceId,
      tenantId: RegistrationDeliverySingleton().tenantId,
      rowVersion: 1,
      auditDetails: AuditDetails(
        createdBy: RegistrationDeliverySingleton().loggedInUserUuid!,
        createdTime: ContextUtilityExtensions(context).millisecondsSinceEpoch(),
        lastModifiedBy: RegistrationDeliverySingleton().loggedInUserUuid,
        lastModifiedTime:
            ContextUtilityExtensions(context).millisecondsSinceEpoch(),
      ),
      clientAuditDetails: ClientAuditDetails(
        createdBy: RegistrationDeliverySingleton().loggedInUserUuid!,
        createdTime: ContextUtilityExtensions(context).millisecondsSinceEpoch(),
        lastModifiedBy: RegistrationDeliverySingleton().loggedInUserUuid,
        lastModifiedTime:
            ContextUtilityExtensions(context).millisecondsSinceEpoch(),
      ),
    );

    List<IdentifierModel>? identifiers = individual.identifiers;
    if (isEditIndividual == false) {
      identifiers?.add(IdentifierModel(
        clientReferenceId: individual.clientReferenceId,
        identifierId: beneficiaryId,
        identifierType: IdentifierTypes.uniqueBeneficiaryID.toValue(),
        clientAuditDetails: individual.clientAuditDetails,
        auditDetails: individual.auditDetails,
      ));
    }

    String? individualName = form.control(_individualNameKey).value as String?;
    individual = individual.copyWith(
      name: name.copyWith(
        givenName: individualName?.trim(),
      ),
      gender: form.control(_genderKey).value == null
          ? null
          : Gender.values
              .byName(form.control(_genderKey).value.toString().toLowerCase()),
      mobileNumber: form.control(_mobileNumberKey).value,
      dateOfBirth: dobString,
      identifiers: isEditIndividual && identifier.identifierId != null
          ? identifiers
          : [
              identifier.copyWith(
                identifierId: beneficiaryId,
                identifierType: IdentifierTypes.uniqueBeneficiaryID.toValue(),
              ),
            ],
    );

    return individual;
  }

  FormGroup buildForm(BeneficiaryRegistrationState state) {
    final individual = state.mapOrNull<IndividualModel>(
      editIndividual: (value) {
        if (value.projectBeneficiaryModel?.tag != null) {
          context.read<DigitScannerBloc>().add(DigitScannerScanEvent(
              barCode: [], qrCode: [value.projectBeneficiaryModel!.tag!]));
        }

        return value.individualModel;
      },
      create: (value) {
        return value.individualModel;
      },
      summary: (value) {
        return value.individualModel;
      },
    );

    final searchQuery = state.mapOrNull<String>(
      create: (value) {
        return value.searchQuery;
      },
    );

    return fb.group(<String, Object>{
      _individualNameKey: FormControl<String>(
        validators: [
          Validators.required,
          Validators.delegate(
              (validator) => CustomValidator.requiredMin(validator)),
          Validators.maxLength(200),
          Validators.delegate((validator) =>
              local_utils.CustomValidator.onlyAlphabets(validator)),
        ],
        value: individual?.name?.givenName ??
            ((RegistrationDeliverySingleton().householdType ==
                    HouseholdType.community)
                ? null
                : searchQuery?.trim()),
      ),
      _dobKey: FormControl<DateTime>(
        value: individual?.dateOfBirth != null
            ? DateFormat(Constants().dateFormat).parse(
                individual!.dateOfBirth!,
              )
            : null,
      ),
      _genderKey: FormControl<String>(value: getGenderOptions(individual)),
      _mobileNumberKey:
          FormControl<String>(value: individual?.mobileNumber, validators: [
        Validators.delegate((validator) =>
            local_utils.CustomValidator.validMobileNumber(validator)),

        Validators.minLength(11),
        Validators.maxLength(11),
        if (widget.isHeadOfHousehold) Validators.required,
        // Validators.required,
      ]),
    });
  }

  getGenderOptions(IndividualModel? individual) {
    final options = RegistrationDeliverySingleton().genderOptions;

    return options?.map((e) => e).firstWhereOrNull(
          (element) => element.toLowerCase() == individual?.gender?.name,
        );
  }

  getInitialDateValue(FormGroup form) {
    var date = form.control(_dobKey).value != null
        ? DateFormat(Constants().dateTimeExtFormat)
            .format(form.control(_dobKey).value)
        : null;

    return date;
  }
}
