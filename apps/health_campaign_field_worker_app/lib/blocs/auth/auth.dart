import 'dart:async';

import 'package:digit_data_model/data_model.dart';
import 'package:digit_ui_components/utils/app_logger.dart';
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../data/local_store/secure_store/secure_store.dart';
import '../../data/repositories/remote/auth.dart';
import '../../data/repositories/remote/mdms.dart';
import '../../models/auth/auth_model.dart';
import '../../models/entities/roles_type.dart';
import '../../models/role_actions/role_actions_model.dart';
import '../../utils/environment_config.dart';

// part 'auth.freezed.dart' need to be added to auto generate the files for freezed model
part 'auth.freezed.dart';

typedef AuthEmitter = Emitter<AuthState>;

//Auth Bloc will be used to handle user authentication services
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LocalSecureStore localSecureStore;
  final AuthRepository authRepository;
  final MdmsRepository mdmsRepository;
  final RemoteRepository<IndividualModel, IndividualSearchModel>
      individualRemoteRepository;

  AuthBloc({
    required this.authRepository,
    required this.mdmsRepository,
    required this.individualRemoteRepository,
    LocalSecureStore? localSecureStore,
  })  : localSecureStore = LocalSecureStore.instance,
        super(const AuthUnauthenticatedState()) {
    on(_onLogin);
    on(_onLogout);
    on(_onAutoLogin);
    on(_onAddSpaqCounts);
  }

  //_onAutoLogin event handles auto-login of the user when the user is already logged in and token is not expired, AuthenticatedWrapper is returned in UI
  FutureOr<void> _onAutoLogin(
    AuthAutoLoginEvent event,
    AuthEmitter emit,
  ) async {
    emit(const AuthLoadingState());

    try {
      final accessToken = await localSecureStore.accessToken;
      final refreshToken = await localSecureStore.refreshToken;
      final userObject = await localSecureStore.userRequestModel;
      final actionsList = await localSecureStore.savedActions;
      final userIndividualId = await localSecureStore.userIndividualId;
      final spaq1 = await localSecureStore.spaq1;
      final spaq2 = await localSecureStore.spaq2;

      final blueVas = await localSecureStore.blueVas;
      final redVas = await localSecureStore.redVas;

      if (accessToken == null ||
          refreshToken == null ||
          userObject == null ||
          actionsList == null) {
        emit(const AuthUnauthenticatedState());
      } else {
        emit(AuthAuthenticatedState(
          accessToken: accessToken,
          refreshToken: refreshToken,
          userModel: userObject,
          individualId: userIndividualId,
          actionsWrapper: actionsList,
          spaq1Count: spaq1,
          spaq2Count: spaq2,
          blueVasCount: blueVas,
          redVasCount: redVas,
        ));
      }
    } catch (_) {
      emit(const AuthUnauthenticatedState());
      rethrow;
    }
  }

  //_onLogin event handles login of the user
  // Here we set the authToken and loggedIn user details in local storage and allow the user to perform actions
  FutureOr<void> _onLogin(AuthLoginEvent event, AuthEmitter emit) async {
    emit(const AuthLoadingState());

    try {
      final AuthModel result = await authRepository.fetchAuthToken(
        loginModel: LoginModel(
          username: event.userId,
          password: event.password,
          tenantId: event.tenantId,
        ),
      );
      await localSecureStore.setAuthCredentials(result);
      await localSecureStore.setBoundaryRefetch(true);

      final actionsWrapper = await mdmsRepository
          .searchRoleActions(envConfig.variables.actionMapApiPath, {
        "roleCodes": result.userRequestModel.roles.map((e) => e.code).toList(),
        "tenantId": envConfig.variables.tenantId,
        "actionMaster": "actions-test",
        "enabled": true,
      });
      await localSecureStore.setBoundaryRefetch(true);
      final spaq1 = await localSecureStore.spaq1;
      final spaq2 = await localSecureStore.spaq2;
      final blueVas = await localSecureStore.blueVas;
      final redVas = await localSecureStore.redVas;

      await localSecureStore.setRoleActions(actionsWrapper);
      if (result.userRequestModel.roles
          .where((role) =>
              role.code == RolesType.districtSupervisor.toValue() ||
              role.code == RolesType.attendanceStaff.toValue())
          .toList()
          .isNotEmpty) {
        final loggedInIndividual = await individualRemoteRepository.search(
          IndividualSearchModel(
            userUuid: [result.userRequestModel.uuid],
          ),
        );
        await localSecureStore
            .setSelectedIndividual(loggedInIndividual.firstOrNull?.id);
      }

      emit(
        AuthAuthenticatedState(
            accessToken: result.accessToken,
            refreshToken: result.refreshToken,
            userModel: result.userRequestModel,
            actionsWrapper: actionsWrapper,
            individualId: await localSecureStore.userIndividualId,
            spaq1Count: spaq1,
            spaq2Count: spaq2,
            blueVasCount: blueVas,
            redVasCount: redVas),
      );
    } on DioException catch (error) {
      emit(const AuthErrorState());
      emit(const AuthUnauthenticatedState());

      AppLogger.instance.error(
        title: 'Login error',
        message: error.response?.data.toString(),
      );
    } catch (_) {
      emit(const AuthErrorState());
      emit(const AuthUnauthenticatedState());
      rethrow;
    }
  }

  //_onLogout event logs out the user and deletes the saved user details from local storage
  FutureOr<void> _onLogout(AuthLogoutEvent event, AuthEmitter emit) async {
    try {
      emit(const AuthLoadingState());
      await localSecureStore.deleteAll();
      await localSecureStore.setBoundaryRefetch(true);
    } catch (error) {
      rethrow;
    }
    emit(const AuthUnauthenticatedState());
  }

  FutureOr<void> _onAddSpaqCounts(
    AuthAddSpaqCountsEvent event,
    AuthEmitter emit,
  ) async {
    // emit(const AuthLoadingState());

    try {
      int spaq1 = await localSecureStore.spaq1;
      int spaq2 = await localSecureStore.spaq2;
      int blueVas = await localSecureStore.blueVas;
      int redVas = await localSecureStore.redVas;

      int additionSpaq1Count = event.spaq1Count;
      int additionSpaq2Count = event.spaq2Count;
      int additionBlueVasCount = event.blueVasCount;
      int additionRedVasCount = event.redVasCount;

      spaq1 = spaq1 + additionSpaq1Count;
      spaq2 = spaq2 + additionSpaq2Count;
      blueVas = blueVas + additionBlueVasCount;
      redVas = redVas + additionRedVasCount;

      localSecureStore.setSpaqCounts(spaq1, spaq2, blueVas, redVas);

      final accessToken = await localSecureStore.accessToken;
      final refreshToken = await localSecureStore.refreshToken;
      final userObject = await localSecureStore.userRequestModel;
      final actionsList = await localSecureStore.savedActions;
      final userIndividualId = await localSecureStore.userIndividualId;

      if (accessToken == null ||
          refreshToken == null ||
          userObject == null ||
          actionsList == null) {
        emit(const AuthUnauthenticatedState());
      } else {
        emit(AuthAuthenticatedState(
          accessToken: accessToken,
          refreshToken: refreshToken,
          userModel: userObject,
          individualId: userIndividualId,
          actionsWrapper: actionsList,
          spaq1Count: spaq1,
          spaq2Count: spaq2,
          blueVasCount: blueVas,
          redVasCount: redVas,
        ));
      }
    } catch (_) {
      await localSecureStore.deleteAll();
      emit(const AuthUnauthenticatedState());
      rethrow;
    }
  }
}

@freezed
class AuthEvent with _$AuthEvent {
  const factory AuthEvent.login({
    required String userId,
    required String password,
    required String tenantId,
  }) = AuthLoginEvent;

  const factory AuthEvent.addSpaqCounts({
    required int spaq1Count,
    required int spaq2Count,
    required int blueVasCount,
    required int redVasCount,
  }) = AuthAddSpaqCountsEvent;

  const factory AuthEvent.autoLogin({
    required String tenantId,
  }) = AuthAutoLoginEvent;

  const factory AuthEvent.logout() = AuthLogoutEvent;
}

@freezed
class AuthState with _$AuthState {
  const factory AuthState.unauthenticated() = AuthUnauthenticatedState;

  const factory AuthState.loading() = AuthLoadingState;

  const factory AuthState.authenticated({
    required String accessToken,
    required String refreshToken,
    required UserRequestModel userModel,
    required RoleActionsWrapperModel actionsWrapper,
    String? individualId,
    final int? spaq1Count,
    final int? spaq2Count,
    final int? blueVasCount,
    final int? redVasCount,
  }) = AuthAuthenticatedState;

  const factory AuthState.error([String? error]) = AuthErrorState;
}
