enum HealthEventType {
  vitalReadingRecorded,
  medicationTaken,
  medicationMissed,
  appointmentScheduled,
  appointmentCancelled,
  labResultReceived,
  imagingResultReceived,
  emergencyTriggered,
  emergencyResolved,
  profileUpdated,
  pregnancyMilestoneReached,
  donationMatched,
  bloodRequestCreated,
  reportExported,
  custom,
}

class HealthEvent {
  HealthEvent({
    required this.type,
    required this.sourceModule,
    this.profileId,
    Map<String, dynamic>? data,
    DateTime? timestamp,
  })  : data = data ?? const {},
        timestamp = timestamp ?? DateTime.now();

  final HealthEventType type;
  final String sourceModule;
  final String? profileId;
  final Map<String, dynamic> data;
  final DateTime timestamp;
}

typedef HealthEventListener = void Function(HealthEvent event);

class HealthEventManager {
  HealthEventManager._();
  static final HealthEventManager instance = HealthEventManager._();

  final Map<HealthEventType, List<HealthEventListener>> _listeners = {};
  final List<HealthEventListener> _global = [];

  void subscribe(HealthEventType type, HealthEventListener listener) {
    _listeners.putIfAbsent(type, () => []).add(listener);
  }

  void unsubscribe(HealthEventType type, HealthEventListener listener) {
    _listeners[type]?.remove(listener);
  }

  void subscribeAll(HealthEventListener listener) => _global.add(listener);

  void emit(HealthEvent event) {
    for (final listener in List<HealthEventListener>.from(_global)) {
      listener(event);
    }
    for (final listener
        in List<HealthEventListener>.from(_listeners[event.type] ?? const [])) {
      listener(event);
    }
  }

  void emitQuick(
    HealthEventType type, {
    required String sourceModule,
    String? profileId,
    Map<String, dynamic>? data,
  }) {
    emit(HealthEvent(
      type: type,
      sourceModule: sourceModule,
      profileId: profileId,
      data: data,
    ));
  }
}
