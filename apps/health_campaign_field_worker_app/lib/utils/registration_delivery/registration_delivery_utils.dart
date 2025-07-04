import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';

class UniqueIdGeneration {
  Future<Set<String>> generateUniqueId({
    required String localityCode,
    required String loggedInUserId,
    required bool returnCombinedIds,
  }) async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;

    // Get the Android ID
    String androidId = androidInfo.serialNumber == 'unknown'
        ? androidInfo.id.replaceAll('.', '')
        : androidInfo.serialNumber;

    // Get current timestamp
    int timestamp = DateTime.now().millisecondsSinceEpoch;

    // Combine the Android ID with the timestamp
    String combinedId = '$loggedInUserId$androidId$localityCode$timestamp';

    // Generate SHA-256 hash
    List<int> bytes = utf8.encode(combinedId);
    Digest sha256Hash = sha256.convert(bytes);

    // Convert the hash to a 12-character string and make it uppercase
    String hashString = sha256Hash.toString();
    String uniqueId = hashString.substring(0, 12).toUpperCase();

    // Add a hyphen every 4 characters, except the last
    String formattedUniqueId = uniqueId.replaceAllMapped(
      RegExp(r'.{1,4}'),
      (match) => '${match.group(0)}-',
    );

    // Remove the last hyphen
    formattedUniqueId =
        formattedUniqueId.substring(0, formattedUniqueId.length - 1);

    if (kDebugMode) {
      print('uniqueId : $formattedUniqueId');
    }

    return returnCombinedIds
        ? {formattedUniqueId, combinedId}
        : {formattedUniqueId};
  }

  Future<Set<String>> generateUniqueMaterialNoteNumber({
    required String loggedInUserId,
    required bool returnCombinedIds,
  }) async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;

    String androidId = androidInfo.serialNumber == 'unknown'
        ? androidInfo.id.replaceAll('.', '')
        : androidInfo.serialNumber;

    int timestamp = DateTime.now().millisecondsSinceEpoch;

    String combinedId = '$loggedInUserId$androidId$timestamp';

    // Generate SHA-256 hash
    List<int> bytes = utf8.encode(combinedId);
    Digest sha256Hash = sha256.convert(bytes);

    // Convert the hash to a 12-character string and make it uppercase
    String hashString = sha256Hash.toString();
    String uniqueId = hashString.substring(0, 12).toUpperCase();

    // Add a hyphen every 4 characters
    String formattedUniqueId = uniqueId.replaceAllMapped(
      RegExp(r'.{1,4}'),
      (match) => '${match.group(0)}-',
    );

    // Remove the last hyphen
    formattedUniqueId =
        formattedUniqueId.substring(0, formattedUniqueId.length - 1);

    if (kDebugMode) {
      print('uniqueId : $formattedUniqueId');
    }

    return returnCombinedIds
        ? {formattedUniqueId, combinedId}
        : {formattedUniqueId};
  }
}
