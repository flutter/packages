import 'dart:io';

/// Defines the available log levels.
class LogLevel {
  const LogLevel._(this._level, this.name);

  final int _level;

  /// String name for the log level.
  final String name;

  /// LogLevel for messages instended for debugging.
  static const LogLevel debug = LogLevel._(0, 'DEBUG');

  /// LogLevel for messages instended to provide information about the
  /// execution.
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
    bool prependLogData,
    this.level = LogLevel.info,
  })  : out = out ?? stdout,
        prependLogData = prependLogData ?? true;

  /// The [IOSink] to print to.
  final IOSink out;

  /// Available log levels.
  final LogLevel level;

  /// Wether to prepend datetime and log level or not.
  final bool prependLogData;

  /// Stdout buffer.
  final StringBuffer stdoutBuffer = StringBuffer();

  /// Stderr buffer.
  final StringBuffer stderrBuffer = StringBuffer();

  /// Returns all the content logged as info, debug and warning without the
  /// datetime and log level prepended to lines.
  String outputLog() {
    return stdoutBuffer.toString();
  }

  /// Returns all the content logged error without the
  /// datetime and log level prepended to lines.
  String errorLog() {
    return stderrBuffer.toString();
  }

  @override
  void debug(Object message) {
    _log(LogLevel.debug, message);
    stdoutBuffer.writeln(message);
  }

  @override
  void info(Object message) {
    _log(LogLevel.info, message);
    stdoutBuffer.writeln(message);
  }

  @override
  void warning(Object message) {
    _log(LogLevel.warning, message);
    stdoutBuffer.writeln(message);
  }

  @override
  void error(Object message) {
    _log(LogLevel.error, message);
    stderrBuffer.writeln(message);
  }

  void _log(LogLevel level, Object message) {
    if (prependLogData) {
      if (level._level >= this.level._level) {
        out.writeln(toLogString('$message', level: level));
      }
    } else {
      out.writeln('$message');
    }
  }
}

/// Transforms a [message] with [level] to a string that contains the DateTime,
/// level and message.
String toLogString(String message, {LogLevel level}) {
  final StringBuffer buffer = StringBuffer();
  buffer.write(DateTime.now().toUtc().toIso8601String());
  buffer.write(': ');
  if (level != null) {
    buffer.write(level.name);
    buffer.write(' ');
  }
  buffer.write(message);
  return buffer.toString();
}
