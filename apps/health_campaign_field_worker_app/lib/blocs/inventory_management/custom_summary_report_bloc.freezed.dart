// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'custom_summary_report_bloc.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$SummaryReportEvent {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String userId) loadSummaryData,
    required TResult Function() loading,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String userId)? loadSummaryData,
    TResult? Function()? loading,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String userId)? loadSummaryData,
    TResult Function()? loading,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(SummaryReportLoadDataEvent value) loadSummaryData,
    required TResult Function(SummaryReportLoadingEvent value) loading,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(SummaryReportLoadDataEvent value)? loadSummaryData,
    TResult? Function(SummaryReportLoadingEvent value)? loading,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(SummaryReportLoadDataEvent value)? loadSummaryData,
    TResult Function(SummaryReportLoadingEvent value)? loading,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SummaryReportEventCopyWith<$Res> {
  factory $SummaryReportEventCopyWith(
          SummaryReportEvent value, $Res Function(SummaryReportEvent) then) =
      _$SummaryReportEventCopyWithImpl<$Res, SummaryReportEvent>;
}

/// @nodoc
class _$SummaryReportEventCopyWithImpl<$Res, $Val extends SummaryReportEvent>
    implements $SummaryReportEventCopyWith<$Res> {
  _$SummaryReportEventCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;
}

/// @nodoc
abstract class _$$SummaryReportLoadDataEventImplCopyWith<$Res> {
  factory _$$SummaryReportLoadDataEventImplCopyWith(
          _$SummaryReportLoadDataEventImpl value,
          $Res Function(_$SummaryReportLoadDataEventImpl) then) =
      __$$SummaryReportLoadDataEventImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String userId});
}

/// @nodoc
class __$$SummaryReportLoadDataEventImplCopyWithImpl<$Res>
    extends _$SummaryReportEventCopyWithImpl<$Res,
        _$SummaryReportLoadDataEventImpl>
    implements _$$SummaryReportLoadDataEventImplCopyWith<$Res> {
  __$$SummaryReportLoadDataEventImplCopyWithImpl(
      _$SummaryReportLoadDataEventImpl _value,
      $Res Function(_$SummaryReportLoadDataEventImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
  }) {
    return _then(_$SummaryReportLoadDataEventImpl(
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$SummaryReportLoadDataEventImpl implements SummaryReportLoadDataEvent {
  const _$SummaryReportLoadDataEventImpl({required this.userId});

  @override
  final String userId;

  @override
  String toString() {
    return 'SummaryReportEvent.loadSummaryData(userId: $userId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SummaryReportLoadDataEventImpl &&
            (identical(other.userId, userId) || other.userId == userId));
  }

  @override
  int get hashCode => Object.hash(runtimeType, userId);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$SummaryReportLoadDataEventImplCopyWith<_$SummaryReportLoadDataEventImpl>
      get copyWith => __$$SummaryReportLoadDataEventImplCopyWithImpl<
          _$SummaryReportLoadDataEventImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String userId) loadSummaryData,
    required TResult Function() loading,
  }) {
    return loadSummaryData(userId);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String userId)? loadSummaryData,
    TResult? Function()? loading,
  }) {
    return loadSummaryData?.call(userId);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String userId)? loadSummaryData,
    TResult Function()? loading,
    required TResult orElse(),
  }) {
    if (loadSummaryData != null) {
      return loadSummaryData(userId);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(SummaryReportLoadDataEvent value) loadSummaryData,
    required TResult Function(SummaryReportLoadingEvent value) loading,
  }) {
    return loadSummaryData(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(SummaryReportLoadDataEvent value)? loadSummaryData,
    TResult? Function(SummaryReportLoadingEvent value)? loading,
  }) {
    return loadSummaryData?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(SummaryReportLoadDataEvent value)? loadSummaryData,
    TResult Function(SummaryReportLoadingEvent value)? loading,
    required TResult orElse(),
  }) {
    if (loadSummaryData != null) {
      return loadSummaryData(this);
    }
    return orElse();
  }
}

abstract class SummaryReportLoadDataEvent implements SummaryReportEvent {
  const factory SummaryReportLoadDataEvent({required final String userId}) =
      _$SummaryReportLoadDataEventImpl;

  String get userId;
  @JsonKey(ignore: true)
  _$$SummaryReportLoadDataEventImplCopyWith<_$SummaryReportLoadDataEventImpl>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$SummaryReportLoadingEventImplCopyWith<$Res> {
  factory _$$SummaryReportLoadingEventImplCopyWith(
          _$SummaryReportLoadingEventImpl value,
          $Res Function(_$SummaryReportLoadingEventImpl) then) =
      __$$SummaryReportLoadingEventImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$SummaryReportLoadingEventImplCopyWithImpl<$Res>
    extends _$SummaryReportEventCopyWithImpl<$Res,
        _$SummaryReportLoadingEventImpl>
    implements _$$SummaryReportLoadingEventImplCopyWith<$Res> {
  __$$SummaryReportLoadingEventImplCopyWithImpl(
      _$SummaryReportLoadingEventImpl _value,
      $Res Function(_$SummaryReportLoadingEventImpl) _then)
      : super(_value, _then);
}

/// @nodoc

class _$SummaryReportLoadingEventImpl implements SummaryReportLoadingEvent {
  const _$SummaryReportLoadingEventImpl();

  @override
  String toString() {
    return 'SummaryReportEvent.loading()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SummaryReportLoadingEventImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String userId) loadSummaryData,
    required TResult Function() loading,
  }) {
    return loading();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String userId)? loadSummaryData,
    TResult? Function()? loading,
  }) {
    return loading?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String userId)? loadSummaryData,
    TResult Function()? loading,
    required TResult orElse(),
  }) {
    if (loading != null) {
      return loading();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(SummaryReportLoadDataEvent value) loadSummaryData,
    required TResult Function(SummaryReportLoadingEvent value) loading,
  }) {
    return loading(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(SummaryReportLoadDataEvent value)? loadSummaryData,
    TResult? Function(SummaryReportLoadingEvent value)? loading,
  }) {
    return loading?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(SummaryReportLoadDataEvent value)? loadSummaryData,
    TResult Function(SummaryReportLoadingEvent value)? loading,
    required TResult orElse(),
  }) {
    if (loading != null) {
      return loading(this);
    }
    return orElse();
  }
}

abstract class SummaryReportLoadingEvent implements SummaryReportEvent {
  const factory SummaryReportLoadingEvent() = _$SummaryReportLoadingEventImpl;
}

/// @nodoc
mixin _$SummaryReportState {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() loading,
    required TResult Function() empty,
    required TResult Function(Map<String, Map<String, int>> data) data,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? loading,
    TResult? Function()? empty,
    TResult? Function(Map<String, Map<String, int>> data)? data,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? loading,
    TResult Function()? empty,
    TResult Function(Map<String, Map<String, int>> data)? data,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(SummaryReportLoadingState value) loading,
    required TResult Function(SummaryReportEmptyState value) empty,
    required TResult Function(SummaryReportDataState value) data,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(SummaryReportLoadingState value)? loading,
    TResult? Function(SummaryReportEmptyState value)? empty,
    TResult? Function(SummaryReportDataState value)? data,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(SummaryReportLoadingState value)? loading,
    TResult Function(SummaryReportEmptyState value)? empty,
    TResult Function(SummaryReportDataState value)? data,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SummaryReportStateCopyWith<$Res> {
  factory $SummaryReportStateCopyWith(
          SummaryReportState value, $Res Function(SummaryReportState) then) =
      _$SummaryReportStateCopyWithImpl<$Res, SummaryReportState>;
}

/// @nodoc
class _$SummaryReportStateCopyWithImpl<$Res, $Val extends SummaryReportState>
    implements $SummaryReportStateCopyWith<$Res> {
  _$SummaryReportStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;
}

/// @nodoc
abstract class _$$SummaryReportLoadingStateImplCopyWith<$Res> {
  factory _$$SummaryReportLoadingStateImplCopyWith(
          _$SummaryReportLoadingStateImpl value,
          $Res Function(_$SummaryReportLoadingStateImpl) then) =
      __$$SummaryReportLoadingStateImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$SummaryReportLoadingStateImplCopyWithImpl<$Res>
    extends _$SummaryReportStateCopyWithImpl<$Res,
        _$SummaryReportLoadingStateImpl>
    implements _$$SummaryReportLoadingStateImplCopyWith<$Res> {
  __$$SummaryReportLoadingStateImplCopyWithImpl(
      _$SummaryReportLoadingStateImpl _value,
      $Res Function(_$SummaryReportLoadingStateImpl) _then)
      : super(_value, _then);
}

/// @nodoc

class _$SummaryReportLoadingStateImpl implements SummaryReportLoadingState {
  const _$SummaryReportLoadingStateImpl();

  @override
  String toString() {
    return 'SummaryReportState.loading()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SummaryReportLoadingStateImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() loading,
    required TResult Function() empty,
    required TResult Function(Map<String, Map<String, int>> data) data,
  }) {
    return loading();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? loading,
    TResult? Function()? empty,
    TResult? Function(Map<String, Map<String, int>> data)? data,
  }) {
    return loading?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? loading,
    TResult Function()? empty,
    TResult Function(Map<String, Map<String, int>> data)? data,
    required TResult orElse(),
  }) {
    if (loading != null) {
      return loading();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(SummaryReportLoadingState value) loading,
    required TResult Function(SummaryReportEmptyState value) empty,
    required TResult Function(SummaryReportDataState value) data,
  }) {
    return loading(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(SummaryReportLoadingState value)? loading,
    TResult? Function(SummaryReportEmptyState value)? empty,
    TResult? Function(SummaryReportDataState value)? data,
  }) {
    return loading?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(SummaryReportLoadingState value)? loading,
    TResult Function(SummaryReportEmptyState value)? empty,
    TResult Function(SummaryReportDataState value)? data,
    required TResult orElse(),
  }) {
    if (loading != null) {
      return loading(this);
    }
    return orElse();
  }
}

abstract class SummaryReportLoadingState implements SummaryReportState {
  const factory SummaryReportLoadingState() = _$SummaryReportLoadingStateImpl;
}

/// @nodoc
abstract class _$$SummaryReportEmptyStateImplCopyWith<$Res> {
  factory _$$SummaryReportEmptyStateImplCopyWith(
          _$SummaryReportEmptyStateImpl value,
          $Res Function(_$SummaryReportEmptyStateImpl) then) =
      __$$SummaryReportEmptyStateImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$SummaryReportEmptyStateImplCopyWithImpl<$Res>
    extends _$SummaryReportStateCopyWithImpl<$Res,
        _$SummaryReportEmptyStateImpl>
    implements _$$SummaryReportEmptyStateImplCopyWith<$Res> {
  __$$SummaryReportEmptyStateImplCopyWithImpl(
      _$SummaryReportEmptyStateImpl _value,
      $Res Function(_$SummaryReportEmptyStateImpl) _then)
      : super(_value, _then);
}

/// @nodoc

class _$SummaryReportEmptyStateImpl implements SummaryReportEmptyState {
  const _$SummaryReportEmptyStateImpl();

  @override
  String toString() {
    return 'SummaryReportState.empty()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SummaryReportEmptyStateImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() loading,
    required TResult Function() empty,
    required TResult Function(Map<String, Map<String, int>> data) data,
  }) {
    return empty();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? loading,
    TResult? Function()? empty,
    TResult? Function(Map<String, Map<String, int>> data)? data,
  }) {
    return empty?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? loading,
    TResult Function()? empty,
    TResult Function(Map<String, Map<String, int>> data)? data,
    required TResult orElse(),
  }) {
    if (empty != null) {
      return empty();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(SummaryReportLoadingState value) loading,
    required TResult Function(SummaryReportEmptyState value) empty,
    required TResult Function(SummaryReportDataState value) data,
  }) {
    return empty(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(SummaryReportLoadingState value)? loading,
    TResult? Function(SummaryReportEmptyState value)? empty,
    TResult? Function(SummaryReportDataState value)? data,
  }) {
    return empty?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(SummaryReportLoadingState value)? loading,
    TResult Function(SummaryReportEmptyState value)? empty,
    TResult Function(SummaryReportDataState value)? data,
    required TResult orElse(),
  }) {
    if (empty != null) {
      return empty(this);
    }
    return orElse();
  }
}

abstract class SummaryReportEmptyState implements SummaryReportState {
  const factory SummaryReportEmptyState() = _$SummaryReportEmptyStateImpl;
}

/// @nodoc
abstract class _$$SummaryReportDataStateImplCopyWith<$Res> {
  factory _$$SummaryReportDataStateImplCopyWith(
          _$SummaryReportDataStateImpl value,
          $Res Function(_$SummaryReportDataStateImpl) then) =
      __$$SummaryReportDataStateImplCopyWithImpl<$Res>;
  @useResult
  $Res call({Map<String, Map<String, int>> data});
}

/// @nodoc
class __$$SummaryReportDataStateImplCopyWithImpl<$Res>
    extends _$SummaryReportStateCopyWithImpl<$Res, _$SummaryReportDataStateImpl>
    implements _$$SummaryReportDataStateImplCopyWith<$Res> {
  __$$SummaryReportDataStateImplCopyWithImpl(
      _$SummaryReportDataStateImpl _value,
      $Res Function(_$SummaryReportDataStateImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? data = null,
  }) {
    return _then(_$SummaryReportDataStateImpl(
      data: null == data
          ? _value._data
          : data // ignore: cast_nullable_to_non_nullable
              as Map<String, Map<String, int>>,
    ));
  }
}

/// @nodoc

class _$SummaryReportDataStateImpl implements SummaryReportDataState {
  const _$SummaryReportDataStateImpl(
      {final Map<String, Map<String, int>> data = const {}})
      : _data = data;

  final Map<String, Map<String, int>> _data;
  @override
  @JsonKey()
  Map<String, Map<String, int>> get data {
    if (_data is EqualUnmodifiableMapView) return _data;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_data);
  }

  @override
  String toString() {
    return 'SummaryReportState.data(data: $data)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SummaryReportDataStateImpl &&
            const DeepCollectionEquality().equals(other._data, _data));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(_data));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$SummaryReportDataStateImplCopyWith<_$SummaryReportDataStateImpl>
      get copyWith => __$$SummaryReportDataStateImplCopyWithImpl<
          _$SummaryReportDataStateImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() loading,
    required TResult Function() empty,
    required TResult Function(Map<String, Map<String, int>> data) data,
  }) {
    return data(this.data);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? loading,
    TResult? Function()? empty,
    TResult? Function(Map<String, Map<String, int>> data)? data,
  }) {
    return data?.call(this.data);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? loading,
    TResult Function()? empty,
    TResult Function(Map<String, Map<String, int>> data)? data,
    required TResult orElse(),
  }) {
    if (data != null) {
      return data(this.data);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(SummaryReportLoadingState value) loading,
    required TResult Function(SummaryReportEmptyState value) empty,
    required TResult Function(SummaryReportDataState value) data,
  }) {
    return data(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(SummaryReportLoadingState value)? loading,
    TResult? Function(SummaryReportEmptyState value)? empty,
    TResult? Function(SummaryReportDataState value)? data,
  }) {
    return data?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(SummaryReportLoadingState value)? loading,
    TResult Function(SummaryReportEmptyState value)? empty,
    TResult Function(SummaryReportDataState value)? data,
    required TResult orElse(),
  }) {
    if (data != null) {
      return data(this);
    }
    return orElse();
  }
}

abstract class SummaryReportDataState implements SummaryReportState {
  const factory SummaryReportDataState(
          {final Map<String, Map<String, int>> data}) =
      _$SummaryReportDataStateImpl;

  Map<String, Map<String, int>> get data;
  @JsonKey(ignore: true)
  _$$SummaryReportDataStateImplCopyWith<_$SummaryReportDataStateImpl>
      get copyWith => throw _privateConstructorUsedError;
}
