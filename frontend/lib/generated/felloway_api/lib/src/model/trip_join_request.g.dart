// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trip_join_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const TripJoinRequestStatusEnum _$tripJoinRequestStatusEnum_pending =
    const TripJoinRequestStatusEnum._('pending');
const TripJoinRequestStatusEnum _$tripJoinRequestStatusEnum_approved =
    const TripJoinRequestStatusEnum._('approved');
const TripJoinRequestStatusEnum _$tripJoinRequestStatusEnum_rejected =
    const TripJoinRequestStatusEnum._('rejected');
const TripJoinRequestStatusEnum _$tripJoinRequestStatusEnum_cancelled =
    const TripJoinRequestStatusEnum._('cancelled');

TripJoinRequestStatusEnum _$tripJoinRequestStatusEnumValueOf(String name) {
  switch (name) {
    case 'pending':
      return _$tripJoinRequestStatusEnum_pending;
    case 'approved':
      return _$tripJoinRequestStatusEnum_approved;
    case 'rejected':
      return _$tripJoinRequestStatusEnum_rejected;
    case 'cancelled':
      return _$tripJoinRequestStatusEnum_cancelled;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<TripJoinRequestStatusEnum> _$tripJoinRequestStatusEnumValues =
    BuiltSet<TripJoinRequestStatusEnum>(const <TripJoinRequestStatusEnum>[
  _$tripJoinRequestStatusEnum_pending,
  _$tripJoinRequestStatusEnum_approved,
  _$tripJoinRequestStatusEnum_rejected,
  _$tripJoinRequestStatusEnum_cancelled,
]);

Serializer<TripJoinRequestStatusEnum> _$tripJoinRequestStatusEnumSerializer =
    _$TripJoinRequestStatusEnumSerializer();

class _$TripJoinRequestStatusEnumSerializer
    implements PrimitiveSerializer<TripJoinRequestStatusEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'pending': 'pending',
    'approved': 'approved',
    'rejected': 'rejected',
    'cancelled': 'cancelled',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'pending': 'pending',
    'approved': 'approved',
    'rejected': 'rejected',
    'cancelled': 'cancelled',
  };

  @override
  final Iterable<Type> types = const <Type>[TripJoinRequestStatusEnum];
  @override
  final String wireName = 'TripJoinRequestStatusEnum';

  @override
  Object serialize(Serializers serializers, TripJoinRequestStatusEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  TripJoinRequestStatusEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      TripJoinRequestStatusEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$TripJoinRequest extends TripJoinRequest {
  @override
  final String? id;
  @override
  final String? requesterId;
  @override
  final TripJoinRequestStatusEnum? status;

  factory _$TripJoinRequest([void Function(TripJoinRequestBuilder)? updates]) =>
      (TripJoinRequestBuilder()..update(updates))._build();

  _$TripJoinRequest._({this.id, this.requesterId, this.status}) : super._();
  @override
  TripJoinRequest rebuild(void Function(TripJoinRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  TripJoinRequestBuilder toBuilder() => TripJoinRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is TripJoinRequest &&
        id == other.id &&
        requesterId == other.requesterId &&
        status == other.status;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, requesterId.hashCode);
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'TripJoinRequest')
          ..add('id', id)
          ..add('requesterId', requesterId)
          ..add('status', status))
        .toString();
  }
}

class TripJoinRequestBuilder
    implements Builder<TripJoinRequest, TripJoinRequestBuilder> {
  _$TripJoinRequest? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _requesterId;
  String? get requesterId => _$this._requesterId;
  set requesterId(String? requesterId) => _$this._requesterId = requesterId;

  TripJoinRequestStatusEnum? _status;
  TripJoinRequestStatusEnum? get status => _$this._status;
  set status(TripJoinRequestStatusEnum? status) => _$this._status = status;

  TripJoinRequestBuilder() {
    TripJoinRequest._defaults(this);
  }

  TripJoinRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _requesterId = $v.requesterId;
      _status = $v.status;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(TripJoinRequest other) {
    _$v = other as _$TripJoinRequest;
  }

  @override
  void update(void Function(TripJoinRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  TripJoinRequest build() => _build();

  _$TripJoinRequest _build() {
    final _$result = _$v ??
        _$TripJoinRequest._(
          id: id,
          requesterId: requesterId,
          status: status,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
