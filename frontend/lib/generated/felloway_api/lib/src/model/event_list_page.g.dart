// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event_list_page.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$EventListPage extends EventListPage {
  @override
  final BuiltList<Event>? items;
  @override
  final String? nextCursor;

  factory _$EventListPage([void Function(EventListPageBuilder)? updates]) =>
      (EventListPageBuilder()..update(updates))._build();

  _$EventListPage._({this.items, this.nextCursor}) : super._();
  @override
  EventListPage rebuild(void Function(EventListPageBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  EventListPageBuilder toBuilder() => EventListPageBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is EventListPage &&
        items == other.items &&
        nextCursor == other.nextCursor;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, items.hashCode);
    _$hash = $jc(_$hash, nextCursor.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'EventListPage')
          ..add('items', items)
          ..add('nextCursor', nextCursor))
        .toString();
  }
}

class EventListPageBuilder
    implements Builder<EventListPage, EventListPageBuilder> {
  _$EventListPage? _$v;

  ListBuilder<Event>? _items;
  ListBuilder<Event> get items => _$this._items ??= ListBuilder<Event>();
  set items(ListBuilder<Event>? items) => _$this._items = items;

  String? _nextCursor;
  String? get nextCursor => _$this._nextCursor;
  set nextCursor(String? nextCursor) => _$this._nextCursor = nextCursor;

  EventListPageBuilder() {
    EventListPage._defaults(this);
  }

  EventListPageBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _items = $v.items?.toBuilder();
      _nextCursor = $v.nextCursor;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(EventListPage other) {
    _$v = other as _$EventListPage;
  }

  @override
  void update(void Function(EventListPageBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  EventListPage build() => _build();

  _$EventListPage _build() {
    _$EventListPage _$result;
    try {
      _$result = _$v ??
          _$EventListPage._(
            items: _items?.build(),
            nextCursor: nextCursor,
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'items';
        _items?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'EventListPage', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
