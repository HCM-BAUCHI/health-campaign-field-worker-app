// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'roles_type.dart';

class RolesTypeMapper extends EnumMapper<RolesType> {
  RolesTypeMapper._();

  static RolesTypeMapper? _instance;
  static RolesTypeMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = RolesTypeMapper._());
    }
    return _instance!;
  }

  static RolesType fromValue(dynamic value) {
    ensureInitialized();
    return MapperContainer.globals.fromValue(value);
  }

  @override
  RolesType decode(dynamic value) {
    switch (value) {
      case "WAREHOUSE_MANAGER":
        return RolesType.warehouseManager;
      case "DISTRIBUTOR":
        return RolesType.distributor;
      case "HEALTH_FACILITY_WORKER":
        return RolesType.healthFacilityWorker;
      case "DISTRICT_SUPERVISOR":
        return RolesType.districtSupervisor;
      case "FIELD_SUPERVISOR":
        return RolesType.fieldSupervisor;
      case "SUPERUSER":
        return RolesType.superuser;
      case "REGISTRAR":
        return RolesType.registrar;
      case "TEAM_SUPERVISOR":
        return RolesType.teamSupervisor;
      case "COMMUNITY_DISTRIBUTOR":
        return RolesType.communityDistributor;
      case "ATTENDANCE_STAFF":
        return RolesType.attendanceStaff;
      case "COMMUNITY_SUPERVISOR":
        return RolesType.communitySupervisor;
      case "SPAQ_MANAGER":
        return RolesType.spaqManager;
      case "HEALTH_FACILITY_SUPERVISOR":
        return RolesType.healthFacilitySupervisor;
      default:
        throw MapperException.unknownEnumValue(value);
    }
  }

  @override
  dynamic encode(RolesType self) {
    switch (self) {
      case RolesType.warehouseManager:
        return "WAREHOUSE_MANAGER";
      case RolesType.distributor:
        return "DISTRIBUTOR";
      case RolesType.healthFacilityWorker:
        return "HEALTH_FACILITY_WORKER";
      case RolesType.districtSupervisor:
        return "DISTRICT_SUPERVISOR";
      case RolesType.fieldSupervisor:
        return "FIELD_SUPERVISOR";
      case RolesType.superuser:
        return "SUPERUSER";
      case RolesType.registrar:
        return "REGISTRAR";
      case RolesType.teamSupervisor:
        return "TEAM_SUPERVISOR";
      case RolesType.communityDistributor:
        return "COMMUNITY_DISTRIBUTOR";
      case RolesType.attendanceStaff:
        return "ATTENDANCE_STAFF";
      case RolesType.communitySupervisor:
        return "COMMUNITY_SUPERVISOR";
      case RolesType.spaqManager:
        return "SPAQ_MANAGER";
      case RolesType.healthFacilitySupervisor:
        return "HEALTH_FACILITY_SUPERVISOR";
    }
  }
}

extension RolesTypeMapperExtension on RolesType {
  dynamic toValue() {
    RolesTypeMapper.ensureInitialized();
    return MapperContainer.globals.toValue<RolesType>(this);
  }
}
