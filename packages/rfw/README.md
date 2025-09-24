# Remote Flutter Widgets

This package provides a mechanism for rendering widgets based on
declarative UI descriptions that can be obtained at runtime.

## Status

This package is relatively stable.

We plan to keep the format and supported widget set backwards compatible,
so that once a file works, it will keep working. _However_, this is best-effort
only. To guarantee that files keep working as you expect, submit
tests to this package (e.g. the binary file and the corresponding screenshot,
as a golden test).

The set of widgets supported by this package is somewhat arbitrary.
PRs that add new widgets from Flutter's default widget libraries
(`widgets`, `material`, and`'cupertino`) are welcome.

There are some known theoretical performance limitations with the
package's current implementation, but so far nobody has reported
experiencing them in production. Please [file
issues](https://github.com/flutter/flutter/issues/new?labels=p:%20rfw,package,P2)
if you run into them.

## Feedback

We would love to hear your experiences using this package, whether
positive or negative. In particular, stories of uses of this package
in production would be very interesting. Please add comments to [issue
90218](https://github.com/flutter/flutter/issues/90218).

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

## Using Remote Flutter Widgets

### Introduction

The Remote Flutter Widgets (RFW) package combines widget descriptions
obtained at runtime, data obtained at runtime, some predefined widgets
provided at compile time, and some app logic provided at compile time
(possibly combined with other packages to enable new logic to be
obtained at runtime), to generate arbitrary widget trees at runtime.

The widget descriptions obtained at runtime (e.g. over the network)
are called _remote widget libraries_. These are normally transported
in a binary format with the file extension `.rfw`. They can be written
in a text format (file extension `.rfwtxt`), and either used directly
or converted into the binary format for transport. The `rfw` package
provides APIs for parsing and encoding these formats. The
[parts of the package](https://pub.dev/documentation/rfw/latest/formats/formats-library.html)
that only deal with these formats can be imported directly and have no
dependency on Flutter's `dart:ui` library, which means they can be
used on the server or in command-line applications.

The data obtained at runtime is known as _configuration data_ and is
represented by `DynamicContent` objects. It uses a data structure
similar to JSON (but it distinguishes `int` and `double` and does not
support `null`). The `rfw` package provides both binary and text
formats to carry this data; JSON can also be used directly (with some
caution), and the data can be created directly in Dart. This is
discussed in more detail in the
[DynamicContent](https://pub.dev/documentation/rfw/latest/rfw/DynamicContent-class.html)
API documentation.

Remote widget libraries can use the configuration data to define how
the widgets are built.

Remote widget libraries all eventually bottom out in the predefined
widgets that are compiled into the application. These are called
_local widget libraries_. The `rfw` package ships with two local
widget libraries, the [core
widgets](https://pub.dev/documentation/rfw/latest/rfw/createCoreWidgets.html)
from the `widgets` library (such as `Text`, `Center`, `Row`, etc), and
some of the [material
widgets](https://pub.dev/documentation/rfw/latest/rfw/createMaterialWidgets.html).

Programs can define their own local widget libraries, to provide more
widgets for remote widget libraries to use.

These components are combined using a
[`RemoteWidget`](https://pub.dev/documentation/rfw/latest/rfw/RemoteWidget-class.html)
widget and a
[`Runtime`](https://pub.dev/documentation/rfw/latest/rfw/Runtime-class.html)
object.

The remote widget libraries can specify _events_ that trigger in
response to callbacks. For example, the `OutlinedButton` widget
defined in the
[Material](https://pub.dev/documentation/rfw/latest/rfw/createMaterialWidgets.html)
local widget library has an `onPressed` property which the remote
widget library can define as triggering an event. Events can contain
data (either hardcoded or obtained from the configuration data).

These events result in a callback on the `RemoteWidget` being invoked.
Events can either have hardcoded results, or the `rfw` package can be
combined with other packages such as
[`wasm_run_flutter`](https://pub.dev/packages/wasm_run_flutter) so
that events trigger code obtained at runtime. That code typically
changes the configuration data, resulting in an update to the rendered
widgets.

_See also: [API documentation](https://pub.dev/documentation/rfw/latest/rfw/rfw-library.html)_

### Getting started

A Flutter application can render remote widgets using the
`RemoteWidget` widget, as in the following snippet:

<?code-excerpt "example/hello/lib/main.dart (Example)"?>
```dart
class Example extends StatefulWidget {
  const Example({super.key});

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

  static const LibraryName coreName = LibraryName(<String>['core', 'widgets']);
  static const LibraryName mainName = LibraryName(<String>['main']);

  @override
  void initState() {
    super.initState();
    // Local widget library:
    _runtime.update(coreName, createCoreWidgets());
    // Remote widget library:
    _runtime.update(mainName, _remoteWidgets);
    // Configuration data:
    _data.update('greet', <String, Object>{'name': 'World'});
  }

  @override
  Widget build(BuildContext context) {
    return RemoteWidget(
      runtime: _runtime,
      data: _data,
      widget: const FullyQualifiedWidgetName(mainName, 'root'),
      onEvent: (String name, DynamicMap arguments) {
        // The example above does not have any way to trigger events, but if it
        // did, they would result in this callback being invoked.
        debugPrint('user triggered event "$name" with data: $arguments');
      },
    );
  }
}

```

In this example, the "remote" widgets are hardcoded into the
application (`_remoteWidgets`), the configuration data is hardcoded
and unchanging (`_data`), and the event handler merely prints a
message to the console.

In typical usage, the remote widgets come from a server at runtime,
either through HTTP or some other network transport. Separately, the
`DynamicContent` data would be updated, either from the server or
based on local data.

Similarly, events that are signalled by the user's interactions with
the remote widgets (`RemoteWidget.onEvent`) would typically be sent to
the server for the server to update the data, or would cause the data
to be updated directly, on the user's device, according to some
predefined logic.

It is recommended that servers send binary data, decoded using
`decodeLibraryBlob` and `decodeDataBlob`, when providing updates for
the remote widget libraries and data.

### Applying these concepts to typical use cases

#### Message of the day, advertising, announcements

When `rfw` is used for displaying content that is largely static in
presentation and updated only occasionally, the simplest approach is
to encode everything into the remote widget library, download that to
the client, and render it, with only minimal data provided in the
configuration data (e.g. the user's dark mode preference, their
username, the current date or time) and with a few predefined events
(such as one to signal the message should be closed and another to
signal the user checking a "do not show this again" checkbox, or
similar).

#### Dynamic data editors

A more elaborate use case might involve remote widget libraries being
used to describe the UI for editing structured data in a database. In
this case, the data may be more important, containing the current data
being edited, and the events may signal to the application how to
update the data on the backend.

#### Search results

A general search engine could have dedicated remote widgets defined
for different kinds of results, allowing the data to be formatted and
made interactive in ways that are specific to the query and in ways
that could not have been predicted when the application was created.
For example, new kinds of search results for current events could be
created on the fly and sent to the client without needing to update
the client application.

### Developing new local widget libraries

A "local" widget library is one that describes the built-in widgets
that your "remote" widgets are built out of. The RFW package comes
with some preprepared libraries, available through
[createCoreWidgets](https://pub.dev/documentation/rfw/latest/rfw/createCoreWidgets.html)
and
[createMaterialWidgets](https://pub.dev/documentation/rfw/latest/rfw/createMaterialWidgets.html).
You can also create your own.

When developing new local widget libraries, it is convenient to hook
into the `reassemble` method to update the local widgets. That way,
changes can be seen in real time when hot reloading.

<?code-excerpt "example/local/lib/main.dart (Example)"?>
```dart
class Example extends StatefulWidget {
  const Example({super.key});

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
    // This function causes the Runtime to be updated any time the app is
    // hot reloaded, so that changes to _createLocalWidgets can be seen
    // during development. This function has no effect in production.
    super.reassemble();
    _update();
  }

  static WidgetLibrary _createLocalWidgets() {
    return LocalWidgetLibrary(<String, LocalWidgetBuilder>{
      'GreenBox': (BuildContext context, DataSource source) {
        return ColoredBox(
          color: const Color(0xFF002211),
          child: source.child(<Object>['child']),
        );
      },
      'Hello': (BuildContext context, DataSource source) {
        return Center(
          child: Text(
            'Hello, ${source.v<String>(<Object>["name"])}!',
            textDirection: TextDirection.ltr,
          ),
        );
      },
    });
  }

  static const LibraryName localName = LibraryName(<String>['local']);
  static const LibraryName remoteName = LibraryName(<String>['remote']);

  void _update() {
    _runtime.update(localName, _createLocalWidgets());
    // Normally we would obtain the remote widget library in binary form from a
    // server, and decode it with [decodeLibraryBlob] rather than parsing the
    // text version using [parseLibraryFile]. However, to make it easier to
    // play with this sample, this uses the slower text format.
    _runtime.update(
      remoteName,
      parseLibraryFile('''
      import local;
      widget root = GreenBox(
        child: Hello(name: "World"),
      );
    '''),
    );
  }

  @override
  Widget build(BuildContext context) {
    return RemoteWidget(
      runtime: _runtime,
      data: _data,
      widget: const FullyQualifiedWidgetName(remoteName, 'root'),
      onEvent: (String name, DynamicMap arguments) {
        debugPrint('user triggered event "$name" with data: $arguments');
      },
    );
  }
}

```

Widgets in local widget libraries are represented by closures that are
invoked by the runtime whenever a local widget is referenced.

The closure uses the
[LocalWidgetBuilder](https://pub.dev/documentation/rfw/latest/rfw/LocalWidgetBuilder.html)
signature. Like any builder in Flutter, it takes a
[`BuildContext`](https://api.flutter.dev/flutter/widgets/BuildContext-class.html),
which can be used to look up inherited widgets.

> For example, widgets that need the current text direction might
> defer to `Directionality.of(context)`, with the given `BuildContext`
> as the context argument.

The other argument is a [`DataSource`](https://pub.dev/documentation/rfw/latest/rfw/DataSource-class.html).
This gives access to the arguments that were provided to the widget in
the remote widget library.

For example, consider the example above, where the remote widget library is:

<?code-excerpt "test/readme_test.dart (root)"?>
```rfwtxt
import local;
widget root = GreenBox(
  child: Hello(name: "World"),
);
```

The `GreenBox` widget is invoked with one argument (`child`), and the
`Hello` widget is invoked with one argument (`name`).

In the definitions of `GreenBox` and `Hello`, the data source is used
to pull out these arguments.

### Obtaining arguments from the `DataSource`

The arguments are a tree of maps and lists with leaves that are Dart
scalar values (`int`, `double`, `bool`, or `String`), further widgets,
or event handlers.

#### Scalars

Here is an example of a more elaborate widget argument:

<?code-excerpt "test/readme_test.dart (fruit)"?>
```rfwtxt
widget fruit = Foo(
  bar: { quux: [ 'apple', 'banana', 'cherry' ] },
);
```

To obtain a scalar value from the arguments, the
[DataSource.v](https://pub.dev/documentation/rfw/latest/rfw/DataSource/v.html)
method is used. This method takes a list of keys (strings or integers)
that denote the path to scalar in question. For instance, to obtain
"cherry" from the example above, the keys would be `bar`, `quux`, and
2, as in:

<?code-excerpt "test/readme_test.dart (v)"?>
```dart
'Foo': (BuildContext context, DataSource source) {
  return Text(source.v<String>(<Object>['bar', 'quux', 2])!);
},
```

The `v` method is generic, with a type argument that specifies the
expected type (one of `int`, `double`, `bool`, or `String`). When the
value of the argument in the remote widget library does not match the
specified (or inferred) type given to `v`, or if the specified keys
don't lead to a value at all, it returns null instead.

#### Maps and lists

The `LocalWidgetBuilder` callback can inspect keys to see if they are
maps or lists before attempting to use them. For example, before
accessing a dozen fields from a map, one might use `isMap` to check if
the map is present at all. If it is not, then all the fields will be
null, and it is inefficient to fetch each one individually.

The
[`DataSource.isMap`](https://pub.dev/documentation/rfw/latest/rfw/DataSource/isMap.html)
method is takes a list of keys (like `v`) and reports if the key
identifies a map.

For example, in this case the `bar` argument can be treated either as
a map with a `name` subkey, or a scalar String:

<?code-excerpt "test/readme_test.dart (isMap)"?>
```dart
'Foo': (BuildContext context, DataSource source) {
  if (source.isMap(<Object>['bar'])) {
    return Text('${source.v<String>(<Object>['bar', 'name'])}', textDirection: TextDirection.ltr);
  }
  return Text('${source.v<String>(<Object>['bar'])}', textDirection: TextDirection.ltr);
},
```

Thus either of the following would have the same result:

<?code-excerpt "test/readme_test.dart (example1)"?>
```rfwtxt
widget example1 = GreenBox(
  child: Foo(
    bar: 'Jean',
  ),
);
```

<?code-excerpt "test/readme_test.dart (example2)"?>
```rfwtxt
widget example2 = GreenBox(
  child: Foo(
    bar: { name: 'Jean' },
  ),
);
```

The
[`DataSource.isList`](https://pub.dev/documentation/rfw/latest/rfw/DataSource/isList.html)
method is similar but reports on whether the specified key identifies a list:

<?code-excerpt "test/readme_test.dart (isList)"?>
```dart
'Foo': (BuildContext context, DataSource source) {
  if (source.isList(<Object>['bar', 'quux'])) {
    return Text('${source.v<String>(<Object>['bar', 'quux', 2])}', textDirection: TextDirection.ltr);
  }
  return Text('${source.v<String>(<Object>['baz'])}', textDirection: TextDirection.ltr);
},
```

For lists, a `LocalWidgetBuilder` callback can iterate over the items
in the list using the
[`length`](https://pub.dev/documentation/rfw/latest/rfw/DataSource/length.html)
method, which returns the length of the list (or zero if the key does
not identify a list):

<?code-excerpt "test/readme_test.dart (length)"?>
```dart
'Foo': (BuildContext context, DataSource source) {
  final int length = source.length(<Object>['text']);
  if (length > 0) {
    final StringBuffer text = StringBuffer();
    for (int index = 0; index < length; index += 1) {
      text.write(source.v<String>(<Object>['text', index]));
    }
    return Text(text.toString(), textDirection: TextDirection.ltr);
  }
  return const Text('<empty>', textDirection: TextDirection.ltr);
},
```

This could be used like this:

<?code-excerpt "test/readme_test.dart (example3)"?>
```rfwtxt
widget example3 = GreenBox(
  child: Foo(
    text: ['apple', 'banana']
  ),
);
```

#### Widgets

The `GreenBox` widget has a child widget, which is itself specified by
the remote widget. This is common, for example, `Row` and `Column`
widgets have children, `Center` has a child, and so on. Indeed, most
widgets have children, except for those like `Text`, `Image`, and
`Spacer`.

The `GreenBox` definition uses
[`DataSource.child`](https://pub.dev/documentation/rfw/latest/rfw/DataSource/child.html)
to obtain the widget, in a manner similar to the `v` method:

<?code-excerpt "test/readme_test.dart (child)"?>
```rfwtxt
'GreenBox': (BuildContext context, DataSource source) {
  return ColoredBox(color: const Color(0xFF002211), child: source.child(<Object>['child']));
},
```

Rather than returning `null` when the specified key points to an
argument that isn't a widget, the `child` method returns an
`ErrorWidget`. For cases where having `null` is acceptable, the
[`optionalChild`](https://pub.dev/documentation/rfw/latest/rfw/DataSource/optionalChild.html) method can be used:

<?code-excerpt "test/readme_test.dart (optionalChild)"?>
```rfwtxt
'GreenBox': (BuildContext context, DataSource source) {
  return ColoredBox(color: const Color(0xFF002211), child: source.optionalChild(<Object>['child']));
},
```

It returns `null` when the specified key does not point to a widget.

For widgets that take lists of children, the
[`childList`](https://pub.dev/documentation/rfw/latest/rfw/DataSource/childList.html)
method can be used. For example, this is how `Row` is defined in
`createCoreWidgets` (see in particular the `children` line):

<?code-excerpt "lib/src/flutter/core_widgets.dart (Row)"?>
```rfwtxt
'Row': (BuildContext context, DataSource source) {
  return Row(
    mainAxisAlignment: ArgumentDecoders.enumValue<MainAxisAlignment>(MainAxisAlignment.values, source, ['mainAxisAlignment']) ?? MainAxisAlignment.start,
    mainAxisSize: ArgumentDecoders.enumValue<MainAxisSize>(MainAxisSize.values, source, ['mainAxisSize']) ?? MainAxisSize.max,
    crossAxisAlignment: ArgumentDecoders.enumValue<CrossAxisAlignment>(CrossAxisAlignment.values, source, ['crossAxisAlignment']) ?? CrossAxisAlignment.center,
    textDirection: ArgumentDecoders.enumValue<TextDirection>(TextDirection.values, source, ['textDirection']),
    verticalDirection: ArgumentDecoders.enumValue<VerticalDirection>(VerticalDirection.values, source, ['verticalDirection']) ?? VerticalDirection.down,
    textBaseline: ArgumentDecoders.enumValue<TextBaseline>(TextBaseline.values, source, ['textBaseline']),
    children: source.childList(['children']),
  );
},
```

#### `ArgumentDecoders`

It is common to need to decode types that are more structured than
merely `int`, `double`, `bool`, or `String` scalars, for example,
enums, `Color`s, or `Paint`s.

The
[`ArgumentDecoders`](https://pub.dev/documentation/rfw/latest/rfw/ArgumentDecoders-class.html)
namespace offers some utility functions to make the decoding of such
values consistent.

For example, the `Row` definition above has some cases of enums. To
decode them, it uses the
[`ArgumentDecoders.enumValue`](https://pub.dev/documentation/rfw/latest/rfw/ArgumentDecoders/enumValue.html)
method.

#### Handlers

The last kind of argument that widgets can have is callbacks.

Since remote widget libraries are declarative and not code, they
cannot represent executable closures. Instead, they are represented as
events. For example:

<?code-excerpt "test/readme_test.dart (button7)"?>
```rfwtxt
CalculatorButton(label: "7", onPressed: event "digit" { arguments: [7] }),
```

This creates a `CalculatorButton` widget with two arguments, `label`,
a string, and `onPressed`, an event, whose name is "digit" and whose
arguments are a map with one key, "arguments", whose value is a list
with one value 7.

In that example, `CalculatorButton` is itself a remote widget that is
defined in terms of a `Button`, and the `onPressed` argument
is passed to the `onPressed` of the `Button`, like this:

<?code-excerpt "test/readme_test.dart (CalculatorButton)"?>
```rfwtxt
widget CalculatorButton = Padding(
  padding: [8.0],
  child: SizedBox(
    width: 100.0,
    height: 100.0,
    child: Button(
      child: FittedBox(child: Text(text: args.label)),
      onPressed: args.onPressed,
    ),
  ),
);
```

Subsequently, `Button` is defined in terms of a `GestureDetector`
local widget (which is defined in terms of the `GestureDetector`
widget from the Flutter framework), and the `args.onPressed` is passed
to the `onTap` argument of that `GestureDetector` local widget (and
from there subsequently to the Flutter framework widget).

When all is said and done, and the button is pressed, an event with
the name "digit" and the given arguments is reported to the
`RemoteWidget`'s `onEvent` callback. That callback takes two
arguments, the event name and the event arguments.

On the implementation side, in local widget libraries, arguments like
the `onTap` of the `GestureDetector` local widget must be turned into
a Dart closure that is passed to the actual Flutter widget called
`GestureDetector` as the value of its `onTap` callback.

The simplest kind of callback closure is a `VoidCallback` (no
arguments, no return value). To turn an `event` value in a local
widget's arguments in the local widget library into a `VoidCallback`
in Dart that reports the event as described above, the
`DataSource.voidHandler` method is used. For example, here is a
simplified `GestureDetector` local widget that just implements `onTap`
(when implementing similar local widgets, you may use a similar
technique):

<?code-excerpt "test/readme_test.dart (onTap)"?>
```dart
return <WidgetLibrary>[
  LocalWidgetLibrary(<String, LocalWidgetBuilder>{
    // The local widget is called `GestureDetector`...
    'GestureDetector': (BuildContext context, DataSource source) {
      // The local widget is implemented using the `GestureDetector`
      // widget from the Flutter framework.
      return GestureDetector(
        onTap: source.voidHandler(<Object>['onTap']),
        // A full implementation of a `GestureDetector` local widget
        // would have more arguments here, like `onTapDown`, etc.
        child: source.optionalChild(<Object>['child']),
      );
    },
  }),
];
```

Sometimes, a callback has a different signature, in particular, it may
provide arguments. To convert the `event` value into a Dart callback
closure that reports an event as described above, the
`DataSource.handler` method is used.

In addition to the list of keys that identify the `event` value, the
method itself takes a callback closure. That callback's purpose is to
convert the given `trigger` (a function which, when called, reports
the event) into the kind of callback closure the `Widget` expects.
This is usually written something like the following:

<?code-excerpt "test/readme_test.dart (onTapDown)"?>
```dart
return GestureDetector(
  onTapDown: source.handler(<Object>['onTapDown'], (HandlerTrigger trigger) => (TapDownDetails details) => trigger()),
  child: source.optionalChild(<Object>['child']),
);
```

To break this down more clearly:

<?code-excerpt "test/readme_test.dart (onTapDown-long)"?>
```dart
return GestureDetector(
  // onTapDown expects a function that takes a TapDownDetails
  onTapDown: source.handler<GestureTapDownCallback>( // this returns a function that takes a TapDownDetails
    <Object>['onTapDown'],
    (HandlerTrigger trigger) { // "trigger" is the function that will send the event to RemoteWidget.onEvent
      return (TapDownDetails details) { // this is the function that is returned by handler() above
        trigger(); // the function calls "trigger"
      };
    },
  ),
  child: source.optionalChild(<Object>['child']),
);
```

In some cases, the arguments sent to the callback (the
`TapDownDetails` in this case) are useful and should be passed to the
`RemoteWidget.onEvent` as part of its arguments. This can be done by
passing some values to the `trigger` method, as in:

<?code-excerpt "test/readme_test.dart (onTapDown-position)"?>
```dart
return GestureDetector(
  onTapDown: source.handler(<Object>['onTapDown'], (HandlerTrigger trigger) {
    return (TapDownDetails details) => trigger(<String, Object>{
      'x': details.globalPosition.dx,
      'y': details.globalPosition.dy,
    });
  }),
  child: source.optionalChild(<Object>['child']),
);
```

Any arguments in the `event` get merged with the arguments passed to
the trigger.

#### Animations

The `rfw` package introduces a new Flutter widget called
[`AnimationDefaults`](https://pub.dev/documentation/rfw/latest/rfw/AnimationDefaults-class.html).

This widget is exposed by `createCoreWidgets` under the same name, and
can be exposed in other local widget libraries as desired. This allows
remote widget libraries to configure the animation speed and curves of
entire subtrees more conveniently than repeating the details for each
widget.

To support this widget, implement curve arguments using
[`ArgumentDecoders.curve`](https://pub.dev/documentation/rfw/latest/rfw/ArgumentDecoders/curve.html)
and duration arguments using
[`ArgumentDecoders.duration`](https://pub.dev/documentation/rfw/latest/rfw/ArgumentDecoders/duration.html).
This automatically defers to the defaults provided by
`AnimationDefaults`. Alternatively, the
[`AnimationDefaults.curveOf`](https://pub.dev/documentation/rfw/latest/rfw/AnimationDefaults/curveOf.html)
and
[`AnimationDefaults.durationOf`](https://pub.dev/documentation/rfw/latest/rfw/AnimationDefaults/durationOf.html)
methods can be used with a `BuildContext` directly to get curve and
duration settings for animations.

The settings default to 200ms and the
[`Curves.fastOutSlowIn`](https://api.flutter.dev/flutter/animation/Curves/fastOutSlowIn-constant.html)
curve.


### Developing remote widget libraries

Remote widget libraries are usually defined using a Remote Flutter
Widgets text library file (`rfwtxt` extension), which is then compiled
into a binary library file (`rfw` extension) on the server before
being sent to the client.

The format of text library files is defined in detail in the API
documentation of the
[`parseLibraryFile`](https://pub.dev/documentation/rfw/latest/formats/parseLibraryFile.html)
function.

Compiling a text `rfwtxt` file to the binary `rfw` format can be done
by calling
[`encodeLibraryBlob`](https://pub.dev/documentation/rfw/latest/formats/encodeLibraryBlob.html)
on the results of calling `parseLibraryFile`.

The example in `example/remote` has some [elaborate remote
widgets](https://github.com/flutter/packages/blob/main/packages/rfw/example/remote/remote_widget_libraries/counter_app2.rfwtxt),
including some that manipulate state (`Button`).

#### State

The canonical example of a state-manipulating widget is a button.
Buttons must react immediately (in milliseconds) and cannot wait for
logic that's possibly running on a remote server (maybe many hundreds
of milliseconds away).

The aforementioned `Button` widget in the `remote_widget_libraries` example
tracks a local "down" state, manipulates it in reaction to
`onTapDown`/`onTapUp` events, and changes the shadow and margins of
the button based on its state:

<?code-excerpt "example/remote/remote_widget_libraries/counter_app2.rfwtxt (Button)"?>
```rfwtxt
widget Button { down: false } = GestureDetector(
  onTap: args.onPressed,
  onTapDown: set state.down = true,
  onTapUp: set state.down = false,
  onTapCancel: set state.down = false,
  child: Container(
    duration: 50,
    margin: switch state.down {
      false: [ 0.0, 0.0, 2.0, 2.0 ],
      true: [ 2.0, 2.0, 0.0, 0.0 ],
    },
    padding: [ 12.0, 8.0 ],
    decoration: {
      type: "shape",
      shape: {
        type: "stadium",
        side: { width: 1.0 },
      },
      gradient: {
        type: "linear",
        begin: { x: -0.5, y: -0.25 },
        end: { x: 0.0, y: 0.5 },
        colors: [ 0xFFFFFF99, 0xFFEEDD00 ],
        stops: [ 0.0, 1.0 ],
        tileMode: "mirror",
      },
      shadows: switch state.down {
        false: [ { blurRadius: 4.0, spreadRadius: 0.5, offset: { x: 1.0, y: 1.0, } } ],
        default: [],
      },
    },
    child: DefaultTextStyle(
      style: {
        color: 0xFF000000,
        fontSize: 32.0,
      },
      child: args.child,
    ),
  ),
);
```

Because `Container` is implemented in `createCoreWidgets` using the
`AnimatedContainer` widget, changing the fields causes the button to
animate. The `duration: 50` argument sets the animation speed to 50ms.

#### Lists

Let us consider a remote widget library that is used to render data in
this form:

<?code-excerpt "test/readme_test.dart (game-data)"?>
```json
{ "games": [
{"rating": 8.219, "users-rated": 16860, "name": "Twilight Struggle", "rank": 1, "link": "/boardgame/12333/twilight-struggle", "id": 12333},
{"rating": 8.093, "users-rated": 11750, "name": "Through the Ages: A Story of Civilization", "rank": 2, "link": "/boardgame/25613/through-ages-story-civilization", "id": 25613},
{"rating": 8.088, "users-rated": 34745, "name": "Agricola", "rank": 3, "link": "/boardgame/31260/agricola", "id": 31260},
{"rating": 8.082, "users-rated": 8913, "name": "Terra Mystica", "rank": 4, "link": "/boardgame/120677/terra-mystica", "id": 120677},
// ···
```

For the sake of this example, let us assume this data is registered
with the `DynamicContent` under the name `server`.

> This configuration data is both valid JSON and a valid RFW data file,
> which shows how similar the two syntaxes are.
>
> This data is parsed by calling
> [`parseDataFile`](https://pub.dev/documentation/rfw/latest/formats/parseDataFile.html),
> which turns it into
> [`DynamicMap`](https://pub.dev/documentation/rfw/latest/formats/DynamicMap.html).
> That object is then passed to a
> [`DynamicContent`](https://pub.dev/documentation/rfw/latest/rfw/DynamicContent-class.html),
> using
> [`DynamicContent.update`](https://pub.dev/documentation/rfw/latest/rfw/DynamicContent/update.html)
> (this is where the name `server` would be specified) which is passed
> to a
> [`RemoteWidget`](https://pub.dev/documentation/rfw/latest/rfw/RemoteWidget-class.html)
> via the
> [`data`](https://pub.dev/documentation/rfw/latest/rfw/RemoteWidget/data.html)
> property.
>
> Ideally, rather than dealing with this text form on the client, the
> data would be turned into a binary form using
> [`encodeDataBlob`](https://pub.dev/documentation/rfw/latest/formats/encodeDataBlob.html)
> on the server, and then parsed on the client using
> [`decodeDataBlob`](https://pub.dev/documentation/rfw/latest/formats/decodeDataBlob.html).

First, let's render a plain Flutter `ListView` with the name of each
product. The `Shop` widget below achieves this:

<?code-excerpt "test/readme_test.dart (Shop)"?>
```rfwtxt
import core;

widget Shop = ListView(
  children: [
    Text(text: "Products:"),
    ...for product in data.server.games:
      Product(product: product)
  ],
);

widget Product = Text(text: args.product.name, softWrap: false, overflow: "fade");
```

The `Product` widget here is not strictly necessary, it could be
inlined into the `Shop`. However, as with Flutter itself, it can be
easier to develop widgets when logically separate components are
separated into separate widgets.

We can elaborate on this example, introducing a Material `AppBar`,
using a `ListTile` for the list items, and making them interactive (at
least in principle; the logic in the app would need to know how to
handle the "shop.productSelect" event):

<?code-excerpt "test/readme_test.dart (MaterialShop)"?>
```rfwtxt
import core;
import material;

widget MaterialShop = Scaffold(
  appBar: AppBar(
    title: Text(text: ['Products']),
  ),
  body: ListView(
    children: [
      ...for product in data.server.games:
        Product(product: product)
    ],
  ),
);

widget Product = ListTile(
  title: Text(text: args.product.name),
  onTap: event 'shop.productSelect' { name: args.product.name, path: args.product.link },
);
```

### Fetching remote widget libraries remotely

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

### Integrating with scripting language runtimes

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

See [CONTRIBUTING.md](https://github.com/flutter/packages/blob/main/packages/rfw/CONTRIBUTING.md)
