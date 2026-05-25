// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'interest_catalog_item.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$InterestCatalogItem extends InterestCatalogItem {
  @override
  final String id;
  @override
  final String name;
  @override
  final int sortOrder;

  factory _$InterestCatalogItem(
          [void Function(InterestCatalogItemBuilder)? updates]) =>
      (InterestCatalogItemBuilder()..update(updates))._build();

  _$InterestCatalogItem._(
      {required this.id, required this.name, required this.sortOrder})
      : super._();
  @override
  InterestCatalogItem rebuild(
          void Function(InterestCatalogItemBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  InterestCatalogItemBuilder toBuilder() =>
      InterestCatalogItemBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is InterestCatalogItem &&
        id == other.id &&
        name == other.name &&
        sortOrder == other.sortOrder;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, sortOrder.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'InterestCatalogItem')
          ..add('id', id)
          ..add('name', name)
          ..add('sortOrder', sortOrder))
        .toString();
  }
}

class InterestCatalogItemBuilder
    implements Builder<InterestCatalogItem, InterestCatalogItemBuilder> {
  _$InterestCatalogItem? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  int? _sortOrder;
  int? get sortOrder => _$this._sortOrder;
  set sortOrder(int? sortOrder) => _$this._sortOrder = sortOrder;

  InterestCatalogItemBuilder() {
    InterestCatalogItem._defaults(this);
  }

  InterestCatalogItemBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _name = $v.name;
      _sortOrder = $v.sortOrder;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(InterestCatalogItem other) {
    _$v = other as _$InterestCatalogItem;
  }

  @override
  void update(void Function(InterestCatalogItemBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  InterestCatalogItem build() => _build();

  _$InterestCatalogItem _build() {
    final _$result = _$v ??
        _$InterestCatalogItem._(
          id: BuiltValueNullFieldError.checkNotNull(
              id, r'InterestCatalogItem', 'id'),
          name: BuiltValueNullFieldError.checkNotNull(
              name, r'InterestCatalogItem', 'name'),
          sortOrder: BuiltValueNullFieldError.checkNotNull(
              sortOrder, r'InterestCatalogItem', 'sortOrder'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
