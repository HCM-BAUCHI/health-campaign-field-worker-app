import 'dart:async';
import 'package:collection/collection.dart';
import 'package:digit_data_model/data_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:registration_delivery/models/entities/household_member.dart';
import 'package:registration_delivery/models/entities/task.dart';
import 'package:registration_delivery/models/entities/task_resource.dart';
import 'package:registration_delivery/utils/typedefs.dart';

import '../../models/entities/assessment_checklist/status.dart';
import '../../utils/app_enums.dart';
import '../../utils/constants.dart';
import '../../utils/date_utils.dart';

import '../../../models/entities/additional_fields_type.dart'
    as additional_fields_local;

part 'custom_summary_report_bloc.freezed.dart';

typedef SummaryReportEmitter = Emitter<SummaryReportState>;

class SummaryReportBloc extends Bloc<SummaryReportEvent, SummaryReportState> {
  final HouseholdMemberDataRepository householdMemberRepository;
  final TaskDataRepository taskDataRepository;
  final ProductVariantDataRepository productVariantDataRepository;

  SummaryReportBloc({
    required this.householdMemberRepository,
    required this.productVariantDataRepository,
    required this.taskDataRepository,
  }) : super(const SummaryReportEmptyState()) {
    on<SummaryReportLoadDataEvent>(_handleLoadDataEvent);
    on<SummaryReportLoadingEvent>(_handleLoadingEvent);
  }

  Future<void> _handleLoadDataEvent(
    SummaryReportLoadDataEvent event,
    SummaryReportEmitter emit,
  ) async {
    emit(const SummaryReportLoadingState());

    List<HouseholdMemberModel> householdMemberList = [];
    List<TaskModel> taskList = [];
    List<TaskModel> refusalCasesList = [];
    List<TaskModel> administeredChildrenList = [];
    List<ProductVariantModel> productVariantList = [];
    List<TaskResourceModel> spaq1List = [];
    List<TaskResourceModel> spaq2List = [];
    List<TaskModel> zeroDoseChildrenList = [];
    householdMemberList = await (householdMemberRepository)
        .search(HouseholdMemberSearchModel(isHeadOfHousehold: false));
    taskList = await (taskDataRepository).search(TaskSearchModel());
    productVariantList = await (productVariantDataRepository)
        .search(ProductVariantSearchModel());
    for (var element in taskList) {
      if (element.status == null) continue;
      final status = StatusMapper.fromValue(element.status);

      if (status == Status.administeredSuccess) {
        administeredChildrenList.add(element);
      } else if (status == Status.beneficiaryRefused) {
        refusalCasesList.add(element);
      }

      if (element.additionalFields?.fields.firstWhereOrNull((element) =>
              element.key ==
              additional_fields_local.AdditionalFieldsType.zeroDoseStatus
                  .toValue()) !=
          null) {
        zeroDoseChildrenList.add(element);
      }
    }

    for (var task in administeredChildrenList) {
      for (var resource in task.resources!) {
        for (var productVariant in productVariantList) {
          if (productVariant.id == resource.productVariantId &&
              productVariant.sku == Constants.spaq1) {
            spaq1List.add(resource);
          } else if (productVariant.id == resource.productVariantId &&
              productVariant.sku == Constants.spaq2) {
            spaq2List.add(resource);
          }
        }
      }
    }

    Map<String, List<HouseholdMemberModel>> dateVsHouseholdMembersList = {};
    Map<String, List<TaskModel>> dateVsAdministeredChilderenList = {};
    Map<String, List<TaskModel>> dateVsRefusalCasesList = {};
    Map<String, List<TaskResourceModel>> dateVsSpaq1List = {};
    Map<String, List<TaskResourceModel>> dateVsSpaq2List = {};
    Map<String, List<TaskModel>> dateVsZeroDoseChildrenList = {};
    Set<String> uniqueDates = {};
    Map<String, int> dateVsHouseholdMembersCount = {};
    Map<String, int> dateVsAdministeredChilderenCount = {};
    Map<String, int> dateVsRefusalCasesCount = {};
    Map<String, int> dateVsZeroDoseChildrenCount = {};
    Map<String, int> dateVsSpaq1Count = {};
    Map<String, int> dateVsSpaq2Count = {};
    Map<String, Map<String, int>> dateVsEntityVsCountMap = {};
    for (var element in householdMemberList) {
      var dateKey = DigitDateUtils.getDateFromTimestamp(
          element.clientAuditDetails!.createdTime);
      dateVsHouseholdMembersList.putIfAbsent(dateKey, () => []).add(element);
    }
    for (var element in administeredChildrenList) {
      var dateKey = DigitDateUtils.getDateFromTimestamp(
          element.clientAuditDetails!.createdTime);
      dateVsAdministeredChilderenList
          .putIfAbsent(dateKey, () => [])
          .add(element);
    }
    for (var element in refusalCasesList) {
      var dateKey = DigitDateUtils.getDateFromTimestamp(
          element.clientAuditDetails!.createdTime);
      dateVsRefusalCasesList.putIfAbsent(dateKey, () => []).add(element);
    }
    for (var element in zeroDoseChildrenList) {
      var dateKey = DigitDateUtils.getDateFromTimestamp(
          element.clientAuditDetails!.createdTime);
      dateVsZeroDoseChildrenList.putIfAbsent(dateKey, () => []).add(element);
    }
    for (var element in spaq1List) {
      var dateKey = DigitDateUtils.getDateFromTimestamp(
          element.auditDetails!.createdTime);
      dateVsSpaq1List.putIfAbsent(dateKey, () => []).add(element);
    }
    for (var element in spaq2List) {
      var dateKey = DigitDateUtils.getDateFromTimestamp(
          element.auditDetails!.createdTime);
      dateVsSpaq2List.putIfAbsent(dateKey, () => []).add(element);
    }

    // get a set of unique dates
    getUniqueSetOfDates(
      dateVsHouseholdMembersList,
      dateVsAdministeredChilderenList,
      dateVsRefusalCasesList,
      dateVsZeroDoseChildrenList,
      dateVsSpaq1List,
      dateVsSpaq2List,
      uniqueDates,
    );

    // populate the day vs count for that day map
    populateDateVsCountMap(
        dateVsHouseholdMembersList, dateVsHouseholdMembersCount);
    populateDateVsCountMap(
        dateVsAdministeredChilderenList, dateVsAdministeredChilderenCount);
    populateDateVsCountMap(dateVsRefusalCasesList, dateVsRefusalCasesCount);
    populateDateVsCountMap(
        dateVsZeroDoseChildrenList, dateVsZeroDoseChildrenCount);
    populateDateVsCountMap(dateVsSpaq1List, dateVsSpaq1Count);
    populateDateVsCountMap(dateVsSpaq2List, dateVsSpaq2Count);

    popoulateDateVsEntityCountMap(
      dateVsEntityVsCountMap,
      dateVsHouseholdMembersCount,
      dateVsAdministeredChilderenCount,
      dateVsRefusalCasesCount,
      dateVsZeroDoseChildrenCount,
      dateVsSpaq1Count,
      dateVsSpaq2Count,
      uniqueDates,
    );
    dateVsEntityVsCountMap =
        sortMapByDateKeyAndRenameDate(dateVsEntityVsCountMap);
    dateVsEntityVsCountMap = addTotalEntryToMap(dateVsEntityVsCountMap);

    emit(SummaryReportDataState(data: dateVsEntityVsCountMap));
  }

  void getUniqueSetOfDates(
    Map<String, List<HouseholdMemberModel>> dateVsHouseholdMembersList,
    Map<String, List<TaskModel>> dateVsAdministeredChilderenList,
    Map<String, List<TaskModel>> dateVsRefusalCasesList,
    Map<String, List<TaskModel>> dateVsZeroDoseChildrenList,
    Map<String, List<TaskResourceModel>> dateVsSpaq1List,
    Map<String, List<TaskResourceModel>> dateVsSpaq2List,
    Set<String> uniqueDates,
  ) {
    uniqueDates.addAll(dateVsHouseholdMembersList.keys.toSet());
    uniqueDates.addAll(dateVsAdministeredChilderenList.keys.toSet());
    uniqueDates.addAll(dateVsRefusalCasesList.keys.toSet());
    uniqueDates.addAll(dateVsZeroDoseChildrenList.keys.toSet());
    uniqueDates.addAll(dateVsSpaq1List.keys.toSet());
    uniqueDates.addAll(dateVsSpaq2List.keys.toSet());
  }

  void populateDateVsCountMap(
      Map<String, List> map, Map<String, int> dateVsCount) {
    map.forEach((key, value) {
      dateVsCount[key] = value.length;
    });
  }

  void popoulateDateVsEntityCountMap(
    Map<String, Map<String, int>> dateVsEntityVsCountMap,
    Map<String, int> dateVsHouseholdMembersCount,
    Map<String, int> dateVsAdministeredChilderenCount,
    Map<String, int> dateVsRefusalCasesCount,
    Map<String, int> dateVsZeroDoseChildrenCount,
    Map<String, int> dateVsSpaq1Count,
    Map<String, int> dateVsSpaq2Count,
    Set<String> uniqueDates,
  ) {
    for (var date in uniqueDates) {
      Map<String, int> elementVsCount = {};
      if (dateVsHouseholdMembersCount.containsKey(date) &&
          dateVsHouseholdMembersCount[date] != null) {
        var count = dateVsHouseholdMembersCount[date];
        elementVsCount[Constants.registered] = count ?? 0;
      }
      if (dateVsAdministeredChilderenCount.containsKey(date) &&
          dateVsAdministeredChilderenCount[date] != null) {
        var count = dateVsAdministeredChilderenCount[date];
        elementVsCount[Constants.administered] = count ?? 0;
      }
      if (dateVsRefusalCasesCount.containsKey(date) &&
          dateVsRefusalCasesCount[date] != null) {
        var count = dateVsRefusalCasesCount[date];
        elementVsCount[Constants.refusals] = count ?? 0;
      }
      if (dateVsZeroDoseChildrenCount.containsKey(date) &&
          dateVsZeroDoseChildrenCount[date] != null) {
        var count = dateVsZeroDoseChildrenCount[date];
        elementVsCount[Constants.zeroDose] = count ?? 0;
      }
      if (dateVsSpaq1Count.containsKey(date) &&
          dateVsSpaq1Count[date] != null) {
        var count = dateVsSpaq1Count[date];
        elementVsCount[Constants.tablet_3_11] = count ?? 0;
      }
      if (dateVsSpaq2Count.containsKey(date) &&
          dateVsSpaq2Count[date] != null) {
        var count = dateVsSpaq2Count[date];
        elementVsCount[Constants.tablet_12_59] = count ?? 0;
      }

      dateVsEntityVsCountMap[date] = elementVsCount;
    }
  }

  Map<String, Map<String, int>> sortMapByDateKeyAndRenameDate(
    Map<String, Map<String, int>> dateVsEntityVsCountMap,
  ) {
    final sortedEntries = dateVsEntityVsCountMap.entries.toList()
      ..sort((a, b) {
        final dateA = DateTime.parse(_toIsoFormat(a.key));
        final dateB = DateTime.parse(_toIsoFormat(b.key));
        return dateA.compareTo(dateB);
      });

    final Map<String, Map<String, int>> renamedMap = {};

    for (int i = 0; i < sortedEntries.length; i++) {
      final originalDate = sortedEntries[i].key;
      final newKey = '$originalDate Day${i + 1}';
      renamedMap[newKey] = sortedEntries[i].value;
    }

    return renamedMap;
  }

  Map<String, Map<String, int>> addTotalEntryToMap(
      Map<String, Map<String, int>> originalMap) {
    final Map<String, int> totalMap = {};

    for (final dayEntry in originalMap.entries) {
      final dayData = dayEntry.value;
      for (final entry in dayData.entries) {
        totalMap.update(entry.key, (value) => value + entry.value,
            ifAbsent: () => entry.value);
      }
    }

    // Create new map with 'Total' at the beginning
    final Map<String, Map<String, int>> newMap = {
      'Total': totalMap,
      ...originalMap,
    };

    return newMap;
  }

  /// Converts 'dd/MM/yyyy' to 'yyyy-MM-dd' for proper DateTime parsing
  String _toIsoFormat(String dateStr) {
    final parts = dateStr.split('/');
    return '${parts[2]}-${parts[1]}-${parts[0]}';
  }

  Future<void> _handleLoadingEvent(
    SummaryReportLoadingEvent event,
    SummaryReportEmitter emit,
  ) async {
    emit(const SummaryReportLoadingState());
  }
}

@freezed
class SummaryReportEvent with _$SummaryReportEvent {
  const factory SummaryReportEvent.loadSummaryData({
    required String userId,
  }) = SummaryReportLoadDataEvent;

  const factory SummaryReportEvent.loading() = SummaryReportLoadingEvent;
}

@freezed
class SummaryReportState with _$SummaryReportState {
  const factory SummaryReportState.loading() = SummaryReportLoadingState;
  const factory SummaryReportState.empty() = SummaryReportEmptyState;

  const factory SummaryReportState.data({
    @Default({}) Map<String, Map<String, int>> data,
  }) = SummaryReportDataState;
}
