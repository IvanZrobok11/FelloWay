// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'users_id_reviews_get200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$UsersIdReviewsGet200Response extends UsersIdReviewsGet200Response {
  @override
  final BuiltList<Review>? items;

  factory _$UsersIdReviewsGet200Response(
          [void Function(UsersIdReviewsGet200ResponseBuilder)? updates]) =>
      (UsersIdReviewsGet200ResponseBuilder()..update(updates))._build();

  _$UsersIdReviewsGet200Response._({this.items}) : super._();
  @override
  UsersIdReviewsGet200Response rebuild(
          void Function(UsersIdReviewsGet200ResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  UsersIdReviewsGet200ResponseBuilder toBuilder() =>
      UsersIdReviewsGet200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is UsersIdReviewsGet200Response && items == other.items;
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
    return (newBuiltValueToStringHelper(r'UsersIdReviewsGet200Response')
          ..add('items', items))
        .toString();
  }
}

class UsersIdReviewsGet200ResponseBuilder
    implements
        Builder<UsersIdReviewsGet200Response,
            UsersIdReviewsGet200ResponseBuilder> {
  _$UsersIdReviewsGet200Response? _$v;

  ListBuilder<Review>? _items;
  ListBuilder<Review> get items => _$this._items ??= ListBuilder<Review>();
  set items(ListBuilder<Review>? items) => _$this._items = items;

  UsersIdReviewsGet200ResponseBuilder() {
    UsersIdReviewsGet200Response._defaults(this);
  }

  UsersIdReviewsGet200ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _items = $v.items?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(UsersIdReviewsGet200Response other) {
    _$v = other as _$UsersIdReviewsGet200Response;
  }

  @override
  void update(void Function(UsersIdReviewsGet200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  UsersIdReviewsGet200Response build() => _build();

  _$UsersIdReviewsGet200Response _build() {
    _$UsersIdReviewsGet200Response _$result;
    try {
      _$result = _$v ??
          _$UsersIdReviewsGet200Response._(
            items: _items?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'items';
        _items?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'UsersIdReviewsGet200Response', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
