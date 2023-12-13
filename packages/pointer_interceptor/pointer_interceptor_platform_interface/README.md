# pointer_interceptor_platform_interface

A common platform interface for the [`pointer_interceptor`][1] plugin.

This interface allows platform-specific implementations of the `pointer_interceptor`
plugin, as well as the plugin itself, to ensure they are supporting the
same interface.

# Usage

To implement a new platform-specific implementation of `pointer_interceptor`, extend
[`PointerInterceptorPlatform`][2] with an implementation that performs the
platform-specific behavior, and when you register your plugin, set the default
`PointerInterceptorPlatform` by calling
`PointerInterceptorPlatform.instance = MyPointerInterceptorPlatform()`.

# Note on breaking changes

Strongly prefer non-breaking changes (such as adding a method to the interface)
over breaking changes for this package.

See https://flutter.dev/go/platform-interface-breaking-changes for a discussion
on why a less-clean interface is preferable to a breaking change.

[1]: https://pub.dev/packages/pointer_interceptor
[2]: lib/src/pointer_interceptor_platform.dart