import 'dart:convert';

import 'package:digit_data_model/data_model.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../models/auth/auth_model.dart';
import '../../../models/role_actions/role_actions_model.dart';

class LocalSecureStore {
  static const accessTokenKey = 'accessTokenKey';
  static const refreshTokenKey = 'refreshTokenKey';
  static const userObjectKey = 'userObject';
  static const selectedProjectKey = 'selectedProject';
  static const selectedIndividualKey = 'selectedIndividual';
  static const hasAppRunBeforeKey = 'hasAppRunBefore';
  static const backgroundServiceKey = 'backgroundServiceKey';
  static const boundaryRefetchInKey = 'boundaryRefetchInKey';
  static const actionsListkey = 'actionsListkey';
  static const isAppInActiveKey = 'isAppInActiveKey';
  static const manualSyncKey = 'manualSyncKey';
  static const selectedProjectTypeKey = 'selectedProjectType';
  static const spaq1Key = 'spaq1';
  static const spaq2Key = 'spaq2';
  static const blueVasKey = 'blueVas';
  static const redVasKey = 'redVas';

  List<String> keysToKeep = [spaq1Key, spaq2Key,blueVasKey,redVasKey];

  final storage = const FlutterSecureStorage();

  static LocalSecureStore get instance => _instance;
  static final LocalSecureStore _instance = LocalSecureStore._();

  LocalSecureStore._();

  Future<String?> get accessToken {
    return storage.read(key: accessTokenKey);
  }

  Future<String?> get refreshToken {
    return storage.read(key: refreshTokenKey);
  }

  Future<bool> get isBackgroundSerivceRunning async {
    final hasRun = await storage.read(key: backgroundServiceKey);

    switch (hasRun) {
      case 'true':
        return true;
      default:
        return false;
    }
  }

  Future<UserRequestModel?> get userRequestModel async {
    final userBody = await storage.read(key: userObjectKey);
    if (userBody == null) return null;

    try {
      final user = UserRequestModel.fromJson(json.decode(userBody));

      return user;
    } catch (_) {
      return null;
    }
  }

  Future<String?> get userIndividualId async {
    final individualId = await storage.read(key: selectedIndividualKey);
    if (individualId == null) return null;

    try {
      final user = individualId;

      return user;
    } catch (_) {
      return null;
    }
  }

  Future<ProjectModel?> get selectedProject async {
    final projectString = await storage.read(key: selectedProjectKey);
    if (projectString == null) return null;

    try {
      final project = ProjectModelMapper.fromMap(json.decode(projectString));

      return project;
    } catch (_) {
      return null;
    }
  }

  Future<ProjectType?> get selectedProjectType async {
    final projectBody = await storage.read(key: selectedProjectTypeKey);
    if (projectBody == null) return null;

    try {
      final projectType = ProjectType.fromJson(json.decode(projectBody));

      return projectType;
    } catch (_) {
      return null;
    }
  }

  Future<bool> get isAppInActive async {
    final hasRun = await storage.read(key: isAppInActiveKey);

    switch (hasRun) {
      case 'true':
        return true;
      default:
        return false;
    }
  }

  Future<bool> get isManualSyncRunning async {
    final hasRun = await storage.read(key: manualSyncKey);

    switch (hasRun) {
      case 'true':
        return true;
      default:
        return false;
    }
  }

  Future<RoleActionsWrapperModel?> get savedActions async {
    final actionsListString = await storage.read(key: actionsListkey);
    if (actionsListString == null) return null;

    try {
      final actions =
          RoleActionsWrapperModel.fromJson(json.decode(actionsListString));

      return actions;
    } catch (_) {
      return null;
    }
  }

  Future<bool> get boundaryRefetched async {
    final isboundaryRefetchRequired =
        await storage.read(key: boundaryRefetchInKey);

    switch (isboundaryRefetchRequired) {
      case 'true':
        return false;
      default:
        return true;
    }
  }

  Future<int> get spaq1 async {
    final userBody = await storage.read(key: userObjectKey);
    if (userBody == null) return 0;
    final spaq1MapString = await storage.read(key: spaq1Key);

    if (spaq1MapString == null) return 0;

    try {
      final user = UserRequestModel.fromJson(json.decode(userBody));

      Map<String, dynamic> spaq1Map = json.decode(spaq1MapString);

      return spaq1Map[user.uuid] != null ? spaq1Map[user.uuid] as int : 0;
    } catch (_) {
      return 0;
    }
  }

  Future<int> get spaq2 async {
    final userBody = await storage.read(key: userObjectKey);
    if (userBody == null) return 0;
    final spaq2MapString = await storage.read(key: spaq2Key);

    if (spaq2MapString == null) return 0;

    try {
      final user = UserRequestModel.fromJson(json.decode(userBody));

      Map<String, dynamic> spaq2Map = json.decode(spaq2MapString);

      return spaq2Map[user.uuid] != null ? spaq2Map[user.uuid] as int : 0;
    } catch (_) {
      return 0;
    }
  }

// for VAS
  Future<int> get blueVas async {
    final userBody = await storage.read(key: userObjectKey);
    if (userBody == null) return 0;
    final blueVasMapString = await storage.read(key: blueVasKey);

    if (blueVasMapString == null) return 0;

    try {
      final user = UserRequestModel.fromJson(json.decode(userBody));

      Map<String, dynamic> blueVasMap = json.decode(blueVasMapString);

      return blueVasMap[user.uuid] != null ? blueVasMap[user.uuid] as int : 0;
    } catch (_) {
      return 0;
    }
  }
  Future<int> get redVas async {
    final userBody = await storage.read(key: userObjectKey);
    if (userBody == null) return 0;
    final redVasMapString = await storage.read(key: redVasKey);

    if (redVasMapString == null) return 0;

    try {
      final user = UserRequestModel.fromJson(json.decode(userBody));

      Map<String, dynamic> redVasMap = json.decode(redVasMapString);

      return redVasMap[user.uuid] != null ? redVasMap[user.uuid] as int : 0;
    } catch (_) {
      return 0;
    }
  }

  Future<void> setSpaqCounts(int spaq1, int spaq2, int blueVas,int redVas) async {
    final userBody = await storage.read(key: userObjectKey);
    if (userBody == null) return;

    try {
      final user = UserRequestModel.fromJson(json.decode(userBody));

      final spaq1MapString = await storage.read(key: spaq1Key);
      final spaq2MapString = await storage.read(key: spaq2Key);
      final blueVasMapString = await storage.read(key: blueVasKey);
      final redVasMapString = await storage.read(key: redVasKey);
      Map<String, dynamic> spaq1Map = {};
      Map<String, dynamic> spaq2Map = {};

      Map<String, dynamic> blueVasMap = {};
      Map<String, dynamic> redVasMap = {};

      if (spaq1MapString != null) {
        try {
          spaq1Map = json.decode(spaq1MapString);
        } catch (_) {}
      }

      if (spaq2MapString != null) {
        try {
          spaq2Map = json.decode(spaq2MapString);
        } catch (_) {}
      }

      if (blueVasMapString != null) {
        try {
          blueVasMap = json.decode(blueVasMapString);
        } catch (_) {}
      }

      if (redVasMapString != null) {
        try {
          redVasMap = json.decode(redVasMapString);
        } catch (_) {}
      }

      spaq1Map[user.uuid] = spaq1;
      spaq2Map[user.uuid] = spaq2;

      blueVasMap[user.uuid] = blueVas;
      redVasMap[user.uuid] = redVas;

      await storage.write(
        key: spaq1Key,
        value: json.encode(spaq1Map),
      );

      await storage.write(
        key: spaq2Key,
        value: json.encode(spaq2Map),
      );

      await storage.write(
        key: blueVasKey,
        value: json.encode(blueVasMap),
      );
      await storage.write(
        key: redVasKey,
        value: json.encode(redVasMap),
      );
    } catch (_) {
      return;
    }
  }

  Future<void> setSelectedProject(ProjectModel projectModel) async {
    await storage.write(
      key: selectedProjectKey,
      value: projectModel.toJson(),
    );
  }

  Future<void> setSelectedProjectType(ProjectType? projectType) async {
    await storage.write(
      key: selectedProjectTypeKey,
      value: json.encode(projectType),
    );
  }

  Future<void> setSelectedIndividual(String? individualId) async {
    await storage.write(
      key: selectedIndividualKey,
      value: individualId,
    );
  }

  // Note TO the app  as Trigger Manual Sync or Not
  Future<void> setManualSyncTrigger(bool isManualSync) async {
    await storage.write(
      key: manualSyncKey,
      value: isManualSync.toString(),
    );
  }

  Future<void> setAuthCredentials(AuthModel model) async {
    await storage.write(key: accessTokenKey, value: model.accessToken);
    await storage.write(key: refreshTokenKey, value: model.refreshToken);
    await storage.write(
      key: userObjectKey,
      value: json.encode(model.userRequestModel),
    );
  }

  Future<void> setBoundaryRefetch(bool isboundaryRefetch) async {
    await storage.write(
      key: boundaryRefetchInKey,
      value: isboundaryRefetch.toString(),
    );
  }

  Future<void> setRoleActions(RoleActionsWrapperModel actions) async {
    await storage.write(
      key: actionsListkey,
      value: json.encode(actions),
    );
  }

  Future<void> setBackgroundService(bool isRunning) async {
    await storage.write(key: backgroundServiceKey, value: isRunning.toString());
  }

  Future<void> setHasAppRunBefore(bool hasRunBefore) async {
    await storage.write(key: hasAppRunBeforeKey, value: '$hasRunBefore');
  }

  // Note TO the app is in closed state or not
  Future<void> setAppInActive(bool isRunning) async {
    await storage.write(key: isAppInActiveKey, value: isRunning.toString());
  }

  Future<bool> get hasAppRunBefore async {
    final hasRun = await storage.read(key: hasAppRunBeforeKey);

    switch (hasRun) {
      case 'true':
        return true;
      default:
        return false;
    }
  }

  Future<void> deleteAll() async {

   // await storage.deleteAll();

    Map<String, String> allValues = await storage.readAll();
    List<String> allKeys = allValues.keys.toList();

    List<String> keysToDelete =
        allKeys.where((key) => !keysToKeep.contains(key)).toList();

    for (String key in keysToDelete) {
      await storage.delete(key: key);
    }
  }

  /*Sets the bool value of project setup as true once project data is downloaded*/
  Future<void> setProjectSetUpComplete(String key, bool value) async {
    await storage.write(
      key: key,
      value: value.toString(),
    );
  }

  /*Checks for project data loaded or not*/
  Future<bool> isProjectSetUpComplete(String projectId) async {
    final isProjectSetUpComplete = await storage.read(key: projectId);

    switch (isProjectSetUpComplete) {
      case 'true':
        return true;
      default:
        return false;
    }
  }
}
