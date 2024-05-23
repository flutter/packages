// Mocks generated by Mockito 5.4.4 from annotations
// in shared_preferences_tool/test/test_helpers/notifier_mocking_helpers.dart.
// Do not manually edit this file.

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i6;
import 'dart:ui' as _i7;

import 'package:mockito/mockito.dart' as _i1;
import 'package:mockito/src/dummies.dart' as _i5;
import 'package:shared_preferences_tool/src/async_state.dart' as _i3;
import 'package:shared_preferences_tool/src/shared_preferences_state.dart'
    as _i4;
import 'package:shared_preferences_tool/src/shared_preferences_state_notifier.dart'
    as _i2;

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

/// A class which mocks [SharedPreferencesStateNotifier].
///
/// See the documentation for Mockito's code generation for more information.
class MockSharedPreferencesStateNotifier extends _i1.Mock
    implements _i2.SharedPreferencesStateNotifier {
  @override
  _i3.AsyncState<_i4.SharedPreferencesState> get value => (super.noSuchMethod(
        Invocation.getter(#value),
        returnValue: _i5.dummyValue<_i3.AsyncState<_i4.SharedPreferencesState>>(
          this,
          Invocation.getter(#value),
        ),
        returnValueForMissingStub:
            _i5.dummyValue<_i3.AsyncState<_i4.SharedPreferencesState>>(
          this,
          Invocation.getter(#value),
        ),
      ) as _i3.AsyncState<_i4.SharedPreferencesState>);

  @override
  set value(_i3.AsyncState<_i4.SharedPreferencesState>? newValue) =>
      super.noSuchMethod(
        Invocation.setter(
          #value,
          newValue,
        ),
        returnValueForMissingStub: null,
      );

  @override
  bool get hasListeners => (super.noSuchMethod(
        Invocation.getter(#hasListeners),
        returnValue: false,
        returnValueForMissingStub: false,
      ) as bool);

  @override
  _i6.Future<void> fetchAllKeys() => (super.noSuchMethod(
        Invocation.method(
          #fetchAllKeys,
          [],
        ),
        returnValue: _i6.Future<void>.value(),
        returnValueForMissingStub: _i6.Future<void>.value(),
      ) as _i6.Future<void>);

  @override
  _i6.Future<void> selectKey(String? key) => (super.noSuchMethod(
        Invocation.method(
          #selectKey,
          [key],
        ),
        returnValue: _i6.Future<void>.value(),
        returnValueForMissingStub: _i6.Future<void>.value(),
      ) as _i6.Future<void>);

  @override
  void filter(String? token) => super.noSuchMethod(
        Invocation.method(
          #filter,
          [token],
        ),
        returnValueForMissingStub: null,
      );

  @override
  _i6.Future<void> changeValue(
    String? key,
    _i4.SharedPreferencesData? newValue,
  ) =>
      (super.noSuchMethod(
        Invocation.method(
          #changeValue,
          [
            key,
            newValue,
          ],
        ),
        returnValue: _i6.Future<void>.value(),
        returnValueForMissingStub: _i6.Future<void>.value(),
      ) as _i6.Future<void>);

  @override
  _i6.Future<void> deleteKey(String? selectedKey) => (super.noSuchMethod(
        Invocation.method(
          #deleteKey,
          [selectedKey],
        ),
        returnValue: _i6.Future<void>.value(),
        returnValueForMissingStub: _i6.Future<void>.value(),
      ) as _i6.Future<void>);

  @override
  void startEditing() => super.noSuchMethod(
        Invocation.method(
          #startEditing,
          [],
        ),
        returnValueForMissingStub: null,
      );

  @override
  void stopEditing() => super.noSuchMethod(
        Invocation.method(
          #stopEditing,
          [],
        ),
        returnValueForMissingStub: null,
      );

  @override
  void addListener(_i7.VoidCallback? listener) => super.noSuchMethod(
        Invocation.method(
          #addListener,
          [listener],
        ),
        returnValueForMissingStub: null,
      );

  @override
  void removeListener(_i7.VoidCallback? listener) => super.noSuchMethod(
        Invocation.method(
          #removeListener,
          [listener],
        ),
        returnValueForMissingStub: null,
      );

  @override
  void dispose() => super.noSuchMethod(
        Invocation.method(
          #dispose,
          [],
        ),
        returnValueForMissingStub: null,
      );

  @override
  void notifyListeners() => super.noSuchMethod(
        Invocation.method(
          #notifyListeners,
          [],
        ),
        returnValueForMissingStub: null,
      );
}
