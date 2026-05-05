import 'package:dummy_pkg/src/calculator.dart';
import 'package:test/test.dart';

void main() {
  test('add', () {
    expect(add(1, 2), 3);
  });
  test('subtract', () {
    expect(subtract(2, 1), 1);
  });
}
