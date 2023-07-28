# plugin_platform_interface

This package provides a base class for platform interfaces of [federated flutter plugins](https://flutter.dev/go/federated-plugins).

Platform implementations should `extends` their platform interface class rather than `implement`s it, as
newly added methods to platform interfaces are not considered breaking changes. Extending a platform
interface ensures that subclasses will get the default implementations from the base class, while
platform implementations that `implements` their platform interface will be broken by newly added methods.

This class package provides common functionality for platform interface to enforce that they are extended
and not implemented.

## Sample usage:

<?code-excerpt "test/plugin_platform_interface_test.dart (Example)"?>
```dart
abstract class SamplePluginPlatform extends PlatformInterface {
  SamplePluginPlatform() : super(token: _token);

  static final Object _token = Object();

  // A plugin can have a default implementation, as shown here, or `instance`
  // can be nullable, and the default instance can be null.
  static SamplePluginPlatform _instance = SamplePluginDefault();

  static SamplePluginPlatform get instance => _instance;

  /// Platform-specific implementations should set this to their own
  /// platform-specific class that extends [SamplePluginPlatform] when they
  /// register themselves.
  static set instance(SamplePluginPlatform instance) {
    PlatformInterface.verify(instance, _token);
    _instance = instance;
  }

  // Methods for the plugin's platform interface would go here, often with
  // implementations that throw UnimplementedError.
}

class SamplePluginDefault extends SamplePluginPlatform {
  // A default real implementation of the platform interface would go here.
}
```

This guarantees that UrlLauncherPlatform.instance cannot be set to an object that `implements`
UrlLauncherPlatform (it can only be set to an object that `extends` UrlLauncherPlatform).

## Mocking or faking platform interfaces


Test implementations of platform interfaces, such as those using `mockito`'s
`Mock` or `test`'s `Fake`, will fail the verification done by `verify`.
This package provides a `MockPlatformInterfaceMixin` which can be used in test
code only to disable the `extends` enforcement.

For example, a Mockito mock of a platform interface can be created with:

<?code-excerpt "test/plugin_platform_interface_test.dart (Mock)"?>
```dart
class SamplePluginPlatformMock extends Mock
    with MockPlatformInterfaceMixin
    implements SamplePluginPlatform {}
```

## A note about `base`

In Dart 3, [the `base` keyword](https://dart.dev/language/class-modifiers#base)
was introduced to the language, which enforces that subclasses use `extends`
rather than `implements` at compile time. The Flutter team is
[considering deprecating this package in favor of using
`base`](https://github.com/flutter/flutter/issues/127396) for platfom interfaces,
but no decision has been made yet since it removes the ability to do mocking/faking
as shown above.

Plugin authors may want to consider using `base` instead of this package when
creating new plugins.

https://github.com/flutter/flutter/issues/127396
