// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'interests_get200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$InterestsGet200Response extends InterestsGet200Response {
  @override
  final BuiltList<InterestCatalogItem> items;

  factory _$InterestsGet200Response(
          [void Function(InterestsGet200ResponseBuilder)? updates]) =>
      (InterestsGet200ResponseBuilder()..update(updates))._build();

  _$InterestsGet200Response._({required this.items}) : super._();
  @override
  InterestsGet200Response rebuild(
          void Function(InterestsGet200ResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  InterestsGet200ResponseBuilder toBuilder() =>
      InterestsGet200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is InterestsGet200Response && items == other.items;
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
    return (newBuiltValueToStringHelper(r'InterestsGet200Response')
          ..add('items', items))
        .toString();
  }
}

class InterestsGet200ResponseBuilder
    implements
        Builder<InterestsGet200Response, InterestsGet200ResponseBuilder> {
  _$InterestsGet200Response? _$v;

  ListBuilder<InterestCatalogItem>? _items;
  ListBuilder<InterestCatalogItem> get items =>
      _$this._items ??= ListBuilder<InterestCatalogItem>();
  set items(ListBuilder<InterestCatalogItem>? items) => _$this._items = items;

  InterestsGet200ResponseBuilder() {
    InterestsGet200Response._defaults(this);
  }

  InterestsGet200ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _items = $v.items.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(InterestsGet200Response other) {
    _$v = other as _$InterestsGet200Response;
  }

  @override
  void update(void Function(InterestsGet200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  InterestsGet200Response build() => _build();

  _$InterestsGet200Response _build() {
    _$InterestsGet200Response _$result;
    try {
      _$result = _$v ??
          _$InterestsGet200Response._(
            items: items.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'items';
        items.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'InterestsGet200Response', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
