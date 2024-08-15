# Contributing to `interactive_media_ads`

## Package Structure

The structure of this plugin is similar to a [federated plugin](https://docs.flutter.dev/packages-and-plugins/developing-packages#federated-plugins),
except the code for each package (platform interface, platform implementations, and app-facing
interface) are  maintained in this one plugin. The sections below will overview how this plugin
implements each portion.

If you are familiar with [changing federated plugin](https://github.com/flutter/flutter/blob/master/docs/ecosystem/contributing/README.md#changing-federated-plugins)
in the `flutter/packages`, the process is similar except that all changes are made in this plugin.

### Platform Interface

Code location: `lib/src/platform_interface`.

Should note that the main philosophy is to make testing easy and to minimize breaking changes.



This portion declares an interface that each platform must implement to support the
app-facing interface. The central [InteractiveMediaAdsPlatform](lib/src/platform_interface/interactive_media_ads_platform.dart)
class.

Classes can be split into two kinds:

* Classes instantiated by the central platform class
* Classes that are not instantiated by the central classes
  * These are classes that are returned by the SDK (e.g. `AdsManager`). Are data classes.
  * 

### Platform Implementations

Code found in:
* Android: `lib/src/android`
* iOS: `lib/srcios`

This uses `pigeon` to wrap.

### App-facing Interface

Code location: `lib/src`.

Philosophy to create an api that follows the structure of the underlying SDKs

## Recommended Process for Adding a New Feature

* Create an issue that includes the specific native classes/methods that this feature requires on
each platform.

* provide where this could be included in the platform interface and app-facing interface 