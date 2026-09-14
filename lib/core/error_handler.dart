enum ErrorSeverity { info, warning, error, critical }

class AppError {
  AppError({
    required this.code,
    required this.message,
    required this.severity,
    required this.sourceModule,
    this.originalException,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  final String code;
  final String message;
  final ErrorSeverity severity;
  final String sourceModule;
  final Object? originalException;
  final DateTime timestamp;
}

typedef ErrorListener = void Function(AppError error);

class ErrorHandler {
  ErrorHandler._();
  static final ErrorHandler instance = ErrorHandler._();

  final List<AppError> _log = [];
  final List<ErrorListener> _listeners = [];

  List<AppError> get errorLog => List.unmodifiable(_log);

  void addListener(ErrorListener listener) => _listeners.add(listener);

  void report(
    String code,
    String message, {
    required String sourceModule,
    ErrorSeverity severity = ErrorSeverity.error,
    Object? exception,
  }) {
    final error = AppError(
      code: code,
      message: message,
      severity: severity,
      sourceModule: sourceModule,
      originalException: exception,
    );
    _log.add(error);
    for (final listener in List<ErrorListener>.from(_listeners)) {
      listener(error);
    }
  }
}
