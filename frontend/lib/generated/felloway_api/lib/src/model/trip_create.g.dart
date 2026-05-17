// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trip_create.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$TripCreate extends TripCreate {
  @override
  final String routeLabel;
  @override
  final DateTime departureAt;
  @override
  final String roleType;
  @override
  final String originCityId;

  factory _$TripCreate([void Function(TripCreateBuilder)? updates]) =>
      (TripCreateBuilder()..update(updates))._build();

  _$TripCreate._(
      {required this.routeLabel,
      required this.departureAt,
      required this.roleType,
      required this.originCityId})
      : super._();
  @override
  TripCreate rebuild(void Function(TripCreateBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  TripCreateBuilder toBuilder() => TripCreateBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is TripCreate &&
        routeLabel == other.routeLabel &&
        departureAt == other.departureAt &&
        roleType == other.roleType &&
        originCityId == other.originCityId;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, routeLabel.hashCode);
    _$hash = $jc(_$hash, departureAt.hashCode);
    _$hash = $jc(_$hash, roleType.hashCode);
    _$hash = $jc(_$hash, originCityId.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'TripCreate')
          ..add('routeLabel', routeLabel)
          ..add('departureAt', departureAt)
          ..add('roleType', roleType)
          ..add('originCityId', originCityId))
        .toString();
  }
}

class TripCreateBuilder implements Builder<TripCreate, TripCreateBuilder> {
  _$TripCreate? _$v;

  String? _routeLabel;
  String? get routeLabel => _$this._routeLabel;
  set routeLabel(String? routeLabel) => _$this._routeLabel = routeLabel;

  DateTime? _departureAt;
  DateTime? get departureAt => _$this._departureAt;
  set departureAt(DateTime? departureAt) => _$this._departureAt = departureAt;

  String? _roleType;
  String? get roleType => _$this._roleType;
  set roleType(String? roleType) => _$this._roleType = roleType;

  String? _originCityId;
  String? get originCityId => _$this._originCityId;
  set originCityId(String? originCityId) => _$this._originCityId = originCityId;

  TripCreateBuilder() {
    TripCreate._defaults(this);
  }

  TripCreateBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _routeLabel = $v.routeLabel;
      _departureAt = $v.departureAt;
      _roleType = $v.roleType;
      _originCityId = $v.originCityId;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(TripCreate other) {
    _$v = other as _$TripCreate;
  }

  @override
  void update(void Function(TripCreateBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  TripCreate build() => _build();

  _$TripCreate _build() {
    final _$result = _$v ??
        _$TripCreate._(
          routeLabel: BuiltValueNullFieldError.checkNotNull(
              routeLabel, r'TripCreate', 'routeLabel'),
          departureAt: BuiltValueNullFieldError.checkNotNull(
              departureAt, r'TripCreate', 'departureAt'),
          roleType: BuiltValueNullFieldError.checkNotNull(
              roleType, r'TripCreate', 'roleType'),
          originCityId: BuiltValueNullFieldError.checkNotNull(
              originCityId, r'TripCreate', 'originCityId'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
