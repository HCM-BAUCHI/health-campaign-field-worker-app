// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'search_households_smc.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$SearchHouseholdsSMCEvent {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initialize,
    required TResult Function(
            String projectId,
            double? latitude,
            double? longitude,
            double? maxRadius,
            bool isProximityEnabled,
            HouseholdModel householdModel)
        searchByHousehold,
    required TResult Function(
            String searchText,
            String projectId,
            bool isProximityEnabled,
            double? latitude,
            double? longitude,
            double? maxRadius,
            String? tag,
            int offset,
            int limit)
        searchByHouseholdHead,
    required TResult Function(double latitude, double longititude,
            String projectId, double maxRadius, int offset, int limit)
        searchByProximity,
    required TResult Function(String tag, String projectId) searchByTag,
    required TResult Function() clear,
    required TResult Function(GlobalSearchParametersSMC globalSearchParams)
        individualGlobalSearch,
    required TResult Function(GlobalSearchParametersSMC globalSearchParams)
        houseHoldGlobalSearch,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initialize,
    TResult? Function(
            String projectId,
            double? latitude,
            double? longitude,
            double? maxRadius,
            bool isProximityEnabled,
            HouseholdModel householdModel)?
        searchByHousehold,
    TResult? Function(
            String searchText,
            String projectId,
            bool isProximityEnabled,
            double? latitude,
            double? longitude,
            double? maxRadius,
            String? tag,
            int offset,
            int limit)?
        searchByHouseholdHead,
    TResult? Function(double latitude, double longititude, String projectId,
            double maxRadius, int offset, int limit)?
        searchByProximity,
    TResult? Function(String tag, String projectId)? searchByTag,
    TResult? Function()? clear,
    TResult? Function(GlobalSearchParametersSMC globalSearchParams)?
        individualGlobalSearch,
    TResult? Function(GlobalSearchParametersSMC globalSearchParams)?
        houseHoldGlobalSearch,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initialize,
    TResult Function(
            String projectId,
            double? latitude,
            double? longitude,
            double? maxRadius,
            bool isProximityEnabled,
            HouseholdModel householdModel)?
        searchByHousehold,
    TResult Function(
            String searchText,
            String projectId,
            bool isProximityEnabled,
            double? latitude,
            double? longitude,
            double? maxRadius,
            String? tag,
            int offset,
            int limit)?
        searchByHouseholdHead,
    TResult Function(double latitude, double longititude, String projectId,
            double maxRadius, int offset, int limit)?
        searchByProximity,
    TResult Function(String tag, String projectId)? searchByTag,
    TResult Function()? clear,
    TResult Function(GlobalSearchParametersSMC globalSearchParams)?
        individualGlobalSearch,
    TResult Function(GlobalSearchParametersSMC globalSearchParams)?
        houseHoldGlobalSearch,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(SearchHouseholdsInitializedEvent value)
        initialize,
    required TResult Function(SearchHouseholdsByHouseholdsSMCEvent value)
        searchByHousehold,
    required TResult Function(
            SearchHouseholdsSearchByHouseholdHeadSMCEvent value)
        searchByHouseholdHead,
    required TResult Function(SearchHouseholdsByProximitySMCEvent value)
        searchByProximity,
    required TResult Function(SearchHouseholdsByTagSMCEvent value) searchByTag,
    required TResult Function(SearchHouseholdsClearEvent value) clear,
    required TResult Function(IndividualGlobalSearchSMCEvent value)
        individualGlobalSearch,
    required TResult Function(HouseHoldGlobalSearchSMCEvent value)
        houseHoldGlobalSearch,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(SearchHouseholdsInitializedEvent value)? initialize,
    TResult? Function(SearchHouseholdsByHouseholdsSMCEvent value)?
        searchByHousehold,
    TResult? Function(SearchHouseholdsSearchByHouseholdHeadSMCEvent value)?
        searchByHouseholdHead,
    TResult? Function(SearchHouseholdsByProximitySMCEvent value)?
        searchByProximity,
    TResult? Function(SearchHouseholdsByTagSMCEvent value)? searchByTag,
    TResult? Function(SearchHouseholdsClearEvent value)? clear,
    TResult? Function(IndividualGlobalSearchSMCEvent value)?
        individualGlobalSearch,
    TResult? Function(HouseHoldGlobalSearchSMCEvent value)?
        houseHoldGlobalSearch,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(SearchHouseholdsInitializedEvent value)? initialize,
    TResult Function(SearchHouseholdsByHouseholdsSMCEvent value)?
        searchByHousehold,
    TResult Function(SearchHouseholdsSearchByHouseholdHeadSMCEvent value)?
        searchByHouseholdHead,
    TResult Function(SearchHouseholdsByProximitySMCEvent value)?
        searchByProximity,
    TResult Function(SearchHouseholdsByTagSMCEvent value)? searchByTag,
    TResult Function(SearchHouseholdsClearEvent value)? clear,
    TResult Function(IndividualGlobalSearchSMCEvent value)?
        individualGlobalSearch,
    TResult Function(HouseHoldGlobalSearchSMCEvent value)?
        houseHoldGlobalSearch,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SearchHouseholdsSMCEventCopyWith<$Res> {
  factory $SearchHouseholdsSMCEventCopyWith(SearchHouseholdsSMCEvent value,
          $Res Function(SearchHouseholdsSMCEvent) then) =
      _$SearchHouseholdsSMCEventCopyWithImpl<$Res, SearchHouseholdsSMCEvent>;
}

/// @nodoc
class _$SearchHouseholdsSMCEventCopyWithImpl<$Res,
        $Val extends SearchHouseholdsSMCEvent>
    implements $SearchHouseholdsSMCEventCopyWith<$Res> {
  _$SearchHouseholdsSMCEventCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;
}

/// @nodoc
abstract class _$$SearchHouseholdsInitializedEventImplCopyWith<$Res> {
  factory _$$SearchHouseholdsInitializedEventImplCopyWith(
          _$SearchHouseholdsInitializedEventImpl value,
          $Res Function(_$SearchHouseholdsInitializedEventImpl) then) =
      __$$SearchHouseholdsInitializedEventImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$SearchHouseholdsInitializedEventImplCopyWithImpl<$Res>
    extends _$SearchHouseholdsSMCEventCopyWithImpl<$Res,
        _$SearchHouseholdsInitializedEventImpl>
    implements _$$SearchHouseholdsInitializedEventImplCopyWith<$Res> {
  __$$SearchHouseholdsInitializedEventImplCopyWithImpl(
      _$SearchHouseholdsInitializedEventImpl _value,
      $Res Function(_$SearchHouseholdsInitializedEventImpl) _then)
      : super(_value, _then);
}

/// @nodoc

class _$SearchHouseholdsInitializedEventImpl
    implements SearchHouseholdsInitializedEvent {
  const _$SearchHouseholdsInitializedEventImpl();

  @override
  String toString() {
    return 'SearchHouseholdsSMCEvent.initialize()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SearchHouseholdsInitializedEventImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initialize,
    required TResult Function(
            String projectId,
            double? latitude,
            double? longitude,
            double? maxRadius,
            bool isProximityEnabled,
            HouseholdModel householdModel)
        searchByHousehold,
    required TResult Function(
            String searchText,
            String projectId,
            bool isProximityEnabled,
            double? latitude,
            double? longitude,
            double? maxRadius,
            String? tag,
            int offset,
            int limit)
        searchByHouseholdHead,
    required TResult Function(double latitude, double longititude,
            String projectId, double maxRadius, int offset, int limit)
        searchByProximity,
    required TResult Function(String tag, String projectId) searchByTag,
    required TResult Function() clear,
    required TResult Function(GlobalSearchParametersSMC globalSearchParams)
        individualGlobalSearch,
    required TResult Function(GlobalSearchParametersSMC globalSearchParams)
        houseHoldGlobalSearch,
  }) {
    return initialize();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initialize,
    TResult? Function(
            String projectId,
            double? latitude,
            double? longitude,
            double? maxRadius,
            bool isProximityEnabled,
            HouseholdModel householdModel)?
        searchByHousehold,
    TResult? Function(
            String searchText,
            String projectId,
            bool isProximityEnabled,
            double? latitude,
            double? longitude,
            double? maxRadius,
            String? tag,
            int offset,
            int limit)?
        searchByHouseholdHead,
    TResult? Function(double latitude, double longititude, String projectId,
            double maxRadius, int offset, int limit)?
        searchByProximity,
    TResult? Function(String tag, String projectId)? searchByTag,
    TResult? Function()? clear,
    TResult? Function(GlobalSearchParametersSMC globalSearchParams)?
        individualGlobalSearch,
    TResult? Function(GlobalSearchParametersSMC globalSearchParams)?
        houseHoldGlobalSearch,
  }) {
    return initialize?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initialize,
    TResult Function(
            String projectId,
            double? latitude,
            double? longitude,
            double? maxRadius,
            bool isProximityEnabled,
            HouseholdModel householdModel)?
        searchByHousehold,
    TResult Function(
            String searchText,
            String projectId,
            bool isProximityEnabled,
            double? latitude,
            double? longitude,
            double? maxRadius,
            String? tag,
            int offset,
            int limit)?
        searchByHouseholdHead,
    TResult Function(double latitude, double longititude, String projectId,
            double maxRadius, int offset, int limit)?
        searchByProximity,
    TResult Function(String tag, String projectId)? searchByTag,
    TResult Function()? clear,
    TResult Function(GlobalSearchParametersSMC globalSearchParams)?
        individualGlobalSearch,
    TResult Function(GlobalSearchParametersSMC globalSearchParams)?
        houseHoldGlobalSearch,
    required TResult orElse(),
  }) {
    if (initialize != null) {
      return initialize();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(SearchHouseholdsInitializedEvent value)
        initialize,
    required TResult Function(SearchHouseholdsByHouseholdsSMCEvent value)
        searchByHousehold,
    required TResult Function(
            SearchHouseholdsSearchByHouseholdHeadSMCEvent value)
        searchByHouseholdHead,
    required TResult Function(SearchHouseholdsByProximitySMCEvent value)
        searchByProximity,
    required TResult Function(SearchHouseholdsByTagSMCEvent value) searchByTag,
    required TResult Function(SearchHouseholdsClearEvent value) clear,
    required TResult Function(IndividualGlobalSearchSMCEvent value)
        individualGlobalSearch,
    required TResult Function(HouseHoldGlobalSearchSMCEvent value)
        houseHoldGlobalSearch,
  }) {
    return initialize(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(SearchHouseholdsInitializedEvent value)? initialize,
    TResult? Function(SearchHouseholdsByHouseholdsSMCEvent value)?
        searchByHousehold,
    TResult? Function(SearchHouseholdsSearchByHouseholdHeadSMCEvent value)?
        searchByHouseholdHead,
    TResult? Function(SearchHouseholdsByProximitySMCEvent value)?
        searchByProximity,
    TResult? Function(SearchHouseholdsByTagSMCEvent value)? searchByTag,
    TResult? Function(SearchHouseholdsClearEvent value)? clear,
    TResult? Function(IndividualGlobalSearchSMCEvent value)?
        individualGlobalSearch,
    TResult? Function(HouseHoldGlobalSearchSMCEvent value)?
        houseHoldGlobalSearch,
  }) {
    return initialize?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(SearchHouseholdsInitializedEvent value)? initialize,
    TResult Function(SearchHouseholdsByHouseholdsSMCEvent value)?
        searchByHousehold,
    TResult Function(SearchHouseholdsSearchByHouseholdHeadSMCEvent value)?
        searchByHouseholdHead,
    TResult Function(SearchHouseholdsByProximitySMCEvent value)?
        searchByProximity,
    TResult Function(SearchHouseholdsByTagSMCEvent value)? searchByTag,
    TResult Function(SearchHouseholdsClearEvent value)? clear,
    TResult Function(IndividualGlobalSearchSMCEvent value)?
        individualGlobalSearch,
    TResult Function(HouseHoldGlobalSearchSMCEvent value)?
        houseHoldGlobalSearch,
    required TResult orElse(),
  }) {
    if (initialize != null) {
      return initialize(this);
    }
    return orElse();
  }
}

abstract class SearchHouseholdsInitializedEvent
    implements SearchHouseholdsSMCEvent {
  const factory SearchHouseholdsInitializedEvent() =
      _$SearchHouseholdsInitializedEventImpl;
}

/// @nodoc
abstract class _$$SearchHouseholdsByHouseholdsSMCEventImplCopyWith<$Res> {
  factory _$$SearchHouseholdsByHouseholdsSMCEventImplCopyWith(
          _$SearchHouseholdsByHouseholdsSMCEventImpl value,
          $Res Function(_$SearchHouseholdsByHouseholdsSMCEventImpl) then) =
      __$$SearchHouseholdsByHouseholdsSMCEventImplCopyWithImpl<$Res>;
  @useResult
  $Res call(
      {String projectId,
      double? latitude,
      double? longitude,
      double? maxRadius,
      bool isProximityEnabled,
      HouseholdModel householdModel});
}

/// @nodoc
class __$$SearchHouseholdsByHouseholdsSMCEventImplCopyWithImpl<$Res>
    extends _$SearchHouseholdsSMCEventCopyWithImpl<$Res,
        _$SearchHouseholdsByHouseholdsSMCEventImpl>
    implements _$$SearchHouseholdsByHouseholdsSMCEventImplCopyWith<$Res> {
  __$$SearchHouseholdsByHouseholdsSMCEventImplCopyWithImpl(
      _$SearchHouseholdsByHouseholdsSMCEventImpl _value,
      $Res Function(_$SearchHouseholdsByHouseholdsSMCEventImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? projectId = null,
    Object? latitude = freezed,
    Object? longitude = freezed,
    Object? maxRadius = freezed,
    Object? isProximityEnabled = null,
    Object? householdModel = null,
  }) {
    return _then(_$SearchHouseholdsByHouseholdsSMCEventImpl(
      projectId: null == projectId
          ? _value.projectId
          : projectId // ignore: cast_nullable_to_non_nullable
              as String,
      latitude: freezed == latitude
          ? _value.latitude
          : latitude // ignore: cast_nullable_to_non_nullable
              as double?,
      longitude: freezed == longitude
          ? _value.longitude
          : longitude // ignore: cast_nullable_to_non_nullable
              as double?,
      maxRadius: freezed == maxRadius
          ? _value.maxRadius
          : maxRadius // ignore: cast_nullable_to_non_nullable
              as double?,
      isProximityEnabled: null == isProximityEnabled
          ? _value.isProximityEnabled
          : isProximityEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      householdModel: null == householdModel
          ? _value.householdModel
          : householdModel // ignore: cast_nullable_to_non_nullable
              as HouseholdModel,
    ));
  }
}

/// @nodoc

class _$SearchHouseholdsByHouseholdsSMCEventImpl
    implements SearchHouseholdsByHouseholdsSMCEvent {
  const _$SearchHouseholdsByHouseholdsSMCEventImpl(
      {required this.projectId,
      this.latitude,
      this.longitude,
      this.maxRadius,
      required this.isProximityEnabled,
      required this.householdModel});

  @override
  final String projectId;
  @override
  final double? latitude;
  @override
  final double? longitude;
  @override
  final double? maxRadius;
  @override
  final bool isProximityEnabled;
  @override
  final HouseholdModel householdModel;

  @override
  String toString() {
    return 'SearchHouseholdsSMCEvent.searchByHousehold(projectId: $projectId, latitude: $latitude, longitude: $longitude, maxRadius: $maxRadius, isProximityEnabled: $isProximityEnabled, householdModel: $householdModel)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SearchHouseholdsByHouseholdsSMCEventImpl &&
            (identical(other.projectId, projectId) ||
                other.projectId == projectId) &&
            (identical(other.latitude, latitude) ||
                other.latitude == latitude) &&
            (identical(other.longitude, longitude) ||
                other.longitude == longitude) &&
            (identical(other.maxRadius, maxRadius) ||
                other.maxRadius == maxRadius) &&
            (identical(other.isProximityEnabled, isProximityEnabled) ||
                other.isProximityEnabled == isProximityEnabled) &&
            (identical(other.householdModel, householdModel) ||
                other.householdModel == householdModel));
  }

  @override
  int get hashCode => Object.hash(runtimeType, projectId, latitude, longitude,
      maxRadius, isProximityEnabled, householdModel);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$SearchHouseholdsByHouseholdsSMCEventImplCopyWith<
          _$SearchHouseholdsByHouseholdsSMCEventImpl>
      get copyWith => __$$SearchHouseholdsByHouseholdsSMCEventImplCopyWithImpl<
          _$SearchHouseholdsByHouseholdsSMCEventImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initialize,
    required TResult Function(
            String projectId,
            double? latitude,
            double? longitude,
            double? maxRadius,
            bool isProximityEnabled,
            HouseholdModel householdModel)
        searchByHousehold,
    required TResult Function(
            String searchText,
            String projectId,
            bool isProximityEnabled,
            double? latitude,
            double? longitude,
            double? maxRadius,
            String? tag,
            int offset,
            int limit)
        searchByHouseholdHead,
    required TResult Function(double latitude, double longititude,
            String projectId, double maxRadius, int offset, int limit)
        searchByProximity,
    required TResult Function(String tag, String projectId) searchByTag,
    required TResult Function() clear,
    required TResult Function(GlobalSearchParametersSMC globalSearchParams)
        individualGlobalSearch,
    required TResult Function(GlobalSearchParametersSMC globalSearchParams)
        houseHoldGlobalSearch,
  }) {
    return searchByHousehold(projectId, latitude, longitude, maxRadius,
        isProximityEnabled, householdModel);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initialize,
    TResult? Function(
            String projectId,
            double? latitude,
            double? longitude,
            double? maxRadius,
            bool isProximityEnabled,
            HouseholdModel householdModel)?
        searchByHousehold,
    TResult? Function(
            String searchText,
            String projectId,
            bool isProximityEnabled,
            double? latitude,
            double? longitude,
            double? maxRadius,
            String? tag,
            int offset,
            int limit)?
        searchByHouseholdHead,
    TResult? Function(double latitude, double longititude, String projectId,
            double maxRadius, int offset, int limit)?
        searchByProximity,
    TResult? Function(String tag, String projectId)? searchByTag,
    TResult? Function()? clear,
    TResult? Function(GlobalSearchParametersSMC globalSearchParams)?
        individualGlobalSearch,
    TResult? Function(GlobalSearchParametersSMC globalSearchParams)?
        houseHoldGlobalSearch,
  }) {
    return searchByHousehold?.call(projectId, latitude, longitude, maxRadius,
        isProximityEnabled, householdModel);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initialize,
    TResult Function(
            String projectId,
            double? latitude,
            double? longitude,
            double? maxRadius,
            bool isProximityEnabled,
            HouseholdModel householdModel)?
        searchByHousehold,
    TResult Function(
            String searchText,
            String projectId,
            bool isProximityEnabled,
            double? latitude,
            double? longitude,
            double? maxRadius,
            String? tag,
            int offset,
            int limit)?
        searchByHouseholdHead,
    TResult Function(double latitude, double longititude, String projectId,
            double maxRadius, int offset, int limit)?
        searchByProximity,
    TResult Function(String tag, String projectId)? searchByTag,
    TResult Function()? clear,
    TResult Function(GlobalSearchParametersSMC globalSearchParams)?
        individualGlobalSearch,
    TResult Function(GlobalSearchParametersSMC globalSearchParams)?
        houseHoldGlobalSearch,
    required TResult orElse(),
  }) {
    if (searchByHousehold != null) {
      return searchByHousehold(projectId, latitude, longitude, maxRadius,
          isProximityEnabled, householdModel);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(SearchHouseholdsInitializedEvent value)
        initialize,
    required TResult Function(SearchHouseholdsByHouseholdsSMCEvent value)
        searchByHousehold,
    required TResult Function(
            SearchHouseholdsSearchByHouseholdHeadSMCEvent value)
        searchByHouseholdHead,
    required TResult Function(SearchHouseholdsByProximitySMCEvent value)
        searchByProximity,
    required TResult Function(SearchHouseholdsByTagSMCEvent value) searchByTag,
    required TResult Function(SearchHouseholdsClearEvent value) clear,
    required TResult Function(IndividualGlobalSearchSMCEvent value)
        individualGlobalSearch,
    required TResult Function(HouseHoldGlobalSearchSMCEvent value)
        houseHoldGlobalSearch,
  }) {
    return searchByHousehold(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(SearchHouseholdsInitializedEvent value)? initialize,
    TResult? Function(SearchHouseholdsByHouseholdsSMCEvent value)?
        searchByHousehold,
    TResult? Function(SearchHouseholdsSearchByHouseholdHeadSMCEvent value)?
        searchByHouseholdHead,
    TResult? Function(SearchHouseholdsByProximitySMCEvent value)?
        searchByProximity,
    TResult? Function(SearchHouseholdsByTagSMCEvent value)? searchByTag,
    TResult? Function(SearchHouseholdsClearEvent value)? clear,
    TResult? Function(IndividualGlobalSearchSMCEvent value)?
        individualGlobalSearch,
    TResult? Function(HouseHoldGlobalSearchSMCEvent value)?
        houseHoldGlobalSearch,
  }) {
    return searchByHousehold?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(SearchHouseholdsInitializedEvent value)? initialize,
    TResult Function(SearchHouseholdsByHouseholdsSMCEvent value)?
        searchByHousehold,
    TResult Function(SearchHouseholdsSearchByHouseholdHeadSMCEvent value)?
        searchByHouseholdHead,
    TResult Function(SearchHouseholdsByProximitySMCEvent value)?
        searchByProximity,
    TResult Function(SearchHouseholdsByTagSMCEvent value)? searchByTag,
    TResult Function(SearchHouseholdsClearEvent value)? clear,
    TResult Function(IndividualGlobalSearchSMCEvent value)?
        individualGlobalSearch,
    TResult Function(HouseHoldGlobalSearchSMCEvent value)?
        houseHoldGlobalSearch,
    required TResult orElse(),
  }) {
    if (searchByHousehold != null) {
      return searchByHousehold(this);
    }
    return orElse();
  }
}

abstract class SearchHouseholdsByHouseholdsSMCEvent
    implements SearchHouseholdsSMCEvent {
  const factory SearchHouseholdsByHouseholdsSMCEvent(
          {required final String projectId,
          final double? latitude,
          final double? longitude,
          final double? maxRadius,
          required final bool isProximityEnabled,
          required final HouseholdModel householdModel}) =
      _$SearchHouseholdsByHouseholdsSMCEventImpl;

  String get projectId;
  double? get latitude;
  double? get longitude;
  double? get maxRadius;
  bool get isProximityEnabled;
  HouseholdModel get householdModel;
  @JsonKey(ignore: true)
  _$$SearchHouseholdsByHouseholdsSMCEventImplCopyWith<
          _$SearchHouseholdsByHouseholdsSMCEventImpl>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$SearchHouseholdsSearchByHouseholdHeadSMCEventImplCopyWith<
    $Res> {
  factory _$$SearchHouseholdsSearchByHouseholdHeadSMCEventImplCopyWith(
          _$SearchHouseholdsSearchByHouseholdHeadSMCEventImpl value,
          $Res Function(_$SearchHouseholdsSearchByHouseholdHeadSMCEventImpl)
              then) =
      __$$SearchHouseholdsSearchByHouseholdHeadSMCEventImplCopyWithImpl<$Res>;
  @useResult
  $Res call(
      {String searchText,
      String projectId,
      bool isProximityEnabled,
      double? latitude,
      double? longitude,
      double? maxRadius,
      String? tag,
      int offset,
      int limit});
}

/// @nodoc
class __$$SearchHouseholdsSearchByHouseholdHeadSMCEventImplCopyWithImpl<$Res>
    extends _$SearchHouseholdsSMCEventCopyWithImpl<$Res,
        _$SearchHouseholdsSearchByHouseholdHeadSMCEventImpl>
    implements
        _$$SearchHouseholdsSearchByHouseholdHeadSMCEventImplCopyWith<$Res> {
  __$$SearchHouseholdsSearchByHouseholdHeadSMCEventImplCopyWithImpl(
      _$SearchHouseholdsSearchByHouseholdHeadSMCEventImpl _value,
      $Res Function(_$SearchHouseholdsSearchByHouseholdHeadSMCEventImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? searchText = null,
    Object? projectId = null,
    Object? isProximityEnabled = null,
    Object? latitude = freezed,
    Object? longitude = freezed,
    Object? maxRadius = freezed,
    Object? tag = freezed,
    Object? offset = null,
    Object? limit = null,
  }) {
    return _then(_$SearchHouseholdsSearchByHouseholdHeadSMCEventImpl(
      searchText: null == searchText
          ? _value.searchText
          : searchText // ignore: cast_nullable_to_non_nullable
              as String,
      projectId: null == projectId
          ? _value.projectId
          : projectId // ignore: cast_nullable_to_non_nullable
              as String,
      isProximityEnabled: null == isProximityEnabled
          ? _value.isProximityEnabled
          : isProximityEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      latitude: freezed == latitude
          ? _value.latitude
          : latitude // ignore: cast_nullable_to_non_nullable
              as double?,
      longitude: freezed == longitude
          ? _value.longitude
          : longitude // ignore: cast_nullable_to_non_nullable
              as double?,
      maxRadius: freezed == maxRadius
          ? _value.maxRadius
          : maxRadius // ignore: cast_nullable_to_non_nullable
              as double?,
      tag: freezed == tag
          ? _value.tag
          : tag // ignore: cast_nullable_to_non_nullable
              as String?,
      offset: null == offset
          ? _value.offset
          : offset // ignore: cast_nullable_to_non_nullable
              as int,
      limit: null == limit
          ? _value.limit
          : limit // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc

class _$SearchHouseholdsSearchByHouseholdHeadSMCEventImpl
    implements SearchHouseholdsSearchByHouseholdHeadSMCEvent {
  const _$SearchHouseholdsSearchByHouseholdHeadSMCEventImpl(
      {required this.searchText,
      required this.projectId,
      required this.isProximityEnabled,
      this.latitude,
      this.longitude,
      this.maxRadius,
      this.tag,
      required this.offset,
      required this.limit});

  @override
  final String searchText;
  @override
  final String projectId;
  @override
  final bool isProximityEnabled;
  @override
  final double? latitude;
  @override
  final double? longitude;
  @override
  final double? maxRadius;
  @override
  final String? tag;
  @override
  final int offset;
  @override
  final int limit;

  @override
  String toString() {
    return 'SearchHouseholdsSMCEvent.searchByHouseholdHead(searchText: $searchText, projectId: $projectId, isProximityEnabled: $isProximityEnabled, latitude: $latitude, longitude: $longitude, maxRadius: $maxRadius, tag: $tag, offset: $offset, limit: $limit)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SearchHouseholdsSearchByHouseholdHeadSMCEventImpl &&
            (identical(other.searchText, searchText) ||
                other.searchText == searchText) &&
            (identical(other.projectId, projectId) ||
                other.projectId == projectId) &&
            (identical(other.isProximityEnabled, isProximityEnabled) ||
                other.isProximityEnabled == isProximityEnabled) &&
            (identical(other.latitude, latitude) ||
                other.latitude == latitude) &&
            (identical(other.longitude, longitude) ||
                other.longitude == longitude) &&
            (identical(other.maxRadius, maxRadius) ||
                other.maxRadius == maxRadius) &&
            (identical(other.tag, tag) || other.tag == tag) &&
            (identical(other.offset, offset) || other.offset == offset) &&
            (identical(other.limit, limit) || other.limit == limit));
  }

  @override
  int get hashCode => Object.hash(runtimeType, searchText, projectId,
      isProximityEnabled, latitude, longitude, maxRadius, tag, offset, limit);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$SearchHouseholdsSearchByHouseholdHeadSMCEventImplCopyWith<
          _$SearchHouseholdsSearchByHouseholdHeadSMCEventImpl>
      get copyWith =>
          __$$SearchHouseholdsSearchByHouseholdHeadSMCEventImplCopyWithImpl<
                  _$SearchHouseholdsSearchByHouseholdHeadSMCEventImpl>(
              this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initialize,
    required TResult Function(
            String projectId,
            double? latitude,
            double? longitude,
            double? maxRadius,
            bool isProximityEnabled,
            HouseholdModel householdModel)
        searchByHousehold,
    required TResult Function(
            String searchText,
            String projectId,
            bool isProximityEnabled,
            double? latitude,
            double? longitude,
            double? maxRadius,
            String? tag,
            int offset,
            int limit)
        searchByHouseholdHead,
    required TResult Function(double latitude, double longititude,
            String projectId, double maxRadius, int offset, int limit)
        searchByProximity,
    required TResult Function(String tag, String projectId) searchByTag,
    required TResult Function() clear,
    required TResult Function(GlobalSearchParametersSMC globalSearchParams)
        individualGlobalSearch,
    required TResult Function(GlobalSearchParametersSMC globalSearchParams)
        houseHoldGlobalSearch,
  }) {
    return searchByHouseholdHead(searchText, projectId, isProximityEnabled,
        latitude, longitude, maxRadius, tag, offset, limit);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initialize,
    TResult? Function(
            String projectId,
            double? latitude,
            double? longitude,
            double? maxRadius,
            bool isProximityEnabled,
            HouseholdModel householdModel)?
        searchByHousehold,
    TResult? Function(
            String searchText,
            String projectId,
            bool isProximityEnabled,
            double? latitude,
            double? longitude,
            double? maxRadius,
            String? tag,
            int offset,
            int limit)?
        searchByHouseholdHead,
    TResult? Function(double latitude, double longititude, String projectId,
            double maxRadius, int offset, int limit)?
        searchByProximity,
    TResult? Function(String tag, String projectId)? searchByTag,
    TResult? Function()? clear,
    TResult? Function(GlobalSearchParametersSMC globalSearchParams)?
        individualGlobalSearch,
    TResult? Function(GlobalSearchParametersSMC globalSearchParams)?
        houseHoldGlobalSearch,
  }) {
    return searchByHouseholdHead?.call(searchText, projectId,
        isProximityEnabled, latitude, longitude, maxRadius, tag, offset, limit);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initialize,
    TResult Function(
            String projectId,
            double? latitude,
            double? longitude,
            double? maxRadius,
            bool isProximityEnabled,
            HouseholdModel householdModel)?
        searchByHousehold,
    TResult Function(
            String searchText,
            String projectId,
            bool isProximityEnabled,
            double? latitude,
            double? longitude,
            double? maxRadius,
            String? tag,
            int offset,
            int limit)?
        searchByHouseholdHead,
    TResult Function(double latitude, double longititude, String projectId,
            double maxRadius, int offset, int limit)?
        searchByProximity,
    TResult Function(String tag, String projectId)? searchByTag,
    TResult Function()? clear,
    TResult Function(GlobalSearchParametersSMC globalSearchParams)?
        individualGlobalSearch,
    TResult Function(GlobalSearchParametersSMC globalSearchParams)?
        houseHoldGlobalSearch,
    required TResult orElse(),
  }) {
    if (searchByHouseholdHead != null) {
      return searchByHouseholdHead(searchText, projectId, isProximityEnabled,
          latitude, longitude, maxRadius, tag, offset, limit);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(SearchHouseholdsInitializedEvent value)
        initialize,
    required TResult Function(SearchHouseholdsByHouseholdsSMCEvent value)
        searchByHousehold,
    required TResult Function(
            SearchHouseholdsSearchByHouseholdHeadSMCEvent value)
        searchByHouseholdHead,
    required TResult Function(SearchHouseholdsByProximitySMCEvent value)
        searchByProximity,
    required TResult Function(SearchHouseholdsByTagSMCEvent value) searchByTag,
    required TResult Function(SearchHouseholdsClearEvent value) clear,
    required TResult Function(IndividualGlobalSearchSMCEvent value)
        individualGlobalSearch,
    required TResult Function(HouseHoldGlobalSearchSMCEvent value)
        houseHoldGlobalSearch,
  }) {
    return searchByHouseholdHead(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(SearchHouseholdsInitializedEvent value)? initialize,
    TResult? Function(SearchHouseholdsByHouseholdsSMCEvent value)?
        searchByHousehold,
    TResult? Function(SearchHouseholdsSearchByHouseholdHeadSMCEvent value)?
        searchByHouseholdHead,
    TResult? Function(SearchHouseholdsByProximitySMCEvent value)?
        searchByProximity,
    TResult? Function(SearchHouseholdsByTagSMCEvent value)? searchByTag,
    TResult? Function(SearchHouseholdsClearEvent value)? clear,
    TResult? Function(IndividualGlobalSearchSMCEvent value)?
        individualGlobalSearch,
    TResult? Function(HouseHoldGlobalSearchSMCEvent value)?
        houseHoldGlobalSearch,
  }) {
    return searchByHouseholdHead?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(SearchHouseholdsInitializedEvent value)? initialize,
    TResult Function(SearchHouseholdsByHouseholdsSMCEvent value)?
        searchByHousehold,
    TResult Function(SearchHouseholdsSearchByHouseholdHeadSMCEvent value)?
        searchByHouseholdHead,
    TResult Function(SearchHouseholdsByProximitySMCEvent value)?
        searchByProximity,
    TResult Function(SearchHouseholdsByTagSMCEvent value)? searchByTag,
    TResult Function(SearchHouseholdsClearEvent value)? clear,
    TResult Function(IndividualGlobalSearchSMCEvent value)?
        individualGlobalSearch,
    TResult Function(HouseHoldGlobalSearchSMCEvent value)?
        houseHoldGlobalSearch,
    required TResult orElse(),
  }) {
    if (searchByHouseholdHead != null) {
      return searchByHouseholdHead(this);
    }
    return orElse();
  }
}

abstract class SearchHouseholdsSearchByHouseholdHeadSMCEvent
    implements SearchHouseholdsSMCEvent {
  const factory SearchHouseholdsSearchByHouseholdHeadSMCEvent(
          {required final String searchText,
          required final String projectId,
          required final bool isProximityEnabled,
          final double? latitude,
          final double? longitude,
          final double? maxRadius,
          final String? tag,
          required final int offset,
          required final int limit}) =
      _$SearchHouseholdsSearchByHouseholdHeadSMCEventImpl;

  String get searchText;
  String get projectId;
  bool get isProximityEnabled;
  double? get latitude;
  double? get longitude;
  double? get maxRadius;
  String? get tag;
  int get offset;
  int get limit;
  @JsonKey(ignore: true)
  _$$SearchHouseholdsSearchByHouseholdHeadSMCEventImplCopyWith<
          _$SearchHouseholdsSearchByHouseholdHeadSMCEventImpl>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$SearchHouseholdsByProximitySMCEventImplCopyWith<$Res> {
  factory _$$SearchHouseholdsByProximitySMCEventImplCopyWith(
          _$SearchHouseholdsByProximitySMCEventImpl value,
          $Res Function(_$SearchHouseholdsByProximitySMCEventImpl) then) =
      __$$SearchHouseholdsByProximitySMCEventImplCopyWithImpl<$Res>;
  @useResult
  $Res call(
      {double latitude,
      double longititude,
      String projectId,
      double maxRadius,
      int offset,
      int limit});
}

/// @nodoc
class __$$SearchHouseholdsByProximitySMCEventImplCopyWithImpl<$Res>
    extends _$SearchHouseholdsSMCEventCopyWithImpl<$Res,
        _$SearchHouseholdsByProximitySMCEventImpl>
    implements _$$SearchHouseholdsByProximitySMCEventImplCopyWith<$Res> {
  __$$SearchHouseholdsByProximitySMCEventImplCopyWithImpl(
      _$SearchHouseholdsByProximitySMCEventImpl _value,
      $Res Function(_$SearchHouseholdsByProximitySMCEventImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? latitude = null,
    Object? longititude = null,
    Object? projectId = null,
    Object? maxRadius = null,
    Object? offset = null,
    Object? limit = null,
  }) {
    return _then(_$SearchHouseholdsByProximitySMCEventImpl(
      latitude: null == latitude
          ? _value.latitude
          : latitude // ignore: cast_nullable_to_non_nullable
              as double,
      longititude: null == longititude
          ? _value.longititude
          : longititude // ignore: cast_nullable_to_non_nullable
              as double,
      projectId: null == projectId
          ? _value.projectId
          : projectId // ignore: cast_nullable_to_non_nullable
              as String,
      maxRadius: null == maxRadius
          ? _value.maxRadius
          : maxRadius // ignore: cast_nullable_to_non_nullable
              as double,
      offset: null == offset
          ? _value.offset
          : offset // ignore: cast_nullable_to_non_nullable
              as int,
      limit: null == limit
          ? _value.limit
          : limit // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc

class _$SearchHouseholdsByProximitySMCEventImpl
    implements SearchHouseholdsByProximitySMCEvent {
  const _$SearchHouseholdsByProximitySMCEventImpl(
      {required this.latitude,
      required this.longititude,
      required this.projectId,
      required this.maxRadius,
      required this.offset,
      required this.limit});

  @override
  final double latitude;
  @override
  final double longititude;
  @override
  final String projectId;
  @override
  final double maxRadius;
  @override
  final int offset;
  @override
  final int limit;

  @override
  String toString() {
    return 'SearchHouseholdsSMCEvent.searchByProximity(latitude: $latitude, longititude: $longititude, projectId: $projectId, maxRadius: $maxRadius, offset: $offset, limit: $limit)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SearchHouseholdsByProximitySMCEventImpl &&
            (identical(other.latitude, latitude) ||
                other.latitude == latitude) &&
            (identical(other.longititude, longititude) ||
                other.longititude == longititude) &&
            (identical(other.projectId, projectId) ||
                other.projectId == projectId) &&
            (identical(other.maxRadius, maxRadius) ||
                other.maxRadius == maxRadius) &&
            (identical(other.offset, offset) || other.offset == offset) &&
            (identical(other.limit, limit) || other.limit == limit));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, latitude, longititude, projectId, maxRadius, offset, limit);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$SearchHouseholdsByProximitySMCEventImplCopyWith<
          _$SearchHouseholdsByProximitySMCEventImpl>
      get copyWith => __$$SearchHouseholdsByProximitySMCEventImplCopyWithImpl<
          _$SearchHouseholdsByProximitySMCEventImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initialize,
    required TResult Function(
            String projectId,
            double? latitude,
            double? longitude,
            double? maxRadius,
            bool isProximityEnabled,
            HouseholdModel householdModel)
        searchByHousehold,
    required TResult Function(
            String searchText,
            String projectId,
            bool isProximityEnabled,
            double? latitude,
            double? longitude,
            double? maxRadius,
            String? tag,
            int offset,
            int limit)
        searchByHouseholdHead,
    required TResult Function(double latitude, double longititude,
            String projectId, double maxRadius, int offset, int limit)
        searchByProximity,
    required TResult Function(String tag, String projectId) searchByTag,
    required TResult Function() clear,
    required TResult Function(GlobalSearchParametersSMC globalSearchParams)
        individualGlobalSearch,
    required TResult Function(GlobalSearchParametersSMC globalSearchParams)
        houseHoldGlobalSearch,
  }) {
    return searchByProximity(
        latitude, longititude, projectId, maxRadius, offset, limit);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initialize,
    TResult? Function(
            String projectId,
            double? latitude,
            double? longitude,
            double? maxRadius,
            bool isProximityEnabled,
            HouseholdModel householdModel)?
        searchByHousehold,
    TResult? Function(
            String searchText,
            String projectId,
            bool isProximityEnabled,
            double? latitude,
            double? longitude,
            double? maxRadius,
            String? tag,
            int offset,
            int limit)?
        searchByHouseholdHead,
    TResult? Function(double latitude, double longititude, String projectId,
            double maxRadius, int offset, int limit)?
        searchByProximity,
    TResult? Function(String tag, String projectId)? searchByTag,
    TResult? Function()? clear,
    TResult? Function(GlobalSearchParametersSMC globalSearchParams)?
        individualGlobalSearch,
    TResult? Function(GlobalSearchParametersSMC globalSearchParams)?
        houseHoldGlobalSearch,
  }) {
    return searchByProximity?.call(
        latitude, longititude, projectId, maxRadius, offset, limit);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initialize,
    TResult Function(
            String projectId,
            double? latitude,
            double? longitude,
            double? maxRadius,
            bool isProximityEnabled,
            HouseholdModel householdModel)?
        searchByHousehold,
    TResult Function(
            String searchText,
            String projectId,
            bool isProximityEnabled,
            double? latitude,
            double? longitude,
            double? maxRadius,
            String? tag,
            int offset,
            int limit)?
        searchByHouseholdHead,
    TResult Function(double latitude, double longititude, String projectId,
            double maxRadius, int offset, int limit)?
        searchByProximity,
    TResult Function(String tag, String projectId)? searchByTag,
    TResult Function()? clear,
    TResult Function(GlobalSearchParametersSMC globalSearchParams)?
        individualGlobalSearch,
    TResult Function(GlobalSearchParametersSMC globalSearchParams)?
        houseHoldGlobalSearch,
    required TResult orElse(),
  }) {
    if (searchByProximity != null) {
      return searchByProximity(
          latitude, longititude, projectId, maxRadius, offset, limit);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(SearchHouseholdsInitializedEvent value)
        initialize,
    required TResult Function(SearchHouseholdsByHouseholdsSMCEvent value)
        searchByHousehold,
    required TResult Function(
            SearchHouseholdsSearchByHouseholdHeadSMCEvent value)
        searchByHouseholdHead,
    required TResult Function(SearchHouseholdsByProximitySMCEvent value)
        searchByProximity,
    required TResult Function(SearchHouseholdsByTagSMCEvent value) searchByTag,
    required TResult Function(SearchHouseholdsClearEvent value) clear,
    required TResult Function(IndividualGlobalSearchSMCEvent value)
        individualGlobalSearch,
    required TResult Function(HouseHoldGlobalSearchSMCEvent value)
        houseHoldGlobalSearch,
  }) {
    return searchByProximity(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(SearchHouseholdsInitializedEvent value)? initialize,
    TResult? Function(SearchHouseholdsByHouseholdsSMCEvent value)?
        searchByHousehold,
    TResult? Function(SearchHouseholdsSearchByHouseholdHeadSMCEvent value)?
        searchByHouseholdHead,
    TResult? Function(SearchHouseholdsByProximitySMCEvent value)?
        searchByProximity,
    TResult? Function(SearchHouseholdsByTagSMCEvent value)? searchByTag,
    TResult? Function(SearchHouseholdsClearEvent value)? clear,
    TResult? Function(IndividualGlobalSearchSMCEvent value)?
        individualGlobalSearch,
    TResult? Function(HouseHoldGlobalSearchSMCEvent value)?
        houseHoldGlobalSearch,
  }) {
    return searchByProximity?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(SearchHouseholdsInitializedEvent value)? initialize,
    TResult Function(SearchHouseholdsByHouseholdsSMCEvent value)?
        searchByHousehold,
    TResult Function(SearchHouseholdsSearchByHouseholdHeadSMCEvent value)?
        searchByHouseholdHead,
    TResult Function(SearchHouseholdsByProximitySMCEvent value)?
        searchByProximity,
    TResult Function(SearchHouseholdsByTagSMCEvent value)? searchByTag,
    TResult Function(SearchHouseholdsClearEvent value)? clear,
    TResult Function(IndividualGlobalSearchSMCEvent value)?
        individualGlobalSearch,
    TResult Function(HouseHoldGlobalSearchSMCEvent value)?
        houseHoldGlobalSearch,
    required TResult orElse(),
  }) {
    if (searchByProximity != null) {
      return searchByProximity(this);
    }
    return orElse();
  }
}

abstract class SearchHouseholdsByProximitySMCEvent
    implements SearchHouseholdsSMCEvent {
  const factory SearchHouseholdsByProximitySMCEvent(
      {required final double latitude,
      required final double longititude,
      required final String projectId,
      required final double maxRadius,
      required final int offset,
      required final int limit}) = _$SearchHouseholdsByProximitySMCEventImpl;

  double get latitude;
  double get longititude;
  String get projectId;
  double get maxRadius;
  int get offset;
  int get limit;
  @JsonKey(ignore: true)
  _$$SearchHouseholdsByProximitySMCEventImplCopyWith<
          _$SearchHouseholdsByProximitySMCEventImpl>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$SearchHouseholdsByTagSMCEventImplCopyWith<$Res> {
  factory _$$SearchHouseholdsByTagSMCEventImplCopyWith(
          _$SearchHouseholdsByTagSMCEventImpl value,
          $Res Function(_$SearchHouseholdsByTagSMCEventImpl) then) =
      __$$SearchHouseholdsByTagSMCEventImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String tag, String projectId});
}

/// @nodoc
class __$$SearchHouseholdsByTagSMCEventImplCopyWithImpl<$Res>
    extends _$SearchHouseholdsSMCEventCopyWithImpl<$Res,
        _$SearchHouseholdsByTagSMCEventImpl>
    implements _$$SearchHouseholdsByTagSMCEventImplCopyWith<$Res> {
  __$$SearchHouseholdsByTagSMCEventImplCopyWithImpl(
      _$SearchHouseholdsByTagSMCEventImpl _value,
      $Res Function(_$SearchHouseholdsByTagSMCEventImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? tag = null,
    Object? projectId = null,
  }) {
    return _then(_$SearchHouseholdsByTagSMCEventImpl(
      tag: null == tag
          ? _value.tag
          : tag // ignore: cast_nullable_to_non_nullable
              as String,
      projectId: null == projectId
          ? _value.projectId
          : projectId // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$SearchHouseholdsByTagSMCEventImpl
    implements SearchHouseholdsByTagSMCEvent {
  const _$SearchHouseholdsByTagSMCEventImpl(
      {required this.tag, required this.projectId});

  @override
  final String tag;
  @override
  final String projectId;

  @override
  String toString() {
    return 'SearchHouseholdsSMCEvent.searchByTag(tag: $tag, projectId: $projectId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SearchHouseholdsByTagSMCEventImpl &&
            (identical(other.tag, tag) || other.tag == tag) &&
            (identical(other.projectId, projectId) ||
                other.projectId == projectId));
  }

  @override
  int get hashCode => Object.hash(runtimeType, tag, projectId);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$SearchHouseholdsByTagSMCEventImplCopyWith<
          _$SearchHouseholdsByTagSMCEventImpl>
      get copyWith => __$$SearchHouseholdsByTagSMCEventImplCopyWithImpl<
          _$SearchHouseholdsByTagSMCEventImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initialize,
    required TResult Function(
            String projectId,
            double? latitude,
            double? longitude,
            double? maxRadius,
            bool isProximityEnabled,
            HouseholdModel householdModel)
        searchByHousehold,
    required TResult Function(
            String searchText,
            String projectId,
            bool isProximityEnabled,
            double? latitude,
            double? longitude,
            double? maxRadius,
            String? tag,
            int offset,
            int limit)
        searchByHouseholdHead,
    required TResult Function(double latitude, double longititude,
            String projectId, double maxRadius, int offset, int limit)
        searchByProximity,
    required TResult Function(String tag, String projectId) searchByTag,
    required TResult Function() clear,
    required TResult Function(GlobalSearchParametersSMC globalSearchParams)
        individualGlobalSearch,
    required TResult Function(GlobalSearchParametersSMC globalSearchParams)
        houseHoldGlobalSearch,
  }) {
    return searchByTag(tag, projectId);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initialize,
    TResult? Function(
            String projectId,
            double? latitude,
            double? longitude,
            double? maxRadius,
            bool isProximityEnabled,
            HouseholdModel householdModel)?
        searchByHousehold,
    TResult? Function(
            String searchText,
            String projectId,
            bool isProximityEnabled,
            double? latitude,
            double? longitude,
            double? maxRadius,
            String? tag,
            int offset,
            int limit)?
        searchByHouseholdHead,
    TResult? Function(double latitude, double longititude, String projectId,
            double maxRadius, int offset, int limit)?
        searchByProximity,
    TResult? Function(String tag, String projectId)? searchByTag,
    TResult? Function()? clear,
    TResult? Function(GlobalSearchParametersSMC globalSearchParams)?
        individualGlobalSearch,
    TResult? Function(GlobalSearchParametersSMC globalSearchParams)?
        houseHoldGlobalSearch,
  }) {
    return searchByTag?.call(tag, projectId);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initialize,
    TResult Function(
            String projectId,
            double? latitude,
            double? longitude,
            double? maxRadius,
            bool isProximityEnabled,
            HouseholdModel householdModel)?
        searchByHousehold,
    TResult Function(
            String searchText,
            String projectId,
            bool isProximityEnabled,
            double? latitude,
            double? longitude,
            double? maxRadius,
            String? tag,
            int offset,
            int limit)?
        searchByHouseholdHead,
    TResult Function(double latitude, double longititude, String projectId,
            double maxRadius, int offset, int limit)?
        searchByProximity,
    TResult Function(String tag, String projectId)? searchByTag,
    TResult Function()? clear,
    TResult Function(GlobalSearchParametersSMC globalSearchParams)?
        individualGlobalSearch,
    TResult Function(GlobalSearchParametersSMC globalSearchParams)?
        houseHoldGlobalSearch,
    required TResult orElse(),
  }) {
    if (searchByTag != null) {
      return searchByTag(tag, projectId);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(SearchHouseholdsInitializedEvent value)
        initialize,
    required TResult Function(SearchHouseholdsByHouseholdsSMCEvent value)
        searchByHousehold,
    required TResult Function(
            SearchHouseholdsSearchByHouseholdHeadSMCEvent value)
        searchByHouseholdHead,
    required TResult Function(SearchHouseholdsByProximitySMCEvent value)
        searchByProximity,
    required TResult Function(SearchHouseholdsByTagSMCEvent value) searchByTag,
    required TResult Function(SearchHouseholdsClearEvent value) clear,
    required TResult Function(IndividualGlobalSearchSMCEvent value)
        individualGlobalSearch,
    required TResult Function(HouseHoldGlobalSearchSMCEvent value)
        houseHoldGlobalSearch,
  }) {
    return searchByTag(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(SearchHouseholdsInitializedEvent value)? initialize,
    TResult? Function(SearchHouseholdsByHouseholdsSMCEvent value)?
        searchByHousehold,
    TResult? Function(SearchHouseholdsSearchByHouseholdHeadSMCEvent value)?
        searchByHouseholdHead,
    TResult? Function(SearchHouseholdsByProximitySMCEvent value)?
        searchByProximity,
    TResult? Function(SearchHouseholdsByTagSMCEvent value)? searchByTag,
    TResult? Function(SearchHouseholdsClearEvent value)? clear,
    TResult? Function(IndividualGlobalSearchSMCEvent value)?
        individualGlobalSearch,
    TResult? Function(HouseHoldGlobalSearchSMCEvent value)?
        houseHoldGlobalSearch,
  }) {
    return searchByTag?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(SearchHouseholdsInitializedEvent value)? initialize,
    TResult Function(SearchHouseholdsByHouseholdsSMCEvent value)?
        searchByHousehold,
    TResult Function(SearchHouseholdsSearchByHouseholdHeadSMCEvent value)?
        searchByHouseholdHead,
    TResult Function(SearchHouseholdsByProximitySMCEvent value)?
        searchByProximity,
    TResult Function(SearchHouseholdsByTagSMCEvent value)? searchByTag,
    TResult Function(SearchHouseholdsClearEvent value)? clear,
    TResult Function(IndividualGlobalSearchSMCEvent value)?
        individualGlobalSearch,
    TResult Function(HouseHoldGlobalSearchSMCEvent value)?
        houseHoldGlobalSearch,
    required TResult orElse(),
  }) {
    if (searchByTag != null) {
      return searchByTag(this);
    }
    return orElse();
  }
}

abstract class SearchHouseholdsByTagSMCEvent
    implements SearchHouseholdsSMCEvent {
  const factory SearchHouseholdsByTagSMCEvent(
      {required final String tag,
      required final String projectId}) = _$SearchHouseholdsByTagSMCEventImpl;

  String get tag;
  String get projectId;
  @JsonKey(ignore: true)
  _$$SearchHouseholdsByTagSMCEventImplCopyWith<
          _$SearchHouseholdsByTagSMCEventImpl>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$SearchHouseholdsClearEventImplCopyWith<$Res> {
  factory _$$SearchHouseholdsClearEventImplCopyWith(
          _$SearchHouseholdsClearEventImpl value,
          $Res Function(_$SearchHouseholdsClearEventImpl) then) =
      __$$SearchHouseholdsClearEventImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$SearchHouseholdsClearEventImplCopyWithImpl<$Res>
    extends _$SearchHouseholdsSMCEventCopyWithImpl<$Res,
        _$SearchHouseholdsClearEventImpl>
    implements _$$SearchHouseholdsClearEventImplCopyWith<$Res> {
  __$$SearchHouseholdsClearEventImplCopyWithImpl(
      _$SearchHouseholdsClearEventImpl _value,
      $Res Function(_$SearchHouseholdsClearEventImpl) _then)
      : super(_value, _then);
}

/// @nodoc

class _$SearchHouseholdsClearEventImpl implements SearchHouseholdsClearEvent {
  const _$SearchHouseholdsClearEventImpl();

  @override
  String toString() {
    return 'SearchHouseholdsSMCEvent.clear()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SearchHouseholdsClearEventImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initialize,
    required TResult Function(
            String projectId,
            double? latitude,
            double? longitude,
            double? maxRadius,
            bool isProximityEnabled,
            HouseholdModel householdModel)
        searchByHousehold,
    required TResult Function(
            String searchText,
            String projectId,
            bool isProximityEnabled,
            double? latitude,
            double? longitude,
            double? maxRadius,
            String? tag,
            int offset,
            int limit)
        searchByHouseholdHead,
    required TResult Function(double latitude, double longititude,
            String projectId, double maxRadius, int offset, int limit)
        searchByProximity,
    required TResult Function(String tag, String projectId) searchByTag,
    required TResult Function() clear,
    required TResult Function(GlobalSearchParametersSMC globalSearchParams)
        individualGlobalSearch,
    required TResult Function(GlobalSearchParametersSMC globalSearchParams)
        houseHoldGlobalSearch,
  }) {
    return clear();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initialize,
    TResult? Function(
            String projectId,
            double? latitude,
            double? longitude,
            double? maxRadius,
            bool isProximityEnabled,
            HouseholdModel householdModel)?
        searchByHousehold,
    TResult? Function(
            String searchText,
            String projectId,
            bool isProximityEnabled,
            double? latitude,
            double? longitude,
            double? maxRadius,
            String? tag,
            int offset,
            int limit)?
        searchByHouseholdHead,
    TResult? Function(double latitude, double longititude, String projectId,
            double maxRadius, int offset, int limit)?
        searchByProximity,
    TResult? Function(String tag, String projectId)? searchByTag,
    TResult? Function()? clear,
    TResult? Function(GlobalSearchParametersSMC globalSearchParams)?
        individualGlobalSearch,
    TResult? Function(GlobalSearchParametersSMC globalSearchParams)?
        houseHoldGlobalSearch,
  }) {
    return clear?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initialize,
    TResult Function(
            String projectId,
            double? latitude,
            double? longitude,
            double? maxRadius,
            bool isProximityEnabled,
            HouseholdModel householdModel)?
        searchByHousehold,
    TResult Function(
            String searchText,
            String projectId,
            bool isProximityEnabled,
            double? latitude,
            double? longitude,
            double? maxRadius,
            String? tag,
            int offset,
            int limit)?
        searchByHouseholdHead,
    TResult Function(double latitude, double longititude, String projectId,
            double maxRadius, int offset, int limit)?
        searchByProximity,
    TResult Function(String tag, String projectId)? searchByTag,
    TResult Function()? clear,
    TResult Function(GlobalSearchParametersSMC globalSearchParams)?
        individualGlobalSearch,
    TResult Function(GlobalSearchParametersSMC globalSearchParams)?
        houseHoldGlobalSearch,
    required TResult orElse(),
  }) {
    if (clear != null) {
      return clear();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(SearchHouseholdsInitializedEvent value)
        initialize,
    required TResult Function(SearchHouseholdsByHouseholdsSMCEvent value)
        searchByHousehold,
    required TResult Function(
            SearchHouseholdsSearchByHouseholdHeadSMCEvent value)
        searchByHouseholdHead,
    required TResult Function(SearchHouseholdsByProximitySMCEvent value)
        searchByProximity,
    required TResult Function(SearchHouseholdsByTagSMCEvent value) searchByTag,
    required TResult Function(SearchHouseholdsClearEvent value) clear,
    required TResult Function(IndividualGlobalSearchSMCEvent value)
        individualGlobalSearch,
    required TResult Function(HouseHoldGlobalSearchSMCEvent value)
        houseHoldGlobalSearch,
  }) {
    return clear(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(SearchHouseholdsInitializedEvent value)? initialize,
    TResult? Function(SearchHouseholdsByHouseholdsSMCEvent value)?
        searchByHousehold,
    TResult? Function(SearchHouseholdsSearchByHouseholdHeadSMCEvent value)?
        searchByHouseholdHead,
    TResult? Function(SearchHouseholdsByProximitySMCEvent value)?
        searchByProximity,
    TResult? Function(SearchHouseholdsByTagSMCEvent value)? searchByTag,
    TResult? Function(SearchHouseholdsClearEvent value)? clear,
    TResult? Function(IndividualGlobalSearchSMCEvent value)?
        individualGlobalSearch,
    TResult? Function(HouseHoldGlobalSearchSMCEvent value)?
        houseHoldGlobalSearch,
  }) {
    return clear?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(SearchHouseholdsInitializedEvent value)? initialize,
    TResult Function(SearchHouseholdsByHouseholdsSMCEvent value)?
        searchByHousehold,
    TResult Function(SearchHouseholdsSearchByHouseholdHeadSMCEvent value)?
        searchByHouseholdHead,
    TResult Function(SearchHouseholdsByProximitySMCEvent value)?
        searchByProximity,
    TResult Function(SearchHouseholdsByTagSMCEvent value)? searchByTag,
    TResult Function(SearchHouseholdsClearEvent value)? clear,
    TResult Function(IndividualGlobalSearchSMCEvent value)?
        individualGlobalSearch,
    TResult Function(HouseHoldGlobalSearchSMCEvent value)?
        houseHoldGlobalSearch,
    required TResult orElse(),
  }) {
    if (clear != null) {
      return clear(this);
    }
    return orElse();
  }
}

abstract class SearchHouseholdsClearEvent implements SearchHouseholdsSMCEvent {
  const factory SearchHouseholdsClearEvent() = _$SearchHouseholdsClearEventImpl;
}

/// @nodoc
abstract class _$$IndividualGlobalSearchSMCEventImplCopyWith<$Res> {
  factory _$$IndividualGlobalSearchSMCEventImplCopyWith(
          _$IndividualGlobalSearchSMCEventImpl value,
          $Res Function(_$IndividualGlobalSearchSMCEventImpl) then) =
      __$$IndividualGlobalSearchSMCEventImplCopyWithImpl<$Res>;
  @useResult
  $Res call({GlobalSearchParametersSMC globalSearchParams});
}

/// @nodoc
class __$$IndividualGlobalSearchSMCEventImplCopyWithImpl<$Res>
    extends _$SearchHouseholdsSMCEventCopyWithImpl<$Res,
        _$IndividualGlobalSearchSMCEventImpl>
    implements _$$IndividualGlobalSearchSMCEventImplCopyWith<$Res> {
  __$$IndividualGlobalSearchSMCEventImplCopyWithImpl(
      _$IndividualGlobalSearchSMCEventImpl _value,
      $Res Function(_$IndividualGlobalSearchSMCEventImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? globalSearchParams = null,
  }) {
    return _then(_$IndividualGlobalSearchSMCEventImpl(
      globalSearchParams: null == globalSearchParams
          ? _value.globalSearchParams
          : globalSearchParams // ignore: cast_nullable_to_non_nullable
              as GlobalSearchParametersSMC,
    ));
  }
}

/// @nodoc

class _$IndividualGlobalSearchSMCEventImpl
    implements IndividualGlobalSearchSMCEvent {
  const _$IndividualGlobalSearchSMCEventImpl(
      {required this.globalSearchParams});

  @override
  final GlobalSearchParametersSMC globalSearchParams;

  @override
  String toString() {
    return 'SearchHouseholdsSMCEvent.individualGlobalSearch(globalSearchParams: $globalSearchParams)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$IndividualGlobalSearchSMCEventImpl &&
            (identical(other.globalSearchParams, globalSearchParams) ||
                other.globalSearchParams == globalSearchParams));
  }

  @override
  int get hashCode => Object.hash(runtimeType, globalSearchParams);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$IndividualGlobalSearchSMCEventImplCopyWith<
          _$IndividualGlobalSearchSMCEventImpl>
      get copyWith => __$$IndividualGlobalSearchSMCEventImplCopyWithImpl<
          _$IndividualGlobalSearchSMCEventImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initialize,
    required TResult Function(
            String projectId,
            double? latitude,
            double? longitude,
            double? maxRadius,
            bool isProximityEnabled,
            HouseholdModel householdModel)
        searchByHousehold,
    required TResult Function(
            String searchText,
            String projectId,
            bool isProximityEnabled,
            double? latitude,
            double? longitude,
            double? maxRadius,
            String? tag,
            int offset,
            int limit)
        searchByHouseholdHead,
    required TResult Function(double latitude, double longititude,
            String projectId, double maxRadius, int offset, int limit)
        searchByProximity,
    required TResult Function(String tag, String projectId) searchByTag,
    required TResult Function() clear,
    required TResult Function(GlobalSearchParametersSMC globalSearchParams)
        individualGlobalSearch,
    required TResult Function(GlobalSearchParametersSMC globalSearchParams)
        houseHoldGlobalSearch,
  }) {
    return individualGlobalSearch(globalSearchParams);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initialize,
    TResult? Function(
            String projectId,
            double? latitude,
            double? longitude,
            double? maxRadius,
            bool isProximityEnabled,
            HouseholdModel householdModel)?
        searchByHousehold,
    TResult? Function(
            String searchText,
            String projectId,
            bool isProximityEnabled,
            double? latitude,
            double? longitude,
            double? maxRadius,
            String? tag,
            int offset,
            int limit)?
        searchByHouseholdHead,
    TResult? Function(double latitude, double longititude, String projectId,
            double maxRadius, int offset, int limit)?
        searchByProximity,
    TResult? Function(String tag, String projectId)? searchByTag,
    TResult? Function()? clear,
    TResult? Function(GlobalSearchParametersSMC globalSearchParams)?
        individualGlobalSearch,
    TResult? Function(GlobalSearchParametersSMC globalSearchParams)?
        houseHoldGlobalSearch,
  }) {
    return individualGlobalSearch?.call(globalSearchParams);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initialize,
    TResult Function(
            String projectId,
            double? latitude,
            double? longitude,
            double? maxRadius,
            bool isProximityEnabled,
            HouseholdModel householdModel)?
        searchByHousehold,
    TResult Function(
            String searchText,
            String projectId,
            bool isProximityEnabled,
            double? latitude,
            double? longitude,
            double? maxRadius,
            String? tag,
            int offset,
            int limit)?
        searchByHouseholdHead,
    TResult Function(double latitude, double longititude, String projectId,
            double maxRadius, int offset, int limit)?
        searchByProximity,
    TResult Function(String tag, String projectId)? searchByTag,
    TResult Function()? clear,
    TResult Function(GlobalSearchParametersSMC globalSearchParams)?
        individualGlobalSearch,
    TResult Function(GlobalSearchParametersSMC globalSearchParams)?
        houseHoldGlobalSearch,
    required TResult orElse(),
  }) {
    if (individualGlobalSearch != null) {
      return individualGlobalSearch(globalSearchParams);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(SearchHouseholdsInitializedEvent value)
        initialize,
    required TResult Function(SearchHouseholdsByHouseholdsSMCEvent value)
        searchByHousehold,
    required TResult Function(
            SearchHouseholdsSearchByHouseholdHeadSMCEvent value)
        searchByHouseholdHead,
    required TResult Function(SearchHouseholdsByProximitySMCEvent value)
        searchByProximity,
    required TResult Function(SearchHouseholdsByTagSMCEvent value) searchByTag,
    required TResult Function(SearchHouseholdsClearEvent value) clear,
    required TResult Function(IndividualGlobalSearchSMCEvent value)
        individualGlobalSearch,
    required TResult Function(HouseHoldGlobalSearchSMCEvent value)
        houseHoldGlobalSearch,
  }) {
    return individualGlobalSearch(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(SearchHouseholdsInitializedEvent value)? initialize,
    TResult? Function(SearchHouseholdsByHouseholdsSMCEvent value)?
        searchByHousehold,
    TResult? Function(SearchHouseholdsSearchByHouseholdHeadSMCEvent value)?
        searchByHouseholdHead,
    TResult? Function(SearchHouseholdsByProximitySMCEvent value)?
        searchByProximity,
    TResult? Function(SearchHouseholdsByTagSMCEvent value)? searchByTag,
    TResult? Function(SearchHouseholdsClearEvent value)? clear,
    TResult? Function(IndividualGlobalSearchSMCEvent value)?
        individualGlobalSearch,
    TResult? Function(HouseHoldGlobalSearchSMCEvent value)?
        houseHoldGlobalSearch,
  }) {
    return individualGlobalSearch?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(SearchHouseholdsInitializedEvent value)? initialize,
    TResult Function(SearchHouseholdsByHouseholdsSMCEvent value)?
        searchByHousehold,
    TResult Function(SearchHouseholdsSearchByHouseholdHeadSMCEvent value)?
        searchByHouseholdHead,
    TResult Function(SearchHouseholdsByProximitySMCEvent value)?
        searchByProximity,
    TResult Function(SearchHouseholdsByTagSMCEvent value)? searchByTag,
    TResult Function(SearchHouseholdsClearEvent value)? clear,
    TResult Function(IndividualGlobalSearchSMCEvent value)?
        individualGlobalSearch,
    TResult Function(HouseHoldGlobalSearchSMCEvent value)?
        houseHoldGlobalSearch,
    required TResult orElse(),
  }) {
    if (individualGlobalSearch != null) {
      return individualGlobalSearch(this);
    }
    return orElse();
  }
}

abstract class IndividualGlobalSearchSMCEvent
    implements SearchHouseholdsSMCEvent {
  const factory IndividualGlobalSearchSMCEvent(
          {required final GlobalSearchParametersSMC globalSearchParams}) =
      _$IndividualGlobalSearchSMCEventImpl;

  GlobalSearchParametersSMC get globalSearchParams;
  @JsonKey(ignore: true)
  _$$IndividualGlobalSearchSMCEventImplCopyWith<
          _$IndividualGlobalSearchSMCEventImpl>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$HouseHoldGlobalSearchSMCEventImplCopyWith<$Res> {
  factory _$$HouseHoldGlobalSearchSMCEventImplCopyWith(
          _$HouseHoldGlobalSearchSMCEventImpl value,
          $Res Function(_$HouseHoldGlobalSearchSMCEventImpl) then) =
      __$$HouseHoldGlobalSearchSMCEventImplCopyWithImpl<$Res>;
  @useResult
  $Res call({GlobalSearchParametersSMC globalSearchParams});
}

/// @nodoc
class __$$HouseHoldGlobalSearchSMCEventImplCopyWithImpl<$Res>
    extends _$SearchHouseholdsSMCEventCopyWithImpl<$Res,
        _$HouseHoldGlobalSearchSMCEventImpl>
    implements _$$HouseHoldGlobalSearchSMCEventImplCopyWith<$Res> {
  __$$HouseHoldGlobalSearchSMCEventImplCopyWithImpl(
      _$HouseHoldGlobalSearchSMCEventImpl _value,
      $Res Function(_$HouseHoldGlobalSearchSMCEventImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? globalSearchParams = null,
  }) {
    return _then(_$HouseHoldGlobalSearchSMCEventImpl(
      globalSearchParams: null == globalSearchParams
          ? _value.globalSearchParams
          : globalSearchParams // ignore: cast_nullable_to_non_nullable
              as GlobalSearchParametersSMC,
    ));
  }
}

/// @nodoc

class _$HouseHoldGlobalSearchSMCEventImpl
    implements HouseHoldGlobalSearchSMCEvent {
  const _$HouseHoldGlobalSearchSMCEventImpl({required this.globalSearchParams});

  @override
  final GlobalSearchParametersSMC globalSearchParams;

  @override
  String toString() {
    return 'SearchHouseholdsSMCEvent.houseHoldGlobalSearch(globalSearchParams: $globalSearchParams)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$HouseHoldGlobalSearchSMCEventImpl &&
            (identical(other.globalSearchParams, globalSearchParams) ||
                other.globalSearchParams == globalSearchParams));
  }

  @override
  int get hashCode => Object.hash(runtimeType, globalSearchParams);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$HouseHoldGlobalSearchSMCEventImplCopyWith<
          _$HouseHoldGlobalSearchSMCEventImpl>
      get copyWith => __$$HouseHoldGlobalSearchSMCEventImplCopyWithImpl<
          _$HouseHoldGlobalSearchSMCEventImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initialize,
    required TResult Function(
            String projectId,
            double? latitude,
            double? longitude,
            double? maxRadius,
            bool isProximityEnabled,
            HouseholdModel householdModel)
        searchByHousehold,
    required TResult Function(
            String searchText,
            String projectId,
            bool isProximityEnabled,
            double? latitude,
            double? longitude,
            double? maxRadius,
            String? tag,
            int offset,
            int limit)
        searchByHouseholdHead,
    required TResult Function(double latitude, double longititude,
            String projectId, double maxRadius, int offset, int limit)
        searchByProximity,
    required TResult Function(String tag, String projectId) searchByTag,
    required TResult Function() clear,
    required TResult Function(GlobalSearchParametersSMC globalSearchParams)
        individualGlobalSearch,
    required TResult Function(GlobalSearchParametersSMC globalSearchParams)
        houseHoldGlobalSearch,
  }) {
    return houseHoldGlobalSearch(globalSearchParams);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initialize,
    TResult? Function(
            String projectId,
            double? latitude,
            double? longitude,
            double? maxRadius,
            bool isProximityEnabled,
            HouseholdModel householdModel)?
        searchByHousehold,
    TResult? Function(
            String searchText,
            String projectId,
            bool isProximityEnabled,
            double? latitude,
            double? longitude,
            double? maxRadius,
            String? tag,
            int offset,
            int limit)?
        searchByHouseholdHead,
    TResult? Function(double latitude, double longititude, String projectId,
            double maxRadius, int offset, int limit)?
        searchByProximity,
    TResult? Function(String tag, String projectId)? searchByTag,
    TResult? Function()? clear,
    TResult? Function(GlobalSearchParametersSMC globalSearchParams)?
        individualGlobalSearch,
    TResult? Function(GlobalSearchParametersSMC globalSearchParams)?
        houseHoldGlobalSearch,
  }) {
    return houseHoldGlobalSearch?.call(globalSearchParams);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initialize,
    TResult Function(
            String projectId,
            double? latitude,
            double? longitude,
            double? maxRadius,
            bool isProximityEnabled,
            HouseholdModel householdModel)?
        searchByHousehold,
    TResult Function(
            String searchText,
            String projectId,
            bool isProximityEnabled,
            double? latitude,
            double? longitude,
            double? maxRadius,
            String? tag,
            int offset,
            int limit)?
        searchByHouseholdHead,
    TResult Function(double latitude, double longititude, String projectId,
            double maxRadius, int offset, int limit)?
        searchByProximity,
    TResult Function(String tag, String projectId)? searchByTag,
    TResult Function()? clear,
    TResult Function(GlobalSearchParametersSMC globalSearchParams)?
        individualGlobalSearch,
    TResult Function(GlobalSearchParametersSMC globalSearchParams)?
        houseHoldGlobalSearch,
    required TResult orElse(),
  }) {
    if (houseHoldGlobalSearch != null) {
      return houseHoldGlobalSearch(globalSearchParams);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(SearchHouseholdsInitializedEvent value)
        initialize,
    required TResult Function(SearchHouseholdsByHouseholdsSMCEvent value)
        searchByHousehold,
    required TResult Function(
            SearchHouseholdsSearchByHouseholdHeadSMCEvent value)
        searchByHouseholdHead,
    required TResult Function(SearchHouseholdsByProximitySMCEvent value)
        searchByProximity,
    required TResult Function(SearchHouseholdsByTagSMCEvent value) searchByTag,
    required TResult Function(SearchHouseholdsClearEvent value) clear,
    required TResult Function(IndividualGlobalSearchSMCEvent value)
        individualGlobalSearch,
    required TResult Function(HouseHoldGlobalSearchSMCEvent value)
        houseHoldGlobalSearch,
  }) {
    return houseHoldGlobalSearch(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(SearchHouseholdsInitializedEvent value)? initialize,
    TResult? Function(SearchHouseholdsByHouseholdsSMCEvent value)?
        searchByHousehold,
    TResult? Function(SearchHouseholdsSearchByHouseholdHeadSMCEvent value)?
        searchByHouseholdHead,
    TResult? Function(SearchHouseholdsByProximitySMCEvent value)?
        searchByProximity,
    TResult? Function(SearchHouseholdsByTagSMCEvent value)? searchByTag,
    TResult? Function(SearchHouseholdsClearEvent value)? clear,
    TResult? Function(IndividualGlobalSearchSMCEvent value)?
        individualGlobalSearch,
    TResult? Function(HouseHoldGlobalSearchSMCEvent value)?
        houseHoldGlobalSearch,
  }) {
    return houseHoldGlobalSearch?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(SearchHouseholdsInitializedEvent value)? initialize,
    TResult Function(SearchHouseholdsByHouseholdsSMCEvent value)?
        searchByHousehold,
    TResult Function(SearchHouseholdsSearchByHouseholdHeadSMCEvent value)?
        searchByHouseholdHead,
    TResult Function(SearchHouseholdsByProximitySMCEvent value)?
        searchByProximity,
    TResult Function(SearchHouseholdsByTagSMCEvent value)? searchByTag,
    TResult Function(SearchHouseholdsClearEvent value)? clear,
    TResult Function(IndividualGlobalSearchSMCEvent value)?
        individualGlobalSearch,
    TResult Function(HouseHoldGlobalSearchSMCEvent value)?
        houseHoldGlobalSearch,
    required TResult orElse(),
  }) {
    if (houseHoldGlobalSearch != null) {
      return houseHoldGlobalSearch(this);
    }
    return orElse();
  }
}

abstract class HouseHoldGlobalSearchSMCEvent
    implements SearchHouseholdsSMCEvent {
  const factory HouseHoldGlobalSearchSMCEvent(
          {required final GlobalSearchParametersSMC globalSearchParams}) =
      _$HouseHoldGlobalSearchSMCEventImpl;

  GlobalSearchParametersSMC get globalSearchParams;
  @JsonKey(ignore: true)
  _$$HouseHoldGlobalSearchSMCEventImplCopyWith<
          _$HouseHoldGlobalSearchSMCEventImpl>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$SearchHouseholdsSMCState {
  int get offset => throw _privateConstructorUsedError;
  int get limit => throw _privateConstructorUsedError;
  bool get loading => throw _privateConstructorUsedError;
  String? get searchQuery => throw _privateConstructorUsedError;
  String? get tag => throw _privateConstructorUsedError;
  List<HouseholdMemberWrapper> get householdMembers =>
      throw _privateConstructorUsedError;
  int get totalResults => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $SearchHouseholdsSMCStateCopyWith<SearchHouseholdsSMCState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SearchHouseholdsSMCStateCopyWith<$Res> {
  factory $SearchHouseholdsSMCStateCopyWith(SearchHouseholdsSMCState value,
          $Res Function(SearchHouseholdsSMCState) then) =
      _$SearchHouseholdsSMCStateCopyWithImpl<$Res, SearchHouseholdsSMCState>;
  @useResult
  $Res call(
      {int offset,
      int limit,
      bool loading,
      String? searchQuery,
      String? tag,
      List<HouseholdMemberWrapper> householdMembers,
      int totalResults});
}

/// @nodoc
class _$SearchHouseholdsSMCStateCopyWithImpl<$Res,
        $Val extends SearchHouseholdsSMCState>
    implements $SearchHouseholdsSMCStateCopyWith<$Res> {
  _$SearchHouseholdsSMCStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? offset = null,
    Object? limit = null,
    Object? loading = null,
    Object? searchQuery = freezed,
    Object? tag = freezed,
    Object? householdMembers = null,
    Object? totalResults = null,
  }) {
    return _then(_value.copyWith(
      offset: null == offset
          ? _value.offset
          : offset // ignore: cast_nullable_to_non_nullable
              as int,
      limit: null == limit
          ? _value.limit
          : limit // ignore: cast_nullable_to_non_nullable
              as int,
      loading: null == loading
          ? _value.loading
          : loading // ignore: cast_nullable_to_non_nullable
              as bool,
      searchQuery: freezed == searchQuery
          ? _value.searchQuery
          : searchQuery // ignore: cast_nullable_to_non_nullable
              as String?,
      tag: freezed == tag
          ? _value.tag
          : tag // ignore: cast_nullable_to_non_nullable
              as String?,
      householdMembers: null == householdMembers
          ? _value.householdMembers
          : householdMembers // ignore: cast_nullable_to_non_nullable
              as List<HouseholdMemberWrapper>,
      totalResults: null == totalResults
          ? _value.totalResults
          : totalResults // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SearchHouseholdsSMCStateImplCopyWith<$Res>
    implements $SearchHouseholdsSMCStateCopyWith<$Res> {
  factory _$$SearchHouseholdsSMCStateImplCopyWith(
          _$SearchHouseholdsSMCStateImpl value,
          $Res Function(_$SearchHouseholdsSMCStateImpl) then) =
      __$$SearchHouseholdsSMCStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int offset,
      int limit,
      bool loading,
      String? searchQuery,
      String? tag,
      List<HouseholdMemberWrapper> householdMembers,
      int totalResults});
}

/// @nodoc
class __$$SearchHouseholdsSMCStateImplCopyWithImpl<$Res>
    extends _$SearchHouseholdsSMCStateCopyWithImpl<$Res,
        _$SearchHouseholdsSMCStateImpl>
    implements _$$SearchHouseholdsSMCStateImplCopyWith<$Res> {
  __$$SearchHouseholdsSMCStateImplCopyWithImpl(
      _$SearchHouseholdsSMCStateImpl _value,
      $Res Function(_$SearchHouseholdsSMCStateImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? offset = null,
    Object? limit = null,
    Object? loading = null,
    Object? searchQuery = freezed,
    Object? tag = freezed,
    Object? householdMembers = null,
    Object? totalResults = null,
  }) {
    return _then(_$SearchHouseholdsSMCStateImpl(
      offset: null == offset
          ? _value.offset
          : offset // ignore: cast_nullable_to_non_nullable
              as int,
      limit: null == limit
          ? _value.limit
          : limit // ignore: cast_nullable_to_non_nullable
              as int,
      loading: null == loading
          ? _value.loading
          : loading // ignore: cast_nullable_to_non_nullable
              as bool,
      searchQuery: freezed == searchQuery
          ? _value.searchQuery
          : searchQuery // ignore: cast_nullable_to_non_nullable
              as String?,
      tag: freezed == tag
          ? _value.tag
          : tag // ignore: cast_nullable_to_non_nullable
              as String?,
      householdMembers: null == householdMembers
          ? _value._householdMembers
          : householdMembers // ignore: cast_nullable_to_non_nullable
              as List<HouseholdMemberWrapper>,
      totalResults: null == totalResults
          ? _value.totalResults
          : totalResults // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc

class _$SearchHouseholdsSMCStateImpl extends _SearchHouseholdsSMCState {
  const _$SearchHouseholdsSMCStateImpl(
      {this.offset = 0,
      this.limit = 10,
      this.loading = false,
      this.searchQuery,
      this.tag,
      final List<HouseholdMemberWrapper> householdMembers = const [],
      this.totalResults = 0})
      : _householdMembers = householdMembers,
        super._();

  @override
  @JsonKey()
  final int offset;
  @override
  @JsonKey()
  final int limit;
  @override
  @JsonKey()
  final bool loading;
  @override
  final String? searchQuery;
  @override
  final String? tag;
  final List<HouseholdMemberWrapper> _householdMembers;
  @override
  @JsonKey()
  List<HouseholdMemberWrapper> get householdMembers {
    if (_householdMembers is EqualUnmodifiableListView)
      return _householdMembers;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_householdMembers);
  }

  @override
  @JsonKey()
  final int totalResults;

  @override
  String toString() {
    return 'SearchHouseholdsSMCState(offset: $offset, limit: $limit, loading: $loading, searchQuery: $searchQuery, tag: $tag, householdMembers: $householdMembers, totalResults: $totalResults)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SearchHouseholdsSMCStateImpl &&
            (identical(other.offset, offset) || other.offset == offset) &&
            (identical(other.limit, limit) || other.limit == limit) &&
            (identical(other.loading, loading) || other.loading == loading) &&
            (identical(other.searchQuery, searchQuery) ||
                other.searchQuery == searchQuery) &&
            (identical(other.tag, tag) || other.tag == tag) &&
            const DeepCollectionEquality()
                .equals(other._householdMembers, _householdMembers) &&
            (identical(other.totalResults, totalResults) ||
                other.totalResults == totalResults));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      offset,
      limit,
      loading,
      searchQuery,
      tag,
      const DeepCollectionEquality().hash(_householdMembers),
      totalResults);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$SearchHouseholdsSMCStateImplCopyWith<_$SearchHouseholdsSMCStateImpl>
      get copyWith => __$$SearchHouseholdsSMCStateImplCopyWithImpl<
          _$SearchHouseholdsSMCStateImpl>(this, _$identity);
}

abstract class _SearchHouseholdsSMCState extends SearchHouseholdsSMCState {
  const factory _SearchHouseholdsSMCState(
      {final int offset,
      final int limit,
      final bool loading,
      final String? searchQuery,
      final String? tag,
      final List<HouseholdMemberWrapper> householdMembers,
      final int totalResults}) = _$SearchHouseholdsSMCStateImpl;
  const _SearchHouseholdsSMCState._() : super._();

  @override
  int get offset;
  @override
  int get limit;
  @override
  bool get loading;
  @override
  String? get searchQuery;
  @override
  String? get tag;
  @override
  List<HouseholdMemberWrapper> get householdMembers;
  @override
  int get totalResults;
  @override
  @JsonKey(ignore: true)
  _$$SearchHouseholdsSMCStateImplCopyWith<_$SearchHouseholdsSMCStateImpl>
      get copyWith => throw _privateConstructorUsedError;
}
