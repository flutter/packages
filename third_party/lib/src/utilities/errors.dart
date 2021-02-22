import 'package:flutter/foundation.dart';

/// Reports a missing or undefined `<defs>` element.
void reportMissingDef(String? key, String? href, String methodName) {
  FlutterError.onError!(
    FlutterErrorDetails(
      exception: FlutterError.fromParts(<DiagnosticsNode>[
        ErrorSummary('Failed to find definition for $href'),
        ErrorDescription(
            'This library only supports <defs> and xlink:href references that '
            'are defined ahead of their references.'),
        ErrorHint(
            'This error can be caused when the desired definition is defined after the element '
            'referring to it (e.g. at the end of the file), or defined in another file.'),
        ErrorDescription(
            'This error is treated as non-fatal, but your SVG file will likely not render as intended'),
      ]),
      context: ErrorDescription('while parsing $key in $methodName'),
      library: 'SVG',
    ),
  );
}
