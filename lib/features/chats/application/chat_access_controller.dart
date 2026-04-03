import 'package:flutter/foundation.dart';

/// Tracks which events the current user is attending (from event detail loads
/// and join/leave actions). Used to lock DM/event composers after leave.
class ChatAccessController extends ChangeNotifier {
  final Set<String> _attendingEventIds = {};

  Set<String> get attendingEventIds => Set.unmodifiable(_attendingEventIds);

  bool isAttending(String eventId) => _attendingEventIds.contains(eventId);

  void setEventAttendance(String eventId, bool attending) {
    if (attending) {
      if (_attendingEventIds.add(eventId)) notifyListeners();
    } else {
      if (_attendingEventIds.remove(eventId)) notifyListeners();
    }
  }

  void clear() {
    if (_attendingEventIds.isEmpty) return;
    _attendingEventIds.clear();
    notifyListeners();
  }
}
