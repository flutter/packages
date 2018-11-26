import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_svg/src/picture_cache.dart';
import 'package:test/test.dart';

class MockPictureStreamCompleter extends PictureStreamCompleter {}

void main() {
  final PictureCache cache = PictureCache();
  test('Cache Tests', () {
    expect(cache.maximumSize, equals(1000));
    cache.maximumSize = 1;
    expect(cache.maximumSize, equals(1));

    expect(() => cache.maximumSize = -1,
        throwsA(const TypeMatcher<AssertionError>()));
    expect(() => cache.maximumSize = null,
        throwsA(const TypeMatcher<AssertionError>()));

    expect(() => cache.putIfAbsent(null, null),
        throwsA(const TypeMatcher<AssertionError>()));
    expect(() => cache.putIfAbsent(1, null),
        throwsA(const TypeMatcher<AssertionError>()));

    final MockPictureStreamCompleter completer1 = MockPictureStreamCompleter();
    final MockPictureStreamCompleter completer2 = MockPictureStreamCompleter();
    expect(cache.putIfAbsent(1, () => completer1), completer1);
    expect(cache.putIfAbsent(1, () => completer1), completer1);
    expect(cache.putIfAbsent(2, () => completer2), completer2);

    cache.clear();
  });
}
