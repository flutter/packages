import 'package:flutter/foundation.dart';

/// Reports a missing or undefined `<defs>` element.
void reportMissingDef(String href, String methodName) {
  FlutterError.onError(
    FlutterErrorDetails(
      exception: StateError('Failed to find definition for $href'),
      context: 'in $methodName',
      library: 'SVG',
      informationCollector: (StringBuffer buff) {
        buff.writeln(
            'This library only supports <defs> and xlink:href references that '
            'are defined ahead of their references. '
            'This error can be caused when the desired definition is defined after the element '
            'referring to it (e.g. at the end of the file), or defined in another file.');
        buff.writeln(
            'This error is treated as non-fatal, but your SVG file will likely not render as intended');
      },
    ),
  );
}
