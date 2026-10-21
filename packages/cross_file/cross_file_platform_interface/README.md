# cross_file_platform_interface

A common platform interface for the [`cross_file`](https://pub.dev/packages/cross_file) plugin.

This interface allows platform implementations of the `cross_file` plugin, as well as the plugin
itself, to ensure they are supporting the same interface.

# Usage

To implement a new platform implementation of `cross_file`, extend
[`CrossFilePlatform`](lib/src/cross_file_platform.dart) with an implementation that performs the
platform-specific behavior, and when you register your plugin, set the default
`CrossFilePlatform` by calling `CrossFilePlatform.instance = CrossFileMyPlatform()`.

# Note on breaking changes

Strongly prefer non-breaking changes (such as adding a method to the interface)
over breaking changes for this package.

See https://flutter.dev/go/platform-interface-breaking-changes for a discussion on why a less-clean
interface is preferable to a breaking change.
