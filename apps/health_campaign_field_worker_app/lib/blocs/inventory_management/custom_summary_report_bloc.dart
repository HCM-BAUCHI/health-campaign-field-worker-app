import 'dart:async';
import 'package:collection/collection.dart';
import 'package:digit_data_model/data_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:intl/intl.dart';
import 'package:inventory_management/models/entities/stock.dart';
import 'package:inventory_management/models/entities/transaction_type.dart';
import 'package:inventory_management/utils/typedefs.dart' as stock_repository;
import 'package:registration_delivery/models/entities/household_member.dart';
import 'package:registration_delivery/models/entities/task.dart';
import 'package:registration_delivery/models/entities/task_resource.dart';
import 'package:registration_delivery/utils/typedefs.dart';

import '../../models/entities/additional_fields_type.dart';
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
  final stock_repository.StockDataRepository stockDataRepository;

  SummaryReportBloc({
    required this.householdMemberRepository,
    required this.productVariantDataRepository,
    required this.taskDataRepository,
    required this.stockDataRepository,
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
    List<TaskModel> administeredChildrenList = [];
    List<TaskModel> SPAQRedoseTaskList = [];
    List<StockModel> stockList = [];
    List<StockModel> returnStockList = [];
    List<ProductVariantModel> productVariantList = [];
    List<StockModel> spaq1List = [];
    List<StockModel> spaq2List = [];
    List<StockModel> redVasList = [];
    List<StockModel> blueVasList = [];
    List<TaskResourceModel> SPAQRedoseList = [];
    householdMemberList = await (householdMemberRepository)
        .search(HouseholdMemberSearchModel(isHeadOfHousehold: true));
    taskList = await (taskDataRepository).search(TaskSearchModel());
    productVariantList = await (productVariantDataRepository)
        .search(ProductVariantSearchModel());
    stockList = await (stockDataRepository).search(StockSearchModel(
        transactionType: [TransactionType.received.toValue()]));
    returnStockList = await (stockDataRepository).search(StockSearchModel(
        transactionType: [TransactionType.dispatched.toValue()]));
    for (var element in taskList) {
      final status = StatusMapper.fromValue(element.status);

      if (status == Status.administeredSuccess) {
        final val = element.additionalFields?.fields
            .firstWhereOrNull(
                (f) => f.key == AdditionalFieldsType.deliveryType.toValue())
            ?.value;
        if (val == EligibilityAssessmentStatus.smcDone.name) {
          administeredChildrenList.add(element);
        }
      }
      if (status == Status.visited) {
        final val = element.additionalFields?.fields
            .firstWhereOrNull((f) => f.key == Constants.reAdministeredKey)
            ?.value;
        if (val == "true" || val == true) {
          SPAQRedoseTaskList.add(element);
        }
      }
    }

    for (var task in SPAQRedoseTaskList) {
      for (var resource in task.resources!) {
        for (var productVariant in productVariantList) {
          if (productVariant.id == resource.productVariantId &&
              productVariant.sku == Constants.spaq1) {
            SPAQRedoseList.add(resource);
          } else if (productVariant.id == resource.productVariantId &&
              productVariant.sku == Constants.spaq2) {
            SPAQRedoseList.add(resource);
          }
        }
      }
    }
    for (var stock in stockList) {
      final productName = stock.additionalFields?.fields
          .firstWhereOrNull((f) => f.key == "productName")
          ?.value;
      if (productName == Constants.spaq1) {
        spaq1List.add(stock);
      } else if (productName == Constants.spaq2) {
        spaq2List.add(stock);
      } else if (productName == Constants.redVAS) {
        redVasList.add(stock);
      } else if (productName == Constants.blueVAS) {
        blueVasList.add(stock);
      }
    }

    Map<String, List<HouseholdMemberModel>> dateVsHouseholdMembersList = {};
    Map<String, List<TaskModel>> dateVsAdministeredChilderenList = {};
    Map<String, List<StockModel>> dateVsSpaq1List = {};
    Map<String, List<StockModel>> dateVsSpaq2List = {};
    Map<String, List<StockModel>> dateVsRedVasList = {};
    Map<String, List<StockModel>> dateVsBlueVasList = {};
    Map<String, List<StockModel>> dateVsReturnStockList = {};
    Map<String, List<TaskResourceModel>> dateVsSPAQRedoseList = {};
    Set<String> uniqueDates = {};
    Map<String, int> dateVsHouseholdMembersCount = {};
    Map<String, int> dateVsAdministeredChilderenCount = {};
    Map<String, int> dateVsSpaq1Count = {};
    Map<String, int> dateVsSpaq2Count = {};
    Map<String, int> dateVsRedVasCount = {};
    Map<String, int> dateVsBlueVasCount = {};
    Map<String, int> dateVsReturnStockCount = {};
    Map<String, int> dateVsSPAQRedoseCount = {};
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
    for (var element in redVasList) {
      var dateKey = DigitDateUtils.getDateFromTimestamp(
          element.auditDetails!.createdTime);
      dateVsRedVasList.putIfAbsent(dateKey, () => []).add(element);
    }
    for (var element in blueVasList) {
      var dateKey = DigitDateUtils.getDateFromTimestamp(
          element.auditDetails!.createdTime);
      dateVsBlueVasList.putIfAbsent(dateKey, () => []).add(element);
    }
    for (var element in SPAQRedoseList) {
      var dateKey = DigitDateUtils.getDateFromTimestamp(
          element.auditDetails!.createdTime);
      dateVsSPAQRedoseList.putIfAbsent(dateKey, () => []).add(element);
    }

    for (var element in returnStockList) {
      final productName = element.additionalFields?.fields
          .firstWhereOrNull((f) => f.key == "productName")
          ?.value;
      if (productName == Constants.spaq1 || productName == Constants.spaq2) {
        var dateKey = DigitDateUtils.getDateFromTimestamp(
            element.auditDetails!.createdTime);
        dateVsReturnStockList.putIfAbsent(dateKey, () => []).add(element);
      }
    }
    // get a set of unique dates
    getUniqueSetOfDates(
      dateVsHouseholdMembersList,
      dateVsAdministeredChilderenList,
      dateVsSpaq1List,
      dateVsSpaq2List,
      dateVsRedVasList,
      dateVsBlueVasList,
      dateVsSPAQRedoseList,
      dateVsReturnStockList,
      uniqueDates,
    );

    // populate the day vs count for that day map
    populateDateVsCountMap(
        dateVsHouseholdMembersList, dateVsHouseholdMembersCount);
    populateDateVsCountMap(
        dateVsAdministeredChilderenList, dateVsAdministeredChilderenCount);

    populateDateVsCountMapForDrugs(dateVsSpaq1List, dateVsSpaq1Count);
    populateDateVsCountMapForDrugs(dateVsSpaq2List, dateVsSpaq2Count);
    populateDateVsCountMapForDrugs(dateVsRedVasList, dateVsRedVasCount);
    populateDateVsCountMapForDrugs(dateVsBlueVasList, dateVsBlueVasCount);
    populateDateVsCountMap(dateVsSPAQRedoseList, dateVsSPAQRedoseCount);
    populateDateVsCountMapForDrugs(
        dateVsReturnStockList, dateVsReturnStockCount);
    popoulateDateVsEntityCountMap(
      dateVsEntityVsCountMap,
      dateVsHouseholdMembersCount,
      dateVsAdministeredChilderenCount,
      dateVsSpaq1Count,
      dateVsSpaq2Count,
      dateVsRedVasCount,
      dateVsBlueVasCount,
      dateVsSPAQRedoseCount,
      dateVsReturnStockCount,
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
    Map<String, List<StockModel>> dateVsSpaq1List,
    Map<String, List<StockModel>> dateVsSpaq2List,
    Map<String, List<StockModel>> dateVsRedVasList,
    Map<String, List<StockModel>> dateVsBlueVasList,
    Map<String, List<TaskResourceModel>> dateVsSPAQRedoseList,
    Map<String, List<StockModel>> dateVsReturnStockList,
    Set<String> uniqueDates,
  ) {
    uniqueDates.addAll(dateVsHouseholdMembersList.keys.toSet());
    uniqueDates.addAll(dateVsAdministeredChilderenList.keys.toSet());
    uniqueDates.addAll(dateVsSpaq1List.keys.toSet());
    uniqueDates.addAll(dateVsSpaq2List.keys.toSet());
    uniqueDates.addAll(dateVsRedVasList.keys.toSet());
    uniqueDates.addAll(dateVsBlueVasList.keys.toSet());
    uniqueDates.addAll(dateVsSPAQRedoseList.keys.toSet());
    uniqueDates.addAll(dateVsReturnStockList.keys.toSet());
  }

  void populateDateVsCountMap(
      Map<String, List> map, Map<String, int> dateVsCount) {
    map.forEach((key, value) {
      dateVsCount[key] = value.length;
    });
  }

  void populateDateVsCountMapForDrugs(
      Map<String, List> map, Map<String, int> dateVsCount) {
    map.forEach((key, value) {
      int totalStock = 0;
      for (var stock in value) {
        int quantity = 0;
        if (stock.quantity != null) {
          quantity = stock.quantity is int
              ? stock.quantity
              : int.tryParse(stock.quantity.toString()) ?? 0;
        }
        totalStock += quantity;
      }
      dateVsCount[key] = totalStock;
    });
  }

  void popoulateDateVsEntityCountMap(
    Map<String, Map<String, int>> dateVsEntityVsCountMap,
    Map<String, int> dateVsHouseholdMembersCount,
    Map<String, int> dateVsAdministeredChilderenCount,
    Map<String, int> dateVsSpaq1Count,
    Map<String, int> dateVsSpaq2Count,
    Map<String, int> dateVsRedVasCount,
    Map<String, int> dateVsBlueVasCount,
    Map<String, int> dateVsSPAQRedoseCount,
    Map<String, int> dateVsReturnStockCount,
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
      if (dateVsSpaq1Count.containsKey(date) &&
          dateVsSpaq1Count[date] != null) {
        var count = dateVsSpaq1Count[date];
        elementVsCount[Constants.spaq1] = count ?? 0;
      }
      if (dateVsSpaq2Count.containsKey(date) &&
          dateVsSpaq2Count[date] != null) {
        var count = dateVsSpaq2Count[date];
        elementVsCount[Constants.spaq2] = count ?? 0;
      }
      if (dateVsRedVasCount.containsKey(date) &&
          dateVsRedVasCount[date] != null) {
        var count = dateVsRedVasCount[date];
        elementVsCount[Constants.redVAS] = count ?? 0;
      }
      if (dateVsBlueVasCount.containsKey(date) &&
          dateVsBlueVasCount[date] != null) {
        var count = dateVsBlueVasCount[date];
        elementVsCount[Constants.blueVAS] = count ?? 0;
      }
      if (dateVsSPAQRedoseCount.containsKey(date) &&
          dateVsSPAQRedoseCount[date] != null) {
        var count = dateVsSPAQRedoseCount[date];
        elementVsCount[Constants.reDoseQuantityKey] = count ?? 0;
      }
      if (dateVsReturnStockCount.containsKey(date) &&
          dateVsReturnStockCount[date] != null) {
        var count = dateVsReturnStockCount[date];
        elementVsCount[Constants.returnStock] = count ?? 0;
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
      // final newKey = '$originalDate Day${i + 1}';
      final parsedDate = DateFormat('dd/MM/yyyy').parse(originalDate);
      final newKey = DateFormat('d MMMM yyyy').format(parsedDate);
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
      // 'Total': totalMap,
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
