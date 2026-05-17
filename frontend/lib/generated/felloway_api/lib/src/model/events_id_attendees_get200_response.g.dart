// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'events_id_attendees_get200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$EventsIdAttendeesGet200Response
    extends EventsIdAttendeesGet200Response {
  @override
  final BuiltList<Attendee>? items;

  factory _$EventsIdAttendeesGet200Response(
          [void Function(EventsIdAttendeesGet200ResponseBuilder)? updates]) =>
      (EventsIdAttendeesGet200ResponseBuilder()..update(updates))._build();

  _$EventsIdAttendeesGet200Response._({this.items}) : super._();
  @override
  EventsIdAttendeesGet200Response rebuild(
          void Function(EventsIdAttendeesGet200ResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  EventsIdAttendeesGet200ResponseBuilder toBuilder() =>
      EventsIdAttendeesGet200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is EventsIdAttendeesGet200Response && items == other.items;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, items.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'EventsIdAttendeesGet200Response')
          ..add('items', items))
        .toString();
  }
}

class EventsIdAttendeesGet200ResponseBuilder
    implements
        Builder<EventsIdAttendeesGet200Response,
            EventsIdAttendeesGet200ResponseBuilder> {
  _$EventsIdAttendeesGet200Response? _$v;

  ListBuilder<Attendee>? _items;
  ListBuilder<Attendee> get items => _$this._items ??= ListBuilder<Attendee>();
  set items(ListBuilder<Attendee>? items) => _$this._items = items;

  EventsIdAttendeesGet200ResponseBuilder() {
    EventsIdAttendeesGet200Response._defaults(this);
  }

  EventsIdAttendeesGet200ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _items = $v.items?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(EventsIdAttendeesGet200Response other) {
    _$v = other as _$EventsIdAttendeesGet200Response;
  }

  @override
  void update(void Function(EventsIdAttendeesGet200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  EventsIdAttendeesGet200Response build() => _build();

  _$EventsIdAttendeesGet200Response _build() {
    _$EventsIdAttendeesGet200Response _$result;
    try {
      _$result = _$v ??
          _$EventsIdAttendeesGet200Response._(
            items: _items?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'items';
        _items?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'EventsIdAttendeesGet200Response', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
