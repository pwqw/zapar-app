import 'package:flutter/foundation.dart';
import 'package:get_storage/get_storage.dart';

class LogEntry {
  LogEntry({
    required this.timestamp,
    required this.screen,
    required this.message,
    this.stackTrace,
    this.extras = const {},
  });

  final DateTime timestamp;
  final String screen;
  final String message;
  final String? stackTrace;
  final Map<String, dynamic> extras;

  Map<String, dynamic> toJson() => {
        'timestamp': timestamp.toIso8601String(),
        'screen': screen,
        'message': message,
        'stackTrace': stackTrace,
        'extras': extras,
      };

  factory LogEntry.fromJson(Map<String, dynamic> json) {
    return LogEntry(
      timestamp: DateTime.parse(json['timestamp'] as String),
      screen: json['screen'] as String? ?? 'unknown',
      message: json['message'] as String? ?? '',
      stackTrace: json['stackTrace'] as String?,
      extras: Map<String, dynamic>.from(json['extras'] as Map? ?? {}),
    );
  }
}

class LogService extends ChangeNotifier {
  LogService._();

  static final instance = LogService._();

  /// Initialize with `GetStorage.init(storageBoxName)` before [loadFromStorage].
  static const storageBoxName = 'AppLogs';
  static const _storageKey = 'app_logs';

  final _entries = <LogEntry>[];
  String _currentScreen = 'unknown';

  List<LogEntry> get entries => List.unmodifiable(_entries);

  void setCurrentScreen(String screen) => _currentScreen = screen;

  void record(Object error, StackTrace? stack, {Map<String, dynamic>? extras}) {
    _entries.insert(
      0,
      LogEntry(
        timestamp: DateTime.now(),
        screen: _currentScreen,
        message: error.toString(),
        stackTrace: stack?.toString(),
        extras: extras ?? {},
      ),
    );
    if (_entries.length > 200) {
      _entries.removeLast();
    }
    _persist();
    notifyListeners();
  }

  void _persist() {
    GetStorage(storageBoxName).write(
      _storageKey,
      _entries.map((e) => e.toJson()).toList(),
    );
  }

  void loadFromStorage() {
    final raw = GetStorage(storageBoxName).read(_storageKey);
    if (raw is List) {
      _entries
        ..clear()
        ..addAll(
          raw.map((e) => LogEntry.fromJson(Map<String, dynamic>.from(e as Map))),
        );
    }
    notifyListeners();
  }

  void clear() {
    _entries.clear();
    _persist();
    notifyListeners();
  }
}
