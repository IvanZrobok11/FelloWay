// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'events_id_trips_get200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$EventsIdTripsGet200Response extends EventsIdTripsGet200Response {
  @override
  final BuiltList<Trip>? items;

  factory _$EventsIdTripsGet200Response(
          [void Function(EventsIdTripsGet200ResponseBuilder)? updates]) =>
      (EventsIdTripsGet200ResponseBuilder()..update(updates))._build();

  _$EventsIdTripsGet200Response._({this.items}) : super._();
  @override
  EventsIdTripsGet200Response rebuild(
          void Function(EventsIdTripsGet200ResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  EventsIdTripsGet200ResponseBuilder toBuilder() =>
      EventsIdTripsGet200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is EventsIdTripsGet200Response && items == other.items;
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
    return (newBuiltValueToStringHelper(r'EventsIdTripsGet200Response')
          ..add('items', items))
        .toString();
  }
}

class EventsIdTripsGet200ResponseBuilder
    implements
        Builder<EventsIdTripsGet200Response,
            EventsIdTripsGet200ResponseBuilder> {
  _$EventsIdTripsGet200Response? _$v;

  ListBuilder<Trip>? _items;
  ListBuilder<Trip> get items => _$this._items ??= ListBuilder<Trip>();
  set items(ListBuilder<Trip>? items) => _$this._items = items;

  EventsIdTripsGet200ResponseBuilder() {
    EventsIdTripsGet200Response._defaults(this);
  }

  EventsIdTripsGet200ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _items = $v.items?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(EventsIdTripsGet200Response other) {
    _$v = other as _$EventsIdTripsGet200Response;
  }

  @override
  void update(void Function(EventsIdTripsGet200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  EventsIdTripsGet200Response build() => _build();

  _$EventsIdTripsGet200Response _build() {
    _$EventsIdTripsGet200Response _$result;
    try {
      _$result = _$v ??
          _$EventsIdTripsGet200Response._(
            items: _items?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'items';
        _items?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'EventsIdTripsGet200Response', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
