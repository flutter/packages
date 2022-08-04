import 'package:path_parsing/path_parsing.dart';
import 'package:test/test.dart';

class DeepTestPathProxy extends PathProxy {
  DeepTestPathProxy(this.expectedCommands);

  final List<String> expectedCommands;
  final List<String> actualCommands = <String>[];

  @override
  void close() {
    actualCommands.add('close()');
  }

  @override
  void cubicTo(
    double x1,
    double y1,
    double x2,
    double y2,
    double x3,
    double y3,
  ) {
    actualCommands.add(
        'cubicTo(${x1.toStringAsFixed(4)}, ${y1.toStringAsFixed(4)}, ${x2.toStringAsFixed(4)}, ${y2.toStringAsFixed(4)}, ${x3.toStringAsFixed(4)}, ${y3.toStringAsFixed(4)})');
  }

  @override
  void lineTo(double x, double y) {
    actualCommands
        .add('lineTo(${x.toStringAsFixed(4)}, ${y.toStringAsFixed(4)})');
  }

  @override
  void moveTo(double x, double y) {
    actualCommands
        .add('moveTo(${x.toStringAsFixed(4)}, ${y.toStringAsFixed(4)})');
  }

  void validate() {
    expect(expectedCommands, orderedEquals(actualCommands));
  }
}

void main() {
  void assertValidPath(String input, List<String> commands) {
    final DeepTestPathProxy proxy = DeepTestPathProxy(commands);
    writeSvgPathDataToPath(input, proxy);
    proxy.validate();
  }

  test('Deep path validation', () {
    assertValidPath('M20,30 Q40,5 60,30 T100,30', <String>[
      'moveTo(20.0000, 30.0000)',
      'cubicTo(33.3333, 13.3333, 46.6667, 13.3333, 60.0000, 30.0000)',
      'cubicTo(73.3333, 46.6667, 86.6667, 46.6667, 100.0000, 30.0000)'
    ]);

    assertValidPath(
        'M5.5 5.5a.5 1.5 30 1 1-.866-.5.5 1.5 30 1 1 .866.5z', <String>[
      'moveTo(5.5000, 5.5000)',
      'cubicTo(5.2319, 5.9667, 4.9001, 6.3513, 4.6307, 6.5077)',
      'cubicTo(4.3612, 6.6640, 4.1953, 6.5683, 4.1960, 6.2567)',
      'cubicTo(4.1967, 5.9451, 4.3638, 5.4655, 4.6340, 5.0000)',
      'cubicTo(4.9021, 4.5333, 5.2339, 4.1487, 5.5033, 3.9923)',
      'cubicTo(5.7728, 3.8360, 5.9387, 3.9317, 5.9380, 4.2433)',
      'cubicTo(5.9373, 4.5549, 5.7702, 5.0345, 5.5000, 5.5000)',
      'close()'
    ]);
  });
}
