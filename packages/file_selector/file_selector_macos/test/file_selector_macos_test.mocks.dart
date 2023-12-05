// Mocks generated by Mockito 5.4.3 from annotations
// in file_selector_macos/test/file_selector_macos_test.dart.
// Do not manually edit this file.

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i3;

import 'package:file_selector_macos/src/messages.g.dart' as _i4;
import 'package:mockito/mockito.dart' as _i1;

import 'messages_test.g.dart' as _i2;

// ignore_for_file: type=lint
// ignore_for_file: avoid_redundant_argument_values
// ignore_for_file: avoid_setters_without_getters
// ignore_for_file: comment_references
// ignore_for_file: deprecated_member_use
// ignore_for_file: deprecated_member_use_from_same_package
// ignore_for_file: implementation_imports
// ignore_for_file: invalid_use_of_visible_for_testing_member
// ignore_for_file: prefer_const_constructors
// ignore_for_file: unnecessary_parenthesis
// ignore_for_file: camel_case_types
// ignore_for_file: subtype_of_sealed_class

/// A class which mocks [TestFileSelectorApi].
///
/// See the documentation for Mockito's code generation for more information.
class MockTestFileSelectorApi extends _i1.Mock
    implements _i2.TestFileSelectorApi {
  MockTestFileSelectorApi() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i3.Future<List<String?>> displayOpenPanel(_i4.OpenPanelOptions? options) =>
      (super.noSuchMethod(
        Invocation.method(
          #displayOpenPanel,
          [options],
        ),
        returnValue: _i3.Future<List<String?>>.value(<String?>[]),
      ) as _i3.Future<List<String?>>);

  @override
  _i3.Future<String?> displaySavePanel(_i4.SavePanelOptions? options) =>
      (super.noSuchMethod(
        Invocation.method(
          #displaySavePanel,
          [options],
        ),
        returnValue: _i3.Future<String?>.value(),
      ) as _i3.Future<String?>);
}
