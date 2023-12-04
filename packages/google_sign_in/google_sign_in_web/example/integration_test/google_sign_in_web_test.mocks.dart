// Mocks generated by Mockito 5.4.1 from annotations
// in google_sign_in_web_integration_tests/integration_test/google_sign_in_web_test.dart.
// Do not manually edit this file.

// @dart=2.19

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i4;

import 'package:google_sign_in_platform_interface/google_sign_in_platform_interface.dart'
    as _i2;
import 'package:google_sign_in_web/src/button_configuration.dart' as _i5;
import 'package:google_sign_in_web/src/gis_client.dart' as _i3;
import 'package:mockito/mockito.dart' as _i1;

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

class _FakeGoogleSignInTokenData_0 extends _i1.SmartFake
    implements _i2.GoogleSignInTokenData {
  _FakeGoogleSignInTokenData_0(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

/// A class which mocks [GisSdkClient].
///
/// See the documentation for Mockito's code generation for more information.
class MockGisSdkClient extends _i1.Mock implements _i3.GisSdkClient {
  @override
  _i4.Future<_i2.GoogleSignInUserData?> signInSilently() => (super.noSuchMethod(
        Invocation.method(
          #signInSilently,
          [],
        ),
        returnValue: _i4.Future<_i2.GoogleSignInUserData?>.value(),
        returnValueForMissingStub:
            _i4.Future<_i2.GoogleSignInUserData?>.value(),
      ) as _i4.Future<_i2.GoogleSignInUserData?>);

  @override
  _i4.Future<void> renderButton(
    Object? parent,
    _i5.GSIButtonConfiguration? options,
  ) =>
      (super.noSuchMethod(
        Invocation.method(
          #renderButton,
          [
            parent,
            options,
          ],
        ),
        returnValue: _i4.Future<void>.value(),
        returnValueForMissingStub: _i4.Future<void>.value(),
      ) as _i4.Future<void>);

  @override
  _i4.Future<String?> requestServerAuthCode() => (super.noSuchMethod(
        Invocation.method(
          #requestServerAuthCode,
          [],
        ),
        returnValue: _i4.Future<String?>.value(),
        returnValueForMissingStub: _i4.Future<String?>.value(),
      ) as _i4.Future<String?>);

  @override
  _i4.Future<_i2.GoogleSignInUserData?> signIn() => (super.noSuchMethod(
        Invocation.method(
          #signIn,
          [],
        ),
        returnValue: _i4.Future<_i2.GoogleSignInUserData?>.value(),
        returnValueForMissingStub:
            _i4.Future<_i2.GoogleSignInUserData?>.value(),
      ) as _i4.Future<_i2.GoogleSignInUserData?>);

  @override
  _i2.GoogleSignInTokenData getTokens() => (super.noSuchMethod(
        Invocation.method(
          #getTokens,
          [],
        ),
        returnValue: _FakeGoogleSignInTokenData_0(
          this,
          Invocation.method(
            #getTokens,
            [],
          ),
        ),
        returnValueForMissingStub: _FakeGoogleSignInTokenData_0(
          this,
          Invocation.method(
            #getTokens,
            [],
          ),
        ),
      ) as _i2.GoogleSignInTokenData);

  @override
  _i4.Future<void> signOut() => (super.noSuchMethod(
        Invocation.method(
          #signOut,
          [],
        ),
        returnValue: _i4.Future<void>.value(),
        returnValueForMissingStub: _i4.Future<void>.value(),
      ) as _i4.Future<void>);

  @override
  _i4.Future<void> disconnect() => (super.noSuchMethod(
        Invocation.method(
          #disconnect,
          [],
        ),
        returnValue: _i4.Future<void>.value(),
        returnValueForMissingStub: _i4.Future<void>.value(),
      ) as _i4.Future<void>);

  @override
  _i4.Future<bool> isSignedIn() => (super.noSuchMethod(
        Invocation.method(
          #isSignedIn,
          [],
        ),
        returnValue: _i4.Future<bool>.value(false),
        returnValueForMissingStub: _i4.Future<bool>.value(false),
      ) as _i4.Future<bool>);

  @override
  _i4.Future<void> clearAuthCache() => (super.noSuchMethod(
        Invocation.method(
          #clearAuthCache,
          [],
        ),
        returnValue: _i4.Future<void>.value(),
        returnValueForMissingStub: _i4.Future<void>.value(),
      ) as _i4.Future<void>);

  @override
  _i4.Future<bool> requestScopes(List<String>? scopes) => (super.noSuchMethod(
        Invocation.method(
          #requestScopes,
          [scopes],
        ),
        returnValue: _i4.Future<bool>.value(false),
        returnValueForMissingStub: _i4.Future<bool>.value(false),
      ) as _i4.Future<bool>);

  @override
  _i4.Future<bool> canAccessScopes(
    List<String>? scopes,
    String? accessToken,
  ) =>
      (super.noSuchMethod(
        Invocation.method(
          #canAccessScopes,
          [
            scopes,
            accessToken,
          ],
        ),
        returnValue: _i4.Future<bool>.value(false),
        returnValueForMissingStub: _i4.Future<bool>.value(false),
      ) as _i4.Future<bool>);
}
