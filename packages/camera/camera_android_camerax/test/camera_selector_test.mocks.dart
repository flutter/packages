// Mocks generated by Mockito 5.3.2 from annotations
// in camera_android_camerax/test/camera_selector_test.dart.
// Do not manually edit this file.

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:mockito/mockito.dart' as _i1;

import 'test_camerax_library.g.dart' as _i2;

// ignore_for_file: type=lint
// ignore_for_file: avoid_redundant_argument_values
// ignore_for_file: avoid_setters_without_getters
// ignore_for_file: comment_references
// ignore_for_file: implementation_imports
// ignore_for_file: invalid_use_of_visible_for_testing_member
// ignore_for_file: prefer_const_constructors
// ignore_for_file: unnecessary_parenthesis
// ignore_for_file: camel_case_types
// ignore_for_file: subtype_of_sealed_class

/// A class which mocks [TestCameraSelectorHostApi].
///
/// See the documentation for Mockito's code generation for more information.
class MockTestCameraSelectorHostApi extends _i1.Mock
    implements _i2.TestCameraSelectorHostApi {
  MockTestCameraSelectorHostApi() {
    _i1.throwOnMissingStub(this);
  }

  @override
  void create(
    int? identifier,
    int? lensFacing,
  ) =>
      super.noSuchMethod(
        Invocation.method(
          #create,
          [
            identifier,
            lensFacing,
          ],
        ),
        returnValueForMissingStub: null,
      );
  @override
  List<int?> filter(
    int? identifier,
    List<int?>? cameraInfoIds,
  ) =>
      (super.noSuchMethod(
        Invocation.method(
          #filter,
          [
            identifier,
            cameraInfoIds,
          ],
        ),
        returnValue: <int?>[],
      ) as List<int?>);
}
