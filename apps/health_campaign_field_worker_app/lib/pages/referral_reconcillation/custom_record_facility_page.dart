import 'package:auto_route/auto_route.dart';
import 'package:digit_data_model/data_model.dart';
import 'package:digit_ui_components/digit_components.dart';
import 'package:digit_ui_components/theme/digit_extended_theme.dart';
import 'package:digit_ui_components/widgets/molecules/digit_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_campaign_field_worker_app/widgets/custom_back_navigation.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:referral_reconciliation/models/entities/referral_recon_enums.dart';
// import 'package:referral_reconciliation/router/referral_reconciliation_router.gm.dart';
import 'package:referral_reconciliation/utils/constants.dart';

import 'package:referral_reconciliation/utils/date_utils.dart';
import 'package:referral_reconciliation/utils/i18_key_constants.dart' as i18;
import '../../utils/constants.dart';
import '../../utils/i18_key_constants.dart' as i18_local;
import 'package:referral_reconciliation/blocs/referral_recon_record.dart';
import 'package:referral_reconciliation/utils/utils.dart';
import 'package:referral_reconciliation/widgets/back_navigation_help_header.dart';
import 'package:referral_reconciliation/widgets/localized.dart';
import '../referral_reconcillation/custom_referral_facility_selection_page.dart';
import 'package:health_campaign_field_worker_app/router/app_router.dart';

@RoutePage()
class CustomReferralFacilityPage extends LocalizedStatefulWidget {
  final bool isEditing;

  const CustomReferralFacilityPage(
      {super.key, super.appLocalizations, this.isEditing = false});

  @override
  State<CustomReferralFacilityPage> createState() =>
      _CustomReferralFacilityPageState();
}

class _CustomReferralFacilityPageState
    extends LocalizedState<CustomReferralFacilityPage> {
  static const _dateOfEvaluationKey = 'dateOfEvaluation';
  static const _administrativeUnitKey = 'administrativeUnit';
  static const _hfCoordinatorKey = 'healthFacilityCoordinatorKey';
  static const _evaluationFacilityKey = 'evaluationFacility';
  static const _referredByKey = 'referredBy';
  final clickedStatus = ValueNotifier<bool>(false);
  String? selectedProjectFacilityId;

  @override
  void dispose() {
    clickedStatus.dispose();
    super.dispose();
  }

  @override
  void initState() {
    final referralState = context.read<RecordHFReferralBloc>().state;
    setState(() {
      selectedProjectFacilityId = referralState.mapOrNull(
        create: (value) =>
            value.viewOnly ? value.hfReferralModel?.projectFacilityId : null,
      );
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.digitTextTheme(context);
    // final router = context.router;

    return BlocBuilder<FacilityBloc, FacilityState>(
        builder: (context, facilityState) {
      return facilityState.maybeWhen(
          orElse: () => const SizedBox.shrink(),
          fetched: (mappedFacilities, allFacilities) {
            List<FacilityModel> healthfacilities = mappedFacilities
                .where((e) => e.usage == Constants.healthFacility)
                .toList();
            FacilityModel mappedFacility = healthfacilities.isNotEmpty
                ? healthfacilities.first
                : mappedFacilities.first;
            return BlocConsumer<ProjectFacilityBloc, ProjectFacilityState>(
              listener: (context, state) {
                state.whenOrNull(
                  empty: () => false,
                );
              },
              builder: (ctx, facilityState) {
                return facilityState.maybeWhen(
                  orElse: () => const SizedBox.shrink(),
                  fetched: (facilities) {
                    final projectFacilities = facilities
                        .where((e) => e.id != 'N/A' && e.id != 'Delivery Team')
                        .toList();
                    selectedProjectFacilityId = facilities
                        .where((e) => e.facilityId == mappedFacility.id)
                        .first
                        .id
                        .toString();

                    return facilities.isNotEmpty
                        ? Scaffold(
                            body: BlocBuilder<RecordHFReferralBloc,
                                RecordHFReferralState>(
                              builder: (context, recordState) {
                                final bool viewOnly = recordState.mapOrNull(
                                      create: (value) => value.viewOnly,
                                    ) ??
                                    false;

                                return ReactiveFormBuilder(
                                  form: () => buildForm(recordState,
                                      projectFacilities, mappedFacility),
                                  builder: (context, form, child) =>
                                      ScrollableContent(
                                    enableFixedDigitButton: true,
                                    header: const Column(children: [
                                      CustomBackNavigationHelpHeaderWidget(
                                        showHelp: false,
                                      ),
                                    ]),
                                    footer: DigitCard(
                                        margin: EdgeInsets.fromLTRB(
                                            0, theme.spacerTheme.spacer2, 0, 0),
                                        cardType: CardType.primary,
                                        children: [
                                          ValueListenableBuilder(
                                            valueListenable: clickedStatus,
                                            builder:
                                                (context, bool isClicked, _) {
                                              return DigitButton(
                                                size: DigitButtonSize.large,
                                                label: localizations.translate(
                                                  i18.common.coreCommonNext,
                                                ),
                                                onPressed: () {
                                                  orElse:
                                                  () => const SizedBox.shrink();
                                                  form.markAllAsTouched();
                                                  if (!form.valid) {
                                                    return;
                                                  } else {
                                                    clickedStatus.value = true;
                                                    if (viewOnly) {
                                                      context.router.push(
                                                        CustomRecordReferralDetailsRoute(
                                                          projectId:
                                                              ReferralReconSingleton()
                                                                  .projectId,
                                                          cycles:
                                                              ReferralReconSingleton()
                                                                  .cycles,
                                                        ),
                                                      );
                                                    } else {
                                                      final evaluationFacility =
                                                          selectedProjectFacilityId;
                                                      if (evaluationFacility ==
                                                          null) {
                                                        Toast.showToast(
                                                          context,
                                                          message: localizations
                                                              .translate(i18
                                                                  .referralReconciliation
                                                                  .facilityIsMandatory),
                                                          type: ToastType.error,
                                                        );
                                                      } else {
                                                        final dateOfEvaluation = form
                                                            .control(
                                                                _dateOfEvaluationKey)
                                                            .value as DateTime;
                                                        final hfCoordinator = form
                                                            .control(
                                                                _hfCoordinatorKey)
                                                            .value as String?;
                                                        final referredByTeam = form
                                                            .control(
                                                                _referredByKey)
                                                            .value as String?;

                                                        final event = context.read<
                                                            RecordHFReferralBloc>();
                                                        event.add(
                                                          RecordHFReferralSaveFacilityDetailsEvent(
                                                            dateOfEvaluation:
                                                                dateOfEvaluation,
                                                            facilityId:
                                                                evaluationFacility
                                                                    .toString(),
                                                            healthFacilityCord:
                                                                hfCoordinator,
                                                            referredBy:
                                                                referredByTeam,
                                                          ),
                                                        );

                                                        context.router.push(
                                                            CustomRecordReferralDetailsRoute(
                                                          projectId:
                                                              ReferralReconSingleton()
                                                                  .projectId,
                                                          cycles:
                                                              ReferralReconSingleton()
                                                                  .cycles,
                                                        ));
                                                      }
                                                    }
                                                  }
                                                },
                                                type: DigitButtonType.primary,
                                                mainAxisSize: MainAxisSize.max,
                                              );
                                            },
                                          ),
                                        ]),
                                    slivers: [
                                      SliverToBoxAdapter(
                                        child: DigitCard(
                                            cardType: CardType.primary,
                                            margin:
                                                const EdgeInsets.all(spacer2),
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      localizations.translate(
                                                        i18.referralReconciliation
                                                            .facilityDetails,
                                                      ),
                                                      style:
                                                          textTheme.headingXl,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              ReactiveWrapperField<String>(
                                                  formControlName:
                                                      _administrativeUnitKey,
                                                  builder: (field) {
                                                    return LabeledField(
                                                      isRequired: true,
                                                      label: localizations
                                                          .translate(
                                                        i18_local
                                                            .referBeneficiary
                                                            .administrationUnitFormLabel,
                                                      ),
                                                      child: DigitTextFormInput(
                                                        readOnly: true,
                                                        initialValue:
                                                            field.value,
                                                      ),
                                                    );
                                                  }),
                                              ReactiveWrapperField(
                                                  formControlName:
                                                      _dateOfEvaluationKey,
                                                  validationMessages: {
                                                    'required': (_) =>
                                                        localizations.translate(
                                                          i18.common
                                                              .corecommonRequired,
                                                        ),
                                                  },
                                                  showErrors: (control) =>
                                                      control.invalid &&
                                                      control
                                                          .touched, // Ensures error is shown if invalid and touched
                                                  builder: (field) {
                                                    return LabeledField(
                                                      isRequired: true,
                                                      label: localizations
                                                          .translate(
                                                        i18.referralReconciliation
                                                            .dateOfEvaluationLabel,
                                                      ),
                                                      child: DigitDateFormInput(
                                                        onChange: (val) => {
                                                          form
                                                              .control(
                                                                  _dateOfEvaluationKey)
                                                              .markAsTouched(),
                                                          form
                                                                  .control(
                                                                      _dateOfEvaluationKey)
                                                                  .value =
                                                              DigitDateUtils
                                                                  .getFormattedDateToDateTime(
                                                                      val),
                                                        },
                                                        readOnly: true,
                                                        errorMessage:
                                                            field.errorText,
                                                        initialValue: DigitDateUtils
                                                            .getDateString(form
                                                                .control(
                                                                    _dateOfEvaluationKey)
                                                                .value),
                                                        lastDate:
                                                            DateTime.now(),
                                                        cancelText:
                                                            localizations
                                                                .translate(
                                                          i18.common
                                                              .coreCommonCancel,
                                                        ),
                                                        confirmText:
                                                            localizations
                                                                .translate(
                                                          i18.common
                                                              .coreCommonOk,
                                                        ),
                                                      ),
                                                    );
                                                  }),
                                              InkWell(
                                                child: IgnorePointer(
                                                  child: ReactiveWrapperField<
                                                          String>(
                                                      validationMessages: {
                                                        'required': (_) =>
                                                            localizations
                                                                .translate(
                                                              i18.referralReconciliation
                                                                  .facilityValidationMessage,
                                                            ),
                                                      },
                                                      formControlName:
                                                          _evaluationFacilityKey,
                                                      showErrors: (control) =>
                                                          control.invalid &&
                                                          control
                                                              .touched, // Ensures error is shown if invalid and touched
                                                      builder: (field) {
                                                        return LabeledField(
                                                          isRequired: true,
                                                          label: localizations
                                                              .translate(
                                                            i18.referralReconciliation
                                                                .evaluationFacilityLabel,
                                                          ),
                                                          child:
                                                              DigitTextFormInput(
                                                            onChange: (val) => {
                                                              form
                                                                  .control(
                                                                      _evaluationFacilityKey)
                                                                  .markAsTouched(),
                                                              form
                                                                  .control(
                                                                      _evaluationFacilityKey)
                                                                  .value = val,
                                                            },
                                                            readOnly: true,
                                                            errorMessage:
                                                                field.errorText,
                                                            initialValue: form
                                                                .control(
                                                                    _evaluationFacilityKey)
                                                                .value,
                                                          ),
                                                        );
                                                      }),
                                                ),
                                              ),
                                              ReactiveWrapperField<String>(
                                                  formControlName:
                                                      _hfCoordinatorKey,
                                                  builder: (field) {
                                                    return LabeledField(
                                                        label: localizations
                                                            .translate(
                                                          i18.referralReconciliation
                                                              .healthFacilityCoordinatorLabel,
                                                        ),
                                                        child:
                                                            DigitTextFormInput(
                                                          onChange: (val) => {
                                                            form
                                                                .control(
                                                                    _hfCoordinatorKey)
                                                                .markAsTouched(),
                                                            form
                                                                .control(
                                                                    _hfCoordinatorKey)
                                                                .value = val,
                                                          },
                                                          readOnly: true,
                                                          initialValue: form
                                                              .control(
                                                                  _hfCoordinatorKey)
                                                              .value,
                                                        ));
                                                  }),
                                              ReactiveWrapperField<String>(
                                                  formControlName:
                                                      _referredByKey,
                                                  validationMessages: {
                                                    'noEmojis': (_) => 
                                                        'Team code cannot contain emoji characters',
                                                    'repeatedChars': (_) => 
                                                        'Team code cannot contain excessive repetition of characters',
                                                  },
                                                  builder: (field) {
                                                    return LabeledField(
                                                        label:  
                                                        localizations
                                                            .translate(
                                                          i18.referralReconciliation
                                                              .referredByTeamCodeLabel,
                                                        ),
                                                        child:
                                                            DigitTextFormInput(
                                                          onChange: (val) => {
                                                            form
                                                                .control(
                                                                    _referredByKey)
                                                                .markAsTouched(),
                                                            form
                                                                .control(
                                                                    _referredByKey)
                                                                .value = val,
                                                          },
                                                          readOnly: viewOnly,
                                                          errorMessage: field.errorText,
                                                          initialValue: form
                                                              .control(
                                                                  _referredByKey)
                                                              .value,
                                                          inputFormatters: viewOnly ? null : [
                                                            // Allow only letters, numbers, and specific special characters
                                                            FilteringTextInputFormatter.allow(
                                                              RegExp(r'[a-zA-Z0-9\-_/#:.,() ]'),
                                                            ),
                                                            // Prevent excessive repetition of characters
                                                            TextInputFormatter.withFunction(
                                                              (oldValue, newValue) {
                                                                final text = newValue.text;
                                                                // Check for repetitions of special characters
                                                                for (final specialChar in ['-', '.', ',', ')', '(', '/', '#', ':', '_']) {
                                                                  if (text.contains('$specialChar$specialChar$specialChar')) {
                                                                    return oldValue;
                                                                  }
                                                                }
                                                                
                                                                // Check for any character repeated excessively (4+ times)
                                                                final repeatedCharsPattern = RegExp(r'(.)\1{3,}');
                                                                if (repeatedCharsPattern.hasMatch(text)) {
                                                                  return oldValue;
                                                                }
                                                                
                                                                return newValue;
                                                              },
                                                            ),
                                                          ],
                                                        ));
                                                  }),
                                            ]),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          )
                        : Center(
                            child: Text(
                              localizations.translate(
                                i18.referralReconciliation.noFacilitiesAssigned,
                              ),
                            ),
                          );
                  },
                  loading: () => const Center(
                    child: CircularProgressIndicator(),
                  ),
                  empty: () => Center(
                    child: Text(
                      localizations.translate(
                        i18.referralReconciliation.noFacilitiesAssigned,
                      ),
                    ),
                  ),
                );
              },
            );
          });
    });
  }

  FormGroup buildForm(
    RecordHFReferralState referralState,
    List<ProjectFacilityModel> facilities,
    FacilityModel mappedFacility,
  ) {
    final dateOfEvaluation = referralState.mapOrNull(
      create: (value) => value.viewOnly &&
              value.hfReferralModel?.additionalFields?.fields
                      .where((e) =>
                          e.key ==
                          ReferralReconEnums.dateOfEvaluation.toValue())
                      .firstOrNull
                      ?.value !=
                  null
          ? DigitDateUtils.getFormattedDateToDateTime(
              DigitDateUtils.getDateFromTimestamp(
                int.tryParse(value.hfReferralModel?.additionalFields?.fields
                            .where((e) =>
                                e.key ==
                                ReferralReconEnums.dateOfEvaluation.toValue())
                            .firstOrNull
                            ?.value
                            .toString() ??
                        '') ??
                    DateTime.now().millisecondsSinceEpoch,
                dateFormat: defaultDateFormat,
              ),
            )
          : DateTime.now(),
    );

    return fb.group(<String, Object>{
      _dateOfEvaluationKey: FormControl<DateTime>(
        value: dateOfEvaluation,
        validators: [Validators.max(DateTime.now()), Validators.required],
      ),
      _administrativeUnitKey: FormControl<String>(
        value: localizations.translate(
            (ReferralReconSingleton().boundary?.code ?? '').toString()),
        validators: [
          Validators.required,
        ],
      ),
      _hfCoordinatorKey: FormControl<String>(
        value: referralState.mapOrNull(
          create: (value) => value.viewOnly &&
                  value.hfReferralModel?.additionalFields?.fields
                          .where((e) =>
                              e.key ==
                              ReferralReconEnums.hFCoordinator.toValue())
                          .firstOrNull
                          ?.value !=
                      null
              ? value.hfReferralModel?.additionalFields?.fields
                  .where((e) =>
                      e.key == ReferralReconEnums.hFCoordinator.toValue())
                  .firstOrNull
                  ?.value
                  .toString()
              : ReferralReconSingleton().userName,
        ),
      ),
      _evaluationFacilityKey: FormControl<String>(
        value: referralState.mapOrNull(
          create: (value) => value.viewOnly
              ? localizations.translate(
                  'FAC_${facilities.where(
                        (e) => e.id == value.hfReferralModel?.projectFacilityId,
                      ).first.facilityId}',
                )
              : localizations.translate(
                  'FAC_${facilities.where((e) => e.boundaryCode ==
                   ReferralReconSingleton().boundary?.boundaryCode).first.facilityId}',
                ),
        ),
        validators: [Validators.required],
      ),
      _referredByKey: FormControl<String>(
        value: referralState.mapOrNull(
          create: (value) => value.viewOnly &&
                  value.hfReferralModel?.additionalFields?.fields
                          .where((e) =>
                              e.key == ReferralReconEnums.referredBy.toValue())
                          .firstOrNull
                          ?.value !=
                      null
              ? value.hfReferralModel?.additionalFields?.fields
                  .where(
                      (e) => e.key == ReferralReconEnums.referredBy.toValue())
                  .firstOrNull
                  ?.value
                  .toString()
              : null,
        ),
        validators: [
          // Add validation to allow alphanumeric and specific special characters but block emojis
          Validators.delegate((control) {
            final value = control.value?.toString();
            if (value == null || value.isEmpty) return null;

            // Check for emoji characters
            final emojiRegex = RegExp(
                r'(\p{Emoji_Presentation}|\p{Extended_Pictographic}|\u00a9|\u00ae|[\u2000-\u3300]|\ud83c[\ud000-\udfff]|\ud83d[\ud000-\udfff]|\ud83e[\ud000-\udfff])', 
                unicode: true);
            if (emojiRegex.hasMatch(value)) {
              return {'noEmojis': true};
            }
            
            // Check for excessive repetition of specific special characters
            for (final specialChar in ['-', '.', ',', ')', '(', '/', '#', ':', '_']) {
              if (value.contains('$specialChar$specialChar$specialChar')) {
                return {'repeatedChars': true};
              }
            }
            
            // Additional check for any character repeated more than 3 times
            final repeatedCharsPattern = RegExp(r'(.)\1{3,}');
            if (repeatedCharsPattern.hasMatch(value)) {
              return {'repeatedChars': true};
            }
            
            return null;
          }),
        ],
      ),
    });
  }
}
