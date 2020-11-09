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
    actualCommands.add('cubicTo($x1, $y1, $x2, $y2, $x3, $y3)');
  }

  @override
  void lineTo(double x, double y) {
    actualCommands.add('lineTo($x, $y)');
  }

  @override
  void moveTo(double x, double y) {
    actualCommands.add('moveTo($x, $y)');
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
      'moveTo(20.0, 30.0)',
      'cubicTo(33.33333333333333, 13.333333333333332, 46.666666666666664, 13.333333333333332, 60.0, 30.0)',
      'cubicTo(73.33333333333333, 46.666666666666664, 86.66666666666666, 46.666666666666664, 100.0, 30.0)',
    ]);
  });
}
