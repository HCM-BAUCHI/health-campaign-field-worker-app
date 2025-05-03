import 'package:auto_route/auto_route.dart';
import 'package:collection/collection.dart';
import 'package:dart_mappable/dart_mappable.dart';
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
import 'package:registration_delivery/utils/utils.dart';
import 'package:registration_delivery/widgets/back_navigation_help_header.dart';
import 'package:registration_delivery/widgets/localized.dart';
import 'package:registration_delivery/widgets/showcase/config/showcase_constants.dart';
import 'package:registration_delivery/widgets/showcase/showcase_button.dart';

import '../../blocs/registration_delivery/custom_beneficairy_registration.dart';
import '../../blocs/registration_delivery/custom_search_household.dart';
import '../../models/entities/identifier_types.dart';
import '../../router/app_router.dart';
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
  // static const _idTypeKey = 'idType';
  // static const _idNumberKey = 'idNumber';
  static const _dobKey = 'dob';
  static const _genderKey = 'gender';
  static const _mobileNumberKey = 'mobileNumber';
  bool isDuplicateTag = false;
  static const maxLength = 200;
  final clickedStatus = ValueNotifier<bool>(false);
  DateTime now = DateTime.now();

  bool isEditIndividual = false;

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
                  child: BackNavigationHelpHeaderWidget(
                    showHelp: false,
                    handleBack: () {
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
                                  form.control(_dobKey).setErrors({'': true});
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

                                    // final submit = await showDialog(
                                    //   context: context,
                                    //   builder: (ctx) => Popup(
                                    //     title: localizations.translate(
                                    //       i18.deliverIntervention.dialogTitle,
                                    //     ),
                                    //     description: localizations.translate(
                                    //       i18.deliverIntervention.dialogContent,
                                    //     ),
                                    //     actions: [
                                    //       DigitButton(
                                    //           label: localizations.translate(
                                    //             i18.common.coreCommonSubmit,
                                    //           ),
                                    //           onPressed: () {
                                    //             clickedStatus.value = true;
                                    //             Navigator.of(
                                    //               context,
                                    //               rootNavigator: true,
                                    //             ).pop(true);
                                    //           },
                                    //           type: DigitButtonType.primary,
                                    //           size: DigitButtonSize.large),
                                    //       DigitButton(
                                    //           label: localizations.translate(
                                    //             i18.common.coreCommonCancel,
                                    //           ),
                                    //           onPressed: () => Navigator.of(
                                    //                 context,
                                    //                 rootNavigator: true,
                                    //               ).pop(false),
                                    //           type: DigitButtonType.secondary,
                                    //           size: DigitButtonSize.large)
                                    //     ],
                                    //   ),
                                    // );

                                    // if (submit ?? false) {
                                    //   if (context.mounted) {
                                    //     bloc.add(
                                    //       BeneficiaryRegistrationCreateEvent(
                                    //           projectId: projectId,
                                    //           userUuid: userId,
                                    //           boundary:
                                    //               RegistrationDeliverySingleton()
                                    //                   .boundary!,
                                    //           tag: projectBeneficiaryModel?.tag,
                                    //           navigateToSummary: false),
                                    //     );
                                    //     router.popUntil((route) =>
                                    //         route.settings.name ==
                                    //         SearchBeneficiaryRoute.name);
                                    //     context
                                    //         .read<SearchBlocWrapper>()
                                    //         .searchHouseholdsBloc
                                    //         .add(
                                    //           SearchHouseholdsEvent
                                    //               .searchByHousehold(
                                    //             householdModel: householdModel!,
                                    //             projectId:
                                    //                 RegistrationDeliverySingleton()
                                    //                     .projectId!,
                                    //             isProximityEnabled: false,
                                    //           ),
                                    //         );
                                    //     router.push(
                                    //         CustomBeneficiaryAcknowledgementRoute(
                                    //       enableViewHousehold: true,
                                    //       beneficiaryId:
                                    //           beneficiaryId?.first ?? "",
                                    //     ));
                                    //   }
                                    // }
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
                                                  lastModifiedTime: context
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
                                  }
                                },
                                addMember: (
                                  addressModel,
                                  householdModel,
                                  loading,
                                ) {
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
                            i18.individualDetails.individualsDetailsLabelText,
                          ),
                          style: textTheme.headingXl.copyWith(
                              color: theme.colorTheme.primary.primary2),
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
                                        '${i18.individualDetails.nameLabelText}_IS_REQUIRED',
                                      ),
                                  'maxLength': (object) => localizations
                                      .translate(i18.common.maxCharsRequired)
                                      .replaceAll('{}', maxLength.toString()),
                                },
                                builder: (field) => LabeledField(
                                  label: localizations.translate(
                                    i18.individualDetails.nameLabelText,
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
                                        i18.individualDetails.checkboxLabelText,
                                      ),
                                value: widget.isHeadOfHousehold,
                                readOnly: widget.isHeadOfHousehold,
                                onChanged: (_) {},
                              ),
                            ),
                          ],
                        ),

                        // ReactiveWrapperField(
                        //   formControlName: _idTypeKey,
                        //   validationMessages: {
                        //     'required': (_) => localizations.translate(
                        //           i18.common.corecommonRequired,
                        //         ),
                        //   },
                        //   builder: (field) => LabeledField(
                        //     label: localizations.translate(
                        //       i18.individualDetails.idTypeLabelText,
                        //     ),
                        //     capitalizedFirstLetter: false,
                        //     isRequired: true,
                        //     child: DigitDropdown<String>(
                        //       selectedOption:
                        //           (form.control(_idTypeKey).value != null)
                        //               ? DropdownItem(
                        //                   name: localizations.translate(
                        //                       form.control(_idTypeKey).value),
                        //                   code: form.control(_idTypeKey).value)
                        //               : const DropdownItem(name: '', code: ''),
                        //       items: RegistrationDeliverySingleton()
                        //           .idTypeOptions!
                        //           .map(
                        //             (e) => DropdownItem(
                        //                 name: localizations.translate(e),
                        //                 code: e),
                        //           )
                        //           .toList(),
                        //       onSelect: (value) {
                        //         form.control(_idTypeKey).value = value.code;
                        //         setState(() {
                        //           if (value.code == 'DEFAULT') {
                        //             form.control(_idNumberKey).value =
                        //                 IdGen.i.identifier.toString();
                        //           } else {
                        //             form.control(_idNumberKey).value = null;
                        //           }
                        //         });
                        //       },
                        //       emptyItemText: localizations
                        //           .translate(i18.common.noMatchFound),
                        //       errorMessage: form.control(_idTypeKey).hasErrors
                        //           ? localizations.translate(
                        //               i18.common.corecommonRequired,
                        //             )
                        //           : null,
                        //     ),
                        //   ),
                        // ),

                        individualDetailsShowcaseData.dateOfBirth.buildWith(
                          child: DigitDobPicker(
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
                            monthsHintLabel: localizations.translate(
                              i18.individualDetails.monthsHintText,
                            ),
                            separatorLabel: localizations.translate(
                              i18.individualDetails.separatorLabelText,
                            ),
                            yearsAndMonthsErrMsg: localizations.translate(
                              i18.individualDetails.yearsAndMonthsErrorText,
                            ),
                            errorMessage: form.control(_dobKey).hasErrors
                                ? localizations
                                    .translate(i18.common.corecommonRequired)
                                : null,
                            initialDate: before150Years,
                            initialValue: getInitialDateValue(form),
                            onChangeOfFormControl: (value) {
                              setState(() {
                                if (value == null) {
                                  form.control(_dobKey).setErrors({'': true});
                                } else {
                                  DigitDOBAgeConvertor age =
                                      DigitDateUtils.calculateAge(value);
                                  if ((age.years == 0 && age.months == 0) ||
                                      (age.months > 11) ||
                                      (age.years >= 150 && age.months >= 0)) {
                                    form.control(_dobKey).setErrors({'': true});
                                  } else {
                                    form.control(_dobKey).value = value;
                                    form.control(_dobKey).removeError('');
                                  }
                                }
                              });
                              // Handle changes to the control's value here
                            },
                            cancelText: localizations
                                .translate(i18.common.coreCommonCancel),
                            confirmText: localizations
                                .translate(i18.common.coreCommonOk),
                          ),
                        ),
                        SelectionCard<String>(
                          isRequired: true,
                          showParentContainer: true,
                          title: localizations.translate(
                            i18.individualDetails.genderLabelText,
                          ),
                          allowMultipleSelection: false,
                          width: 126,
                          initialSelection:
                              form.control(_genderKey).value != null
                                  ? [form.control(_genderKey).value]
                                  : [],
                          options: RegistrationDeliverySingleton()
                              .genderOptions!
                              .map(
                                (e) => e,
                              )
                              .toList(),
                          onSelectionChanged: (value) {
                            setState(() {
                              if (value.isNotEmpty) {
                                form.control(_genderKey).value = value.first;
                              } else {
                                form.control(_genderKey).value = null;
                                setState(() {
                                  form
                                      .control(_genderKey)
                                      .setErrors({'': true});
                                });
                              }
                            });
                          },
                          valueMapper: (value) {
                            return localizations.translate(value);
                          },
                          errorMessage: form.control(_genderKey).hasErrors
                              ? localizations
                                  .translate(i18.common.corecommonRequired)
                              : null,
                        ),
                        individualDetailsShowcaseData.mobile.buildWith(
                          child: Offstage(
                            offstage: !widget.isHeadOfHousehold,
                            child: ReactiveWrapperField(
                              formControlName: _mobileNumberKey,
                              validationMessages: {
                                'maxLength': (object) => localizations.translate(
                                    i18.individualDetails
                                        .mobileNumberLengthValidationMessage),
                                'minLength': (object) => localizations.translate(
                                    i18.individualDetails
                                        .mobileNumberLengthValidationMessage),
                              },
                              builder: (field) => LabeledField(
                                label: localizations.translate(
                                  i18.individualDetails.mobileNumberLabelText,
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
                                    form.control(_mobileNumberKey).value = value;
                                  },
                                  errorMessage: field.errorText,
                                ),
                              ),
                            ),
                          ),
                        ),
                        // const SizedBox(height: spacer4),
                        // if ((RegistrationDeliverySingleton().beneficiaryType ==
                        //             BeneficiaryType.household &&
                        //         widget.isHeadOfHousehold) ||
                        //     (RegistrationDeliverySingleton().beneficiaryType ==
                        //         BeneficiaryType.individual))
                        // BlocBuilder<DigitScannerBloc, DigitScannerState>(
                        //   buildWhen: (p, c) {
                        //     return true;
                        //   },
                        //   builder: (context, state) => state
                        //           .qrCodes.isNotEmpty
                        //       ? Row(
                        //           mainAxisAlignment:
                        //               MainAxisAlignment.spaceBetween,
                        //           children: [
                        //             SizedBox(
                        //               width:
                        //                   MediaQuery.of(context).size.width /
                        //                       3,
                        //               child: Text(
                        //                 localizations.translate(
                        //                   i18.deliverIntervention.voucherCode,
                        //                 ),
                        //                 style: textTheme.headingS,
                        //               ),
                        //             ),
                        //             Flexible(
                        //               child: Text(
                        //                 overflow: TextOverflow.ellipsis,
                        //                 localizations
                        //                     .translate(state.qrCodes.last),
                        //               ),
                        //             ),
                        //             Padding(
                        //               padding: const EdgeInsets.only(
                        //                 bottom: spacer2 * 2,
                        //               ),
                        //               child: IconButton(
                        //                 color:
                        //                     theme.colorTheme.primary.primary1,
                        //                 icon: const Icon(Icons.edit),
                        //                 onPressed: () {
                        //                   Navigator.of(context).push(
                        //                     //[TODO: Add the route to auto_route]
                        //                     MaterialPageRoute(
                        //                       builder: (context) =>
                        //                           const DigitScannerPage(
                        //                         quantity: 1,
                        //                         isGS1code: false,
                        //                         singleValue: true,
                        //                         isEditEnabled: true,
                        //                       ),
                        //                       settings: const RouteSettings(
                        //                           name: '/qr-scanner'),
                        //                     ),
                        //                   );
                        //                 },
                        //               ),
                        //             ),
                        //           ],

                        //           // ignore: no-empty-block
                        //         )
                        //       : DigitButton(
                        //           type: DigitButtonType.secondary,
                        //           size: DigitButtonSize.large,
                        //           mainAxisSize: MainAxisSize.max,
                        //           onPressed: () {
                        //             Navigator.of(context).push(
                        //               // [TODO: Add the route to auto_route]
                        //               MaterialPageRoute(
                        //                 builder: (context) =>
                        //                     const DigitScannerPage(
                        //                   quantity: 1,
                        //                   isGS1code: false,
                        //                   singleValue: true,
                        //                 ),
                        //                 settings: const RouteSettings(
                        //                     name: '/qr-scanner'),
                        //               ),
                        //             );
                        //           },
                        //           prefixIcon: Icons.qr_code,
                        //           label: localizations.translate(
                        //             i18.individualDetails
                        //                 .linkVoucherToIndividual,
                        //           ),
                        //         ),
                        // ),
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
        createdTime: context.millisecondsSinceEpoch(),
        lastModifiedBy: RegistrationDeliverySingleton().loggedInUserUuid,
        lastModifiedTime: context.millisecondsSinceEpoch(),
      ),
      clientAuditDetails: ClientAuditDetails(
        createdBy: RegistrationDeliverySingleton().loggedInUserUuid!,
        createdTime: context.millisecondsSinceEpoch(),
        lastModifiedBy: RegistrationDeliverySingleton().loggedInUserUuid,
        lastModifiedTime: context.millisecondsSinceEpoch(),
      ),
    );

    var name = individual.name;
    name ??= NameModel(
      individualClientReferenceId: individual.clientReferenceId,
      tenantId: RegistrationDeliverySingleton().tenantId,
      rowVersion: 1,
      auditDetails: AuditDetails(
        createdBy: RegistrationDeliverySingleton().loggedInUserUuid!,
        createdTime: context.millisecondsSinceEpoch(),
        lastModifiedBy: RegistrationDeliverySingleton().loggedInUserUuid,
        lastModifiedTime: context.millisecondsSinceEpoch(),
      ),
      clientAuditDetails: ClientAuditDetails(
        createdBy: RegistrationDeliverySingleton().loggedInUserUuid!,
        createdTime: context.millisecondsSinceEpoch(),
        lastModifiedBy: RegistrationDeliverySingleton().loggedInUserUuid,
        lastModifiedTime: context.millisecondsSinceEpoch(),
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
        createdTime: context.millisecondsSinceEpoch(),
        lastModifiedBy: RegistrationDeliverySingleton().loggedInUserUuid,
        lastModifiedTime: context.millisecondsSinceEpoch(),
      ),
      clientAuditDetails: ClientAuditDetails(
        createdBy: RegistrationDeliverySingleton().loggedInUserUuid!,
        createdTime: context.millisecondsSinceEpoch(),
        lastModifiedBy: RegistrationDeliverySingleton().loggedInUserUuid,
        lastModifiedTime: context.millisecondsSinceEpoch(),
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
        Validators.pattern(Constants.mobileNumberRegExp,
            validationMessage:
                localizations.translate(i18.common.coreCommonMobileNumber)),
        Validators.maxLength(10)
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
