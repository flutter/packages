// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'dart:math';

import 'package:intl/intl.dart';
import 'package:meta/meta.dart';

import 'common.dart';
import 'io.dart';
import 'terminal.dart' show OutputPreferences, Terminal, TerminalColor;

const int kDefaultStatusPadding = 59;
final NumberFormat kSecondsFormat = NumberFormat('0.0');
final NumberFormat kMillisecondsFormat = NumberFormat.decimalPattern();

/// Smallest column that will be used for text wrapping. If the requested column
/// width is smaller than this, then this is what will be used.
const int kMinColumnWidth = 10;

/// A factory for generating [Stopwatch] instances for [Status] instances.
class StopwatchFactory {
  /// const constructor so that subclasses may be const.
  const StopwatchFactory();

  /// Create a new [Stopwatch] instance.
  ///
  /// The optional [name] parameter is useful in tests when there are multiple
  /// instances being created.
  Stopwatch createStopwatch([String name = '']) => Stopwatch();
}

typedef VoidCallback = void Function();

abstract class Logger {
  /// Whether or not this logger should print [printTrace] messages.
  bool get isVerbose => false;

  /// If true, silences the logger output.
  bool quiet = false;

  /// If true, this logger supports color output.
  bool get supportsColor;

  /// If true, this logger is connected to a terminal.
  bool get hasTerminal;

  /// If true, then [printError] has been called at least once for this logger
  /// since the last time it was set to false.
  bool hadErrorOutput = false;

  /// If true, then [printWarning] has been called at least once for this logger
  /// since the last time it was reset to false.
  bool hadWarningOutput = false;

  /// Causes [checkForFatalLogs] to call [throwToolExit] when it is called if
  /// [hadWarningOutput] is true.
  bool fatalWarnings = false;

  /// Returns the terminal attached to this logger.
  Terminal get terminal;

  /// Display an error `message` to the user. Commands should use this if they
  /// fail in some way. Errors are typically followed shortly by a call to
  /// [throwToolExit] to terminate the run.
  ///
  /// The `message` argument is printed to the stderr in [TerminalColor.red] by
  /// default.
  ///
  /// The `stackTrace` argument is the stack trace that will be printed if
  /// supplied.
  ///
  /// The `emphasis` argument will cause the output message be printed in bold text.
  ///
  /// The `color` argument will print the message in the supplied color instead
  /// of the default of red. Colors will not be printed if the output terminal
  /// doesn't support them.
  ///
  /// The `indent` argument specifies the number of spaces to indent the overall
  /// message. If wrapping is enabled in [outputPreferences], then the wrapped
  /// lines will be indented as well.
  ///
  /// If `hangingIndent` is specified, then any wrapped lines will be indented
  /// by this much more than the first line, if wrapping is enabled in
  /// [outputPreferences].
  ///
  /// If `wrap` is specified, then it overrides the
  /// `outputPreferences.wrapText` setting.
  void printError(
    String message, {
    StackTrace? stackTrace,
    bool? emphasis,
    TerminalColor? color,
    int? indent,
    int? hangingIndent,
    bool? wrap,
  });

  /// Display a warning `message` to the user. Commands should use this if they
  /// important information to convey to the user that is not fatal.
  ///
  /// The `message` argument is printed to the stderr in [TerminalColor.cyan] by
  /// default.
  ///
  /// The `emphasis` argument will cause the output message be printed in bold text.
  ///
  /// The `color` argument will print the message in the supplied color instead
  /// of the default of cyan. Colors will not be printed if the output terminal
  /// doesn't support them.
  ///
  /// The `indent` argument specifies the number of spaces to indent the overall
  /// message. If wrapping is enabled in [outputPreferences], then the wrapped
  /// lines will be indented as well.
  ///
  /// If `hangingIndent` is specified, then any wrapped lines will be indented
  /// by this much more than the first line, if wrapping is enabled in
  /// [outputPreferences].
  ///
  /// If `wrap` is specified, then it overrides the
  /// `outputPreferences.wrapText` setting.
  void printWarning(
    String message, {
    bool? emphasis,
    TerminalColor? color,
    int? indent,
    int? hangingIndent,
    bool? wrap,
  });

  /// Display normal output of the command. This should be used for things like
  /// progress messages, success messages, or just normal command output.
  ///
  /// The `message` argument is printed to the stdout.
  ///
  /// The `stackTrace` argument is the stack trace that will be printed if
  /// supplied.
  ///
  /// If the `emphasis` argument is true, it will cause the output message be
  /// printed in bold text. Defaults to false.
  ///
  /// The `color` argument will print the message in the supplied color instead
  /// of the default of red. Colors will not be printed if the output terminal
  /// doesn't support them.
  ///
  /// If `newline` is true, then a newline will be added after printing the
  /// status. Defaults to true.
  ///
  /// The `indent` argument specifies the number of spaces to indent the overall
  /// message. If wrapping is enabled in [outputPreferences], then the wrapped
  /// lines will be indented as well.
  ///
  /// If `hangingIndent` is specified, then any wrapped lines will be indented
  /// by this much more than the first line, if wrapping is enabled in
  /// [outputPreferences].
  ///
  /// If `wrap` is specified, then it overrides the
  /// `outputPreferences.wrapText` setting.
  void printStatus(
    String message, {
    bool? emphasis,
    TerminalColor? color,
    bool? newline,
    int? indent,
    int? hangingIndent,
    bool? wrap,
  });

  /// Display the [message] inside a box.
  ///
  /// For example, this is the generated output:
  ///
  ///   ┌─ [title] ─┐
  ///   │ [message] │
  ///   └───────────┘
  ///
  /// If a terminal is attached, the lines in [message] are automatically wrapped based on
  /// the available columns.
  ///
  /// Use this utility only to highlight a message in the logs.
  ///
  /// This is particularly useful when the message can be easily missed because of clutter
  /// generated by other commands invoked by the tool.
  ///
  /// One common use case is to provide actionable steps in a Flutter app when a Gradle
  /// error is printed.
  ///
  /// In the future, this output can be integrated with an IDE like VS Code to display a
  /// notification, and allow the user to trigger an action. e.g. run a migration.
  void printBox(
    String message, {
    String? title,
  });

  /// Use this for verbose tracing output. Users can turn this output on in order
  /// to help diagnose issues with the toolchain or with their setup.
  void printTrace(String message);

  /// Start an indeterminate progress display.
  ///
  /// The `message` argument is the message to display to the user.
  ///
  /// The `progressId` argument provides an ID that can be used to identify
  /// this type of progress (e.g. `hot.reload`, `hot.restart`).
  ///
  /// The `progressIndicatorPadding` can optionally be used to specify the width
  /// of the space into which the `message` is placed before the progress
  /// indicator, if any. It is ignored if the message is longer.
  Status startProgress(
    String message, {
    String? progressId,
    int progressIndicatorPadding = kDefaultStatusPadding,
  });

  /// A [SilentStatus] or an [AnonymousSpinnerStatus] (depending on whether the
  /// terminal is fancy enough), already started.
  Status startSpinner({
    VoidCallback? onFinish,
    Duration? timeout,
    SlowWarningCallback? slowWarningCallback,
  });

  /// Clears all output.
  void clear();

  /// If [fatalWarnings] is set, causes the logger to check if
  /// [hadWarningOutput] is true, and then to call [throwToolExit] if so.
  ///
  /// The [fatalWarnings] flag can be set from the command line with the
  /// "--fatal-warnings" option on commands that support it.
  void checkForFatalLogs() {
    if (fatalWarnings && (hadWarningOutput || hadErrorOutput)) {
      throwToolExit(
          'Logger received ${hadErrorOutput ? 'error' : 'warning'} output '
          'during the run, and "--fatal-warnings" is enabled.');
    }
  }
}

class StdoutLogger extends Logger {
  StdoutLogger({
    required this.terminal,
    required Stdio stdio,
    required OutputPreferences outputPreferences,
    StopwatchFactory stopwatchFactory = const StopwatchFactory(),
  })  : _stdio = stdio,
        _outputPreferences = outputPreferences,
        _stopwatchFactory = stopwatchFactory;

  @override
  final Terminal terminal;
  final OutputPreferences _outputPreferences;
  final Stdio _stdio;
  final StopwatchFactory _stopwatchFactory;

  Status? _status;

  @override
  bool get isVerbose => false;

  @override
  bool get supportsColor => terminal.supportsColor;

  @override
  bool get hasTerminal => _stdio.stdinHasTerminal;

  @override
  void printError(
    String message, {
    StackTrace? stackTrace,
    bool? emphasis,
    TerminalColor? color,
    int? indent,
    int? hangingIndent,
    bool? wrap,
  }) {
    hadErrorOutput = true;
    _status?.pause();
    message = wrapText(
      message,
      indent: indent,
      hangingIndent: hangingIndent,
      shouldWrap: wrap ?? _outputPreferences.wrapText,
      columnWidth: _outputPreferences.wrapColumn,
    );
    if (emphasis ?? false) {
      message = terminal.bolden(message);
    }
    message = terminal.color(message, color ?? TerminalColor.red);
    writeToStdErr('$message\n');
    if (stackTrace != null) {
      writeToStdErr('$stackTrace\n');
    }
    _status?.resume();
  }

  @override
  void printWarning(
    String message, {
    bool? emphasis,
    TerminalColor? color,
    int? indent,
    int? hangingIndent,
    bool? wrap,
  }) {
    hadWarningOutput = true;
    _status?.pause();
    message = wrapText(
      message,
      indent: indent,
      hangingIndent: hangingIndent,
      shouldWrap: wrap ?? _outputPreferences.wrapText,
      columnWidth: _outputPreferences.wrapColumn,
    );
    if (emphasis ?? false) {
      message = terminal.bolden(message);
    }
    message = terminal.color(message, color ?? TerminalColor.cyan);
    writeToStdErr('$message\n');
    _status?.resume();
  }

  @override
  void printStatus(
    String message, {
    bool? emphasis,
    TerminalColor? color,
    bool? newline,
    int? indent,
    int? hangingIndent,
    bool? wrap,
  }) {
    _status?.pause();
    message = wrapText(
      message,
      indent: indent,
      hangingIndent: hangingIndent,
      shouldWrap: wrap ?? _outputPreferences.wrapText,
      columnWidth: _outputPreferences.wrapColumn,
    );
    if (emphasis ?? false) {
      message = terminal.bolden(message);
    }
    if (color != null) {
      message = terminal.color(message, color);
    }
    if (newline ?? true) {
      message = '$message\n';
    }
    writeToStdOut(message);
    _status?.resume();
  }

  @override
  void printBox(
    String message, {
    String? title,
  }) {
    _status?.pause();
    _generateBox(
      title: title,
      message: message,
      wrapColumn: _outputPreferences.wrapColumn,
      terminal: terminal,
      write: writeToStdOut,
    );
    _status?.resume();
  }

  @protected
  void writeToStdOut(String message) => _stdio.stdoutWrite(message);

  @protected
  void writeToStdErr(String message) => _stdio.stderrWrite(message);

  @override
  void printTrace(String message) {}

  @override
  Status startProgress(
    String message, {
    String? progressId,
    int progressIndicatorPadding = kDefaultStatusPadding,
  }) {
    if (_status != null) {
      // Ignore nested progresses; return a no-op status object.
      return SilentStatus(
        stopwatch: _stopwatchFactory.createStopwatch(),
      )..start();
    }
    if (supportsColor) {
      _status = SpinnerStatus(
        message: message,
        padding: progressIndicatorPadding,
        onFinish: _clearStatus,
        stdio: _stdio,
        stopwatch: _stopwatchFactory.createStopwatch(),
        terminal: terminal,
      )..start();
    } else {
      _status = SummaryStatus(
        message: message,
        padding: progressIndicatorPadding,
        onFinish: _clearStatus,
        stdio: _stdio,
        stopwatch: _stopwatchFactory.createStopwatch(),
      )..start();
    }
    return _status!;
  }

  @override
  Status startSpinner({
    VoidCallback? onFinish,
    Duration? timeout,
    SlowWarningCallback? slowWarningCallback,
  }) {
    if (_status != null || !supportsColor) {
      return SilentStatus(
        onFinish: onFinish,
        stopwatch: _stopwatchFactory.createStopwatch(),
      )..start();
    }
    _status = AnonymousSpinnerStatus(
      onFinish: () {
        if (onFinish != null) {
          onFinish();
        }
        _clearStatus();
      },
      stdio: _stdio,
      stopwatch: _stopwatchFactory.createStopwatch(),
      terminal: terminal,
      timeout: timeout,
      slowWarningCallback: slowWarningCallback,
    )..start();
    return _status!;
  }

  void _clearStatus() {
    _status = null;
  }

  @override
  void clear() {
    _status?.pause();
    writeToStdOut('${terminal.clearScreen()}\n');
    _status?.resume();
  }
}

/// A [StdoutLogger] which replaces Unicode characters that cannot be printed to
/// the Windows console with alternative symbols.
///
/// By default, Windows uses either "Consolas" or "Lucida Console" as fonts to
/// render text in the console. Both fonts only have a limited character set.
/// Unicode characters, that are not available in either of the two default
/// fonts, should be replaced by this class with printable symbols. Otherwise,
/// they will show up as the unrepresentable character symbol '�'.
class WindowsStdoutLogger extends StdoutLogger {
  WindowsStdoutLogger({
    required super.terminal,
    required super.stdio,
    required super.outputPreferences,
    super.stopwatchFactory,
  });

  @override
  void writeToStdOut(String message) {
    final String windowsMessage = terminal.supportsEmoji
        ? message
        : message
            .replaceAll('🔥', '')
            .replaceAll('🖼️', '')
            .replaceAll('✗', 'X')
            .replaceAll('✓', '√')
            .replaceAll('🔨', '')
            .replaceAll('💪', '')
            .replaceAll('⚠️', '!')
            .replaceAll('✏️', '');
    _stdio.stdoutWrite(windowsMessage);
  }
}

typedef _Writter = void Function(String message);

/// Wraps the message in a box, and writes the bytes by calling [write].
///
///  Example output:
///
///   ┌─ [title] ─┐
///   │ [message] │
///   └───────────┘
///
/// When [title] is provided, the box will have a title above it.
///
/// The box width never exceeds [wrapColumn].
///
/// If [wrapColumn] is not provided, the default value is 100.
void _generateBox({
  required String message,
  required int wrapColumn,
  required _Writter write,
  required Terminal terminal,
  String? title,
}) {
  const int kPaddingLeftRight = 1;
  const int kEdges = 2;

  final int maxTextWidthPerLine = wrapColumn - kEdges - kPaddingLeftRight * 2;
  final List<String> lines =
      wrapText(message, shouldWrap: true, columnWidth: maxTextWidthPerLine)
          .split('\n');
  final List<int> lineWidth =
      lines.map((String line) => _getColumnSize(line)).toList();
  final int maxColumnSize =
      lineWidth.reduce((int currLen, int maxLen) => max(currLen, maxLen));
  final int textWidth = min(maxColumnSize, maxTextWidthPerLine);
  final int textWithPaddingWidth = textWidth + kPaddingLeftRight * 2;

  write('\n');

  // Write `┌─ [title] ─┐`.
  write('┌');
  write('─');
  if (title == null) {
    write('─' * (textWithPaddingWidth - 1));
  } else {
    write(' ${terminal.bolden(title)} ');
    write('─' * (textWithPaddingWidth - title.length - 3));
  }
  write('┐');
  write('\n');

  // Write `│ [message] │`.
  for (int lineIdx = 0; lineIdx < lines.length; lineIdx++) {
    write('│');
    write(' ' * kPaddingLeftRight);
    write(lines[lineIdx]);
    final int remainingSpacesToEnd = textWidth - lineWidth[lineIdx];
    write(' ' * (remainingSpacesToEnd + kPaddingLeftRight));
    write('│');
    write('\n');
  }

  // Write `└───────────┘`.
  write('└');
  write('─' * textWithPaddingWidth);
  write('┘');
  write('\n');
}

final RegExp _ansiEscapePattern =
    RegExp('\x1B\\[[\x30-\x3F]*[\x20-\x2F]*[\x40-\x7E]');

int _getColumnSize(String line) {
  // Remove ANSI escape characters from the string.
  return line.replaceAll(_ansiEscapePattern, '').length;
}

class BufferLogger extends Logger {
  BufferLogger({
    required this.terminal,
    required OutputPreferences outputPreferences,
    StopwatchFactory stopwatchFactory = const StopwatchFactory(),
    bool verbose = false,
  })  : _outputPreferences = outputPreferences,
        _stopwatchFactory = stopwatchFactory,
        _verbose = verbose;

  /// Create a [BufferLogger] with test preferences.
  BufferLogger.test({
    Terminal? terminal,
    OutputPreferences? outputPreferences,
    bool verbose = false,
  })  : terminal = terminal ?? Terminal.test(),
        _outputPreferences = outputPreferences ?? OutputPreferences.test(),
        _stopwatchFactory = const StopwatchFactory(),
        _verbose = verbose;

  final OutputPreferences _outputPreferences;

  @override
  final Terminal terminal;

  final StopwatchFactory _stopwatchFactory;

  final bool _verbose;

  @override
  bool get isVerbose => _verbose;

  @override
  bool get supportsColor => terminal.supportsColor;

  final StringBuffer _error = StringBuffer();
  final StringBuffer _warning = StringBuffer();
  final StringBuffer _status = StringBuffer();
  final StringBuffer _trace = StringBuffer();
  final StringBuffer _events = StringBuffer();

  String get errorText => _error.toString();
  String get warningText => _warning.toString();
  String get statusText => _status.toString();
  String get traceText => _trace.toString();
  String get eventText => _events.toString();

  @override
  bool get hasTerminal => false;

  @override
  void printError(
    String message, {
    StackTrace? stackTrace,
    bool? emphasis,
    TerminalColor? color,
    int? indent,
    int? hangingIndent,
    bool? wrap,
  }) {
    hadErrorOutput = true;
    _error.writeln(terminal.color(
      wrapText(
        message,
        indent: indent,
        hangingIndent: hangingIndent,
        shouldWrap: wrap ?? _outputPreferences.wrapText,
        columnWidth: _outputPreferences.wrapColumn,
      ),
      color ?? TerminalColor.red,
    ));
  }

  @override
  void printWarning(
    String message, {
    bool? emphasis,
    TerminalColor? color,
    int? indent,
    int? hangingIndent,
    bool? wrap,
  }) {
    hadWarningOutput = true;
    _warning.writeln(terminal.color(
      wrapText(
        message,
        indent: indent,
        hangingIndent: hangingIndent,
        shouldWrap: wrap ?? _outputPreferences.wrapText,
        columnWidth: _outputPreferences.wrapColumn,
      ),
      color ?? TerminalColor.cyan,
    ));
  }

  @override
  void printStatus(
    String message, {
    bool? emphasis,
    TerminalColor? color,
    bool? newline,
    int? indent,
    int? hangingIndent,
    bool? wrap,
  }) {
    if (newline ?? true) {
      _status.writeln(wrapText(
        message,
        indent: indent,
        hangingIndent: hangingIndent,
        shouldWrap: wrap ?? _outputPreferences.wrapText,
        columnWidth: _outputPreferences.wrapColumn,
      ));
    } else {
      _status.write(wrapText(
        message,
        indent: indent,
        hangingIndent: hangingIndent,
        shouldWrap: wrap ?? _outputPreferences.wrapText,
        columnWidth: _outputPreferences.wrapColumn,
      ));
    }
  }

  @override
  void printBox(
    String message, {
    String? title,
  }) {
    _generateBox(
      title: title,
      message: message,
      wrapColumn: _outputPreferences.wrapColumn,
      terminal: terminal,
      write: _status.write,
    );
  }

  @override
  void printTrace(String message) => _trace.writeln(message);

  @override
  Status startProgress(
    String message, {
    String? progressId,
    int progressIndicatorPadding = kDefaultStatusPadding,
  }) {
    printStatus(message);
    return SilentStatus(
      stopwatch: _stopwatchFactory.createStopwatch(),
    )..start();
  }

  @override
  Status startSpinner({
    VoidCallback? onFinish,
    Duration? timeout,
    SlowWarningCallback? slowWarningCallback,
  }) {
    return SilentStatus(
      stopwatch: _stopwatchFactory.createStopwatch(),
      onFinish: onFinish,
    )..start();
  }

  @override
  void clear() {
    _error.clear();
    _status.clear();
    _trace.clear();
    _events.clear();
  }
}

typedef SlowWarningCallback = String Function();

/// A [Status] class begins when start is called, and may produce progress
/// information asynchronously.
///
/// The [SilentStatus] class never has any output.
///
/// The [SpinnerStatus] subclass shows a message with a spinner, and replaces it
/// with timing information when stopped. When canceled, the information isn't
/// shown. In either case, a newline is printed.
///
/// The [AnonymousSpinnerStatus] subclass just shows a spinner.
///
/// The [SummaryStatus] subclass shows only a static message (without an
/// indicator), then updates it when the operation ends.
///
/// Generally, consider `logger.startProgress` instead of directly creating
/// a [Status] or one of its subclasses.
abstract class Status {
  Status({
    this.onFinish,
    required Stopwatch stopwatch,
    this.timeout,
  }) : _stopwatch = stopwatch;

  final VoidCallback? onFinish;
  final Duration? timeout;

  @protected
  final Stopwatch _stopwatch;

  @protected
  String get elapsedTime {
    if (_stopwatch.elapsed.inSeconds > 2) {
      return _getElapsedAsSeconds(_stopwatch.elapsed);
    }
    return _getElapsedAsMilliseconds(_stopwatch.elapsed);
  }

  String _getElapsedAsSeconds(Duration duration) {
    final double seconds =
        duration.inMilliseconds / Duration.millisecondsPerSecond;
    return '${kSecondsFormat.format(seconds)}s';
  }

  String _getElapsedAsMilliseconds(Duration duration) {
    return '${kMillisecondsFormat.format(duration.inMilliseconds)}ms';
  }

  @visibleForTesting
  bool get seemsSlow => timeout != null && _stopwatch.elapsed > timeout!;

  /// Call to start spinning.
  void start() {
    assert(!_stopwatch.isRunning);
    _stopwatch.start();
  }

  /// Call to stop spinning after success.
  void stop() {
    finish();
  }

  /// Call to cancel the spinner after failure or cancellation.
  void cancel() {
    finish();
  }

  /// Call to clear the current line but not end the progress.
  void pause() {}

  /// Call to resume after a pause.
  void resume() {}

  @protected
  void finish() {
    assert(_stopwatch.isRunning);
    _stopwatch.stop();
    onFinish?.call();
  }
}

/// A [Status] that shows nothing.
class SilentStatus extends Status {
  SilentStatus({
    required super.stopwatch,
    super.onFinish,
  });

  @override
  void finish() {
    onFinish?.call();
  }
}

/// Constructor writes [message] to [stdout]. On [cancel] or [stop], will call
/// [onFinish]. On [stop], will additionally print out summary information.
class SummaryStatus extends Status {
  SummaryStatus({
    this.message = '',
    required super.stopwatch,
    this.padding = kDefaultStatusPadding,
    super.onFinish,
    required Stdio stdio,
  }) : _stdio = stdio;

  final String message;
  final int padding;
  final Stdio _stdio;

  bool _messageShowingOnCurrentLine = false;

  @override
  void start() {
    _printMessage();
    super.start();
  }

  void _writeToStdOut(String message) => _stdio.stdoutWrite(message);

  void _printMessage() {
    assert(!_messageShowingOnCurrentLine);
    _writeToStdOut('${message.padRight(padding)}     ');
    _messageShowingOnCurrentLine = true;
  }

  @override
  void stop() {
    if (!_messageShowingOnCurrentLine) {
      _printMessage();
    }
    super.stop();
    assert(_messageShowingOnCurrentLine);
    _writeToStdOut(elapsedTime.padLeft(_kTimePadding));
    _writeToStdOut('\n');
  }

  @override
  void cancel() {
    super.cancel();
    if (_messageShowingOnCurrentLine) {
      _writeToStdOut('\n');
    }
  }

  @override
  void pause() {
    super.pause();
    if (_messageShowingOnCurrentLine) {
      _writeToStdOut('\n');
      _messageShowingOnCurrentLine = false;
    }
  }
}

const int _kTimePadding = 8; // should fit "99,999ms"

/// A kind of animated [Status] that has no message.
///
/// Call [pause] before outputting any text while this is running.
class AnonymousSpinnerStatus extends Status {
  AnonymousSpinnerStatus({
    super.onFinish,
    required super.stopwatch,
    required Stdio stdio,
    required Terminal terminal,
    this.slowWarningCallback,
    super.timeout,
  })  : _stdio = stdio,
        _terminal = terminal,
        _animation = _selectAnimation(terminal);

  final Stdio _stdio;
  final Terminal _terminal;
  String _slowWarning = '';
  final SlowWarningCallback? slowWarningCallback;

  static const String _backspaceChar = '\b';
  static const String _clearChar = ' ';

  static const List<String> _emojiAnimations = <String>[
    '⣾⣽⣻⢿⡿⣟⣯⣷', // counter-clockwise
    '⣾⣷⣯⣟⡿⢿⣻⣽', // clockwise
    '⣾⣷⣯⣟⡿⢿⣻⣽⣷⣾⣽⣻⢿⡿⣟⣯⣷', // bouncing clockwise and counter-clockwise
    '⣾⣷⣯⣽⣻⣟⡿⢿⣻⣟⣯⣽', // snaking
    '⣾⣽⣻⢿⣿⣷⣯⣟⡿⣿', // alternating rain
    '⣀⣠⣤⣦⣶⣾⣿⡿⠿⠻⠛⠋⠉⠙⠛⠟⠿⢿⣿⣷⣶⣴⣤⣄', // crawl up and down, large
    '⠙⠚⠖⠦⢤⣠⣄⡤⠴⠲⠓⠋', // crawl up and down, small
    '⣀⡠⠤⠔⠒⠊⠉⠑⠒⠢⠤⢄', // crawl up and down, tiny
    '⡀⣄⣦⢷⠻⠙⠈⠀⠁⠋⠟⡾⣴⣠⢀⠀', // slide up and down
    '⠙⠸⢰⣠⣄⡆⠇⠋', // clockwise line
    '⠁⠈⠐⠠⢀⡀⠄⠂', // clockwise dot
    '⢇⢣⢱⡸⡜⡎', // vertical wobble up
    '⡇⡎⡜⡸⢸⢱⢣⢇', // vertical wobble down
    '⡀⣀⣐⣒⣖⣶⣾⣿⢿⠿⠯⠭⠩⠉⠁⠀', // swirl
    '⠁⠐⠄⢀⢈⢂⢠⣀⣁⣐⣄⣌⣆⣤⣥⣴⣼⣶⣷⣿⣾⣶⣦⣤⣠⣀⡀⠀⠀', // snowing and melting
    '⠁⠋⠞⡴⣠⢀⠀⠈⠙⠻⢷⣦⣄⡀⠀⠉⠛⠲⢤⢀⠀', // falling water
    '⠄⡢⢑⠈⠀⢀⣠⣤⡶⠞⠋⠁⠀⠈⠙⠳⣆⡀⠀⠆⡷⣹⢈⠀⠐⠪⢅⡀⠀', // fireworks
    '⠐⢐⢒⣒⣲⣶⣷⣿⡿⡷⡧⠧⠇⠃⠁⠀⡀⡠⡡⡱⣱⣳⣷⣿⢿⢯⢧⠧⠣⠃⠂⠀⠈⠨⠸⠺⡺⡾⡿⣿⡿⡷⡗⡇⡅⡄⠄⠀⡀⡐⣐⣒⣓⣳⣻⣿⣾⣼⡼⡸⡘⡈⠈⠀', // fade
    '⢸⡯⠭⠅⢸⣇⣀⡀⢸⣇⣸⡇⠈⢹⡏⠁⠈⢹⡏⠁⢸⣯⣭⡅⢸⡯⢕⡂⠀⠀', // text crawl
  ];

  static const List<String> _asciiAnimations = <String>[
    r'-\|/',
  ];

  static List<String> _selectAnimation(Terminal terminal) {
    final List<String> animations =
        terminal.supportsEmoji ? _emojiAnimations : _asciiAnimations;
    return animations[terminal.preferredStyle % animations.length]
        .runes
        .map<String>((int scalar) => String.fromCharCode(scalar))
        .toList();
  }

  final List<String> _animation;

  Timer? timer;
  int ticks = 0;
  int _lastAnimationFrameLength = 0;
  bool timedOut = false;

  String get _currentAnimationFrame => _animation[ticks % _animation.length];
  int get _currentLineLength => _lastAnimationFrameLength + _slowWarning.length;

  void _writeToStdOut(String message) => _stdio.stdoutWrite(message);

  void _clear(int length) {
    _writeToStdOut('${_backspaceChar * length}'
        '${_clearChar * length}'
        '${_backspaceChar * length}');
  }

  @override
  void start() {
    super.start();
    assert(timer == null);
    _startSpinner();
  }

  void _startSpinner() {
    timer = Timer.periodic(const Duration(milliseconds: 100), _callback);
    _callback(timer!);
  }

  void _callback(Timer timer) {
    assert(this.timer == timer);
    assert(timer.isActive);
    _writeToStdOut(_backspaceChar * _lastAnimationFrameLength);
    ticks += 1;
    if (seemsSlow) {
      if (!timedOut) {
        timedOut = true;
        _clear(_currentLineLength);
      }
      if (_slowWarning == '' && slowWarningCallback != null) {
        _slowWarning = slowWarningCallback!();
        _writeToStdOut(_slowWarning);
      }
    }
    final String newFrame = _currentAnimationFrame;
    _lastAnimationFrameLength = newFrame.runes.length;
    _writeToStdOut(newFrame);
  }

  @override
  void pause() {
    assert(timer != null);
    assert(timer!.isActive);
    if (_terminal.supportsColor) {
      _writeToStdOut('\r\x1B[K'); // go to start of line and clear line
    } else {
      _clear(_currentLineLength);
    }
    _lastAnimationFrameLength = 0;
    timer?.cancel();
  }

  @override
  void resume() {
    assert(timer != null);
    assert(!timer!.isActive);
    _startSpinner();
  }

  @override
  void finish() {
    assert(timer != null);
    assert(timer!.isActive);
    timer?.cancel();
    timer = null;
    _clear(_lastAnimationFrameLength);
    _lastAnimationFrameLength = 0;
    super.finish();
  }
}

/// An animated version of [Status].
///
/// The constructor writes [message] to [stdout] with padding, then starts an
/// indeterminate progress indicator animation.
///
/// On [cancel] or [stop], will call [onFinish]. On [stop], will
/// additionally print out summary information.
///
/// Call [pause] before outputting any text while this is running.
class SpinnerStatus extends AnonymousSpinnerStatus {
  SpinnerStatus({
    required this.message,
    this.padding = kDefaultStatusPadding,
    super.onFinish,
    required super.stopwatch,
    required super.stdio,
    required super.terminal,
  });

  final String message;
  final int padding;

  static final String _margin =
      AnonymousSpinnerStatus._clearChar * (5 + _kTimePadding - 1);

  int _totalMessageLength = 0;

  @override
  int get _currentLineLength => _totalMessageLength + super._currentLineLength;

  @override
  void start() {
    _printStatus();
    super.start();
  }

  void _printStatus() {
    final String line = '${message.padRight(padding)}$_margin';
    _totalMessageLength = line.length;
    _writeToStdOut(line);
  }

  @override
  void pause() {
    super.pause();
    _totalMessageLength = 0;
  }

  @override
  void resume() {
    _printStatus();
    super.resume();
  }

  @override
  void stop() {
    super.stop(); // calls finish, which clears the spinner
    assert(_totalMessageLength > _kTimePadding);
    _writeToStdOut(AnonymousSpinnerStatus._backspaceChar * (_kTimePadding - 1));
    _writeToStdOut(elapsedTime.padLeft(_kTimePadding));
    _writeToStdOut('\n');
  }

  @override
  void cancel() {
    super.cancel(); // calls finish, which clears the spinner
    assert(_totalMessageLength > 0);
    _writeToStdOut('\n');
  }
}

/// Wraps a block of text into lines no longer than [columnWidth].
///
/// Tries to split at whitespace, but if that's not good enough to keep it under
/// the limit, then it splits in the middle of a word. If [columnWidth] (minus
/// any indent) is smaller than [kMinColumnWidth], the text is wrapped at that
/// [kMinColumnWidth] instead.
///
/// Preserves indentation (leading whitespace) for each line (delimited by '\n')
/// in the input, and will indent wrapped lines that same amount, adding
/// [indent] spaces in addition to any existing indent.
///
/// If [hangingIndent] is supplied, then that many additional spaces will be
/// added to each line, except for the first line. The [hangingIndent] is added
/// to the specified [indent], if any. This is useful for wrapping
/// text with a heading prefix (e.g. "Usage: "):
///
/// ```dart
/// String prefix = "Usage: ";
/// print(prefix + wrapText(invocation, indent: 2, hangingIndent: prefix.length, columnWidth: 40));
/// ```
///
/// yields:
/// ```
///   Usage: app main_command <subcommand>
///          [arguments]
/// ```
///
/// If [outputPreferences.wrapText] is false, then the text will be returned
/// unchanged. If [shouldWrap] is specified, then it overrides the
/// [outputPreferences.wrapText] setting.
///
/// If the amount of indentation (from the text, [indent], and [hangingIndent])
/// is such that less than [kMinColumnWidth] characters can fit in the
/// [columnWidth], then the indent is truncated to allow the text to fit.
String wrapText(
  String text, {
  required int columnWidth,
  required bool shouldWrap,
  int? hangingIndent,
  int? indent,
}) {
  assert(columnWidth >= 0);
  if (text.isEmpty) {
    return '';
  }
  indent ??= 0;
  hangingIndent ??= 0;
  final List<String> splitText = text.split('\n');
  final List<String> result = <String>[];
  for (final String line in splitText) {
    String trimmedText = line.trimLeft();
    final String leadingWhitespace =
        line.substring(0, line.length - trimmedText.length);
    List<String> notIndented;
    if (hangingIndent != 0) {
      // When we have a hanging indent, we want to wrap the first line at one
      // width, and the rest at another (offset by hangingIndent), so we wrap
      // them twice and recombine.
      final List<String> firstLineWrap = _wrapTextAsLines(
        trimmedText,
        columnWidth: columnWidth - leadingWhitespace.length - indent,
        shouldWrap: shouldWrap,
      );
      notIndented = <String>[firstLineWrap.removeAt(0)];
      trimmedText = trimmedText.substring(notIndented[0].length).trimLeft();
      if (trimmedText.isNotEmpty) {
        notIndented.addAll(_wrapTextAsLines(
          trimmedText,
          columnWidth:
              columnWidth - leadingWhitespace.length - indent - hangingIndent,
          shouldWrap: shouldWrap,
        ));
      }
    } else {
      notIndented = _wrapTextAsLines(
        trimmedText,
        columnWidth: columnWidth - leadingWhitespace.length - indent,
        shouldWrap: shouldWrap,
      );
    }
    String? hangingIndentString;
    final String indentString = ' ' * indent;
    result.addAll(notIndented.map<String>(
      (String line) {
        // Don't return any lines with just whitespace on them.
        if (line.isEmpty) {
          return '';
        }
        String truncatedIndent =
            '$indentString${hangingIndentString ?? ''}$leadingWhitespace';
        if (truncatedIndent.length > columnWidth - kMinColumnWidth) {
          truncatedIndent = truncatedIndent.substring(
              0, math.max(columnWidth - kMinColumnWidth, 0));
        }
        final String result = '$truncatedIndent$line';
        hangingIndentString ??= ' ' * hangingIndent!;
        return result;
      },
    ));
  }
  return result.join('\n');
}

/// Wraps a block of text into lines no longer than [columnWidth], starting at the
/// [start] column, and returning the result as a list of strings.
///
/// Tries to split at whitespace, but if that's not good enough to keep it
/// under the limit, then splits in the middle of a word. Preserves embedded
/// newlines, but not indentation (it trims whitespace from each line).
///
/// If [columnWidth] is not specified, then the column width will be the width of the
/// terminal window by default. If the stdout is not a terminal window, then the
/// default will be [outputPreferences.wrapColumn].
///
/// The [columnWidth] is clamped to [kMinColumnWidth] at minimum (so passing negative
/// widths is fine, for instance).
///
/// If [outputPreferences.wrapText] is false, then the text will be returned
/// simply split at the newlines, but not wrapped. If [shouldWrap] is specified,
/// then it overrides the [outputPreferences.wrapText] setting.
List<String> _wrapTextAsLines(
  String text, {
  int start = 0,
  required int columnWidth,
  required bool shouldWrap,
}) {
  if (text.isEmpty) {
    return <String>[''];
  }
  assert(start >= 0);

  // Splits a string so that the resulting list has the same number of elements
  // as there are visible characters in the string, but elements may include one
  // or more adjacent ANSI sequences. Joining the list elements again will
  // reconstitute the original string. This is useful for manipulating "visible"
  // characters in the presence of ANSI control codes.
  List<_AnsiRun> splitWithCodes(String input) {
    final RegExp characterOrCode =
        RegExp('(\u001b\\[[0-9;]*m|.)', multiLine: true);
    List<_AnsiRun> result = <_AnsiRun>[];
    final StringBuffer current = StringBuffer();
    for (final Match match in characterOrCode.allMatches(input)) {
      current.write(match[0]);
      if (match[0]!.length < 4) {
        // This is a regular character, write it out.
        result.add(_AnsiRun(current.toString(), match[0]!));
        current.clear();
      }
    }
    // If there's something accumulated, then it must be an ANSI sequence, so
    // add it to the end of the last entry so that we don't lose it.
    if (current.isNotEmpty) {
      if (result.isNotEmpty) {
        result.last.original += current.toString();
      } else {
        // If there is nothing in the string besides control codes, then just
        // return them as the only entry.
        result = <_AnsiRun>[_AnsiRun(current.toString(), '')];
      }
    }
    return result;
  }

  String joinRun(List<_AnsiRun> list, int start, [int? end]) {
    return list
        .sublist(start, end)
        .map<String>((_AnsiRun run) => run.original)
        .join()
        .trim();
  }

  final List<String> result = <String>[];
  final int effectiveLength = math.max(columnWidth - start, kMinColumnWidth);
  for (final String line in text.split('\n')) {
    // If the line is short enough, even with ANSI codes, then we can just add
    // add it and move on.
    if (line.length <= effectiveLength || !shouldWrap) {
      result.add(line);
      continue;
    }
    final List<_AnsiRun> splitLine = splitWithCodes(line);
    if (splitLine.length <= effectiveLength) {
      result.add(line);
      continue;
    }

    int currentLineStart = 0;
    int? lastWhitespace;
    // Find the start of the current line.
    for (int index = 0; index < splitLine.length; ++index) {
      if (splitLine[index].character.isNotEmpty &&
          _isWhitespace(splitLine[index])) {
        lastWhitespace = index;
      }

      if (index - currentLineStart >= effectiveLength) {
        // Back up to the last whitespace, unless there wasn't any, in which
        // case we just split where we are.
        if (lastWhitespace != null) {
          index = lastWhitespace;
        }

        result.add(joinRun(splitLine, currentLineStart, index));

        // Skip any intervening whitespace.
        while (index < splitLine.length && _isWhitespace(splitLine[index])) {
          index++;
        }

        currentLineStart = index;
        lastWhitespace = null;
      }
    }
    result.add(joinRun(splitLine, currentLineStart));
  }
  return result;
}

// Used to represent a run of ANSI control sequences next to a visible
// character.
class _AnsiRun {
  _AnsiRun(this.original, this.character);

  String original;
  String character;
}

/// Returns true if the code unit at [index] in [text] is a whitespace
/// character.
///
/// Based on: https://en.wikipedia.org/wiki/Whitespace_character#Unicode
bool _isWhitespace(_AnsiRun run) {
  final int rune = run.character.isNotEmpty ? run.character.codeUnitAt(0) : 0x0;
  return rune >= 0x0009 && rune <= 0x000D ||
      rune == 0x0020 ||
      rune == 0x0085 ||
      rune == 0x1680 ||
      rune == 0x180E ||
      rune >= 0x2000 && rune <= 0x200A ||
      rune == 0x2028 ||
      rune == 0x2029 ||
      rune == 0x202F ||
      rune == 0x205F ||
      rune == 0x3000 ||
      rune == 0xFEFF;
}

/// An abstraction for instantiation of the correct logger type.
///
/// Our logger class hierarchy and runtime requirements are overly complicated.
class LoggerFactory {
  LoggerFactory({
    required Terminal terminal,
    required Stdio stdio,
    required OutputPreferences outputPreferences,
    StopwatchFactory stopwatchFactory = const StopwatchFactory(),
  })  : _terminal = terminal,
        _stdio = stdio,
        _stopwatchFactory = stopwatchFactory,
        _outputPreferences = outputPreferences;

  final Terminal _terminal;
  final Stdio _stdio;
  final StopwatchFactory _stopwatchFactory;
  final OutputPreferences _outputPreferences;

  /// Create the appropriate logger for the current platform and configuration.
  Logger createLogger({
    required bool windows,
  }) {
    Logger logger;
    if (windows) {
      logger = WindowsStdoutLogger(
        terminal: _terminal,
        stdio: _stdio,
        outputPreferences: _outputPreferences,
        stopwatchFactory: _stopwatchFactory,
      );
    } else {
      logger = StdoutLogger(
          terminal: _terminal,
          stdio: _stdio,
          outputPreferences: _outputPreferences,
          stopwatchFactory: _stopwatchFactory);
    }
    return logger;
  }
}
