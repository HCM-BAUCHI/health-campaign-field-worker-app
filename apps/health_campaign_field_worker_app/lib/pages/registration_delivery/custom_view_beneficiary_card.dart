import 'package:collection/collection.dart';
import 'package:digit_data_model/data_model.dart';
import 'package:digit_data_model/models/entities/household_type.dart';
import 'package:digit_ui_components/digit_components.dart';
import 'package:digit_ui_components/theme/digit_extended_theme.dart';
import 'package:digit_ui_components/utils/date_utils.dart';
import 'package:digit_ui_components/widgets/atoms/table_cell.dart';
import 'package:digit_ui_components/widgets/molecules/digit_card.dart';
import 'package:digit_ui_components/widgets/molecules/digit_table.dart';
import 'package:flutter/material.dart';
import 'package:registration_delivery/models/entities/project_beneficiary.dart';

import 'package:registration_delivery/blocs/search_households/search_households.dart';
import 'package:registration_delivery/models/entities/status.dart';
import 'package:registration_delivery/models/entities/task.dart';
import 'package:registration_delivery/utils/constants.dart';
import 'package:registration_delivery/utils/i18_key_constants.dart' as i18;
import '../../utils/i18_key_constants.dart' as i18_local;
import 'package:registration_delivery/utils/utils.dart';
import 'package:registration_delivery/widgets/beneficiary/beneficiary_card.dart';
import 'package:registration_delivery/widgets/localized.dart';

import '../../utils/registration_delivery/utils_smc.dart' as util_local;

class CustomViewBeneficiaryCard extends LocalizedStatefulWidget {
  final HouseholdMemberWrapper householdMember;
  final VoidCallback onOpenPressed;
  final double? distance;

  const CustomViewBeneficiaryCard({
    super.key,
    super.appLocalizations,
    required this.householdMember,
    required this.onOpenPressed,
    this.distance,
  });

  @override
  State<CustomViewBeneficiaryCard> createState() =>
      CustomViewBeneficiaryCardState();
}

class CustomViewBeneficiaryCardState
    extends LocalizedState<CustomViewBeneficiaryCard> {
  late HouseholdMemberWrapper householdMember;

  @override
  void initState() {
    householdMember = widget.householdMember;
    super.initState();
  }

  @override
  void didUpdateWidget(covariant CustomViewBeneficiaryCard oldWidget) {
    householdMember = widget.householdMember;
    super.didUpdateWidget(oldWidget);
  }

  bool _isCardExpanded = false;

  bool get isCardExpanded => _isCardExpanded;

  set isCardExpanded(bool value) => setState(() => _isCardExpanded = value);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final headerList = [
      DigitTableColumn(
        header:
            localizations.translate(i18.beneficiaryDetails.beneficiaryHeader),
        cellValue: 'beneficiary',
        isFrozen: true,
      ),
      DigitTableColumn(
        header: localizations.translate(i18.beneficiaryDetails.deliveryHeader),
        cellValue: 'delivery',
      ),
      DigitTableColumn(
        header: localizations.translate(i18.individualDetails.ageLabelText),
        cellValue: 'age',
      ),
      DigitTableColumn(
        header: localizations.translate(i18.common.coreCommonGender),
        cellValue: 'gender',
      ),
    ];
    final filteredHeaderList =
        RegistrationDeliverySingleton().beneficiaryType !=
                BeneficiaryType.individual
            ? headerList
                .where((element) => element.cellValue != 'delivery')
                .toList()
            : headerList;
    final currentCycle =
        RegistrationDeliverySingleton().projectType?.cycles?.firstWhereOrNull(
              (e) =>
                  (e.startDate) < DateTime.now().millisecondsSinceEpoch &&
                  (e.endDate) > DateTime.now().millisecondsSinceEpoch,
              // Return null when no matching cycle is found
            );

    final tableData = householdMember.members?.map(
      (e) {
        final projectBeneficiary =
            householdMember.projectBeneficiaries?.where((element) {
          if (RegistrationDeliverySingleton().beneficiaryType ==
              BeneficiaryType.individual) {
            return element.beneficiaryClientReferenceId == e.clientReferenceId;
          } else {
            return element.beneficiaryClientReferenceId ==
                householdMember.household!.clientReferenceId;
          }
        }).toList();

        final taskData = (projectBeneficiary ?? []).isNotEmpty &&
                householdMember.tasks != null
            ? householdMember.tasks
                ?.where((element) =>
                    element.projectBeneficiaryClientReferenceId ==
                    projectBeneficiary?.first.clientReferenceId)
                .toList()
            : null;
        final referralData = (projectBeneficiary ?? []).isNotEmpty
            ? householdMember.referrals
                ?.where((element) =>
                    element.projectBeneficiaryClientReferenceId ==
                    projectBeneficiary?.first.clientReferenceId)
                .toList()
            : null;
        final sideEffects = taskData != null && taskData.isNotEmpty
            ? householdMember.sideEffects
                ?.where((element) =>
                    element.taskClientReferenceId ==
                    taskData.last.clientReferenceId)
                .toList()
            : null;

        final ageInYears = DigitDateUtils.calculateAge(
          e.dateOfBirth != null
              ? DigitDateUtils.getFormattedDateToDateTime(
                    e.dateOfBirth!,
                  ) ??
                  DateTime.now()
              : DateTime.now(),
        ).years;
        final ageInMonths = DigitDateUtils.calculateAge(
          e.dateOfBirth != null
              ? DigitDateUtils.getFormattedDateToDateTime(
                    e.dateOfBirth!,
                  ) ??
                  DateTime.now()
              : DateTime.now(),
        ).months;

        final isNotEligible = !checkEligibilityForAgeAndSideEffect(
          DigitDOBAgeConvertor(
            years: ageInYears,
            months: ageInMonths,
          ),
          RegistrationDeliverySingleton().projectType,
          (taskData ?? []).isNotEmpty ? taskData?.last : null,
          sideEffects,
        );

        final isSideEffectRecorded = recordedSideEffect(
          currentCycle,
          (taskData ?? []).isNotEmpty ? taskData?.last : null,
          sideEffects,
        );
        final isBeneficiaryRefused = checkIfBeneficiaryRefused(taskData);
        final isBeneficiaryReferred = checkIfBeneficiaryReferred(
          referralData,
          currentCycle,
        );

        final isBeneficiaryReferredSMC =
            util_local.checkBeneficiaryReferredSMC(taskData);
        final isBeneficiaryReferredVAS =
            util_local.checkBeneficiaryReferredVAS(taskData);

        final isIneligibleForSMC =
            util_local.checkBeneficiaryInEligibleSMC(taskData);
        final isIneligibleForVAS =
            util_local.checkBeneficiaryInEligibleVAS(taskData);

        final isSMCDelivered =
            !util_local.checkStatusSMC(taskData, currentCycle);
        final isVASDelivered = taskData == null
            ? false
            : taskData.isNotEmpty &&
                    !util_local.checkStatusVAS(
                      taskData,
                      currentCycle,
                    )
                ? true
                : false;
        // !util_local.checkStatusVAS(taskData, currentCycle);

        final isStatusReset = checkStatus(taskData, currentCycle);

        final rowTableData = [
          DigitTableData(
            [
              e.name?.givenName ?? '--',
              (e.name?.familyName?.trim().isNotEmpty ?? false)
                  ? e.name?.familyName
                  : null,
            ].whereNotNull().join(' '),
            cellKey: 'beneficiary',
          ),
          DigitTableData(
            getTableCellText(
              CustomStatusKeys(
                  isNotEligible,
                  isIneligibleForSMC,
                  isIneligibleForVAS,
                  isBeneficiaryRefused,
                  isBeneficiaryReferred,
                  isStatusReset,
                  isVASDelivered,
                  isSMCDelivered,
                  isBeneficiaryReferredSMC,
                  isBeneficiaryReferredVAS),
              taskData,
            ),
            cellKey: 'delivery',
            style: TextStyle(
              color: getTableCellTextColor(
                isNotEligible:
                    isNotEligible || isIneligibleForVAS || isIneligibleForSMC,
                taskdata: taskData,
                isBeneficiaryRefused:
                    isBeneficiaryRefused || isBeneficiaryReferred,
                isStatusReset: isStatusReset,
                theme: theme,
              ),
            ),
          ),
          DigitTableData(
            e.dateOfBirth == null
                ? '--'
                : '${DigitDateUtils.calculateAge(
                    DigitDateUtils.getFormattedDateToDateTime(
                          e.dateOfBirth!,
                        ) ??
                        DateTime.now(),
                  ).years} ${localizations.translate(i18.searchBeneficiary.yearsAbbr)} ${DigitDateUtils.calculateAge(
                    DigitDateUtils.getFormattedDateToDateTime(
                          e.dateOfBirth!,
                        ) ??
                        DateTime.now(),
                  ).months} ${localizations.translate(i18.searchBeneficiary.monthsAbbr)}',
            cellKey: 'age',
          ),
          DigitTableData(
            e.gender?.name == null
                ? '--'
                : localizations
                    .translate('CORE_COMMON_${e.gender?.name.toUpperCase()}'),
            cellKey: 'gender',
          ),
        ];

        return DigitTableRow(
          tableRow: RegistrationDeliverySingleton().beneficiaryType !=
                  BeneficiaryType.individual
              ? rowTableData
                  .where((element) => element.cellKey != 'delivery')
                  .toList()
              : rowTableData,
        );
        // rowTableData
      },
    ).toList();

    final ageInYears = DigitDateUtils.calculateAge(
      householdMember.headOfHousehold?.dateOfBirth != null
          ? DigitDateUtils.getFormattedDateToDateTime(
                householdMember.headOfHousehold!.dateOfBirth!,
              ) ??
              DateTime.now()
          : DateTime.now(),
    ).years;
    final ageInMonths = DigitDateUtils.calculateAge(
      householdMember.headOfHousehold?.dateOfBirth != null
          ? DigitDateUtils.getFormattedDateToDateTime(
                householdMember.headOfHousehold!.dateOfBirth!,
              ) ??
              DateTime.now()
          : DateTime.now(),
    ).months;

    final isNotEligible = !checkEligibilityForAgeAndSideEffect(
      DigitDOBAgeConvertor(
        years: ageInYears,
        months: ageInMonths,
      ),
      RegistrationDeliverySingleton().projectType,
      (householdMember.tasks ?? []).isNotEmpty
          ? householdMember.tasks?.last
          : null,
      (householdMember.sideEffects ?? []).isNotEmpty
          ? householdMember.sideEffects
          : null,
    );

    final isBeneficiaryRefused =
        checkIfBeneficiaryRefused(householdMember.tasks);
    final projectBeneficiary = householdMember.projectBeneficiaries?.where((p) {
      if (RegistrationDeliverySingleton().beneficiaryType ==
          BeneficiaryType.individual) {
        return p.beneficiaryClientReferenceId ==
            householdMember.headOfHousehold?.clientReferenceId;
      } else {
        return p.beneficiaryClientReferenceId ==
            householdMember.household?.clientReferenceId;
      }
    }).firstOrNull;

    final tasks = householdMember.tasks?.where((t) =>
        t.projectBeneficiaryClientReferenceId ==
        projectBeneficiary?.clientReferenceId);

    return DigitCard(
        margin: const EdgeInsets.only(top: spacer2, bottom: spacer2),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width / 1.8,
                child: BeneficiaryCard(
                  description: [
                    householdMember.household?.address?.doorNo,
                    householdMember.household?.address?.addressLine1,
                    householdMember.household?.address?.addressLine2,
                    householdMember.household?.address?.landmark,
                    householdMember.household?.address?.city,
                    householdMember.household?.address?.pincode,
                  ].whereNotNull().take(2).join(' '),
                  subtitle: (RegistrationDeliverySingleton().householdType ==
                          HouseholdType.family)
                      ? widget.distance != null
                          ? '${householdMember.members?.length ?? 1} ${householdMember.members?.length == 1 ? localizations.translate(i18.beneficiaryDetails.householdMemberSingular) : localizations.translate(i18.beneficiaryDetails.householdMemberPlural)}\n${((widget.distance!) * 1000).round() > 999 ? '(${((widget.distance!).round())} km)' : '(${((widget.distance!) * 1000).round()} mts) ${localizations.translate(i18.beneficiaryDetails.fromCurrentLocation)}'}'
                          : '${householdMember.members?.length ?? 1} ${householdMember.members?.length == 1 ? localizations.translate(i18.beneficiaryDetails.householdMemberSingular) : localizations.translate(i18.beneficiaryDetails.householdMemberPlural)}'
                      : (widget.distance != null)
                          ? ((widget.distance!) * 1000).round() > 999
                              ? '(${((widget.distance!).round())} km)'
                              : '(${((widget.distance!) * 1000).round()} mts) ${localizations.translate(i18.beneficiaryDetails.fromCurrentLocation)}'
                          : null,
                  status: (RegistrationDeliverySingleton().householdType ==
                          HouseholdType.community)
                      ? null
                      : getStatus(
                          tasks ?? [],
                          householdMember.projectBeneficiaries ?? [],
                          RegistrationDeliverySingleton().beneficiaryType ==
                                  BeneficiaryType.individual
                              ? isNotEligible
                              : false,
                          isBeneficiaryRefused),
                  title: (RegistrationDeliverySingleton().householdType ==
                          HouseholdType.community)
                      ? householdMember.household?.address?.buildingName ??
                          localizations.translate(i18.common.coreCommonNA)
                      : [
                          householdMember.headOfHousehold?.name?.givenName ??
                              localizations.translate(i18.common.coreCommonNA),
                          householdMember.headOfHousehold?.name?.familyName,
                        ].whereNotNull().join(''),
                ),
              ),
              Flexible(
                child: DigitButton(
                  label:
                      localizations.translate(i18.searchBeneficiary.iconLabel),
                  onPressed: widget.onOpenPressed,
                  type: DigitButtonType.secondary,
                  size: DigitButtonSize.medium,
                ),
              ),
            ],
          ),
          if (RegistrationDeliverySingleton().householdType ==
              HouseholdType.family) ...[
            Offstage(
              offstage: !isCardExpanded,
              child: DigitTable(
                enableBorder: true,
                showPagination: false,
                columns: filteredHeaderList,
                rows: tableData ?? [],
              ),
            ),
            Container(
              height: 24,
              margin: const EdgeInsets.all(4),
              child: Center(
                child: IconButton(
                  padding: EdgeInsets.zero,
                  icon: Icon(
                    isCardExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    size: 24,
                  ),
                  onPressed: () => isCardExpanded = !isCardExpanded,
                ),
              ),
            ),
          ]
        ]);
  }

  String getTableCellText(
    CustomStatusKeys statusKeys,
    List<TaskModel>? taskData,
  ) {
    if (statusKeys.isNotEligible) {
      return localizations.translate(
          i18_local.householdOverView.householdOverViewHouseholderHeadLabel);
    } else if (statusKeys.isIneligibleForSMC && statusKeys.isIneligibleForVAS) {
      return 'SMC & VAS ${localizations.translate(i18.householdOverView.householdOverViewNotEligibleIconLabel)}';
    }
    // else if (statusKeys.isBeneficiaryReferred) {
    //   return localizations.translate(Status.beneficiaryReferred.toValue());
    // }
    else if (taskData != null) {
      if (taskData.isEmpty) {
        return localizations.translate(Status.notVisited.toValue());
      } else if (statusKeys.isIneligibleForSMC &&
          statusKeys.isBeneficiaryReferredVAS) {
        return 'SMC ${localizations.translate(i18.householdOverView.householdOverViewNotEligibleIconLabel)} '
            ' ${localizations.translate(i18_local.householdOverView.householdOverViewBeneficiaryReferredVASLabel)}';
      } else if (statusKeys.isIneligibleForSMC && statusKeys.isVASDelivered) {
        return 'SMC ${localizations.translate(i18.householdOverView.householdOverViewNotEligibleIconLabel)} '
            ' ${localizations.translate(i18_local.householdOverView.householdOverViewVASDeliveredIconLabel)}';
      } else if (statusKeys.isBeneficiaryReferredSMC &&
          statusKeys.isIneligibleForVAS) {
        return '${localizations.translate(i18_local.householdOverView.householdOverViewBeneficiaryReferredSMCLabel)} VAS ${localizations.translate(i18.householdOverView.householdOverViewNotEligibleIconLabel)}';
      } else if (statusKeys.isSMCDelivered && statusKeys.isIneligibleForVAS) {
        return '${localizations.translate(i18_local.householdOverView.householdOverViewSMCDeliveredIconLabel)} VAS ${localizations.translate(i18.householdOverView.householdOverViewNotEligibleIconLabel)}';
      } else if (statusKeys.isIneligibleForSMC ||
          statusKeys.isIneligibleForVAS) {
        return localizations.translate(
            i18.householdOverView.householdOverViewNotEligibleIconLabel);
      } else if (statusKeys.isVASDelivered &&
          statusKeys.isBeneficiaryReferredSMC) {
        return localizations.translate(i18_local.householdOverView
            .householdOverViewVASDeliveredAndSMCReferredIconLabel);
      } else if (statusKeys.isBeneficiaryReferredVAS &&
          statusKeys.isSMCDelivered) {
        return localizations.translate(i18_local.householdOverView
            .householdOverViewVASReferredAndSMCDeliveredIconLabel);
      } else if (statusKeys.isBeneficiaryReferredVAS &&
          statusKeys.isBeneficiaryReferredSMC) {
        return localizations.translate(i18_local.householdOverView
            .householdOverViewVASReferredAndSMCReferredIconLabel);
      } else if (statusKeys.isVASDelivered && statusKeys.isSMCDelivered) {
        return localizations.translate(i18_local
            .householdOverView.householdOverViewSMCAndVASDeliveredIconLabel);
      } else if (statusKeys.isBeneficiaryReferredSMC) {
        return localizations.translate(i18_local
            .householdOverView.householdOverViewBeneficiaryReferredSMCLabel);
      } else if (statusKeys.isBeneficiaryReferredVAS) {
        return localizations.translate(i18_local
            .householdOverView.householdOverViewBeneficiaryReferredVASLabel);
      } else if (statusKeys.isSMCDelivered) {
        return localizations.translate(
            i18_local.householdOverView.householdOverViewSMCDeliveredIconLabel);
      } else if (statusKeys.isVASDelivered) {
        return localizations.translate(
            i18_local.householdOverView.householdOverViewVASDeliveredIconLabel);
      } else if (statusKeys.isBeneficiaryRefused && !statusKeys.isStatusReset) {
        return localizations.translate(Status.beneficiaryRefused.toValue());
      } else if (statusKeys.isStatusReset) {
        return localizations.translate(Status.notVisited.toValue());
      } else {
        return localizations.translate(Status.visited.toValue());
      }
    } else {
      return localizations.translate(Status.notVisited.toValue());
    }
  }

  // ignore: long-parameter-list
  Color getTableCellTextColor({
    required bool isNotEligible,
    required List<TaskModel>? taskdata,
    required bool isBeneficiaryRefused,
    required bool isStatusReset,
    required ThemeData theme,
  }) {
    return taskdata != null &&
            taskdata.isNotEmpty &&
            !isBeneficiaryRefused &&
            !isNotEligible &&
            !isStatusReset
        ? theme.colorTheme.alert.success
        : theme.colorTheme.alert.error;
  }

  getStatus(
      Iterable<TaskModel> tasks,
      List<ProjectBeneficiaryModel> projectBeneficiaries,
      bool isNotEligible,
      bool isBeneficiaryRefused) {
    if (projectBeneficiaries.isNotEmpty) {
      if (tasks.isEmpty) {
        return Status.registered.toValue();
      } else {
        return getTaskStatus(tasks.toList()).toValue();
      }
    } else {
      return Status.notRegistered.toValue();
    }
  }
}

class CustomStatusKeys {
  bool isNotEligible;
  bool isIneligibleForSMC;
  bool isIneligibleForVAS;
  bool isBeneficiaryRefused;
  bool isBeneficiaryReferred;
  bool isStatusReset;
  bool isVASDelivered;
  bool isSMCDelivered;
  bool isBeneficiaryReferredSMC;
  bool isBeneficiaryReferredVAS;
  CustomStatusKeys(
      this.isNotEligible,
      this.isIneligibleForSMC,
      this.isIneligibleForVAS,
      this.isBeneficiaryRefused,
      this.isBeneficiaryReferred,
      this.isStatusReset,
      this.isVASDelivered,
      this.isSMCDelivered,
      this.isBeneficiaryReferredSMC,
      this.isBeneficiaryReferredVAS);
}
