import 'package:test/test.dart';
import 'package:vector_graphics_compiler/src/util.dart';

void main() {
  test('listEquals', () {
    final List<int> listA = <int>[1, 2, 3];
    final List<int> listB = <int>[1, 2, 3];
    final List<int> listC = <int>[1, 2];
    final List<int> listD = <int>[3, 2, 1];

    expect(listEquals<void>(null, null), isTrue);
    expect(listEquals(listA, null), isFalse);
    expect(listEquals(null, listB), isFalse);
    expect(listEquals(listA, listA), isTrue);
    expect(listEquals(listA, listB), isTrue);
    expect(listEquals(listA, listC), isFalse);
    expect(listEquals(listA, listD), isFalse);
  });
}