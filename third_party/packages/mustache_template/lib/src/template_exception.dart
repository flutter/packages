library mustache.template_exception;

import 'package:mustache/mustache.dart' as m;

class TemplateException implements m.TemplateException {
  TemplateException(this.message, this.templateName, this.source, this.offset);

  final String message;
  final String templateName;
  final String source;
  final int offset;

  bool _isUpdated = false;
  int _line;
  int _column;
  String _context;

  int get line {
    _update();
    return _line;
  }

  int get column {
    _update();
    return _column;
  }

  String get context {
    _update();
    return _context;
  }

  String toString() {
    var list = [];
    if (templateName != null) list.add(templateName);
    if (line != null) list.add(line);
    if (column != null) list.add(column);
    var location = list.isEmpty ? '' : ' (${list.join(':')})';
    return '$message$location\n$context';
  }

  // This source code is a modified version of FormatException.toString().
  void _update() {
    if (_isUpdated) return;
    _isUpdated = true;

    if (source == null ||
        offset == null ||
        (offset < 0 || offset > source.length)) return;

    // Find line and character column.
    int lineNum = 1;
    int lineStart = 0;
    bool lastWasCR = false;
    for (int i = 0; i < offset; i++) {
      int char = source.codeUnitAt(i);
      if (char == 0x0a) {
        if (lineStart != i || !lastWasCR) {
          lineNum++;
        }
        lineStart = i + 1;
        lastWasCR = false;
      } else if (char == 0x0d) {
        lineNum++;
        lineStart = i + 1;
        lastWasCR = true;
      }
    }

    _line = lineNum;
    _column = offset - lineStart + 1;

    // Find context.
    int lineEnd = source.length;
    for (int i = offset; i < source.length; i++) {
      int char = source.codeUnitAt(i);
      if (char == 0x0a || char == 0x0d) {
        lineEnd = i;
        break;
      }
    }
    int length = lineEnd - lineStart;
    int start = lineStart;
    int end = lineEnd;
    String prefix = "";
    String postfix = "";
    if (length > 78) {
      // Can't show entire line. Try to anchor at the nearest end, if
      // one is within reach.
      int index = offset - lineStart;
      if (index < 75) {
        end = start + 75;
        postfix = "...";
      } else if (end - offset < 75) {
        start = end - 75;
        prefix = "...";
      } else {
        // Neither end is near, just pick an area around the offset.
        start = offset - 36;
        end = offset + 36;
        prefix = postfix = "...";
      }
    }
    String slice = source.substring(start, end);
    int markOffset = offset - start + prefix.length;

    _context = "$prefix$slice$postfix\n${" " * markOffset}^\n";
  }
}
