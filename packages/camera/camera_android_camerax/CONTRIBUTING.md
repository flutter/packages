# Contributing to camera\_android\_camerax

## Plugin structure

The `camera_platform_interface` implementation is located at
`lib/src/android_camera_camerax.dart`, and it is implemented using Dart classes
that are wrapped versions of native Android Java classes.

In this approach, each native Android library used in the plugin implementation
is represented by an equivalent Dart class. Instances of these classes are
considered paired and represent each other in Java and Dart, respectively. An
`InstanceManager`, which is essentially a map between `long` identifiers and
objects that also provides notifications when an object has become unreachable
by memory. There is both a Dart and Java `InstanceManager` implementation, so
when a Dart instance is created that represens an Android native instance,
both are stored in the `InstanceManager` of their respective language with a
shared `long` identifier. These `InstanceManager`s take callbacks that run
when objects become unrechable or removed, allowing the Dart library to easily
handle removing references to native resources automatically. To ensure all
created instances are properly managed and to more easily allow for testing,
each wrapped Android native class in Dart takes an `InstanceManager` and has
a detached constructor, a constructor that allows for the creation of instances
not attached to the `InstanceManager` and unlinked to a paired Android native
instance.

In `lib/src/`, you will find all of the Dart-wrapped native Android classes that
the plugin currently uses in its implementation. As aforementioned, each of
these classes uses an `InstanceManager` (implementation in `instance_manager.dart`)
to manage objects that are created by the plugin implementation that map to objects
of the same type created in the native Android code. This plugin uses [`pigeon`][1]
to generate the communication layer between Flutter and native Android code, so each
of these Dart-wrapped classes may also have Host API and Flutter API implementations
that handle communication to the host native Android platform and from the host
native Android platform, respectively. The communication interface is defined in
the `pigeons/camerax_library.dart` file. After editing the communication interface,
regenerate the communication layer by running
`dart run pigeon --input pigeons/camerax_library.dart` from the plugin root.

In the native Java Android code in `android/src/main/java/io/flutter/plugins/camerax/`,
you'll find the Host API and Flutter API implementations of the same classes
wrapped with Dart in `lib/src/` that handle communication from that Dart code
and to that Dart code, respectively. The Host API implementations should directly
delegate calls to the CameraX or other wrapped Android libraries and should not
have any additional logic or abstraction; any exceptions should be thoroughly
documented in the code. As aforementioned, the objects created in the native
Android code map to objects created on the Dart side and are also managed by
an `InstanceManager` (implementation in `InstanceManager.java`).

If CameraX or other Android classes that you need to access do not have a
duplicately named implementation in `lib/src/`, then follow the same structure
described above to add them.

For more information, please see the [design document][2] or feel free
to ask any questions on the #hackers-ecosystem channel on [Discord][6]. For
more information on contributing packages in general, check out our
[contribution guide][3].

## Testing

While none of the generated `pigeon` files are tested, all plugin impelementation and
wrapped native Android classes (Java & Dart) are tested. You can find the Java tests under
`android/src/test/java/io/flutter/plugins/camerax/` and the Dart tests under `test/`. To
run these tests, please see the instructions in the [running plugin tests guide][5].

Besides [`pigeon`][1], this plugin also uses [`mockito`][4] to generate mock objects for
testing purposes. To generate the mock objects, run
`dart run build_runner build --delete-conflicting-outputs`.


[1]: https://pub.dev/packages/pigeon
[2]: https://docs.google.com/document/d/1wXB1zNzYhd2SxCu1_BK3qmNWRhonTB6qdv4erdtBQqo/edit?usp=sharing&resourcekey=0-WOBqqOKiO9SARnziBg28pg
[3]: https://github.com/flutter/packages/blob/main/CONTRIBUTING.md
[4]: https://pub.dev/packages/mockito
[5]: https://github.com/flutter/flutter/wiki/Plugin-Tests#running-tests
[6]: https://github.com/flutter/flutter/wiki/Chat