# Remote Flutter Widgets

This package provides a mechanism for rendering widgets based on
declarative UI descriptions that can be obtained at runtime.

### Status

This package is experimental, in that it was created without a clear
idea of what problem it solves, in order to see if it was interesting
to people using Flutter and to learn more about the problem space.

There is currently no commitment to adding new features or fixing bugs,
though we will consider pull requests (please cc @Hixie). We might abandon
this package without prior notice.

We plan to keep the format and supported widget set backwards compatible,
so that once a file works, it will keep working. _However_, this is best-effort
only. To guarantee that files keep working as you expect, submit
tests to this package (e.g. the binary file and the corresponding screenshot,
as a golden test).

If you use this project, please describe your experiences, positive or negative, on
[issue 90218](https://github.com/flutter/flutter/issues/90218). This will help us
determine whether to spend more effort on this package, whether we should look at
creating other packages, and so forth.

## Getting started

A Flutter application can render remote widgets using the
`RemoteWidget` widget, as in the following snippet:

```dart
// see example/hello

class Example extends StatefulWidget {
  const Example({Key? key}) : super(key: key);

  @override
  State<Example> createState() => _ExampleState();
}

class _ExampleState extends State<Example> {
  final Runtime _runtime = Runtime();
  final DynamicContent _data = DynamicContent();

  // Normally this would be obtained dynamically, but for this example
  // we hard-code the "remote" widgets into the app.
  //
  // Also, normally we would decode this with [decodeLibraryBlob] rather than
  // parsing the text version using [parseLibraryFile]. However, to make it
  // easier to demo, this uses the slower text format.
  static final RemoteWidgetLibrary _remoteWidgets = parseLibraryFile('''
    // The "import" keyword is used to specify dependencies, in this case,
    // the built-in widgets that are added by initState below.
    import core.widgets;
    // The "widget" keyword is used to define a new widget constructor.
    // The "root" widget is specified as the one to render in the build
    // method below.
    widget root = Container(
      color: 0xFF002211,
      child: Center(
        child: Text(text: ["Hello, ", data.greet.name, "!"], textDirection: "ltr"),
      ),
    );
  ''');
  
  @override
  void initState() {
    super.initState();
    _runtime.update(const LibraryName(<String>['core', 'widgets']), createCoreWidgets());
    _runtime.update(const LibraryName(<String>['main']), _remoteWidgets);
    _data.update('greet', <String, Object>{ 'name': 'World' });
  }
  
  @override
  Widget build(BuildContext context) {
    return RemoteWidget(
      runtime: _runtime,
      data: _data,
      widget: const FullyQualifiedWidgetName(LibraryName(<String>['main']), 'root'),
      onEvent: (String name, DynamicMap arguments) {
        // The example above does not have any way to trigger events, but if it
        // did, they would result in this callback being invoked.
        debugPrint('user triggered event "$name" with data: $arguments');
      },
    );
  }
}
```

In this example, the "remote" widgets are hard-coded into the application.

## Usage

In typical usage, the remote widgets come from a server at runtime,
either through HTTP or some other network transport. Separately, the
`DynamicContent` data is updated, either from the server or based on
local data.

It is recommended that servers send binary data, decoded using
`decodeLibraryBlob` and `decodeDataBlob`, when providing updates for
the remote widget libraries and data.

Events (`onEvent`) are signalled by the user's interactions with the
remote widgets. The client is responsible for handling them, either by
sending the data to the server for the server to update the data, or
directly, on the user's device.

## Limitations

Once you realize that you can ship UI (and maybe logic, e.g. using
Wasm; see the example below) you will slowly be tempted to move your
whole application to this model.

This won't work.

Flutter proper lets you create widgets for compelling UIs with
gestures and animations and so forth. With RFW you can use those
widgets, but it doesn't let you _create_ those widgets.

For example, you don't want to use RFW to create a UI that involves
page transitions. You don't want to use RFW to create new widgets that
involve drag and drop. You don't want to use RFW to create widgets
that involve custom painters.

Rather, RFW is best suited for interfaces made out of prebuilt
components. For example, a database front-end could use this to
describe bespoke UIs for editing different types of objects in the
database. Message-of-the-day announcements could be built using this
mechanism. Search interfaces could use this mechanism for rich result
cards.

RFW is well-suited for describing custom UIs from a potentially
infinite set of UIs that could not possibly have been known when the
application was created. On the other hand, updating the application's
look and feel, changing how navigation works in an application, or
adding new features, are all changes that are best made in Flutter
itself, creating a new application and shipping that through normal
update channels.

## Developing new local widget libraries

A "local" widget library is one that describes the built-in widgets
that your "remote" widgets are built out of. The RFW package comes
with some preprepared libraries, available through [createCoreWidgets]
and [createMaterialWidgets]. You can also create your own.

When developing new local widget libraries, it is convenient to hook
into the `reassemble` method to update the local widgets. That way,
changes can be seen in real time when hot reloading.

```dart
// see example/local

class Example extends StatefulWidget {
  const Example({Key? key}) : super(key: key);

  @override
  State<Example> createState() => _ExampleState();
}

class _ExampleState extends State<Example> {
  final Runtime _runtime = Runtime();
  final DynamicContent _data = DynamicContent();
  
  @override
  void initState() {
    super.initState();
    _update();
  }

  @override
  void reassemble() {
    super.reassemble();
    _update();
  }

  static WidgetLibrary _createLocalWidgets() => LocalWidgetLibrary(<String, LocalWidgetBuilder>{
    'GreenBox': (BuildContext context, DataSource source) {
      return Container(color: const Color(0xFF002211), child: source.child(<Object>['child']));
    },
    'Hello': (BuildContext context, DataSource source) {
      return Center(child: Text('Hello, ${source.v<String>(<Object>["name"])}!', textDirection: TextDirection.ltr));
    },
  });


  void _update() {
    _runtime.update(const LibraryName(<String>['local']), _createLocalWidgets());
    _runtime.update(const LibraryName(<String>['remote']), parseLibraryFile('''
      import local;
      widget root = GreenBox(
        child: Hello(name: "World"),
      );
    '''));
  }

  @override
  Widget build(BuildContext context) {
    return RemoteWidget(
      runtime: _runtime,
      data: _data,
      widget: const FullyQualifiedWidgetName(LibraryName(<String>['remote']), 'root'),
      onEvent: (String name, DynamicMap arguments) {
        debugPrint('user triggered event "$name" with data: $arguments');
      },
    );
  }
}
```

## Fetching remote widget libraries remotely

The example in `example/remote` shows how a program could fetch
different user interfaces at runtime. In this example, the interface
used on startup is the one last cached locally. Each time the program
is run, after displaying the currently-cached interface, the
application fetches a new interface over the network, overwriting the
one in the cache, so that a different interface is used the next time
the app is run.

This example also shows how an application can implement custom local
code for events; in this case, incrementing a counter (both of the
"remote" widgets are just different ways of implementing a counter).

## Integrating with scripting language runtimes

The example in `example/wasm` shows how a program could fetch logic in
addition to UI, in this case using Wasm compiled from C (and let us
briefly appreciate the absurdity of using C as a scripting language
for an application written in Dart).

In this example, as written, the Dart client could support any
application whose data model consisted of a single integer and whose
logic could be expressed in C without external dependencies.

This example could be extended to have the C program export data in
the Remote Flutter Widgets binary data blob format which could be
parsed using `decodeDataBlob` and passed to `DynamicContent.update`
(thus allowing any structured data supported by RFW), and similarly
arguments could be passed to the Wasm code using the same format
(encoding using `encodeDataBlob`) to allow arbitrary structured data
to be communicated from the interface to the Wasm logic. In addition,
the Wasm logic could be provided with WASI interface bindings or with
custom bindings that expose platform capabilities (e.g. from Flutter
plugins), greatly extending the scope of what could be implemented in
the Wasm logic.

As of the time of writing, `package:wasm` does not support Android,
iOS, or web, so this demo is limited to desktop environments. The
underlying Wasmer runtime supports Android and iOS already, and
obviously Wasm in general is supported by web browsers, so it is
expected that these limitations are only temporary (modulo policy
concerns on iOS, anyway).

## Contributing

If you run into any problems, please file a [new bug](https://github.com/flutter/flutter/issues/new?labels=p:%20rfw,package,P4), though
as noted above, you may have to fix the issue yourself and submit a PR.
See our [contributing guide](https://github.com/flutter/packages/blob/master/CONTRIBUTING.md) for details.

Adding more widgets to `lib/flutter/core_widgets.dart` and `lib/flutter/material_widgets.dart` is welcome.

When contributing code, ensure that `flutter test --coverage; lcov
--list coverage/lcov.info` continues to show 100% test coverage, and
update `test_coverage/bin/test_coverage.dart` with the appropriate
expectations to prevent future coverage regressions. (That program is
run by `run_tests.sh`.)

Golden tests are only run against the Flutter master channel and only
run on Linux, since minor rendering differences are expected on
different platforms and on different versions of Flutter.