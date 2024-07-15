# shared_preferences_platform_interface

A common platform interface for the [`shared_preferences`][1] plugins.

This interface allows platform-specific implementations of the `shared_preferences`
plugin, as well as the plugin itself, to ensure they are supporting the
same interface.

# Usage

To implement a new platform-specific implementation of `shared_preferences`, 
extend [`SharedPreferencesPlatform`][2] with an implementation that performs 
the platform-specific behavior, and when you register your plugin, set the default
`SharedPreferencesStorePlatform` by calling the `SharedPreferencesPlatform.instance` setter.

To implement a new platform-specific implementation of `shared_preferences_async`, 
extend [`SharedPreferencesAsyncPlatform`][3] with an implementation that performs 
the platform-specific behavior, and when you register your plugin, set the default
`SharedPreferencesAsyncPlatform` by calling the `SharedPreferencesAsyncPlatform.instance` setter.

Please note that the current tooling for platform communication only registers `SharedPreferencesPlugin`
so if you intend to implement more than one plugin (as can be seen in the Android and iOS implementations)
you will need to manually register the second plugin.

# Note on breaking changes

Strongly prefer non-breaking changes (such as adding a method to the interface)
over breaking changes for this package.

See https://flutter.dev/go/platform-interface-breaking-changes for a discussion
on why a less-clean interface is preferable to a breaking change.

[1]: ../shared_preferences
[2]: lib/shared_preferences_platform_interface.dart
[3]: lib/shared_preferences_async_platform_interface.dart