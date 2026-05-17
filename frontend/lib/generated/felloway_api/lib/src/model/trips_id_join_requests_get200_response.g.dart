// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trips_id_join_requests_get200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$TripsIdJoinRequestsGet200Response
    extends TripsIdJoinRequestsGet200Response {
  @override
  final BuiltList<TripJoinRequest>? items;

  factory _$TripsIdJoinRequestsGet200Response(
          [void Function(TripsIdJoinRequestsGet200ResponseBuilder)? updates]) =>
      (TripsIdJoinRequestsGet200ResponseBuilder()..update(updates))._build();

  _$TripsIdJoinRequestsGet200Response._({this.items}) : super._();
  @override
  TripsIdJoinRequestsGet200Response rebuild(
          void Function(TripsIdJoinRequestsGet200ResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  TripsIdJoinRequestsGet200ResponseBuilder toBuilder() =>
      TripsIdJoinRequestsGet200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is TripsIdJoinRequestsGet200Response && items == other.items;
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
    return (newBuiltValueToStringHelper(r'TripsIdJoinRequestsGet200Response')
          ..add('items', items))
        .toString();
  }
}

class TripsIdJoinRequestsGet200ResponseBuilder
    implements
        Builder<TripsIdJoinRequestsGet200Response,
            TripsIdJoinRequestsGet200ResponseBuilder> {
  _$TripsIdJoinRequestsGet200Response? _$v;

  ListBuilder<TripJoinRequest>? _items;
  ListBuilder<TripJoinRequest> get items =>
      _$this._items ??= ListBuilder<TripJoinRequest>();
  set items(ListBuilder<TripJoinRequest>? items) => _$this._items = items;

  TripsIdJoinRequestsGet200ResponseBuilder() {
    TripsIdJoinRequestsGet200Response._defaults(this);
  }

  TripsIdJoinRequestsGet200ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _items = $v.items?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(TripsIdJoinRequestsGet200Response other) {
    _$v = other as _$TripsIdJoinRequestsGet200Response;
  }

  @override
  void update(
      void Function(TripsIdJoinRequestsGet200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  TripsIdJoinRequestsGet200Response build() => _build();

  _$TripsIdJoinRequestsGet200Response _build() {
    _$TripsIdJoinRequestsGet200Response _$result;
    try {
      _$result = _$v ??
          _$TripsIdJoinRequestsGet200Response._(
            items: _items?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'items';
        _items?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'TripsIdJoinRequestsGet200Response', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
