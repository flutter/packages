// Mocks generated by Mockito 5.4.2 from annotations
// in url_launcher_ios/test/url_launcher_ios_test.dart.
// Do not manually edit this file.

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i3;

import 'package:mockito/mockito.dart' as _i1;
import 'package:url_launcher_ios/src/messages.g.dart' as _i2;

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

/// A class which mocks [UrlLauncherApi].
///
/// See the documentation for Mockito's code generation for more information.
class MockUrlLauncherApi extends _i1.Mock implements _i2.UrlLauncherApi {
  MockUrlLauncherApi() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i3.Future<_i2.LaunchResult> canLaunchUrl(String? arg_url) =>
      (super.noSuchMethod(
        Invocation.method(
          #canLaunchUrl,
          [arg_url],
        ),
        returnValue:
            _i3.Future<_i2.LaunchResult>.value(_i2.LaunchResult.success),
      ) as _i3.Future<_i2.LaunchResult>);

  @override
  _i3.Future<_i2.LaunchResult> launchUrl(
    String? arg_url,
    bool? arg_universalLinksOnly,
  ) =>
      (super.noSuchMethod(
        Invocation.method(
          #launchUrl,
          [
            arg_url,
            arg_universalLinksOnly,
          ],
        ),
        returnValue:
            _i3.Future<_i2.LaunchResult>.value(_i2.LaunchResult.success),
      ) as _i3.Future<_i2.LaunchResult>);

  @override
  _i3.Future<_i2.LaunchResult> openUrlInSafariViewController(String? arg_url) =>
      (super.noSuchMethod(
        Invocation.method(
          #openUrlInSafariViewController,
          [arg_url],
        ),
        returnValue:
            _i3.Future<_i2.LaunchResult>.value(_i2.LaunchResult.success),
      ) as _i3.Future<_i2.LaunchResult>);

  @override
  _i3.Future<void> closeSafariViewController() => (super.noSuchMethod(
        Invocation.method(
          #closeSafariViewController,
          [],
        ),
        returnValue: _i3.Future<void>.value(),
        returnValueForMissingStub: _i3.Future<void>.value(),
      ) as _i3.Future<void>);
}
