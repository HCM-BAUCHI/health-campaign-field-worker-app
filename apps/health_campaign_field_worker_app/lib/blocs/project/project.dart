// GENERATED using mason_cli
import 'dart:async';
import 'dart:core';
import 'dart:math';

import 'package:collection/collection.dart';
import 'package:attendance_management/models/entities/attendance_log.dart';
import 'package:attendance_management/models/entities/attendance_register.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:digit_data_model/data_model.dart';
import 'package:digit_dss/digit_dss.dart';
import 'package:digit_ui_components/utils/app_logger.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:inventory_management/models/entities/stock.dart';
import 'package:inventory_management/models/entities/transaction_type.dart';
import 'package:isar/isar.dart';
import 'package:recase/recase.dart';
import 'package:survey_form/models/entities/service_definition.dart';

import '../../../models/app_config/app_config_model.dart' as app_configuration;
import '../../data/local_store/no_sql/schema/app_configuration.dart';
import '../../data/local_store/no_sql/schema/row_versions.dart';
import '../../data/local_store/secure_store/secure_store.dart';
import '../../data/repositories/local/inventory_management/custom_stock.dart';
import '../../data/repositories/remote/bandwidth_check.dart';
import '../../data/repositories/remote/mdms.dart';
import '../../models/app_config/app_config_model.dart';
import '../../models/auth/auth_model.dart';
import '../../models/entities/roles_type.dart';
import '../../models/data_model.dart';
import '../../utils/background_service.dart';
import '../../utils/environment_config.dart';
import '../../utils/least_level_boundary_singleton.dart';
import '../../utils/utils.dart';
import 'package:inventory_management/data/repositories/remote/stock.dart';

part 'project.freezed.dart';

typedef ProjectEmitter = Emitter<ProjectState>;

class ProjectBloc extends Bloc<ProjectEvent, ProjectState> {
  final LocalSecureStore localSecureStore;
  final Isar isar;
  final MdmsRepository mdmsRepository;

  final BandwidthCheckRepository bandwidthCheckRepository;

  /// Service Definition Repositories
  final RemoteRepository<ServiceDefinitionModel, ServiceDefinitionSearchModel>
      serviceDefinitionRemoteRepository;
  final LocalRepository<ServiceDefinitionModel, ServiceDefinitionSearchModel>
      serviceDefinitionLocalRepository;

  /// Project Staff Repositories
  final RemoteRepository<ProjectStaffModel, ProjectStaffSearchModel>
      projectStaffRemoteRepository;
  final LocalRepository<ProjectStaffModel, ProjectStaffSearchModel>
      projectStaffLocalRepository;

  /// Project Repositories
  final RemoteRepository<ProjectModel, ProjectSearchModel>
      projectRemoteRepository;
  final LocalRepository<ProjectModel, ProjectSearchModel>
      projectLocalRepository;

  final RemoteRepository<IndividualModel, IndividualSearchModel>
      individualRemoteRepository;
  final LocalRepository<IndividualModel, IndividualSearchModel>
      individualLocalRepository;

  /// Project Facility Repositories
  final RemoteRepository<ProjectFacilityModel, ProjectFacilitySearchModel>
      projectFacilityRemoteRepository;
  final LocalRepository<ProjectFacilityModel, ProjectFacilitySearchModel>
      projectFacilityLocalRepository;

  /// Facility Repositories
  final RemoteRepository<FacilityModel, FacilitySearchModel>
      facilityRemoteRepository;
  final LocalRepository<FacilityModel, FacilitySearchModel>
      facilityLocalRepository;

  ///Boundary Resource Repositories
  final RemoteRepository<BoundaryModel, BoundarySearchModel>
      boundaryRemoteRepository;
  final LocalRepository<BoundaryModel, BoundarySearchModel>
      boundaryLocalRepository;

  /// Project Resource Repositories
  final RemoteRepository<ProjectResourceModel, ProjectResourceSearchModel>
      projectResourceRemoteRepository;
  final LocalRepository<ProjectResourceModel, ProjectResourceSearchModel>
      projectResourceLocalRepository;

  /// Attendance Repositories
  final RemoteRepository<AttendanceRegisterModel, AttendanceRegisterSearchModel>
      attendanceRemoteRepository;
  final LocalRepository<AttendanceRegisterModel, AttendanceRegisterSearchModel>
      attendanceLocalRepository;
  final LocalRepository<AttendanceLogModel, AttendanceLogSearchModel>
      attendanceLogLocalRepository;
  final RemoteRepository<AttendanceLogModel, AttendanceLogSearchModel>
      attendanceLogRemoteRepository;

  /// Product Variant Repositories
  final RemoteRepository<ProductVariantModel, ProductVariantSearchModel>
      productVariantRemoteRepository;
  final LocalRepository<ProductVariantModel, ProductVariantSearchModel>
      productVariantLocalRepository;

  /// Stock Repositories
  // final RemoteRepository<StockModel, StockSearchModel> stockRemoteRepository;
  final StockRemoteRepository stockRemoteRepository;
  final LocalRepository<StockModel, StockSearchModel> stockLocalRepository;

  final DashboardRemoteRepository dashboardRemoteRepository;
  BuildContext context;

  ProjectBloc({
    LocalSecureStore? localSecureStore,
    required this.serviceDefinitionRemoteRepository,
    required this.serviceDefinitionLocalRepository,
    required this.bandwidthCheckRepository,
    required this.projectStaffRemoteRepository,
    required this.projectRemoteRepository,
    required this.projectStaffLocalRepository,
    required this.projectLocalRepository,
    required this.projectFacilityRemoteRepository,
    required this.projectFacilityLocalRepository,
    required this.facilityRemoteRepository,
    required this.facilityLocalRepository,
    required this.boundaryRemoteRepository,
    required this.boundaryLocalRepository,
    required this.isar,
    required this.projectResourceLocalRepository,
    required this.projectResourceRemoteRepository,
    required this.productVariantLocalRepository,
    required this.productVariantRemoteRepository,
    required this.mdmsRepository,
    required this.individualLocalRepository,
    required this.individualRemoteRepository,
    required this.dashboardRemoteRepository,
    required this.attendanceRemoteRepository,
    required this.attendanceLocalRepository,
    required this.attendanceLogLocalRepository,
    required this.attendanceLogRemoteRepository,
    required this.stockLocalRepository,
    required this.stockRemoteRepository,
    required this.context,
  })  : localSecureStore = localSecureStore ?? LocalSecureStore.instance,
        super(const ProjectState()) {
    on(_handleProjectInit);
    on(_handleProjectSelection);
  }

  FutureOr<void> _handleProjectInit(
    ProjectInitializeEvent event,
    ProjectEmitter emit,
  ) async {
    emit(const ProjectState(
      loading: true,
      projects: [],
      selectedProject: null,
      projectType: null,
    ));

    final connectivityResult = await (Connectivity().checkConnectivity());

    AppLogger.instance.info(
      'Connectivity Result: $connectivityResult',
      title: 'ProjectBloc',
    );

    final isOnline =
        connectivityResult.firstOrNull == ConnectivityResult.wifi ||
            connectivityResult.firstOrNull == ConnectivityResult.mobile;
    final selectedProject = await localSecureStore.selectedProject;
    final isProjectSetUpComplete = await localSecureStore
        .isProjectSetUpComplete(selectedProject?.id ?? "noProjectId");

    /*Checks for if device is online and project data downloaded*/
    if (isOnline && !isProjectSetUpComplete) {
      await _loadOnline(emit);
    } else {
      await _loadOffline(emit);
    }
  }

  FutureOr<void> _loadOnline(ProjectEmitter emit) async {
    final batchSize = await _getBatchSize();
    final userObject = await localSecureStore.userRequestModel;
    final uuid = userObject?.uuid;

    List<ProjectStaffModel> projectStaffList;
    try {
      projectStaffList = await projectStaffRemoteRepository.search(
        ProjectStaffSearchModel(staffId: [uuid.toString()]),
      );
    } catch (error) {
      emit(
        state.copyWith(
          loading: false,
          syncError: ProjectSyncErrorType.projectStaff,
        ),
      );

      return;
    }

    projectStaffList.removeDuplicates((e) => e.id);

    if (projectStaffList.isEmpty) {
      emit(const ProjectState(
        projects: [],
        loading: false,
        selectedProject: null,
        syncError: null,
      ));

      return;
    }

    List<ProjectModel> projects = [];
    ProjectType? projectType;
    for (final projectStaff in projectStaffList) {
      await projectStaffLocalRepository.create(
        projectStaff,
        createOpLog: false,
      );

      List<ProjectModel> staffProjects;

      try {
        staffProjects = await projectRemoteRepository.search(
          ProjectSearchModel(
            id: projectStaff.projectId,
            tenantId: projectStaff.tenantId,
          ),
        );
      } catch (_) {
        emit(state.copyWith(
          loading: false,
          syncError: ProjectSyncErrorType.project,
        ));

        return;
      }

      projects.addAll(staffProjects);
    }

    projects.removeDuplicates((e) => e.id);

    for (final project in projects) {
      await projectLocalRepository.create(
        project,
        createOpLog: false,
      );
    }

    if (projects.isNotEmpty) {
      // INFO : Need to add project load functions
      try {
        await _loadServiceDefinition(projects);
      } catch (_) {
        emit(
          state.copyWith(
            loading: false,
            syncError: ProjectSyncErrorType.serviceDefinitions,
          ),
        );
      }
      try {
        await _loadProjectFacilities(projects, batchSize);
      } catch (_) {
        emit(
          state.copyWith(
            loading: false,
            syncError: ProjectSyncErrorType.projectFacilities,
          ),
        );
      }
      try {
        await _loadProductVariants(projects);
      } catch (_) {
        emit(
          state.copyWith(
            loading: false,
            syncError: ProjectSyncErrorType.productVariants,
          ),
        );
      }
      try {
        final projectTypes = await mdmsRepository.searchProjectType(
          envConfig.variables.mdmsApiPath,
          MdmsRequestModel(
            mdmsCriteria: MdmsCriteriaModel(
              tenantId: envConfig.variables.tenantId,
              moduleDetails: [
                const MdmsModuleDetailModel(
                  moduleName: 'HCM-PROJECT-TYPES',
                  masterDetails: [MdmsMasterDetailModel('projectTypes')],
                ),
              ],
            ),
          ).toJson(),
        );

        await mdmsRepository.writeToProjectTypeDB(
          projectTypes,
          isar,
        );

        String? additionalProjectTypeId =
            projects.first.additionalDetails?.projectType?.id;

        emit(state.copyWith(
          projectType: projectTypes.projectTypeWrapper?.projectTypes
              .where((element) =>
                  element.id ==
                  (additionalProjectTypeId ?? projects.first.projectTypeId))
              .toList()
              .firstOrNull,
        ));
      } catch (_) {}
    }

    emit(ProjectState(
      projects: projects,
      loading: false,
      syncError: null,
      projectType: projectType,
    ));

    if (projects.length == 1) {
      add(ProjectSelectProjectEvent(projects.first));
    }
  }

  FutureOr<void> _loadOffline(ProjectEmitter emit) async {
    final projects = await projectLocalRepository.search(
      ProjectSearchModel(
        tenantId: envConfig.variables.tenantId,
      ),
    );

    projects.removeDuplicates((element) => element.id);

    final selectedProject = await localSecureStore.selectedProject;
    final getSelectedProjectType = await localSecureStore.selectedProjectType;
    final currentRunningCycle = getSelectedProjectType?.cycles
        ?.where(
          (e) =>
              (e.startDate!) < DateTime.now().millisecondsSinceEpoch &&
              (e.endDate!) > DateTime.now().millisecondsSinceEpoch,
          // Return null when no matching cycle is found
        )
        .firstOrNull;
    emit(
      ProjectState(
        loading: false,
        projects: projects,
        selectedProject: selectedProject,
        projectType: getSelectedProjectType,
        selectedCycle: currentRunningCycle,
      ),
    );

    /* An empty BoundarySearchModel is sent to retrieve all boundaries from the repository.
    This ensures that the entire dataset is fetched, as no specific filters or constraints are applied.
    The retrieved boundaries are then processed to find the least level boundaries and set them in the singleton.*/
    final boundaries = await boundaryLocalRepository.search(
      BoundarySearchModel(),
    );
    LeastLevelBoundarySingleton()
        .setBoundary(boundaries: findLeastLevelBoundaries(boundaries));
  }

  FutureOr<void> _loadProjectFacilities(
      List<ProjectModel> projects, int batchSize) async {
    final projectFacilities = await projectFacilityRemoteRepository.search(
      ProjectFacilitySearchModel(
        projectId: projects.map((e) => e.id).toList(),
      ),
      limit: 1000,
    );

    await projectFacilityLocalRepository.bulkCreate(projectFacilities);

    try {
      // info : download the stock data
      // await downloadStockDataBasedOnRole(projectFacilities);
      final facilities = await facilityRemoteRepository.search(
        FacilitySearchModel(tenantId: envConfig.variables.tenantId),
        limit: 1000,
      );

      await facilityLocalRepository.bulkCreate(facilities);
    } catch (e) {
      print(e);
    }
  }

  FutureOr<void> _loadProductVariants(List<ProjectModel> projects) async {
    for (final project in projects) {
      final projectResources = await projectResourceRemoteRepository.search(
        ProjectResourceSearchModel(projectId: [project.id]),
      );

      for (final projectResource in projectResources) {
        await projectResourceLocalRepository.create(
          projectResource,
          createOpLog: false,
        );

        final productVariants = await productVariantRemoteRepository.search(
          ProductVariantSearchModel(
            id: [projectResource.resource.productVariantId],
          ),
        );

        for (final productVariant in productVariants) {
          await productVariantLocalRepository.create(
            productVariant,
            createOpLog: false,
          );
        }
      }
    }
  }

  Future<void> _handleProjectSelection(
    ProjectSelectProjectEvent event,
    ProjectEmitter emit,
  ) async {
    emit(state.copyWith(loading: true, syncError: null));

    List<BoundaryModel> boundaries;
    try {
      if (context.loggedInUserRoles
          .where(
            (role) =>
                role.code == RolesType.districtSupervisor.toValue() ||
                role.code == RolesType.attendanceStaff.toValue(),
          )
          .toList()
          .isNotEmpty) {
        final attendanceRegisters = await attendanceRemoteRepository.search(
          AttendanceRegisterSearchModel(
            staffId: context.loggedInIndividualId,
            referenceId: event.model.id,
            localityCode: event.model.address?.boundary,
          ),
        );
        await attendanceLocalRepository.bulkCreate(attendanceRegisters);

        for (final register in attendanceRegisters) {
          if (register.attendees != null &&
              (register.attendees ?? []).isNotEmpty) {
            try {
              final individuals = await individualRemoteRepository.search(
                IndividualSearchModel(
                  id: register.attendees!.map((e) => e.individualId!).toList(),
                ),
              );
              await individualLocalRepository.bulkCreate(individuals);
              final logs = await attendanceLogRemoteRepository.search(
                AttendanceLogSearchModel(
                  registerId: register.id,
                ),
              );
              await attendanceLogLocalRepository.bulkCreate(logs);
            } catch (_) {
              emit(state.copyWith(
                loading: false,
                syncError: ProjectSyncErrorType.project,
              ));

              return;
            }
          }
        }
      }
      final configResult = await mdmsRepository.searchAppConfig(
        envConfig.variables.mdmsApiPath,
        MdmsRequestModel(
          mdmsCriteria: MdmsCriteriaModel(
            tenantId: envConfig.variables.tenantId,
            moduleDetails: [
              const MdmsModuleDetailModel(
                moduleName: 'module-version',
                masterDetails: [
                  MdmsMasterDetailModel('ROW_VERSIONS'),
                ],
              ),
            ],
          ),
        ).toJson(),
      );

      final projectType = await mdmsRepository.searchProjectType(
        envConfig.variables.mdmsApiPath,
        MdmsRequestModel(
          mdmsCriteria: MdmsCriteriaModel(
            tenantId: envConfig.variables.tenantId,
            moduleDetails: [
              const MdmsModuleDetailModel(
                moduleName: 'HCM-PROJECT-TYPES',
                masterDetails: [MdmsMasterDetailModel('projectTypes')],
              ),
            ],
          ),
        ).toJson(),
      );

      await mdmsRepository.writeToProjectTypeDB(
        projectType,
        isar,
      );

      String? additionalProjectTypeId =
          event.model.additionalDetails?.projectType?.id;

      final selectedProjectType = projectType.projectTypeWrapper?.projectTypes
          .where(
            (element) =>
                element.id ==
                (additionalProjectTypeId ?? event.model.projectTypeId),
          )
          .toList()
          .firstOrNull;
      final currentRunningCycle = selectedProjectType?.cycles
          ?.where(
            (e) =>
                (e.startDate!) < DateTime.now().millisecondsSinceEpoch &&
                (e.endDate!) > DateTime.now().millisecondsSinceEpoch,
            // Return null when no matching cycle is found
          )
          .firstOrNull;

      final cycles = List<Cycle>.from(
        selectedProjectType?.cycles ?? [],
      );
      cycles.sort((a, b) => a.id.compareTo(b.id));

      final reqProjectType = selectedProjectType?.copyWith(cycles: cycles);

      final rowversionList = await isar.rowVersionLists
          .filter()
          .moduleEqualTo('egov-location')
          .findAll();

      final serverVersion = configResult.rowVersions?.rowVersionslist
          ?.where(
            (element) => element.module == 'egov-location',
          )
          .toList()
          .firstOrNull
          ?.version;
      final boundaryRefetched = await localSecureStore.boundaryRefetched;

      if (rowversionList.firstOrNull?.version != serverVersion ||
          boundaryRefetched) {
        boundaries = await boundaryRemoteRepository.search(
          BoundarySearchModel(
            boundaryType: event.model.address?.boundaryType,
            codes: event.model.address?.boundary,
          ),
        );
        await boundaryLocalRepository.bulkCreate(boundaries);
        await localSecureStore.setSelectedProject(event.model);
        await localSecureStore.setSelectedProjectType(reqProjectType);
        await localSecureStore.setBoundaryRefetch(false);
        final List<RowVersionList> rowVersionList = [];

        final data = (configResult).rowVersions?.rowVersionslist;

        for (final element in data ?? <app_configuration.RowVersions>[]) {
          final rowVersion = RowVersionList();
          rowVersion.module = element.module;
          rowVersion.version = element.version;
          rowVersionList.add(rowVersion);
        }
        isar.writeTxnSync(() {
          isar.rowVersionLists.clear();

          isar.rowVersionLists.putAllSync(rowVersionList);
        });
      } else {
        boundaries = await boundaryLocalRepository.search(
          BoundarySearchModel(
            boundaryType: event.model.address?.boundaryType,
            codes: event.model.address?.boundary,
          ),
        );
        if (boundaries.isEmpty) {
          boundaries = await boundaryRemoteRepository.search(
            BoundarySearchModel(
              boundaryType: event.model.address?.boundaryType,
              codes: event.model.address?.boundary,
            ),
          );
        }
        await boundaryLocalRepository.bulkCreate(boundaries);
        LeastLevelBoundarySingleton()
            .setBoundary(boundaries: findLeastLevelBoundaries(boundaries));
        await localSecureStore.setSelectedProject(event.model);
        await localSecureStore.setSelectedProjectType(reqProjectType);
      }
      await localSecureStore.setProjectSetUpComplete(event.model.id, true);
    } catch (_) {
      emit(state.copyWith(
        loading: false,
        syncError: ProjectSyncErrorType.boundary,
      ));
    }

    final getSelectedProjectType = await localSecureStore.selectedProjectType;
    final currentRunningCycle = getSelectedProjectType?.cycles
        ?.where(
          (e) =>
              (e.startDate!) < DateTime.now().millisecondsSinceEpoch &&
              (e.endDate!) > DateTime.now().millisecondsSinceEpoch,
          // Return null when no matching cycle is found
        )
        .firstOrNull;
    try {

      final projectFacilities = await projectFacilityLocalRepository
          .search(ProjectFacilitySearchModel());
      final facilities =
          await facilityLocalRepository.search(FacilitySearchModel());
      await downloadStockDataBasedOnRole(
          projectFacilities, facilities, event.model.address?.boundaryType, currentRunningCycle);
    } catch (_) {
      emit(state.copyWith(
        loading: false,
        syncError: ProjectSyncErrorType.projectFacilities,
      ));
    }

    emit(state.copyWith(
      selectedProject: event.model,
      loading: false,
      syncError: null,
      projectType: getSelectedProjectType,
      selectedCycle: currentRunningCycle,
    ));
  }

  FutureOr<int> _getBatchSize() async {
    try {
      final configs = await isar.appConfigurations.where().findAll();

      final double speed = await bandwidthCheckRepository.pingBandwidthCheck(
        bandWidthCheckModel: null,
      );

      int configuredBatchSize = getBatchSizeToBandwidth(
        speed,
        configs,
        isDownSync: true,
      );
      return configuredBatchSize;
    } catch (e) {
      rethrow;
    }
  }

  FutureOr<void> _loadServiceDefinition(List<ProjectModel> projects) async {
    final configs = await isar.appConfigurations.where().findAll();
    final userObject = await localSecureStore.userRequestModel;
    List<String> codes = [];
    for (UserRoleModel elements in userObject!.roles) {
      configs.first.checklistTypes?.map((e) => e.code).forEach((element) {
        for (final project in projects) {
          codes.add(
            '${project.name}.$element.${elements.code.snakeCase.toUpperCase()}',
          );
        }
      });
    }

    final serviceDefinition = await serviceDefinitionRemoteRepository
        .search(ServiceDefinitionSearchModel(
      tenantId: envConfig.variables.tenantId,
      code: codes,
    ));

    for (var element in serviceDefinition) {
      await serviceDefinitionLocalRepository.create(
        element,
        createOpLog: false,
      );
    }
  }

  // info: downloads stock data from remote , based on the user role
  FutureOr<void> downloadStockDataBasedOnRole(
      List<ProjectFacilityModel> projectFacilities,
      List<FacilityModel> allFacilities,
      String? boundaryType,  Cycle? currentRunningCycle) async {
    final userObject = await localSecureStore.userRequestModel;
    final userRoles = userObject!.roles.map((e) => e.code);
    final lastChangedSince = currentRunningCycle?.startDate;

    Map<String, String> facilityIdUsageMap = {};

    for (var element in allFacilities) {
      facilityIdUsageMap[element.id] = element?.usage ?? "";
    }

    // info : assumption both roles will not be assigned to user

    if (userRoles.contains(RolesType.healthFacilitySupervisor.toValue())) {
      List<String> receiverIds =
          projectFacilities.map((e) => e.facilityId).toList();
      receiverIds = receiverIds
          .where((e) => facilityIdUsageMap[e] == Constants.healthFacility)
          .toList();
      final stockSearchModel = StockSearchModel(
        receiverId: receiverIds,
        transactionType: [TransactionType.dispatched.toValue()],
      );
      final stockEntriesDownloaded =
          await downloadStockEntries(stockSearchModel, lastChangedSince);
      // info : create entries in the local repository

      await createStockDownloadedEntries(stockEntriesDownloaded);
    } else if (userRoles.contains(RolesType.warehouseManager.toValue()) &&
        boundaryType == Constants.lgaBoundaryLevel) {
      List<String> receiverIds =
          projectFacilities.map((e) => e.facilityId).toList();
      receiverIds = receiverIds
          .where((e) => facilityIdUsageMap[e] == Constants.lgaFacility)
          .toList();
      final stockSearchModel = StockSearchModel(
        receiverId: receiverIds,
        transactionType: [TransactionType.dispatched.toValue()],
      );
      final stockEntriesDownloaded =
          await downloadStockEntries(stockSearchModel, lastChangedSince);

      // info : create entries in the local repository
      await createStockDownloadedEntries(stockEntriesDownloaded);
    } else if (userRoles.contains(RolesType.communityDistributor.toValue())) {
      final receiverIds = [context.loggedInUserUuid];
      final stockSearchModel = StockSearchModel(
        receiverId: receiverIds,
        transactionType: [TransactionType.dispatched.toValue()],
      );
      final stockEntriesDownloaded =
          await downloadStockEntries(stockSearchModel, lastChangedSince);

      // info : create entries in the local repository
      await createStockDownloadedEntries(stockEntriesDownloaded);
    }
  }

  // info : insert data in db
  FutureOr<void> createStockDownloadedEntries(
      List<StockModel> stockEntries) async {
    await (stockLocalRepository as CustomStockLocalRepository)
        .bulkStockCreate(stockEntries);
  }

  // info:  downloads the stock data from remote repository

  FutureOr<List<StockModel>> downloadStockEntries(
      StockSearchModel stockSearchModel, int? lastChangedSince) async {
    var offset = 0;
    var initialLimit = Constants.apiCallLimit;

    final stockEntries = await stockRemoteRepository.search(stockSearchModel,
        limit: initialLimit, offSet: offset, lastChangedSince: lastChangedSince);

    return stockEntries;
  }
}

@freezed
class ProjectEvent with _$ProjectEvent {
  const factory ProjectEvent.initialize() = ProjectInitializeEvent;

  const factory ProjectEvent.selectProject(ProjectModel model) =
      ProjectSelectProjectEvent;
}

@freezed
class ProjectState with _$ProjectState {
  const ProjectState._();

  const factory ProjectState({
    @Default([]) List<ProjectModel> projects,
    ProjectType? projectType,
    Cycle? selectedCycle,
    ProjectModel? selectedProject,
    @Default(false) bool loading,
    ProjectSyncErrorType? syncError,
  }) = _ProjectState;

  bool get isEmpty => projects.isEmpty;

  bool get isNotEmpty => !isEmpty;

  bool get hasSelectedProject => selectedProject != null;
}

enum ProjectSyncErrorType {
  projectStaff,
  project,
  projectFacilities,
  productVariants,
  serviceDefinitions,
  boundary
}
