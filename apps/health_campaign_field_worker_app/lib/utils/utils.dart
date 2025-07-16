library app_utils;

import 'package:digit_data_model/data_model.dart';
import 'package:intl/intl.dart';
import 'package:inventory_management/inventory_management.dart';
import 'package:referral_reconciliation/referral_reconciliation.dart'
    as referral_reconciliation_mappers;
import 'package:collection/collection.dart';
import 'package:digit_components/utils/date_utils.dart';
import 'package:digit_data_model/models/entities/individual.dart';
import 'package:digit_data_model/models/entities/product_variant.dart';
import 'package:digit_data_model/models/entities/project_type.dart';
import 'package:registration_delivery/models/entities/additional_fields_type.dart';
import 'package:registration_delivery/models/entities/household.dart';
import 'package:registration_delivery/registration_delivery.dart';
import 'package:survey_form/survey_form.init.dart' as surveyForm_mappers;
import 'package:complaints/complaints.init.dart' as complaints_mappers;
import '../../utils/i18_key_constants.dart' as i18_local;
import 'package:inventory_management/utils/i18_key_constants.dart' as i18_stock;

import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:inventory_management/inventory_management.init.dart'
    as inventory_mappers;

import 'package:registration_delivery/registration_delivery.init.dart'
    as registration_delivery_mappers;

import 'dart:async';
import 'dart:io';

import 'package:attendance_management/attendance_management.dart'
    as attendance_mappers;
import 'package:survey_form/survey_form.dart' as surveyForm_mappers;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:digit_data_model/data_model.dart' as data_model;
import 'package:digit_data_model/data_model.init.dart' as data_model_mappers;
import 'package:digit_dss/digit_dss.dart' as dss_mappers;
import 'package:digit_ui_components/digit_components.dart';
import 'package:digit_ui_components/theme/digit_extended_theme.dart';
import 'package:digit_ui_components/utils/component_utils.dart';
import 'package:digit_ui_components/widgets/atoms/pop_up_card.dart';
import 'package:digit_ui_components/widgets/molecules/show_pop_up.dart';
import 'package:disable_battery_optimization/disable_battery_optimization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:isar/isar.dart';
import 'package:reactive_forms/reactive_forms.dart';

import '../blocs/app_initialization/app_initialization.dart';
import '../blocs/projects_beneficiary_downsync/project_beneficiaries_downsync.dart';
import '../data/local_store/app_shared_preferences.dart';
import '../data/local_store/no_sql/schema/localization.dart';
import '../data/local_store/secure_store/secure_store.dart';
import '../models/app_config/app_config_model.dart';
import '../models/entities/identifier_types.dart';
import '../models/entities/roles_type.dart';
import '../router/app_router.dart';
import '../widgets/progress_indicator/progress_indicator.dart';
import 'constants.dart';
import 'extensions/extensions.dart';

export 'app_exception.dart';
export 'constants.dart';
export 'extensions/extensions.dart';

class CustomValidator {
  /// Validates that control's value must be `true`
  static Map<String, dynamic>? requiredMin(
    AbstractControl<dynamic> control,
  ) {
    return control.value == null ||
            control.value.toString().length >= 2 ||
            control.value.toString().trim().isEmpty
        ? null
        : {'required': true};
  }

  static Map<String, dynamic>? validMobileNumber(
    AbstractControl<dynamic> control,
  ) {
    if (control.value == null || control.value.toString().isEmpty) {
      return null;
    }

    const pattern = r'[0-9]';

    if (control.value.toString().length != 11) {
      return {'mobileNumber': true};
    }

    if (RegExp(pattern).hasMatch(control.value.toString())) return null;

    if (control.value.toString().length < 11) return {'mobileNumber': true};

    return {'mobileNumber': true};
  }

  static Map<String, dynamic>? onlyAlphabets(AbstractControl<dynamic> control) {
    final value = control.value?.toString().trim();

    if (value == null || value.isEmpty) return null;

    final pattern = r"^[A-Za-z\s]+$"; // Only A-Z, a-z, and spaces
    final regExp = RegExp(pattern);

    return regExp.hasMatch(value) ? null : {'onlyAlphabets': true};
  }

  static Map<String, dynamic>? onlyAlphabetsAndDigits(
      AbstractControl<dynamic> control) {
    final value = control.value?.toString().trim();

    if (value == null || value.isEmpty) return null;

    final pattern = r'^[A-Za-z0-9\s]+$'; // Allows A-Z, a-z, 0-9, and spaces
    final regExp = RegExp(pattern);

    return regExp.hasMatch(value) ? null : {'onlyAlphabetsAndDigits': true};
  }

  static Map<String, dynamic>? validStockCount(
    AbstractControl<dynamic> control,
  ) {
    if (control.value == null || control.value.toString().isEmpty) {
      return {'required': true};
    }

    var parsed = int.tryParse(control.value) ?? 0;
    if (parsed < 0) {
      return {'min': true};
    } else if (parsed > Constants.stockMaxLimit) {
      return {'max': true};
    }

    return null;
  }

  static Map<String, dynamic>? validStockCountUpdated(
    AbstractControl<dynamic> control,
  ) {
    if (control.value == null || control.value.toString().isEmpty) {
      return {'required': true};
    }

    var parsed = int.tryParse(control.value) ?? 0;
    if (parsed < 0) {
      return {'min': true};
    } else if (parsed > 1000000000) {
      return {'max': true};
    }

    return null;
  }
}

Future<void> requestDisableBatteryOptimization() async {
  bool isIgnoringBatteryOptimizations =
      await DisableBatteryOptimization.isBatteryOptimizationDisabled ?? false;

  if (!isIgnoringBatteryOptimizations) {
    await DisableBatteryOptimization.showDisableBatteryOptimizationSettings();
  }
}

setBgRunning(bool isBgRunning) async {
  final localSecureStore = LocalSecureStore.instance;
  await localSecureStore.setBackgroundService(isBgRunning);
}

int getAgeMonths(DigitDOBAge age) {
  return (age.years * 12) + age.months;
}

performBackgroundService({
  BuildContext? context,
  required bool stopService,
  required bool isBackground,
}) async {
  final connectivityResult = await (Connectivity().checkConnectivity());

  final isOnline = connectivityResult.firstOrNull == ConnectivityResult.wifi ||
      connectivityResult.firstOrNull == ConnectivityResult.mobile;
  final service = FlutterBackgroundService();
  var isRunning = await service.isRunning();

  if (stopService) {
    if (isRunning) {
      if (!isBackground && context != null && context.mounted) {
        if (context.mounted) {
          Toast.showToast(
            context,
            message: 'Background Service Stopped',
            type: ToastType.error,
          );
        }
      }
    }
  } else {
    if (!isRunning && isOnline) {
      service.startService();
      if (context != null && context.mounted) {
        requestDisableBatteryOptimization();
        Toast.showToast(
          context,
          message: 'Background Service Started',
          type: ToastType.success,
        );
      }
    }
  }
}

String formatDateFromMillis(int millis) {
  final date = DateTime.fromMillisecondsSinceEpoch(millis);
  final day = date.day.toString().padLeft(2, '0');
  final month = _monthShort(date.month);
  final year = date.year;
  return '$day $month $year';
}

String _monthShort(int month) {
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec'
  ];
  return months[month - 1];
}

String formatAgeRange(String condition) {
  final regex =
      RegExp(r'(\d+)\s*<=\s*ageandage\s*<\s*(\d+)', caseSensitive: false);
  final match = regex.firstMatch(condition);
  if (match != null && match.groupCount == 2) {
    final min = match.group(1);
    final max = match.group(2);
    return '$min - $max months';
  }
  return condition;
}

bool validateStockSubmission({
  required num availableBalance,
  required num stockReturned,
  required num stockWasted,
}) {
  final total = stockReturned + stockWasted;
  return total <= availableBalance;
}

String customFormatAgeRange(String condition) {
  final regex =
      RegExp(r'(\d+)\s*<\s*ageandage\s*<\s*(\d+)', caseSensitive: false);
  final match = regex.firstMatch(condition);
  if (match != null && match.groupCount == 2) {
    // final min = match.group(1);
    // final max = match.group(2);
    int min = int.parse(match.group(1)!);
    int max = int.parse(match.group(2)!);

    max -= 1;
    min += 1;

    print('min: $min, max: $max');
    return '$min - $max months';
  }
  return condition;
}

String? getAgeConditionStringFromVariant(
    DeliveryProductVariant productVariant, List<ProductVariantModel>? variant) {
  String? finalCondition;
  String? value = variant
      ?.firstWhereOrNull(
        (element) => element.id == productVariant.productVariantId,
      )
      ?.sku;

  if (value != null) {
    finalCondition = value.split('(').last.split(')').first;
  }

  return finalCondition;
}

int getUnderFiveChildCount(HouseholdModel? householdCaptured) {
  final additionalFields = householdCaptured?.additionalFields?.fields;
  if (additionalFields == null || additionalFields.isEmpty) {
    return 0;
  }

  final underFiveChildEntry = additionalFields
      .where(
        (e) => e.key == AdditionalFieldsType.children.toValue(),
      )
      .firstOrNull;

  if (underFiveChildEntry == null) {
    return 0;
  }

  final value = underFiveChildEntry.value;

  if (value == null) {
    return 0;
  } else if (value is int) {
    return value;
  } else if (value is String) {
    return int.tryParse(value) ?? 0;
  } else if (value is double) {
    return value.toInt();
  } else {
    // Any other unexpected type
    return 0;
  }
}

int getPregnantWomenCount(HouseholdModel? householdCaptured) {
  final additionalFields = householdCaptured?.additionalFields?.fields;

  if (additionalFields == null || additionalFields.isEmpty) {
    return 0;
  }

  final pregnantWomenEntry = additionalFields
      .where(
        (e) => e.key == AdditionalFieldsType.pregnantWomen.toValue(),
      )
      .firstOrNull;

  if (pregnantWomenEntry == null) {
    return 0;
  }

  final value = pregnantWomenEntry.value;

  if (value == null) {
    return 0;
  } else if (value is int) {
    return value;
  } else if (value is String) {
    return int.tryParse(value) ?? 0;
  } else if (value is double) {
    return value.toInt();
  } else {
    return 0;
  }
}

Map<String, dynamic>? customValidMobileNumber(
  AbstractControl<dynamic> control,
) {
  if (control.value == null || control.value.toString().isEmpty) {
    return null; // Optional field
  }

  const pattern = r'^\d{11}$'; // Exactly 11 digits

  if (RegExp(pattern).hasMatch(control.value.toString())) {
    return null; // Valid
  }

  return {'mobileNumber': true}; // Invalid
}

String maskString(String input) {
  // Define the character to use for masking (e.g., "*")
  const maskingChar = '*';

  // Create a new string with the same length as the input string
  final maskedString =
      List<String>.generate(input.length, (index) => maskingChar).join();

  return maskedString;
}

List<MdmsMasterDetailModel> getMasterDetailsModel(List<String> masterNames) {
  return masterNames.map((e) => MdmsMasterDetailModel(e)).toList();
}

Timer makePeriodicTimer(
  Duration duration,
  void Function(Timer timer) callback, {
  bool fireNow = false,
}) {
  var timer = Timer.periodic(duration, callback);
  if (fireNow) {
    callback(timer);
  }

  return timer;
}

final requestData = {
  "data": [
    {
      "id": 1,
      "name": "John Doe",
      "age": 30,
      "email": "johndoe@example.com",
      "address": {
        "street": "123 Main Street",
        "city": "New York",
        "state": "NY",
        "zipcode": "10001",
      },
      "orders": [
        {
          "id": 101,
          "product": "Widget A",
          "quantity": 2,
          "price": 10.99,
        },
        {
          "id": 102,
          "product": "Widget B",
          "quantity": 1,
          "price": 19.99,
        },
      ],
    },
    {
      "id": 2,
      "name": "Jane Smith",
      "age": 25,
      "email": "janesmith@example.com",
      "address": {
        "street": "456 Elm Street",
        "city": "Los Angeles",
        "state": "CA",
        "zipcode": "90001",
      },
      "orders": [
        {
          "id": 201,
          "product": "Widget C",
          "quantity": 3,
          "price": 15.99,
        },
        {
          "id": 202,
          "product": "Widget D",
          "quantity": 2,
          "price": 12.99,
        },
      ],
    },
    // ... Repeat the above structure to reach approximately 100KB in size
  ],
};

Future<bool> getIsConnected() async {
  try {
    final result = await InternetAddress.lookup('example.com');
    if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
      return true;
    }

    return false;
  } on SocketException catch (_) {
    return false;
  }
}

String getEntryTypeLabel(StockModel? stock) {
  String label =
      '${i18_stock.stockDetails.receivedPageTitle}_${i18_stock.stockReconciliationDetails.stockLabel}';

  if (stock != null) {
    if (stock.transactionType == "RECEIVED" &&
        stock.transactionReason == "RETURNED") {
      label = i18_local.stockDetails.selectTransactingPartyReturnedFrom;
    } else if (stock.transactionType == "DISPATCHED" &&
        stock.senderType == "STAFF") {
      label = i18_local.stockDetails.returnedTo;
    } else if (stock.transactionType == "DISPATCHED") {
      label =
          '${i18_stock.stockDetails.issuedPageTitle}_${i18_stock.stockReconciliationDetails.stockLabel}';
    }
  }

  return label;
}
/*Old Logic
String getSecondaryPartyValue(StockModel? stock) {
  String value = stock?.receiverId ?? "";

  if (stock != null) {
    if ((stock.transactionType == "RECEIVED" && stock.senderType == "STAFF") ||
        (stock.transactionType == "DISPATCHED" &&
            stock.receiverType == "STAFF")) {
      value = stock.additionalFields?.fields
              .firstWhereOrNull((e) => e.key == "distributorName")
              ?.value ??
          "Delivery Team";
    } else {
      value = stock.transactionType == "RECEIVED"
          ? 'FAC_${stock.senderId}'
          : 'FAC_${stock.receiverId}';
    }
  }

  return value;
}*/

//New Logic
String getSecondaryPartyValue(StockModel? stock) {
  // Use a guard clause for null safety
  if (stock == null) return "";

  // For a RECEIPT, the other party is always the SENDER.
  if (stock.transactionType == "RECEIVED") {
    // This now correctly handles your case without checking senderType.
    return 'FAC_${stock.senderId}';
  }

  // For a DISPATCH, the other party is the RECEIVER.
  // Here we can keep the special logic for STAFF receivers.
  if (stock.transactionType == "DISPATCHED") {
    if (stock.receiverType == "STAFF") {
      return stock.additionalFields?.fields
              .firstWhereOrNull((e) => e.key == "distributorName")
              ?.value ??
          "Delivery Team";
    } else {
      return 'FAC_${stock.receiverId}';
    }
  }

  // Provide a sensible fallback for any other transaction types
  return 'FAC_${stock.receiverId ?? ''}';
}

void showDownloadDialog(
  BuildContext context, {
  required DownloadBeneficiary model,
  required DigitProgressDialogType dialogType,
  bool isPop = true,
  StreamController<double>? downloadProgressController,
}) {
  if (isPop) {
    Navigator.of(context, rootNavigator: true).pop();
  }

  switch (dialogType) {
    case DigitProgressDialogType.failed:
    case DigitProgressDialogType.checkFailed:
      DigitSyncDialog.show(
        context,
        type: DialogType.failed,
        label: model.title,
        primaryAction: DigitDialogActions(
          label: model.primaryButtonLabel ?? '',
          action: (ctx) {
            if (dialogType == DigitProgressDialogType.failed ||
                dialogType == DigitProgressDialogType.checkFailed) {
              Navigator.of(context, rootNavigator: true).pop();
              context.read<BeneficiaryDownSyncBloc>().add(
                    DownSyncGetBatchSizeEvent(
                      appConfiguration: [model.appConfiguartion!],
                      projectId: context.projectId,
                      boundaryCode: model.boundary,
                      pendingSyncCount: model.pendingSyncCount ?? 0,
                      boundaryName: model.boundaryName,
                    ),
                  );
            } else {
              Navigator.of(context, rootNavigator: true).pop();
              context.router.replaceAll([HomeRoute()]);
            }
          },
        ),
        secondaryAction: DigitDialogActions(
          label: model.secondaryButtonLabel ?? '',
          action: (ctx) {
            Navigator.of(context, rootNavigator: true).pop();
            context.router.replaceAll([HomeRoute()]);
          },
        ),
      );
    case DigitProgressDialogType.dataFound:
    case DigitProgressDialogType.pendingSync:
    case DigitProgressDialogType.insufficientStorage:
      showCustomPopup(
        context: context,
        builder: (ctx) => Popup(
          title: model.title,
          titleIcon: Icon(
            dialogType == DigitProgressDialogType.insufficientStorage
                ? Icons.warning
                : Icons.info_outline_rounded,
            color: dialogType == DigitProgressDialogType.insufficientStorage
                ? Theme.of(context).colorTheme.alert.error
                : Theme.of(context).colorTheme.text.primary,
          ),
          description: model.content,
          actions: [
            DigitButton(
                label: model.primaryButtonLabel ?? '',
                onPressed: () {
                  if (dialogType == DigitProgressDialogType.pendingSync) {
                    Navigator.of(context, rootNavigator: true).pop();
                    context.router.replaceAll([HomeRoute()]);
                  } else {
                    if ((model.totalCount ?? 0) > 0) {
                      context.read<BeneficiaryDownSyncBloc>().add(
                            DownSyncBeneficiaryEvent(
                              projectId: context.projectId,
                              boundaryCode: model.boundary,
                              // Batch Size need to be defined based on Internet speed.
                              batchSize: model.batchSize ?? 1,
                              initialServerCount: model.totalCount ?? 0,
                              boundaryName: model.boundaryName,
                            ),
                          );
                    } else {
                      Navigator.of(context, rootNavigator: true).pop();
                      context.read<BeneficiaryDownSyncBloc>().add(
                            const DownSyncResetStateEvent(),
                          );
                    }
                  }
                },
                type: DigitButtonType.primary,
                size: DigitButtonSize.medium),
            if (model.secondaryButtonLabel != null)
              DigitButton(
                  label: model.secondaryButtonLabel ?? '',
                  onPressed: () async {
                    await LocalSecureStore.instance.setManualSyncTrigger(false);
                    if (context.mounted) {
                      Navigator.of(context, rootNavigator: true).pop();
                      context.router.replaceAll([HomeRoute()]);
                    }
                  },
                  type: DigitButtonType.secondary,
                  size: DigitButtonSize.medium),
          ],
        ),
      );
    case DigitProgressDialogType.inProgress:
      showCustomPopup(
        context: context,
        builder: (ctx) => Popup(title: "", additionalWidgets: [
          StreamBuilder<double>(
            stream: downloadProgressController?.stream,
            builder: (context, snapshot) {
              return ProgressIndicatorContainer(
                label: '',
                prefixLabel: '',
                suffixLabel:
                    '${(snapshot.data == null ? 0 : snapshot.data! * model.totalCount!.toDouble()).toInt()}/${model.suffixLabel}',
                value: snapshot.data ?? 0,
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).colorTheme.primary.primary1,
                ),
                subLabel: model.title,
              );
            },
          ),
        ]),
      );
    default:
      return;
  }
}

// Existing _findLeastLevelBoundaryCode method remains unchanged
String _findLeastLevelBoundaryCode(List<data_model.BoundaryModel> boundaries) {
  data_model.BoundaryModel? highestBoundary;

  // Find the boundary with the highest boundaryNum
  for (var boundary in boundaries) {
    if (highestBoundary == null ||
        (boundary.boundaryNum ?? 0) > (highestBoundary.boundaryNum ?? 0)) {
      highestBoundary = boundary;
    }
  }

  // If the highest boundary is a leaf node (no children), it is the least-level boundary
  if (highestBoundary?.children.isEmpty ?? true) {
    // Return the boundary type if available, otherwise fallback to the label or an empty string
    return highestBoundary?.boundaryType ?? highestBoundary?.label ?? "";
  }

  // If the highest boundary has children, recursively search in them
  if (highestBoundary?.children != null) {
    for (var child in highestBoundary!.children) {
      String leastCode = _findLeastLevelBoundaryCode(
          [child]); // Recursively find the least level
      if (leastCode.isNotEmpty) {
        return leastCode;
      }
    }
  }

  // If no boundary found
  return "";
}

// Recursive function to find the least level boundary codes
List<String> findLeastLevelBoundaries(
    List<data_model.BoundaryModel> boundaries) {
  // Find the least level boundary type
  String leastLevelType = _findLeastLevelBoundaryCode(boundaries);

  // Initialize a list to store the matching boundary codes with lowest level boundary type
  List<String> leastLevelBoundaryCodes = [];

  // Iterate through the boundaries to find matching codes
  if (leastLevelType.isNotEmpty) {
    for (var boundary in boundaries) {
      // Check if the boundary matches the least-level type and has no children (leaf node)
      if ((boundary.boundaryType == leastLevelType ||
              boundary.label == leastLevelType) &&
          boundary.children.isEmpty) {
        // Found a least level boundary with no children (leaf node), add its code
        leastLevelBoundaryCodes.add(boundary.code!);
      } else if (boundary.children.isNotEmpty) {
        // Recursively search in the children
        List<String> childVillageCodes =
            findLeastLevelBoundaries(boundary.children);
        leastLevelBoundaryCodes.addAll(childVillageCodes);
      }
    }
  }

  // Return the list of matching boundary codes
  return leastLevelBoundaryCodes;
}

//Function to read the localizations from ISAR,
getLocalizationString(Isar isar, String selectedLocale) async {
  List<dynamic> localizationValues = [];

  final List<LocalizationWrapper> localizationList =
      await isar.localizationWrappers
          .filter()
          .localeEqualTo(
            selectedLocale.toString(),
          )
          .findAll();
  if (localizationList.isNotEmpty) {
    localizationValues.addAll(localizationList.first.localization!);
  }

  return localizationValues;
}

List<dss_mappers.DashboardConfigSchema?> filterDashboardConfig(
    List<dss_mappers.DashboardConfigSchema?>? dashboardConfig,
    String projectTypeCode) {
  return dashboardConfig
          ?.where((element) =>
              element != null && element.projectTypeCode == projectTypeCode)
          .toList() ??
      [];
}

getSelectedLanguage(AppInitialized state, int index) {
  if (AppSharedPreferences().getSelectedLocale == null) {
    AppSharedPreferences()
        .setSelectedLocale(state.appConfiguration.languages!.last.value);
  }
  final selectedLanguage = AppSharedPreferences().getSelectedLocale;
  final isSelected =
      state.appConfiguration.languages![index].value == selectedLanguage;

  return isSelected;
}

bool isLGAUser() {
  String? boundaryLevel =
      RegistrationDeliverySingleton().selectedProject?.address?.boundaryType;
  if (InventorySingleton().isWareHouseMgr) {
    if (boundaryLevel == Constants.lgaBoundaryLevel) {
      return true;
    }
  }
  return false;
}

bool isHFUser(BuildContext context) {
  try {
    // todo : verify this make this healthFacilitySupervsior as per kebbi
    bool isDownSyncEnabled = context.loggedInUserRoles
        .where(
          (role) =>
              role.code == RolesType.healthFacilityWorker.toValue() ||
              role.code == RolesType.healthFacilitySupervisor.toValue(),
        )
        .toList()
        .isNotEmpty;

    return isDownSyncEnabled;
  } catch (_) {
    return false;
  }
}

int getIndividualAge(IndividualModel individualModel) {
  DateTime dateOfBirth =
      DateFormat("dd/MM/yyyy").parse(individualModel.dateOfBirth ?? '');
  DigitDOBAge age = DigitDateUtils.calculateAge(dateOfBirth);
  return getAgeMonths(age);
}

String? getBeneficiaryId(IndividualModel individualModel) {
  IdentifierTypes.uniqueBeneficiaryID.toValue();
  return individualModel.identifiers
          ?.firstWhereOrNull((e) =>
              e.identifierType == IdentifierTypes.uniqueBeneficiaryID.toValue())
          ?.identifierId ??
      '';
}

List<AdditionalField> getIndividualAdditionalFields(
    IndividualModel? individualModel) {
  return [
    if (individualModel != null)
      AdditionalField(
        AdditionalFieldsType.age.toValue(),
        getIndividualAge(individualModel),
      ),
    if (individualModel?.gender != null)
      AdditionalField(
        AdditionalFieldsType.gender.toValue(),
        individualModel?.gender,
      ),
    if (individualModel?.clientReferenceId != null)
      AdditionalField(
        'individualClientReferenceId',
        individualModel?.clientReferenceId,
      ),
    if (individualModel != null && getBeneficiaryId(individualModel) != null)
      AdditionalField(
        'uniqueBeneficiaryId',
        getBeneficiaryId(individualModel),
      ),
  ];
}

initializeAllMappers() async {
  List<Future> initializations = [
    Future(() => data_model_mappers.initializeMappers()),
    Future(() => attendance_mappers.initializeMappers()),
    Future(() => data_model_mappers.initializeMappers()),
    Future(() => dss_mappers.initializeMappers()),
    Future(() => registration_delivery_mappers.initializeMappers()),
    Future(() => inventory_mappers.initializeMappers()),
    Future(() => surveyForm_mappers.initializeMappers()),
    Future(() => complaints_mappers.initializeMappers()),
    Future(() => referral_reconciliation_mappers.initializeMappers()),
  ];
  await Future.wait(initializations);
}

class LocalizationParams {
  static final LocalizationParams _singleton = LocalizationParams._internal();

  factory LocalizationParams() {
    return _singleton;
  }

  LocalizationParams._internal();

  List<String>? _code;
  List<String>? _module;
  Locale? _locale;
  bool? _exclude = true;

  void setCode(List<String>? code) {
    _code = code;
  }

  void setModule(List<String>? module, bool? exclude) {
    _module = module;
    _exclude = exclude;
  }

  void setLocale(Locale locale) {
    _locale = locale;
  }

  void clear() {
    _code = null;
    _module = null;
  }

  List<String>? get code => _code;

  List<String>? get module => _module;

  Locale? get locale => _locale;

  bool? get exclude => _exclude;
}
