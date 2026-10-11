// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// Canonicalizes CSS-wide keywords without changing case-sensitive identifiers.
String cssWideKeyword(String value) {
  final String lower = value.toLowerCase();
  return <String>{'inherit', 'initial', 'unset', 'revert', 'revert-layer'}.contains(lower)
      ? lower
      : value;
}

/// Applies an inline declaration list over presentation attributes.
///
/// Attribute order has no effect on the cascade. Invalid declarations cannot
/// replace an earlier valid value. This deliberately handles declaration lists;
/// stylesheets and selectors are outside the SVG compiler's supported CSS.
Map<String, String> resolveInlineStyles(
  Map<String, String> presentation, {
  bool Function(String name, String value)? validProperty,
}) {
  final attributes = Map<String, String>.of(presentation);
  final important = <String>{};
  for (final String declaration in _declarations(presentation['style'] ?? '')) {
    final int separator = declaration.indexOf(':');
    if (separator <= 0) {
      continue;
    }
    final String name = declaration.substring(0, separator).trim().toLowerCase();
    if (!RegExp(r'^[-a-z][\w-]*$').hasMatch(name)) {
      continue;
    }
    String value = declaration.substring(separator + 1).trim();
    final RegExpMatch? priority = RegExp(
      r'\s*!\s*important\s*$',
      caseSensitive: false,
    ).firstMatch(value);
    final isImportant = priority != null;
    if (priority != null) {
      value = value.substring(0, priority.start).trimRight();
    }
    value = cssWideKeyword(value);
    if (value.isEmpty ||
        !(validProperty?.call(name, value) ?? true) ||
        (important.contains(name) && !isImportant)) {
      continue;
    }
    if (value == 'revert') {
      attributes[name] = 'unset';
    } else if (value == 'revert-layer') {
      if (presentation.containsKey(name)) {
        attributes[name] = presentation[name]!;
      } else {
        attributes.remove(name);
      }
    } else {
      attributes[name] = value;
    }
    if (isImportant) {
      important.add(name);
    }
  }
  return attributes;
}

Iterable<String> _declarations(String source) sync* {
  var buffer = StringBuffer();
  String? quote;
  var depth = 0;
  for (var i = 0; i < source.length; i++) {
    final String char = source[i];
    if (char == r'\' && i + 1 < source.length) {
      buffer.write(char);
      buffer.write(source[++i]);
      continue;
    }
    if (quote != null) {
      buffer.write(char);
      if (char == quote) {
        quote = null;
      }
      continue;
    }
    if (char == '/' && i + 1 < source.length && source[i + 1] == '*') {
      final int end = source.indexOf('*/', i + 2);
      if (end < 0) {
        // CSS consumes an unterminated comment through EOF. The declaration
        // preceding it is still usable if its value is otherwise complete.
        break;
      }
      buffer.write(' ');
      i = end + 1;
    } else if (char == '"' || char == "'") {
      quote = char;
      buffer.write(char);
    } else if (char == '(') {
      depth++;
      buffer.write(char);
    } else if (char == ')') {
      // An unmatched closing token invalidates this declaration, but must not
      // swallow the next declaration's semicolon during error recovery.
      if (depth > 0) {
        depth--;
      }
      buffer.write(char);
    } else if (char == ';' && depth == 0) {
      yield buffer.toString();
      buffer = StringBuffer();
    } else {
      buffer.write(char);
    }
  }
  if (quote == null && depth == 0) {
    yield buffer.toString();
  }
}

/// Validates and normalizes the compiler's supported single filter reference.
String? normalizeFilterReference(String value) {
  value = cssWideKeyword(value.trim());
  if (<String>{'inherit', 'initial', 'unset', 'revert', 'revert-layer'}.contains(value)) {
    return value;
  }
  if (value.toLowerCase() == 'none') {
    return 'none';
  }
  if (!value.toLowerCase().startsWith('url(') || !value.endsWith(')')) {
    return null;
  }
  String source = value.substring(4, value.length - 1).trim();
  final bool quoted = source.startsWith('"') || source.startsWith("'");
  String? quote;
  if (quoted) {
    quote = source[0];
    if (source.length < 2 || !source.endsWith(quote)) {
      return null;
    }
    source = source.substring(1, source.length - 1);
  }
  final target = StringBuffer();
  for (var i = 0; i < source.length; i++) {
    final String char = source[i];
    if (char != r'\') {
      if (char == quote ||
          RegExp(r'[\r\n\f]').hasMatch(char) ||
          (!quoted && RegExp(r'''[\s()'"]''').hasMatch(char))) {
        return null;
      }
      target.write(char);
      continue;
    }
    if (++i == source.length) {
      return null;
    }
    final Match? hex = RegExp(r'[0-9a-fA-F]{1,6}').matchAsPrefix(source, i);
    if (hex != null) {
      final int code = int.parse(hex[0]!, radix: 16);
      target.writeCharCode(
        code == 0 || code > 0x10ffff || (code >= 0xd800 && code <= 0xdfff) ? 0xfffd : code,
      );
      i += hex[0]!.length - 1;
      if (i + 1 < source.length && RegExp(r'\s').hasMatch(source[i + 1])) {
        i++;
        if (source[i] == '\r' && i + 1 < source.length && source[i + 1] == '\n') {
          i++;
        }
      }
    } else if (RegExp(r'[\r\n\f]').hasMatch(source[i])) {
      if (!quoted) {
        return null;
      }
      if (source[i] == '\r' && i + 1 < source.length && source[i + 1] == '\n') {
        i++;
      }
    } else {
      target.write(source[i]);
    }
  }
  return 'url($target)';
}

/// Decodes the fragment identifier of a local filter URL or template href.
String? localFilterTarget(String target) {
  if (!target.startsWith('#')) {
    return null;
  }
  try {
    return target.contains('%') ? '#${Uri.decodeComponent(target.substring(1))}' : target;
  } on FormatException {
    return null;
  }
}
