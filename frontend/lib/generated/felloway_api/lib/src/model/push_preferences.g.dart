// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'push_preferences.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PushPreferences extends PushPreferences {
  @override
  final bool? globalEnabled;
  @override
  final bool? eventMessages;
  @override
  final bool? tripMessages;
  @override
  final bool? directMessages;

  factory _$PushPreferences([void Function(PushPreferencesBuilder)? updates]) =>
      (PushPreferencesBuilder()..update(updates))._build();

  _$PushPreferences._(
      {this.globalEnabled,
      this.eventMessages,
      this.tripMessages,
      this.directMessages})
      : super._();
  @override
  PushPreferences rebuild(void Function(PushPreferencesBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PushPreferencesBuilder toBuilder() => PushPreferencesBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PushPreferences &&
        globalEnabled == other.globalEnabled &&
        eventMessages == other.eventMessages &&
        tripMessages == other.tripMessages &&
        directMessages == other.directMessages;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, globalEnabled.hashCode);
    _$hash = $jc(_$hash, eventMessages.hashCode);
    _$hash = $jc(_$hash, tripMessages.hashCode);
    _$hash = $jc(_$hash, directMessages.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'PushPreferences')
          ..add('globalEnabled', globalEnabled)
          ..add('eventMessages', eventMessages)
          ..add('tripMessages', tripMessages)
          ..add('directMessages', directMessages))
        .toString();
  }
}

class PushPreferencesBuilder
    implements Builder<PushPreferences, PushPreferencesBuilder> {
  _$PushPreferences? _$v;

  bool? _globalEnabled;
  bool? get globalEnabled => _$this._globalEnabled;
  set globalEnabled(bool? globalEnabled) =>
      _$this._globalEnabled = globalEnabled;

  bool? _eventMessages;
  bool? get eventMessages => _$this._eventMessages;
  set eventMessages(bool? eventMessages) =>
      _$this._eventMessages = eventMessages;

  bool? _tripMessages;
  bool? get tripMessages => _$this._tripMessages;
  set tripMessages(bool? tripMessages) => _$this._tripMessages = tripMessages;

  bool? _directMessages;
  bool? get directMessages => _$this._directMessages;
  set directMessages(bool? directMessages) =>
      _$this._directMessages = directMessages;

  PushPreferencesBuilder() {
    PushPreferences._defaults(this);
  }

  PushPreferencesBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _globalEnabled = $v.globalEnabled;
      _eventMessages = $v.eventMessages;
      _tripMessages = $v.tripMessages;
      _directMessages = $v.directMessages;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PushPreferences other) {
    _$v = other as _$PushPreferences;
  }

  @override
  void update(void Function(PushPreferencesBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PushPreferences build() => _build();

  _$PushPreferences _build() {
    final _$result = _$v ??
        _$PushPreferences._(
          globalEnabled: globalEnabled,
          eventMessages: eventMessages,
          tripMessages: tripMessages,
          directMessages: directMessages,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
