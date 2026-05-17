// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trip.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$Trip extends Trip {
  @override
  final String? id;
  @override
  final String? routeLabel;
  @override
  final DateTime? departureAt;
  @override
  final String? roleType;
  @override
  final int? memberCount;

  factory _$Trip([void Function(TripBuilder)? updates]) =>
      (TripBuilder()..update(updates))._build();

  _$Trip._(
      {this.id,
      this.routeLabel,
      this.departureAt,
      this.roleType,
      this.memberCount})
      : super._();
  @override
  Trip rebuild(void Function(TripBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  TripBuilder toBuilder() => TripBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Trip &&
        id == other.id &&
        routeLabel == other.routeLabel &&
        departureAt == other.departureAt &&
        roleType == other.roleType &&
        memberCount == other.memberCount;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, routeLabel.hashCode);
    _$hash = $jc(_$hash, departureAt.hashCode);
    _$hash = $jc(_$hash, roleType.hashCode);
    _$hash = $jc(_$hash, memberCount.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'Trip')
          ..add('id', id)
          ..add('routeLabel', routeLabel)
          ..add('departureAt', departureAt)
          ..add('roleType', roleType)
          ..add('memberCount', memberCount))
        .toString();
  }
}

class TripBuilder implements Builder<Trip, TripBuilder> {
  _$Trip? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _routeLabel;
  String? get routeLabel => _$this._routeLabel;
  set routeLabel(String? routeLabel) => _$this._routeLabel = routeLabel;

  DateTime? _departureAt;
  DateTime? get departureAt => _$this._departureAt;
  set departureAt(DateTime? departureAt) => _$this._departureAt = departureAt;

  String? _roleType;
  String? get roleType => _$this._roleType;
  set roleType(String? roleType) => _$this._roleType = roleType;

  int? _memberCount;
  int? get memberCount => _$this._memberCount;
  set memberCount(int? memberCount) => _$this._memberCount = memberCount;

  TripBuilder() {
    Trip._defaults(this);
  }

  TripBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _routeLabel = $v.routeLabel;
      _departureAt = $v.departureAt;
      _roleType = $v.roleType;
      _memberCount = $v.memberCount;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(Trip other) {
    _$v = other as _$Trip;
  }

  @override
  void update(void Function(TripBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  Trip build() => _build();

  _$Trip _build() {
    final _$result = _$v ??
        _$Trip._(
          id: id,
          routeLabel: routeLabel,
          departureAt: departureAt,
          roleType: roleType,
          memberCount: memberCount,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
