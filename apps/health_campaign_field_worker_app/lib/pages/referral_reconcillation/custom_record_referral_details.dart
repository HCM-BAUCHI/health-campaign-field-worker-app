import 'package:auto_route/auto_route.dart';
import 'package:digit_data_model/data/local_store/sql_store/tables/package_tables/referral.dart';
import 'package:digit_data_model/data_model.dart';
import 'package:digit_ui_components/digit_components.dart';
import 'package:digit_ui_components/models/RadioButtonModel.dart';
import 'package:digit_ui_components/theme/digit_extended_theme.dart';
import 'package:digit_ui_components/widgets/atoms/dropdown_wrapper.dart';
import 'package:digit_ui_components/widgets/molecules/digit_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_campaign_field_worker_app/widgets/custom_back_navigation.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:referral_reconciliation/models/entities/referral_recon_enums.dart';
import 'package:referral_reconciliation/router/referral_reconciliation_router.gm.dart';
import 'package:referral_reconciliation/utils/extensions/extensions.dart';
import 'package:survey_form/survey_form.dart';

import 'package:referral_reconciliation/utils/i18_key_constants.dart' as i18;
import '../../utils/i18_key_constants.dart' as i18_local;
import 'package:referral_reconciliation/blocs/referral_recon_record.dart';
import 'package:referral_reconciliation/blocs/referral_recon_service_definition.dart';
import 'package:referral_reconciliation/models/entities/hf_referral.dart';
import 'package:referral_reconciliation/utils/utils.dart';
import 'package:referral_reconciliation/widgets/localized.dart';
import '../../router/app_router.dart';
import '../../widgets/registration_delivery/custom_labeled_field.dart';

@RoutePage()
class CustomRecordReferralDetailsPage extends LocalizedStatefulWidget {
  final bool isEditing;
  final String projectId;
  final List<String> cycles;

  const CustomRecordReferralDetailsPage({
    super.key,
    super.appLocalizations,
    this.isEditing = false,
    required this.projectId,
    required this.cycles,
  });

  @override
  State<CustomRecordReferralDetailsPage> createState() =>
      _CustomRecordReferralDetailsPageState();
}

class _CustomRecordReferralDetailsPageState
    extends LocalizedState<CustomRecordReferralDetailsPage> {
  static const _nameOfChildKey = 'nameOfChild';
  static const _evaluationFacilityKey = 'evaluationFacility';
  static const _referralReason = 'referralReason';
  static const _referredByKey = 'referredBy';
  static const _genderKey = 'gender';
  static const _cycleKey = 'cycle';
  static const _beneficiaryIdKey = 'beneficiaryId';
  static const _referralCodeKey = 'referralCode';
  static const _ageKey = 'ageInMonths';
  String selectedReasonIndex = '';
  final clickedStatus = ValueNotifier<bool>(false);

  @override
  void dispose() {
    clickedStatus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.digitTextTheme(context);

    return BlocBuilder<ReferralReconServiceDefinitionBloc,
        ReferralReconServiceDefinitionState>(
      builder: (context, state) {
        return state.map(
          empty: (value) => const Text('No Checklist'),
          isloading: (value) => const Center(
            child: CircularProgressIndicator(),
          ),
          serviceDefinitionFetch:
              (ReferralReconServiceDefinitionServiceFetchedState value) {
            return Scaffold(
              body: BlocBuilder<RecordHFReferralBloc, RecordHFReferralState>(
                builder: (context, recordState) {
                  final bool viewOnly = recordState.mapOrNull(
                        create: (value) => value.viewOnly,
                      ) ??
                      false;

                  return ReactiveFormBuilder(
                    form: () => buildForm(recordState),
                    builder: (context, form, child) {
                      form.control(_referralReason).value =
                          recordState.mapOrNull(
                        create: (value) => value.viewOnly
                            ? ReferralReconSingleton()
                                .referralReasons
                                .where(
                                    (e) => e == value.hfReferralModel?.symptom)
                                .first
                            : null,
                      );
                      return ScrollableContent(
                        enableFixedDigitButton: true,
                        header: const Column(children: [
                          CustomBackNavigationHelpHeaderWidget(
                            showHelp: false,
                          ),
                        ]),
                        footer: BlocBuilder<ServiceBloc, ServiceState>(
                          builder: (context, serviceState) {
                            return serviceState.maybeWhen(
                              orElse: () => DigitCard(
                                  padding:
                                      EdgeInsets.all(theme.spacerTheme.spacer2),
                                  cardType: CardType.primary,
                                  children: [
                                    ValueListenableBuilder(
                                      valueListenable: clickedStatus,
                                      builder: (context, bool isClicked, _) {
                                        return DigitButton(
                                          size: DigitButtonSize.large,
                                          type: DigitButtonType.primary,
                                          mainAxisSize: MainAxisSize.max,
                                          label: localizations
                                              .translate(recordState.mapOrNull(
                                                    create: (value) => value
                                                            .viewOnly
                                                        ? i18.common
                                                            .coreCommonNext
                                                        : i18.common
                                                            .coreCommonSubmit,
                                                  ) ??
                                                  i18.common.coreCommonSubmit),
                                          onPressed: isClicked
                                              ? () {}
                                              : () {
                                                  if (form
                                                          .control(_cycleKey)
                                                          .value ==
                                                      null) {
                                                    clickedStatus.value = false;
                                                    form
                                                        .control(_cycleKey)
                                                        .setErrors({'': true});
                                                  } else if (form
                                                          .control(_genderKey)
                                                          .value ==
                                                      null) {
                                                    clickedStatus.value = false;
                                                    form
                                                        .control(_genderKey)
                                                        .setErrors({'': true});
                                                  } else if (form
                                                          .control(
                                                              _referralReason)
                                                          .value ==
                                                      null) {
                                                    clickedStatus.value = false;
                                                    form
                                                        .control(
                                                            _referralReason)
                                                        .setErrors({'': true});
                                                  } else if (form
                                                          .control(
                                                              _beneficiaryIdKey)
                                                          .value ==
                                                      null) {
                                                    clickedStatus.value = false;
                                                    form
                                                        .control(
                                                            _beneficiaryIdKey)
                                                        .setErrors({'': true});
                                                  }

                                                  form.markAllAsTouched();

                                                  if (viewOnly) {
                                                    final symptom = form
                                                        .control(
                                                            _referralReason)
                                                        .value as String;
                                                    context
                                                        .read<
                                                            ReferralReconServiceDefinitionBloc>()
                                                        .add(
                                                          ReferralReconServiceDefinitionSelectionEvent(
                                                            serviceDefinitionCode:
                                                                symptom,
                                                          ),
                                                        );
                                                    context
                                                        .read<ServiceBloc>()
                                                        .add(
                                                          ServiceSearchEvent(
                                                            serviceSearchModel:
                                                                ServiceSearchModel(
                                                              relatedClientReferenceId:
                                                                  recordState
                                                                      .mapOrNull(
                                                                create: (value) => value
                                                                        .viewOnly
                                                                    ? value
                                                                        .hfReferralModel
                                                                        ?.clientReferenceId
                                                                    : null,
                                                              ),
                                                            ),
                                                          ),
                                                        );
                                                    context.router.push(
                                                      CustomReferralReasonChecklistPreviewRoute(),
                                                    );
                                                  } else if (!form.valid) {
                                                    return;
                                                  } else if (value
                                                      .serviceDefinitionList
                                                      .isEmpty) {
                                                    Toast.showToast(
                                                      context,
                                                      message: localizations
                                                          .translate(i18
                                                              .referralReconciliation
                                                              .noChecklistFound),
                                                      type: ToastType.error,
                                                    );
                                                  } else {
                                                    final hfState = BlocProvider
                                                        .of<RecordHFReferralBloc>(
                                                      context,
                                                    ).state;
                                                    clickedStatus.value = true;
                                                    final nameOfChild = form
                                                        .control(
                                                            _nameOfChildKey)
                                                        .value as String;
                                                    final age = form
                                                        .control(_ageKey)
                                                        .value as int;
                                                    final gender = form
                                                        .control(_genderKey)
                                                        .value as String;
                                                    final cycle = form
                                                        .control(_cycleKey)
                                                        .value as String;
                                                    final beneficiaryId = form
                                                        .control(
                                                            _beneficiaryIdKey)
                                                        .value as String?;
                                                    final referralCode = form
                                                        .control(
                                                            _referralCodeKey)
                                                        .value as String?;
                                                    final symptom = form
                                                        .control(
                                                            _referralReason)
                                                        .value as String;
                                                    final hfCoordinator =
                                                        hfState.mapOrNull(
                                                      create: (val) => val
                                                          .healthFacilityCord,
                                                    );
                                                    final referredBy =
                                                        hfState.mapOrNull(
                                                      create: (val) =>
                                                          val.referredBy,
                                                    );
                                                    final dateOfEvaluation = hfState
                                                        .mapOrNull(
                                                          create: (val) => val
                                                              .dateOfEvaluation,
                                                        )
                                                        ?.millisecondsSinceEpoch;
                                                    final facilityId =
                                                        hfState.mapOrNull(
                                                      create: (val) =>
                                                          val.facilityId,
                                                    );
                                                    final hfClientRefId =
                                                        IdGen.i.identifier;

                                                    final event = context.read<
                                                        RecordHFReferralBloc>();
                                                    event.add(
                                                      RecordHFReferralCreateEntryEvent(
                                                        hfReferralModel:
                                                            HFReferralModel(
                                                          clientReferenceId:
                                                              hfClientRefId,
                                                          projectFacilityId:
                                                              facilityId,
                                                          projectId:
                                                              widget.projectId,
                                                          name: nameOfChild
                                                              .trim(),
                                                          beneficiaryId:
                                                              beneficiaryId,
                                                          referralCode:
                                                              referralCode,
                                                          symptom: symptom,
                                                          tenantId:
                                                              ReferralReconSingleton()
                                                                  .tenantId,
                                                          rowVersion: 1,
                                                          auditDetails:
                                                              AuditDetails(
                                                            createdBy:
                                                                ReferralReconSingleton()
                                                                    .userUUid,
                                                            createdTime: context
                                                                .millisecondsSinceEpoch(),
                                                            lastModifiedBy:
                                                                ReferralReconSingleton()
                                                                    .userUUid,
                                                            lastModifiedTime:
                                                                context
                                                                    .millisecondsSinceEpoch(),
                                                          ),
                                                          clientAuditDetails:
                                                              ClientAuditDetails(
                                                            createdBy:
                                                                ReferralReconSingleton()
                                                                    .userUUid,
                                                            createdTime: context
                                                                .millisecondsSinceEpoch(),
                                                            lastModifiedBy:
                                                                ReferralReconSingleton()
                                                                    .userUUid,
                                                            lastModifiedTime:
                                                                context
                                                                    .millisecondsSinceEpoch(),
                                                          ),
                                                          additionalFields:
                                                              HFReferralAdditionalFields(
                                                            version: 1,
                                                            fields: [
                                                              AdditionalField(
                                                                  "boundaryCode",
                                                                  ReferralReconSingleton()
                                                                      .boundary
                                                                      ?.code),
                                                              if (hfCoordinator !=
                                                                      null &&
                                                                  hfCoordinator
                                                                      .toString()
                                                                      .trim()
                                                                      .isNotEmpty)
                                                                AdditionalField(
                                                                  ReferralReconEnums
                                                                      .hFCoordinator
                                                                      .toValue(),
                                                                  hfCoordinator,
                                                                ),
                                                              if (referredBy !=
                                                                      null &&
                                                                  referredBy
                                                                      .toString()
                                                                      .trim()
                                                                      .isNotEmpty)
                                                                AdditionalField(
                                                                  ReferralReconEnums
                                                                      .referredBy
                                                                      .toValue(),
                                                                  referredBy,
                                                                ),
                                                              if (dateOfEvaluation !=
                                                                      null &&
                                                                  dateOfEvaluation
                                                                      .toString()
                                                                      .trim()
                                                                      .isNotEmpty)
                                                                AdditionalField(
                                                                  ReferralReconEnums
                                                                      .dateOfEvaluation
                                                                      .toValue(),
                                                                  dateOfEvaluation,
                                                                ),
                                                              if (nameOfChild !=
                                                                      null &&
                                                                  nameOfChild
                                                                      .toString()
                                                                      .trim()
                                                                      .isNotEmpty)
                                                                AdditionalField(
                                                                  ReferralReconEnums
                                                                      .nameOfReferral
                                                                      .toValue(),
                                                                  nameOfChild,
                                                                ),
                                                              if (age != null &&
                                                                  age
                                                                      .toString()
                                                                      .trim()
                                                                      .isNotEmpty)
                                                                AdditionalField(
                                                                  ReferralReconEnums
                                                                      .age
                                                                      .toValue(),
                                                                  age,
                                                                ),
                                                              if (gender !=
                                                                      null &&
                                                                  gender
                                                                      .toString()
                                                                      .trim()
                                                                      .isNotEmpty)
                                                                AdditionalField(
                                                                  ReferralReconEnums
                                                                      .gender
                                                                      .toValue(),
                                                                  gender,
                                                                ),
                                                              if (cycle !=
                                                                      null &&
                                                                  cycle
                                                                      .toString()
                                                                      .trim()
                                                                      .isNotEmpty)
                                                                AdditionalField(
                                                                  ReferralReconEnums
                                                                      .cycle
                                                                      .toValue(),
                                                                  gender,
                                                                ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    );
                                                    context
                                                        .read<
                                                            ReferralReconServiceDefinitionBloc>()
                                                        .add(
                                                          ReferralReconServiceDefinitionSelectionEvent(
                                                              serviceDefinitionCode:
                                                                  symptom),
                                                        );
                                                    context.router.push(
                                                      CustomReferralReasonChecklistRoute(
                                                        referralClientRefId:
                                                            hfClientRefId,
                                                      ),
                                                    );
                                                  }
                                                },
                                        );
                                      },
                                    ),
                                  ]),
                              serviceSearch: (value1, value2, value3) {
                                return DigitCard(
                                    cardType: CardType.primary,
                                    children: [
                                      ValueListenableBuilder(
                                        valueListenable: clickedStatus,
                                        builder: (context, bool isClicked, _) {
                                          return DigitButton(
                                            size: DigitButtonSize.large,
                                            type: DigitButtonType.primary,
                                            mainAxisSize: MainAxisSize.max,
                                            label: localizations.translate(
                                                recordState.mapOrNull(
                                                      create: (value) => value
                                                              .viewOnly
                                                          ? i18.common
                                                              .coreCommonNext
                                                          : i18.common
                                                              .coreCommonSubmit,
                                                    ) ??
                                                    i18.common
                                                        .coreCommonSubmit),
                                            onPressed: isClicked
                                                ? () {}
                                                : () {
                                                    if (form
                                                            .control(_genderKey)
                                                            .value ==
                                                        null) {
                                                      clickedStatus.value =
                                                          false;
                                                      form
                                                          .control(_genderKey)
                                                          .setErrors(
                                                              {'': true});
                                                    }
                                                    if (form
                                                            .control(_cycleKey)
                                                            .value ==
                                                        null) {
                                                      clickedStatus.value =
                                                          false;
                                                      form
                                                          .control(_cycleKey)
                                                          .setErrors(
                                                              {'': true});
                                                    }
                                                    form.markAllAsTouched();
                                                    if (form.invalid) return;

                                                    if (viewOnly) {
                                                      final symptom = form
                                                          .control(
                                                              _referralReason)
                                                          .value as String;
                                                      if (value1.isNotEmpty) {
                                                        context
                                                            .read<
                                                                ReferralReconServiceDefinitionBloc>()
                                                            .add(
                                                              ReferralReconServiceDefinitionSelectionEvent(
                                                                  serviceDefinitionCode:
                                                                      symptom),
                                                            );
                                                        context
                                                            .read<ServiceBloc>()
                                                            .add(
                                                              ServiceSearchEvent(
                                                                serviceSearchModel:
                                                                    ServiceSearchModel(
                                                                  relatedClientReferenceId:
                                                                      recordState
                                                                          .mapOrNull(
                                                                    create: (value) => value
                                                                            .viewOnly
                                                                        ? value
                                                                            .hfReferralModel
                                                                            ?.clientReferenceId
                                                                        : null,
                                                                  ),
                                                                ),
                                                              ),
                                                            );
                                                        context.router.push(
                                                          CustomReferralReasonChecklistPreviewRoute(),
                                                        );
                                                      } else {
                                                        final hfClientRefId =
                                                            recordState
                                                                .mapOrNull(
                                                          create: (value) => value
                                                              .hfReferralModel
                                                              ?.clientReferenceId,
                                                        );
                                                        context
                                                            .read<
                                                                ReferralReconServiceDefinitionBloc>()
                                                            .add(
                                                              ReferralReconServiceDefinitionSelectionEvent(
                                                                serviceDefinitionCode:
                                                                    symptom,
                                                              ),
                                                            );
                                                        context.router.push(
                                                          CustomReferralReasonChecklistRoute(
                                                            referralClientRefId:
                                                                hfClientRefId,
                                                          ),
                                                        );
                                                      }
                                                    } else if (!form.valid) {
                                                      return;
                                                    } else if (value
                                                        .serviceDefinitionList
                                                        .isEmpty) {
                                                      Toast.showToast(
                                                        context,
                                                        message: localizations
                                                            .translate(i18
                                                                .referralReconciliation
                                                                .noChecklistFound),
                                                        type: ToastType.error,
                                                      );
                                                    } else {
                                                      final hfState =
                                                          BlocProvider.of<
                                                              RecordHFReferralBloc>(
                                                        context,
                                                      ).state;
                                                      clickedStatus.value =
                                                          true;
                                                      final nameOfChild = form
                                                          .control(
                                                              _nameOfChildKey)
                                                          .value as String;
                                                      final age = form
                                                          .control(_ageKey)
                                                          .value as int;
                                                      final gender = form
                                                          .control(_genderKey)
                                                          .value as String;
                                                      final cycle = form
                                                          .control(_cycleKey)
                                                          .value as String;
                                                      final beneficiaryId = form
                                                          .control(
                                                              _beneficiaryIdKey)
                                                          .value as String?;
                                                      final referralCode = form
                                                          .control(
                                                              _referralCodeKey)
                                                          .value as String?;
                                                      final symptom = form
                                                          .control(
                                                              _referralReason)
                                                          .value as String;
                                                      final hfCoordinator =
                                                          hfState.mapOrNull(
                                                        create: (val) => val
                                                            .healthFacilityCord,
                                                      );
                                                      final referredBy =
                                                          hfState.mapOrNull(
                                                        create: (val) =>
                                                            val.referredBy,
                                                      );
                                                      final dateOfEvaluation =
                                                          hfState
                                                              .mapOrNull(
                                                                create: (val) =>
                                                                    val.dateOfEvaluation,
                                                              )
                                                              ?.millisecondsSinceEpoch;
                                                      final facilityId =
                                                          hfState.mapOrNull(
                                                        create: (val) =>
                                                            val.facilityId,
                                                      );
                                                      final hfClientRefId =
                                                          IdGen.i.identifier;

                                                      final event = context.read<
                                                          RecordHFReferralBloc>();
                                                      event.add(
                                                        RecordHFReferralCreateEntryEvent(
                                                          hfReferralModel:
                                                              HFReferralModel(
                                                            clientReferenceId:
                                                                hfClientRefId,
                                                            projectFacilityId:
                                                                facilityId,
                                                            projectId:
                                                                ReferralReconSingleton()
                                                                    .projectId,
                                                            name: nameOfChild
                                                                .trim(),
                                                            beneficiaryId:
                                                                beneficiaryId,
                                                            referralCode:
                                                                referralCode,
                                                            symptom: symptom,
                                                            tenantId:
                                                                ReferralReconSingleton()
                                                                    .tenantId,
                                                            rowVersion: 1,
                                                            auditDetails:
                                                                AuditDetails(
                                                              createdBy:
                                                                  ReferralReconSingleton()
                                                                      .userUUid,
                                                              createdTime: context
                                                                  .millisecondsSinceEpoch(),
                                                              lastModifiedBy:
                                                                  ReferralReconSingleton()
                                                                      .userUUid,
                                                              lastModifiedTime:
                                                                  context
                                                                      .millisecondsSinceEpoch(),
                                                            ),
                                                            clientAuditDetails:
                                                                ClientAuditDetails(
                                                              createdBy:
                                                                  ReferralReconSingleton()
                                                                      .userUUid,
                                                              createdTime: context
                                                                  .millisecondsSinceEpoch(),
                                                              lastModifiedBy:
                                                                  ReferralReconSingleton()
                                                                      .userUUid,
                                                              lastModifiedTime:
                                                                  context
                                                                      .millisecondsSinceEpoch(),
                                                            ),
                                                            additionalFields:
                                                                HFReferralAdditionalFields(
                                                              version: 1,
                                                              fields: [
                                                                AdditionalField(
                                                                    "boundaryCode",
                                                                    ReferralReconSingleton()
                                                                        .boundary
                                                                        ?.code),
                                                                if (hfCoordinator !=
                                                                        null &&
                                                                    hfCoordinator
                                                                        .toString()
                                                                        .trim()
                                                                        .isNotEmpty)
                                                                  AdditionalField(
                                                                    ReferralReconEnums
                                                                        .hFCoordinator
                                                                        .toValue(),
                                                                    hfCoordinator,
                                                                  ),
                                                                if (referredBy !=
                                                                        null &&
                                                                    referredBy
                                                                        .toString()
                                                                        .trim()
                                                                        .isNotEmpty)
                                                                  AdditionalField(
                                                                    ReferralReconEnums
                                                                        .referredBy
                                                                        .toValue(),
                                                                    referredBy,
                                                                  ),
                                                                if (dateOfEvaluation !=
                                                                        null &&
                                                                    dateOfEvaluation
                                                                        .toString()
                                                                        .trim()
                                                                        .isNotEmpty)
                                                                  AdditionalField(
                                                                    ReferralReconEnums
                                                                        .dateOfEvaluation
                                                                        .toValue(),
                                                                    dateOfEvaluation,
                                                                  ),
                                                                if (nameOfChild
                                                                    .toString()
                                                                    .trim()
                                                                    .isNotEmpty)
                                                                  AdditionalField(
                                                                    ReferralReconEnums
                                                                        .nameOfReferral
                                                                        .toValue(),
                                                                    nameOfChild,
                                                                  ),
                                                                if (age
                                                                    .toString()
                                                                    .trim()
                                                                    .isNotEmpty)
                                                                  AdditionalField(
                                                                    ReferralReconEnums
                                                                        .age
                                                                        .toValue(),
                                                                    age,
                                                                  ),
                                                                if (gender
                                                                    .toString()
                                                                    .trim()
                                                                    .isNotEmpty)
                                                                  AdditionalField(
                                                                    ReferralReconEnums
                                                                        .gender
                                                                        .toValue(),
                                                                    gender,
                                                                  ),
                                                                if (cycle
                                                                    .toString()
                                                                    .trim()
                                                                    .isNotEmpty)
                                                                  AdditionalField(
                                                                    ReferralReconEnums
                                                                        .cycle
                                                                        .toValue(),
                                                                    cycle,
                                                                  ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      );
                                                      context
                                                          .read<
                                                              ReferralReconServiceDefinitionBloc>()
                                                          .add(
                                                            ReferralReconServiceDefinitionSelectionEvent(
                                                              serviceDefinitionCode:
                                                                  symptom,
                                                            ),
                                                          );
                                                      final parent = context
                                                              .router
                                                              .parent()
                                                          as StackRouter;
                                                      parent.push(
                                                        CustomReferralReasonChecklistRoute(
                                                          referralClientRefId:
                                                              hfClientRefId,
                                                        ),
                                                      );
                                                    }
                                                  },
                                          );
                                        },
                                      ),
                                    ]);
                              },
                            );
                          },
                        ),
                        slivers: [
                          SliverToBoxAdapter(
                            child: Column(
                              children: [
                                DigitCard(
                                    cardType: CardType.primary,
                                    margin: const EdgeInsets.all(spacer2),
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              localizations.translate(
                                                i18.referralReconciliation
                                                    .referralDetails,
                                              ),
                                              style: textTheme.headingXl,
                                            ),
                                          ),
                                        ],
                                      ),
                                      ReactiveWrapperField<String>(
                                        validationMessages: {
                                          '': (_) => localizations.translate(
                                                i18.common.corecommonRequired,
                                              ),
                                        },
                                        formControlName: _cycleKey,
                                        showErrors: (control) =>
                                            control.invalid && control.touched,
                                        builder: (field) {
                                          final cycleItems = widget.cycles
                                              .asMap()
                                              .entries
                                              .map((entry) => DropdownItem(
                                                    name: localizations.translate(
                                                        'Cycle ${entry.key + 1}'),
                                                    code: entry.value,
                                                  ))
                                              .toList();

                                          return LabeledField(
                                            isRequired: true,
                                            label: localizations.translate(i18
                                                .referralReconciliation
                                                .selectCycle),
                                            child: Dropdown(
                                              readOnly: viewOnly,
                                              onSelect: (val) {
                                                form
                                                    .control(_cycleKey)
                                                    .markAsTouched();
                                                form.control(_cycleKey).value =
                                                    val.code;
                                              },
                                              errorMessage: field.errorText,
                                              selectedOption:
                                                  cycleItems.firstWhere(
                                                (item) =>
                                                    item.code ==
                                                    form
                                                        .control(_cycleKey)
                                                        .value,
                                                orElse: () =>
                                                    const DropdownItem(
                                                        name: '', code: ''),
                                              ),
                                              items: cycleItems,
                                            ),
                                          );
                                        },
                                      ),
                                      ReactiveWrapperField<String>(
                                          validationMessages: {
                                            'required': (_) =>
                                                localizations.translate(
                                                  i18.common.corecommonRequired,
                                                ),
                                            'onlyAlphabets': (_) =>
                                                'Please enter alphabets only',
                                          },
                                          formControlName: _nameOfChildKey,
                                          showErrors: (control) =>
                                              control.invalid &&
                                              control.touched,
                                          // Ensures error is shown if invalid and touched
                                          builder: (field) {
                                            return LabeledField(
                                              isRequired: true,
                                              label: localizations.translate(
                                                i18.referralReconciliation
                                                    .nameOfTheChildLabel,
                                              ),
                                              child: DigitTextFormInput(
                                                onChange: (val) => {
                                                  form
                                                      .control(_nameOfChildKey)
                                                      .markAsTouched(),
                                                  form
                                                      .control(_nameOfChildKey)
                                                      .value = val,
                                                },
                                                errorMessage: field.errorText,
                                                readOnly: viewOnly,
                                                initialValue: form
                                                    .control(_nameOfChildKey)
                                                    .value,
                                                inputFormatters: [
                                                  // Allow only letters and spaces
                                                  FilteringTextInputFormatter
                                                      .allow(
                                                    RegExp(r'[A-Za-z\s]'),
                                                  ),
                                                ],
                                              ),
                                            );
                                          }),
                                      ReactiveWrapperField<String>(
                                          validationMessages: {
                                            'required': (_) =>
                                                localizations.translate(
                                                  i18.common.corecommonRequired,
                                                ),
                                            'noEmojis': (_) =>
                                                'Beneficiary ID cannot contain emoji characters',
                                            'repeatedChars': (_) =>
                                                'Beneficiary ID cannot contain excessive repetition of characters',
                                          },
                                          formControlName: _beneficiaryIdKey,
                                          showErrors: (control) =>
                                              control.invalid &&
                                              control.touched,
                                          builder: (field) {
                                            return CustomLabeledField(
                                              isRequired: true,
                                              label: localizations
                                                  .translate(i18_local
                                                      .beneficiaryDetails
                                                      .beneficiaryId)
                                                  .toString(),
                                              child: DigitTextFormInput(
                                                onChange: (val) => {
                                                  form
                                                      .control(
                                                          _beneficiaryIdKey)
                                                      .markAsTouched(),
                                                  form
                                                      .control(
                                                          _beneficiaryIdKey)
                                                      .value = val,
                                                },
                                                initialValue: form
                                                    .control(_beneficiaryIdKey)
                                                    .value,
                                                readOnly: viewOnly,
                                                errorMessage: field.errorText,
                                                inputFormatters: [
                                                  // Allow only letters, numbers, and specific special characters
                                                  FilteringTextInputFormatter
                                                      .allow(
                                                    RegExp(
                                                        r'[a-zA-Z0-9\-_/#:.,() ]'),
                                                  ),
                                                  // Prevent excessive repetition of characters
                                                  TextInputFormatter
                                                      .withFunction(
                                                    (oldValue, newValue) {
                                                      final text =
                                                          newValue.text;
                                                      // Check for repetitions of special characters
                                                      for (final specialChar
                                                          in [
                                                        '-',
                                                        '.',
                                                        ',',
                                                        ')',
                                                        '(',
                                                        '/',
                                                        '#',
                                                        ':',
                                                        '_'
                                                      ]) {
                                                        if (text.contains(
                                                            '$specialChar$specialChar$specialChar')) {
                                                          return oldValue;
                                                        }
                                                      }

                                                      // Check for any character repeated excessively (4+ times)
                                                      final repeatedCharsPattern =
                                                          RegExp(r'(.)\1{3,}');
                                                      if (repeatedCharsPattern
                                                          .hasMatch(text)) {
                                                        return oldValue;
                                                      }

                                                      return newValue;
                                                    },
                                                  ),
                                                ],
                                              ),
                                            );
                                          }),
                                      ReactiveWrapperField<int>(
                                          formControlName: _ageKey,
                                          validationMessages: {
                                            'required': (_) =>
                                                localizations.translate(
                                                  i18.common.corecommonRequired,
                                                ),
                                            'max': (_) => localizations
                                                .translate(
                                                  i18.common.maxValue,
                                                )
                                                .replaceAll(
                                                  '{}',
                                                  ReferralReconSingleton()
                                                      .validIndividualAgeForCampaign
                                                      .validMaxAge
                                                      .toString(),
                                                ),
                                            'min': (_) => localizations
                                                .translate(
                                                  i18.common.minValue,
                                                )
                                                .replaceAll(
                                                  '{}',
                                                  ReferralReconSingleton()
                                                      .validIndividualAgeForCampaign
                                                      .validMinAge
                                                      .toString(),
                                                ),
                                          },
                                          showErrors: (control) =>
                                              control.invalid &&
                                              control.touched,
                                          // Ensures error is shown if invalid and touched
                                          builder: (field) {
                                            return LabeledField(
                                              isRequired: true,
                                              label: localizations.translate(
                                                i18.common.ageInMonths,
                                              ),
                                              child: DigitTextFormInput(
                                                onChange: (val) => {
                                                  form
                                                      .control(_ageKey)
                                                      .markAsTouched(),
                                                  form.control(_ageKey).value =
                                                      int.tryParse(val),
                                                },
                                                keyboardType:
                                                    TextInputType.number,
                                                inputFormatters: [
                                                  FilteringTextInputFormatter
                                                      .digitsOnly,
                                                  LengthLimitingTextInputFormatter(
                                                      4)
                                                ],
                                                readOnly: viewOnly,
                                                initialValue: form
                                                            .control(_ageKey)
                                                            .value ==
                                                        null
                                                    ? ""
                                                    : form
                                                        .control(_ageKey)
                                                        .value
                                                        .toString(),
                                                errorMessage: field.errorText,
                                              ),
                                            );
                                          }),
                                      ReactiveWrapperField<String>(
                                          validationMessages: {
                                            '': (_) => localizations.translate(
                                                  i18.common.corecommonRequired,
                                                ),
                                          },
                                          formControlName: _genderKey,
                                          showErrors: (control) =>
                                              control.invalid &&
                                              control.touched,
                                          // Ensures error is shown if invalid and touched
                                          builder: (field) {
                                            return LabeledField(
                                                isRequired: true,
                                                label: localizations.translate(
                                                  i18.common.genderLabelText,
                                                ),
                                                child: Dropdown(
                                                  readOnly: viewOnly,
                                                  onSelect: (val) => {
                                                    form
                                                        .control(_genderKey)
                                                        .markAsTouched(),
                                                    form
                                                        .control(_genderKey)
                                                        .value = val.code,
                                                  },
                                                  errorMessage: field.errorText,
                                                  selectedOption:
                                                      ReferralReconSingleton()
                                                          .genderOptions
                                                          .map((item) =>
                                                              DropdownItem(
                                                                name: localizations
                                                                    .translate(
                                                                        item),
                                                                code: item
                                                                    .toString(),
                                                              ))
                                                          .firstWhere(
                                                            (item) =>
                                                                item.code ==
                                                                form
                                                                    .control(
                                                                        _genderKey)
                                                                    .value,
                                                            orElse: () =>
                                                                const DropdownItem(
                                                                    name: '',
                                                                    code: ''),
                                                          ),
                                                  items:
                                                      ReferralReconSingleton()
                                                          .genderOptions
                                                          .map(
                                                            (item) =>
                                                                DropdownItem(
                                                              name: localizations
                                                                  .translate(
                                                                      item),
                                                              code: item
                                                                  .toString(),
                                                            ),
                                                          )
                                                          .toList(),
                                                ));
                                          }),
                                    ]),
                                StatefulBuilder(builder: (context, set) {
                                  print(
                                      "Current referral reason: ${ReferralReconSingleton().referralReasons}");
                                  form.control(_referralReason).value =
                                      recordState.mapOrNull(
                                    create: (value) => value.viewOnly
                                        ? ReferralReconSingleton()
                                            .referralReasons
                                            .where((e) =>
                                                e ==
                                                value.hfReferralModel?.symptom)
                                            .first
                                        : null,
                                  );
                                  return DigitCard(
                                      cardType: CardType.primary,
                                      margin: const EdgeInsets.all(spacer2),
                                      children: [
                                        SizedBox(
                                          width: double.infinity,
                                          child: ReactiveWrapperField<String>(
                                              formControlName: _referralReason,
                                              validationMessages: {
                                                'required': (_) =>
                                                    localizations.translate(
                                                      i18.common
                                                          .corecommonRequired,
                                                    ),
                                              },
                                              showErrors: (control) =>
                                                  control.invalid &&
                                                  control.touched,
                                              // Ensures error is shown if invalid and touched
                                              builder: (field) {
                                                return LabeledField(
                                                  isRequired: true,
                                                  label:
                                                      localizations.translate(
                                                    i18.referralReconciliation
                                                        .reasonForReferralHeader,
                                                  ),
                                                  child: RadioList(
                                                    readOnly: viewOnly,
                                                    onChanged: (val) {
                                                      form
                                                          .control(
                                                              _referralReason)
                                                          .markAsTouched();
                                                      form
                                                          .control(
                                                              _referralReason)
                                                          .value = val.code;
                                                    },
                                                    groupValue: form
                                                            .control(
                                                                _referralReason)
                                                            .value ??
                                                        "",
                                                    errorMessage:
                                                        field.errorText,
                                                    radioDigitButtons:
                                                        ReferralReconSingleton()
                                                            .referralReasons
                                                            .map((r) {
                                                      return RadioButtonModel(
                                                        code: r
                                                            .toString()
                                                            .toUpperCase(),
                                                        // Use the index as the code
                                                        name: localizations
                                                            .translate(r
                                                                .toString()
                                                                .toUpperCase()),
                                                      );
                                                    }).toList(),
                                                  ),
                                                );
                                              }),
                                        ),
                                      ]);
                                }),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  FormGroup buildForm(RecordHFReferralState referralState) {
    return fb.group(<String, Object>{
      _nameOfChildKey: FormControl<String>(
        value: referralState.mapOrNull(
          create: (value) => value.viewOnly &&
                  value.hfReferralModel?.additionalFields?.fields
                          .where((e) =>
                              e.key ==
                              ReferralReconEnums.nameOfReferral.toValue())
                          .firstOrNull
                          ?.value !=
                      null
              ? value.hfReferralModel?.additionalFields?.fields
                  .where((e) =>
                      e.key == ReferralReconEnums.nameOfReferral.toValue())
                  .firstOrNull
                  ?.value
                  .toString()
              : value.hfReferralModel?.name ?? '',
        ),
        disabled: referralState.mapOrNull(
              create: (value) => value.viewOnly,
            ) ??
            false,
        validators: [
          Validators.required,
          // Add validation to only allow alphabets and spaces
          Validators.delegate((control) {
            final value = control.value?.toString().trim();
            if (value == null || value.isEmpty) return null;
            final regExp = RegExp(r'^[A-Za-z\s]+$');
            return regExp.hasMatch(value) ? null : {'onlyAlphabets': true};
          }),
        ],
      ),
      _beneficiaryIdKey: FormControl<String>(
        validators: [
          Validators.required,
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
            for (final specialChar in [
              '-',
              '.',
              ',',
              ')',
              '(',
              '/',
              '#',
              ':',
              '_'
            ]) {
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
        value: referralState.mapOrNull(
          create: (value) => value.hfReferralModel?.beneficiaryId,
        ),
        disabled: referralState.mapOrNull(
              create: (value) => value.viewOnly,
            ) ??
            false,
      ),
      _referralCodeKey: FormControl<String>(
        value: referralState.mapOrNull(
          create: (value) =>
              value.viewOnly ? value.hfReferralModel?.referralCode : null,
        ),
        disabled: referralState.mapOrNull(
              create: (value) => value.viewOnly,
            ) ??
            false,
      ),
      _genderKey: FormControl<String>(
        value: referralState.mapOrNull(
          create: (value) => value.viewOnly &&
                  value.hfReferralModel?.additionalFields?.fields
                          .where((e) =>
                              e.key == ReferralReconEnums.gender.toValue())
                          .firstOrNull
                          ?.value !=
                      null
              ? value.hfReferralModel?.additionalFields?.fields
                  .where((e) => e.key == ReferralReconEnums.gender.toValue())
                  .firstOrNull
                  ?.value
                  .toString()
              : null,
        ),
        disabled: referralState.mapOrNull(
              create: (value) => value.viewOnly,
            ) ??
            false,
      ),
      _cycleKey: FormControl<String>(
        value: referralState.mapOrNull(
          create: (value) => value.viewOnly &&
                  value.hfReferralModel?.additionalFields?.fields
                          .where((e) =>
                              e.key == ReferralReconEnums.cycle.toValue())
                          .firstOrNull
                          ?.value !=
                      null
              ? value.hfReferralModel?.additionalFields?.fields
                  .where((e) => e.key == ReferralReconEnums.cycle.toValue())
                  .firstOrNull
                  ?.value
                  .toString()
              : null,
        ),
        disabled: referralState.mapOrNull(
              create: (value) => value.viewOnly,
            ) ??
            false,
        validators: [Validators.required],
      ),
      _ageKey: FormControl<int>(
        value: referralState.mapOrNull(
          create: (value) => value.viewOnly &&
                  value.hfReferralModel?.additionalFields?.fields
                          .where(
                              (e) => e.key == ReferralReconEnums.age.toValue())
                          .firstOrNull
                          ?.value !=
                      null
              ? int.tryParse(value.hfReferralModel?.additionalFields?.fields
                      .where((e) => e.key == ReferralReconEnums.age.toValue())
                      .firstOrNull
                      ?.value
                      .toString() ??
                  '')
              : null,
        ),
        disabled: referralState.mapOrNull(
              create: (value) => value.viewOnly,
            ) ??
            false,
        validators: (ReferralReconSingleton()
                        .validIndividualAgeForCampaign
                        .validMaxAge !=
                    0 &&
                ReferralReconSingleton()
                        .validIndividualAgeForCampaign
                        .validMinAge !=
                    0)
            ? [
                Validators.required,
                Validators.max<int>(
                  ReferralReconSingleton()
                      .validIndividualAgeForCampaign
                      .validMaxAge,
                ),
                Validators.min<int>(
                  ReferralReconSingleton()
                      .validIndividualAgeForCampaign
                      .validMinAge,
                ),
              ]
            : [Validators.required],
      ),
      _referralReason: FormControl<String>(
        value: referralState.mapOrNull(
          create: (value) =>
              value.viewOnly && value.hfReferralModel?.symptom != null
                  ? value.hfReferralModel?.symptom
                  : null,
        ),
        disabled: referralState.mapOrNull(
              create: (value) => value.viewOnly,
            ) ??
            false,
        validators: [
          Validators.required,
        ],
      ),
    });
  }
}
