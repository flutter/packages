import 'package:google_identity_services_web/src/js_interop/shared.dart';
import 'package:test/test.dart';

enum AuthMethod { google, facebook, apple }

void main() {
  group('maybeEnum', () {
    test('returns correct enum when match is found', () {
      expect(maybeEnum('google', AuthMethod.values), AuthMethod.google);
    });

    test('returns null when needle is null', () {
      expect(maybeEnum(null, AuthMethod.values), isNull);
    });

    test('returns null when needle does not match', () {
      expect(maybeEnum('github', AuthMethod.values), isNull);
    });
  });
}
