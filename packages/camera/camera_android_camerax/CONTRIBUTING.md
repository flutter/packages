# Contributing to camera\_android\_camerax

## Note on the plugin structure

The `camera_platform_interface` implementation is located at
`lib/src/android_camera_camerax.dart`, and it is implemented using Dart classes that
are wrapped versions of native Android Java classes.

In `lib/src/`, you will find all of the Dart-wrapped native classes that the plugin
currently uses in its implementation. Each of these classes uses an `InstanceManager`
(implementation in `instance_manager.dart`) to manage objects that are created by
the plugin implementation that map to objects of the same type created on the native
side. This plugin uses [`pigeon`][1] to generate the communication layer between Flutter
and native Android code, so each of these Dart-wrapped classes also have Host API and
Flutter API implementations, as needed. The communication interface is defined in
the `pigeons/camerax_library.dart` file. After editing the communication interface,
regenerate the communication layer by running
`dart run pigeon --input pigeons/camerax_library.dart` from the plugin root.

On the native side in `android/src/main/java/io/flutter/plugins/camerax/`, you'll
find the Host API and Flutter API implementations of the same classes wrapped with
Dart in `lib/src/`. These implementations call directly to the classes that they 
are wrapping in the CameraX library or other Android libraries. The objects created
in the native code map to objects created on the Dart side, and thus, are also
managed by an `InstanceManager` (implementation in `InstanceManager.java`).

If you need to access any Android classes to contribute to this plugin, you should
search in `lib/src/` for any Dart-wrapped classes you may need. If any classes that
you need are not wrapped or you need to access any methods not wrapped in a class,
you must take the additional steps to wrap them to maintain the structure of this plugin.

For more information on the approach of wrapping native libraries For plugins, please
see the [design document][2]. For more information on contributing packages in general,
check out our [contribution guide][3].

## Note on testing

Besides [`pigeon`][1], this plugin also uses [`mockito`][4] to generate mock objects for
testing purposes. To generate the mock objects, run
`dart run build_runner build --delete-conflicting-outputs`.


[1]: https://pub.dev/packages/pigeon
[2]: https://docs.google.com/document/d/1wXB1zNzYhd2SxCu1_BK3qmNWRhonTB6qdv4erdtBQqo/edit?usp=sharing&resourcekey=0-WOBqqOKiO9SARnziBg28pg
[3]: https://github.com/flutter/packages/blob/main/CONTRIBUTING.md
[4]: https://pub.dev/packages/mockito
