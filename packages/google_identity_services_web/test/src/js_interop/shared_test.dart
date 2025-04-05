import 'package:google_identity_services_web/src/js_interop/shared.dart'
    show maybeEnum;
import 'package:test/test.dart';

// Define a sample enum for testing
enum TestEnum {
  first,
  second,
  third,
  camelCase,
  UPPERCASE,
}

void main() {
  group('maybeEnum tests', () {
    test('should return null when needle is null', () {
      expect(maybeEnum<TestEnum>(null, TestEnum.values), isNull);
    });

    test('should return the correct enum when needle exists', () {
      expect(maybeEnum('first', TestEnum.values), equals(TestEnum.first));
      expect(maybeEnum('second', TestEnum.values), equals(TestEnum.second));
      expect(maybeEnum('third', TestEnum.values), equals(TestEnum.third));
    });

    test('should handle different casing in enum names', () {
      expect(maybeEnum('camelCase', TestEnum.values), equals(TestEnum.camelCase));
      expect(maybeEnum('UPPERCASE', TestEnum.values), equals(TestEnum.UPPERCASE));
    });

    test('should return null when needle is not found', () {
      expect(maybeEnum('notFound', TestEnum.values), isNull);
      expect(maybeEnum('Fourth', TestEnum.values), isNull);
      expect(maybeEnum('', TestEnum.values), isNull);
    });

    test('should return null for case-mismatched enum names', () {
      expect(maybeEnum('FIRST', TestEnum.values), isNull);
      expect(maybeEnum('camelcase', TestEnum.values), isNull);
      expect(maybeEnum('uppercase', TestEnum.values), isNull);
    });
    
    test('should handle special characters in needle', () {
      expect(maybeEnum('first!', TestEnum.values), isNull);
      expect(maybeEnum(' first ', TestEnum.values), isNull);
    });
    
    test('should work with empty enum values list', () {
      // This is a theoretical test - in practice, enum values are never empty
      // But the function should handle this case gracefully
      final emptyList = <TestEnum>[];
      expect(maybeEnum('anything', emptyList), isNull);
    });
  });
}
