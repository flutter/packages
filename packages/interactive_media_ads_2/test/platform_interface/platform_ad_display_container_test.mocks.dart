// Mocks generated by Mockito 5.4.4 from annotations
// in interactive_media_ads/test/platform_interface/platform_ad_display_container_test.dart.
// Do not manually edit this file.

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:flutter/cupertino.dart' as _i5;
import 'package:interactive_media_ads/src/platform_interface/interactive_media_ads_platform.dart'
    as _i6;
import 'package:interactive_media_ads/src/platform_interface/platform_ad_display_container.dart'
    as _i4;
import 'package:interactive_media_ads/src/platform_interface/platform_ads_loader.dart'
    as _i2;
import 'package:interactive_media_ads/src/platform_interface/platform_ads_manager_delegate.dart'
    as _i3;
import 'package:mockito/mockito.dart' as _i1;
import 'package:mockito/src/dummies.dart' as _i7;

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

class _FakePlatformAdsLoader_0 extends _i1.SmartFake
    implements _i2.PlatformAdsLoader {
  _FakePlatformAdsLoader_0(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakePlatformAdsManagerDelegate_1 extends _i1.SmartFake
    implements _i3.PlatformAdsManagerDelegate {
  _FakePlatformAdsManagerDelegate_1(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakePlatformAdDisplayContainer_2 extends _i1.SmartFake
    implements _i4.PlatformAdDisplayContainer {
  _FakePlatformAdDisplayContainer_2(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeWidget_3 extends _i1.SmartFake implements _i5.Widget {
  _FakeWidget_3(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );

  @override
  String toString({_i5.DiagnosticLevel? minLevel = _i5.DiagnosticLevel.info}) =>
      super.toString();
}

/// A class which mocks [InteractiveMediaAdsPlatform].
///
/// See the documentation for Mockito's code generation for more information.
class MockInteractiveMediaAdsPlatform extends _i1.Mock
    implements _i6.InteractiveMediaAdsPlatform {
  MockInteractiveMediaAdsPlatform() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i2.PlatformAdsLoader createPlatformAdsLoader(
          _i2.PlatformAdsLoaderCreationParams? params) =>
      (super.noSuchMethod(
        Invocation.method(
          #createPlatformAdsLoader,
          [params],
        ),
        returnValue: _FakePlatformAdsLoader_0(
          this,
          Invocation.method(
            #createPlatformAdsLoader,
            [params],
          ),
        ),
      ) as _i2.PlatformAdsLoader);

  @override
  _i3.PlatformAdsManagerDelegate createPlatformAdsManagerDelegate(
          _i3.PlatformAdsManagerDelegateCreationParams? params) =>
      (super.noSuchMethod(
        Invocation.method(
          #createPlatformAdsManagerDelegate,
          [params],
        ),
        returnValue: _FakePlatformAdsManagerDelegate_1(
          this,
          Invocation.method(
            #createPlatformAdsManagerDelegate,
            [params],
          ),
        ),
      ) as _i3.PlatformAdsManagerDelegate);

  @override
  _i4.PlatformAdDisplayContainer createPlatformAdDisplayContainer(
          _i4.PlatformAdDisplayContainerCreationParams? params) =>
      (super.noSuchMethod(
        Invocation.method(
          #createPlatformAdDisplayContainer,
          [params],
        ),
        returnValue: _FakePlatformAdDisplayContainer_2(
          this,
          Invocation.method(
            #createPlatformAdDisplayContainer,
            [params],
          ),
        ),
      ) as _i4.PlatformAdDisplayContainer);
}

/// A class which mocks [PlatformAdDisplayContainer].
///
/// See the documentation for Mockito's code generation for more information.
class MockPlatformAdDisplayContainer extends _i1.Mock
    implements _i4.PlatformAdDisplayContainer {
  MockPlatformAdDisplayContainer() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i4.PlatformAdDisplayContainerCreationParams get params =>
      (super.noSuchMethod(
        Invocation.getter(#params),
        returnValue:
            _i7.dummyValue<_i4.PlatformAdDisplayContainerCreationParams>(
          this,
          Invocation.getter(#params),
        ),
      ) as _i4.PlatformAdDisplayContainerCreationParams);

  @override
  _i5.Widget build(_i5.BuildContext? context) => (super.noSuchMethod(
        Invocation.method(
          #build,
          [context],
        ),
        returnValue: _FakeWidget_3(
          this,
          Invocation.method(
            #build,
            [context],
          ),
        ),
      ) as _i5.Widget);
}
