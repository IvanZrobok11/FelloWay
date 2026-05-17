// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attendee.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$Attendee extends Attendee {
  @override
  final String? id;
  @override
  final String? displayName;
  @override
  final String? homeCity;

  factory _$Attendee([void Function(AttendeeBuilder)? updates]) =>
      (AttendeeBuilder()..update(updates))._build();

  _$Attendee._({this.id, this.displayName, this.homeCity}) : super._();
  @override
  Attendee rebuild(void Function(AttendeeBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  AttendeeBuilder toBuilder() => AttendeeBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Attendee &&
        id == other.id &&
        displayName == other.displayName &&
        homeCity == other.homeCity;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, displayName.hashCode);
    _$hash = $jc(_$hash, homeCity.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'Attendee')
          ..add('id', id)
          ..add('displayName', displayName)
          ..add('homeCity', homeCity))
        .toString();
  }
}

class AttendeeBuilder implements Builder<Attendee, AttendeeBuilder> {
  _$Attendee? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _displayName;
  String? get displayName => _$this._displayName;
  set displayName(String? displayName) => _$this._displayName = displayName;

  String? _homeCity;
  String? get homeCity => _$this._homeCity;
  set homeCity(String? homeCity) => _$this._homeCity = homeCity;

  AttendeeBuilder() {
    Attendee._defaults(this);
  }

  AttendeeBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _displayName = $v.displayName;
      _homeCity = $v.homeCity;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(Attendee other) {
    _$v = other as _$Attendee;
  }

  @override
  void update(void Function(AttendeeBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  Attendee build() => _build();

  _$Attendee _build() {
    final _$result = _$v ??
        _$Attendee._(
          id: id,
          displayName: displayName,
          homeCity: homeCity,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
