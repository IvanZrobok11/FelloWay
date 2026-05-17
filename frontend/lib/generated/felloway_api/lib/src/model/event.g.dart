// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$Event extends Event {
  @override
  final String? id;
  @override
  final String? title;
  @override
  final DateTime? startsAt;
  @override
  final DateTime? endsAt;
  @override
  final String? city;
  @override
  final String? coverImageUrl;
  @override
  final int? attendeeCount;
  @override
  final bool? isJoined;

  factory _$Event([void Function(EventBuilder)? updates]) =>
      (EventBuilder()..update(updates))._build();

  _$Event._(
      {this.id,
      this.title,
      this.startsAt,
      this.endsAt,
      this.city,
      this.coverImageUrl,
      this.attendeeCount,
      this.isJoined})
      : super._();
  @override
  Event rebuild(void Function(EventBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  EventBuilder toBuilder() => EventBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Event &&
        id == other.id &&
        title == other.title &&
        startsAt == other.startsAt &&
        endsAt == other.endsAt &&
        city == other.city &&
        coverImageUrl == other.coverImageUrl &&
        attendeeCount == other.attendeeCount &&
        isJoined == other.isJoined;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, title.hashCode);
    _$hash = $jc(_$hash, startsAt.hashCode);
    _$hash = $jc(_$hash, endsAt.hashCode);
    _$hash = $jc(_$hash, city.hashCode);
    _$hash = $jc(_$hash, coverImageUrl.hashCode);
    _$hash = $jc(_$hash, attendeeCount.hashCode);
    _$hash = $jc(_$hash, isJoined.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'Event')
          ..add('id', id)
          ..add('title', title)
          ..add('startsAt', startsAt)
          ..add('endsAt', endsAt)
          ..add('city', city)
          ..add('coverImageUrl', coverImageUrl)
          ..add('attendeeCount', attendeeCount)
          ..add('isJoined', isJoined))
        .toString();
  }
}

class EventBuilder implements Builder<Event, EventBuilder> {
  _$Event? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _title;
  String? get title => _$this._title;
  set title(String? title) => _$this._title = title;

  DateTime? _startsAt;
  DateTime? get startsAt => _$this._startsAt;
  set startsAt(DateTime? startsAt) => _$this._startsAt = startsAt;

  DateTime? _endsAt;
  DateTime? get endsAt => _$this._endsAt;
  set endsAt(DateTime? endsAt) => _$this._endsAt = endsAt;

  String? _city;
  String? get city => _$this._city;
  set city(String? city) => _$this._city = city;

  String? _coverImageUrl;
  String? get coverImageUrl => _$this._coverImageUrl;
  set coverImageUrl(String? coverImageUrl) =>
      _$this._coverImageUrl = coverImageUrl;

  int? _attendeeCount;
  int? get attendeeCount => _$this._attendeeCount;
  set attendeeCount(int? attendeeCount) =>
      _$this._attendeeCount = attendeeCount;

  bool? _isJoined;
  bool? get isJoined => _$this._isJoined;
  set isJoined(bool? isJoined) => _$this._isJoined = isJoined;

  EventBuilder() {
    Event._defaults(this);
  }

  EventBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _title = $v.title;
      _startsAt = $v.startsAt;
      _endsAt = $v.endsAt;
      _city = $v.city;
      _coverImageUrl = $v.coverImageUrl;
      _attendeeCount = $v.attendeeCount;
      _isJoined = $v.isJoined;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(Event other) {
    _$v = other as _$Event;
  }

  @override
  void update(void Function(EventBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  Event build() => _build();

  _$Event _build() {
    final _$result = _$v ??
        _$Event._(
          id: id,
          title: title,
          startsAt: startsAt,
          endsAt: endsAt,
          city: city,
          coverImageUrl: coverImageUrl,
          attendeeCount: attendeeCount,
          isJoined: isJoined,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
