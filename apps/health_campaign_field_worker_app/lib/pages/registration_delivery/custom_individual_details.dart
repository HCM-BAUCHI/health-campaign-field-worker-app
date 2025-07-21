import 'package:auto_route/auto_route.dart';
import 'package:collection/collection.dart';
import 'package:dart_mappable/dart_mappable.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../utils/date_utils.dart' as digits;
import 'package:digit_components/widgets/atoms/digit_toaster.dart';
import 'package:digit_ui_components/theme/ComponentTheme/checkbox_theme.dart';
import '../../utils/upper_case.dart';
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
import 'package:registration_delivery/widgets/localized.dart';
import 'package:registration_delivery/widgets/showcase/config/showcase_constants.dart';
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
  static const _idTypeKey = 'idType';
  static const _idNumberKey = 'idNumber';
  bool isDuplicateTag = false;
  static const maxLength = 200;
  final clickedStatus = ValueNotifier<bool>(false);
  DateTime now = DateTime.now();

  bool isEditIndividual = false;
  bool isAddIndividual = false;
  bool isBeneficaryRegistration = false;
  final String yes = "yes";
  final String no = "no";
  String? yesNoValue;
  bool get isRelocated => yesNoValue == yes;
  final RegExp uuidRegex = RegExp(
      r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$');
  final trainingRegex = RegExp(r'^cps-f\d{5}$');
  final productionRegex = RegExp(r'^CPS26-(\d{6})$');

  final beneficiaryType = RegistrationDeliverySingleton().beneficiaryType!;
  Set<String>? beneficiaryId;

  late final CustomSearchHouseholdsBloc customSearchHouseholdsBloc;

  @override
  void initState() {
    customSearchHouseholdsBloc = context.read<CustomSearchHouseholdsBloc>();
    super.initState();
  }

  onSubmit(IndividualModel individual, bool isCreate) async {
    final bloc = context.read<CustomBeneficiaryRegistrationBloc>();
    final router = context.router;
    final name = individual?.name?.givenName ?? '';

    if (context.mounted) {
      if (isCreate) {
        router.push(CustomSummaryRoute(name: name));
      } else {
        customSearchHouseholdsBloc
            .add(const CustomSearchHouseholdsEvent.clear());
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
        router.popUntil(
            (route) => route.settings.name == SearchBeneficiaryRoute.name);
        router.push(CustomBeneficiaryAcknowledgementRoute(
          enableViewHousehold: true,
          acknowledgementType: isCreate
              ? AcknowledgementType.addHousehold
              : AcknowledgementType.addMember,
          selectedIndividual: individual,
        ));
      }
    }
  }

  onBeneficiarySubmit(name, individual) async {
    final router = context.router;
    router.push(CustomBeneficiarySummaryRoute(
      name: name,
      individualModel: individual,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<CustomBeneficiaryRegistrationBloc>();
    final router = context.router;
    final theme = Theme.of(context);
    DateTime before150Years = DateTime(now.year - 150, now.month, now.day);
    DateTime lastDate = DateTime(now.year, now.month - 3, now.day);
    DateTime firstDate = DateTime(now.year, now.month - 59, now.day);
    yesNoValue ??= no;

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
                            if (form.control(_dobKey).value == null) {
                              setState(() {
                                form
                                    .control(_dobKey)
                                    .setErrors({'required': true});
                                form.control(_dobKey).markAsTouched();
                              });
                            }
                            if (form.control(_genderKey).value == null) {
                              setState(() {
                                form.control(_genderKey).setErrors({'': true});
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
                                    await onSubmit(individual, true);
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
                                      !uuidRegex.hasMatch(tag) &&
                                      !trainingRegex.hasMatch(tag) &&
                                      !productionRegex.hasMatch(tag)) {
                                    Toast.showToast(
                                      context,
                                      type: ToastType.error,
                                      message: localizations.translate(i18_local
                                          .stockReconciliationDetails
                                          .qrCodeInvalidFormat),
                                    );
                                    return;
                                  }

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
                                    onSubmit(individual, false);
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
                                    if (scannerBloc.state.qrCodes.isNotEmpty &&
                                        !uuidRegex.hasMatch(
                                            scannerBloc.state.qrCodes.first) &&
                                        !productionRegex.hasMatch(
                                            scannerBloc.state.qrCodes.first) &&
                                        !trainingRegex.hasMatch(
                                            scannerBloc.state.qrCodes.first)) {
                                      Toast.showToast(
                                        context,
                                        type: ToastType.error,
                                        message:
                                            'Invalid QR code format. Please scan a valid code.',
                                      );
                                      return;
                                    }
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
                                      // bloc.add(
                                      //   BeneficiaryRegistrationAddMemberEvent(
                                      //     beneficiaryType:
                                      //         RegistrationDeliverySingleton()
                                      //             .beneficiaryType!,
                                      //     householdModel: householdModel,
                                      //     individualModel: individual,
                                      //     addressModel: addressModel,
                                      //     userUuid:
                                      //         RegistrationDeliverySingleton()
                                      //             .loggedInUserUuid!,
                                      //     projectId:
                                      //         RegistrationDeliverySingleton()
                                      //             .projectId!,
                                      //     tag: scannerBloc
                                      //             .state.qrCodes.isNotEmpty
                                      //         ? scannerBloc.state.qrCodes.first
                                      //         : null,
                                      //   ),
                                      // );
                                      final boundary =
                                          RegistrationDeliverySingleton()
                                              .boundary;
                                      // bloc.add(
                                      //   BeneficiaryRegistrationSummaryEvent(
                                      //     projectId: projectId!,
                                      //     userUuid: userId!,
                                      //     boundary: boundary!,
                                      //     tag: scannerBloc
                                      //             .state.qrCodes.isNotEmpty
                                      //         ? scannerBloc.state.qrCodes.first
                                      //         : null,
                                      //   ),
                                      // );
                                      onBeneficiarySubmit(
                                          individual.name?.givenName ?? "",
                                          individual);
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
                                  child: DigitTextFormInput(
                                    inputFormatters: [
                                      UpperCaseTextFormatter(),
                                    ],
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
                        Offstage(
                          offstage: !widget.isHeadOfHousehold,
                          child: ReactiveWrapperField(
                            formControlName: _idTypeKey,
                            validationMessages: {
                              'required': (_) => localizations.translate(
                                    i18.common.corecommonRequired,
                                  ),
                            },
                            builder: (field) => LabeledField(
                              label: localizations.translate(
                                i18.individualDetails.idTypeLabelText,
                              ),
                              capitalizedFirstLetter: false,
                              isRequired: false,
                              child: DigitDropdown<String>(
                                //check if the value is null or empty. if yes default to "Default"
                                selectedOption: (form
                                                .control(_idTypeKey)
                                                .value !=
                                            null &&
                                        form.control(_idTypeKey).value != '')
                                    ? DropdownItem(
                                        name: localizations.translate(
                                            form.control(_idTypeKey).value),
                                        code: form.control(_idTypeKey).value)
                                    : DropdownItem(
                                        // This block handles the default case
                                        name: localizations.translate(
                                            'DEFAULT'), // Display "Default"
                                        code:
                                            'DEFAULT', // Set the internal code to 'DEFAULT'
                                      ),
                                items: [
                                  ...RegistrationDeliverySingleton()
                                      .idTypeOptions!
                                      .map((e) => DropdownItem(
                                            name: localizations.translate(e),
                                            code: e,
                                          )),
                                ],
                                onSelect: (value) {
                                  form.control(_idTypeKey).value = value.code;
                                  setState(() {
                                    if (value.code == 'DEFAULT') {
                                      form.control(_idNumberKey).value =
                                          IdGen.i.identifier.toString();
                                    } else {
                                      form.control(_idNumberKey).value = null;
                                    }
                                  });
                                },
                                emptyItemText: localizations
                                    .translate(i18.common.noMatchFound),
                                errorMessage: form.control(_idTypeKey).hasErrors
                                    ? localizations.translate(
                                        i18.common.corecommonRequired,
                                      )
                                    : null,
                              ),
                            ),
                          ),
                        ),
                        if (widget.isHeadOfHousehold &&
                            form.control(_idTypeKey).value != 'DEFAULT')
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ReactiveFormConsumer(
                                builder: (context, formGroup, child) {
                                  return ReactiveWrapperField(
                                    formControlName: _idNumberKey,
                                    validationMessages: {
                                      'required': (object) =>
                                          localizations.translate(
                                            '${i18.individualDetails.idNumberLabelText}_IS_REQUIRED',
                                          ),
                                    },
                                    builder: (field) => LabeledField(
                                      label: localizations.translate(
                                        i18.individualDetails.idNumberLabelText,
                                      ),
                                      capitalizedFirstLetter: false,
                                      isRequired: false,
                                      child: DigitTextFormInput(
                                        inputFormatters: [
                                          UpperCaseTextFormatter(),
                                        ],
                                        readOnly:
                                            form.control(_idTypeKey).value ==
                                                'DEFAULT',
                                        initialValue:
                                            form.control(_idNumberKey).value,
                                        onChange: (value) {
                                          form.control(_idNumberKey).value =
                                              value;
                                        },
                                        errorMessage: field.errorText,
                                      ),
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(height: 4),
                            ],
                          ),
                        if (widget.isHeadOfHousehold &&
                            form.control(_idTypeKey).value == 'DEFAULT')
                          const SizedBox(
                            height: spacer2,
                          ),
                        individualDetailsShowcaseData.dateOfBirth.buildWith(
                          // child: CustomDigitDobPicker(
                          //   datePickerFormControl: _dobKey,
                          //   datePickerLabel: localizations.translate(
                          //     i18.individualDetails.dobLabelText,
                          //   ),
                          //   ageFieldLabel: localizations.translate(
                          //     i18.individualDetails.ageLabelText,
                          //   ),
                          //   yearsHintLabel: localizations.translate(
                          //     i18.individualDetails.yearsHintText,
                          //   ),
                          //   separatorLabel: localizations.translate(
                          //     i18.individualDetails.separatorLabelText,
                          //   ),
                          //   yearsAndMonthsErrMsg: localizations.translate(
                          //     i18_local.individualDetails
                          //         .yearsAndMonthsErrorTextUpdate,
                          //   ),
                          //   isHead: widget.isHeadOfHousehold,
                          //   requiredErrMsg: localizations.translate(
                          //     i18.common.corecommonRequired,
                          //   ),
                          //   initialDate: before150Years,
                          //   onChangeOfFormControl: (formControl) {
                          //     // Handle changes to the control's value here
                          //     final value = formControl.value;

                          //     digits.DigitDOBAge age =
                          //         digits.DigitDateUtils.calculateAge(value);
                          //     // Allow only between 0 to 59 months for cycle 1
                          //     final ageInMonths = age.years * 12 + age.months;
                          //     if (ageInMonths > 59) {
                          //       widget.isHeadOfHousehold
                          //           ? formControl.removeError('')
                          //           : formControl.setErrors({'': true});
                          //     } else {
                          //       formControl.removeError('');
                          //     }
                          //   },
                          //   cancelText: localizations
                          //       .translate(i18.common.coreCommonCancel),
                          //   confirmText: localizations
                          //       .translate(i18.common.coreCommonOk),
                          //   monthsHintLabel: 'Month',
                          // ),
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
                            isHeadOfHousehold: widget.isHeadOfHousehold,
                            initialDate: widget.isHeadOfHousehold
                                ? before150Years
                                : firstDate,
                            requiredErrMsg: localizations.translate(
                              i18.common.corecommonRequired,
                            ),
                            onChangeOfFormControl: (dob) {
                              final control = form.control(_dobKey);
                              if (dob == null) {
                                control.setErrors({'required': true});
                                return;
                              }
                              final age =
                                  digits.DigitDateUtils.calculateAge(dob);
                              final ageInMonths = age.years * 12 + age.months;
                              if (!widget.isHeadOfHousehold &&
                                  ageInMonths > 59) {
                                control.setErrors({'ageLimit': true});
                              } else {
                                control.removeError('ageLimit');
                                control.removeError('required');
                                control.removeError('');
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
                        if (!widget.isHeadOfHousehold)
                          DigitButton(
                            capitalizeLetters: false,
                            label: localizations.translate(
                              i18_local.individualDetails
                                  .linkQrCodeToBeneficiaryLabel,
                            ),
                            mainAxisSize: MainAxisSize.max,
                            type: DigitButtonType.secondary,
                            size: DigitButtonSize.large,
                            isDisabled: false,
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => const DigitScannerPage(
                                    quantity: 5,
                                    isGS1code: false,
                                    singleValue: false,
                                  ),
                                  settings:
                                      const RouteSettings(name: '/qr-scanner'),
                                ),
                              );
                            },
                          ),
                        if (!widget.isHeadOfHousehold)
                          Text(
                              localizations.translate(i18_local
                                  .individualDetails
                                  .relocatedBeneficiaryQuestion),
                              style: TextStyle(
                                fontSize: 16,
                                color: theme.colorTheme.text.primary,
                              )),
                        if (!widget.isHeadOfHousehold)
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.grey,
                              ),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: StatefulBuilder(
                              builder: (context, setState) {
                                return Row(
                                  children: [
                                    Expanded(
                                      child: RadioListTile<String>(
                                        title: Text(localizations.translate(
                                          i18_local.householdDetails
                                              .capitalYesLabelText,
                                        )),
                                        value: yes,
                                        groupValue: yesNoValue,
                                        onChanged: (value) {
                                          setState(() {
                                            yesNoValue = value!;
                                          });
                                          // Force rebuild to show/hide button
                                          this.setState(() {});
                                        },
                                      ),
                                    ),
                                    Expanded(
                                      child: RadioListTile<String>(
                                        title: Text(localizations.translate(
                                          i18_local.householdDetails
                                              .capitalNoLabelText,
                                        )),
                                        value: no,
                                        groupValue: yesNoValue,
                                        onChanged: (value) {
                                          setState(() {
                                            yesNoValue = value!;
                                          });
                                          this.setState(() {});
                                        },
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                        if (!widget.isHeadOfHousehold && isRelocated)
                          DigitButton(
                            capitalizeLetters: false,
                            label: localizations.translate(i18_local
                                .householdDetails.previousBeneficiaryQRCode),
                            mainAxisSize: MainAxisSize.max,
                            type: DigitButtonType.secondary,
                            size: DigitButtonSize.large,
                            isDisabled: false,
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => const DigitScannerPage(
                                    quantity: 5,
                                    isGS1code: false,
                                    singleValue: false,
                                  ),
                                  settings:
                                      const RouteSettings(name: '/qr-scanner'),
                                ),
                              );
                            },
                          ),
                        individualDetailsShowcaseData.mobile.buildWith(
                          child: Offstage(
                            offstage: !widget.isHeadOfHousehold,
                            child: ReactiveWrapperField(
                              formControlName: _mobileNumberKey,
                              validationMessages: {
                                'mobileNumber': (object) =>
                                    localizations.translate(i18_local
                                        .individualDetails
                                        .mobileNumberLengthValidationMessage),
                                'maxLength': (object) => localizations
                                    .translate(i18_local.individualDetails
                                        .mobileNumberLengthValidationMessage)
                                    .replaceAll('{}', '8'),
                                'startsWith7or9': (object) =>
                                    localizations.translate(i18_local
                                        .individualDetails
                                        .mobileNumberStartWith7or9ValidationMessage),
                              },
                              builder: (field) => LabeledField(
                                label: localizations.translate(
                                  i18_local.individualDetails.mobileNumberLabel,
                                ),
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
      // additionalFields: IndividualAdditionalFields(version: 1, fields: [
      //   AdditionalField(form.control(_idTypeKey).value ?? '',
      //       form.control(_idNumberKey).value ?? '')
      // ])
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
        validators: [Validators.required],
        value: individual?.dateOfBirth != null
            ? DateFormat(Constants().dateFormat).parse(
                individual!.dateOfBirth!,
              )
            : null,
      ),
      _idTypeKey: FormControl<String>(
        value: individual?.identifiers?.firstOrNull?.identifierType,
      ),
      _idNumberKey: FormControl<String>(
        value: individual?.identifiers?.firstOrNull?.identifierId,
      ),
      _genderKey: FormControl<String>(value: getGenderOptions(individual)),
      _mobileNumberKey:
          FormControl<String>(value: individual?.mobileNumber, validators: [
        Validators.delegate((validator) =>
            local_utils.CustomValidator.validMobileNumber(validator)),
        Validators.maxLength(8),
        Validators.delegate((validator) =>
            local_utils.CustomValidator.startsWith7or9(validator)),
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
