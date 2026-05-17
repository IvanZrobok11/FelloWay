/// Pure rules for chat access (FR-009–FR-012). Server remains authoritative;
/// the client uses this for composer visibility and navigation guards.
class ChatAccessPolicy {
  const ChatAccessPolicy._();

  /// Event-wide or trip channel UI is available only while the user retains
  /// the corresponding membership on the client-known set.
  static bool canAccessScopedChannel({required bool hasMembership}) =>
      hasMembership;

  /// After the user leaves an event, DMs tied to that event are read-only
  /// (FR-011): history stays visible but sending is disabled.
  static bool isEventScopedDmComposerEnabled({
    required bool currentUserAttendsEvent,
  }) => currentUserAttendsEvent;
}
