import 'dart:io';

/// Defines the available log levels.
class LogLevel {
  const LogLevel._(this._level, this.name);

  final int _level;

  /// String name for the log level.
  final String name;

  /// LogLevel for messages instended for debugging.
  static const LogLevel debug = LogLevel._(0, 'DEBUG');

  /// LogLevel for messages instended to provide information about the exection.
  static const LogLevel info = LogLevel._(1, 'INFO');

  /// LogLevel for messages instended to flag potential problems.
  static const LogLevel warning = LogLevel._(2, 'WARN');

  /// LogLevel for errors in the execution.
  static const LogLevel error = LogLevel._(3, 'ERROR');
}

/// Abstract class for loggers.
abstract class Logger {
  /// Processes a debug message.
  void debug(Object message);

  /// Processes an info message.
  void info(Object message);

  /// Processes a warning message.
  void warning(Object message);

  /// Processes an error message.
  void error(Object message);
}

/// Logger to print message to standard output.
class PrintLogger implements Logger {
  /// Creates a logger instance to print messages to standard output.
  PrintLogger({
    IOSink out,
    this.level = LogLevel.info,
  }) : out = out ?? stdout;

  /// The [IOSink] to print to.
  final IOSink out;

  /// Available log levels.
  final LogLevel level;

  @override
  void debug(Object message) => _log(LogLevel.debug, message);

  @override
  void info(Object message) => _log(LogLevel.info, message);

  @override
  void warning(Object message) => _log(LogLevel.warning, message);

  @override
  void error(Object message) => _log(LogLevel.error, message);

  void _log(LogLevel level, Object message) {
    if (level._level >= this.level._level)
      out.writeln(toLogString('$message', level: level));
  }
}

/// Transforms a [message] with [level] to a string that contains the DateTime,
/// level and message.
String toLogString(String message, {LogLevel level}) {
  final StringBuffer buffer = StringBuffer();
  buffer.write(DateTime.now().toIso8601String());
  buffer.write(': ');
  if (level != null) {
    buffer.write(level.name);
    buffer.write(' ');
  }
  buffer.write(message);
  return buffer.toString();
}
