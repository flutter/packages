import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_svg/parser.dart';

void main() {
  testWidgets('Reports tag in out of order defs', (WidgetTester tester) async {
    final FlutterExceptionHandler oldHandler = FlutterError.onError!;
    late FlutterErrorDetails error;
    FlutterError.onError = (FlutterErrorDetails details) {
      error = details;
    };
    const String svgStr = '''
<svg id="svgRoot" xmlns="http://www.w3.org/2000/svg" version="1.1" viewBox="0 0 166 202">
  <path id="path4" d="M79.5 170.7 120.9 156.4 107.4 142.8" fill="url(#triangleGradient)" />
  <defs>
    <linearGradient id="triangleGradient">
      <stop offset="20%" stop-color="#000000" stop-opacity=".55" />
      <stop offset="85%" stop-color="#616161" stop-opacity=".01" />
    </linearGradient>
  </defs>
</svg>
''';

    final SvgParser parser = SvgParser();
    await parser.parse(svgStr, key: 'some_svg.svg');

    expect(
      error.context.toString(),
      contains('while parsing some_svg.svg in _getDefinitionPaint'),
    );
    FlutterError.onError = oldHandler;
  });
}
