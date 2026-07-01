# cupertino_ui API Example Code
This directory contains the example code that is referenced in the documentation
in cupertino_ui's source code.

These examples were originally located [in
flutter/flutter](https://github.com/flutter/flutter/tree/master/examples/api)
before the Cupertino library was decoupled and moved into its current home in
flutter/packages.

The examples can be run individually by just specifying the path to the example
on the command line (or in the run configuration of an IDE).

For example (no pun intended!), to run the first example from the
`CupertinoActivityIndicator` class in Chrome, you would run it like so from the
[example](.) directory:

```sh
% flutter run -d chrome lib/activity_indicator/cupertino_activity_indicator.0.dart
```

All of these same examples are available on the API docs site.

<!-- TODO(justinmc): Include a link to the docs page with the example above like this: For instance, the example above is available on [this page](https://api.flutter.dev/flutter/animation/Curve2D-class.html#animation.Curve2D.1).
-->

## Naming

> `lib/file/class_name.n.dart`
>
> `lib/file/class_name.member_name.n.dart`

The naming scheme corresponds to the files under [lib/src](../lib/src) where
each file is represented as a directory (without the `.dart` suffix), and each
sample in the file is a separate file in that directory. So, for the example
above, where the examples are from the
[lib/src/activity_indicator.dart](../lib/src/activity_indicator.dart) file, the
`CupertinoActivityIndicator` class, the first sample (hence the index "0") for
that symbol resides in the file named
[lib/activity_indicator/cupertino_activity_indicator.0.dart](lib/activity_indicator/cupertino_activity_indicator.0.dart).

Symbol names are converted from "CamelCase" to "snake_case". Dots are left
between symbol names, so the first example for symbol
`InputDecoration.prefixIconConstraints` would be converted to
`input_decoration.prefix_icon_constraints.0.dart`.

If the same example is linked to from multiple symbols, the source will be in
the canonical location for one of the symbols, and the link in the API docs
block for the other symbols will point to the first symbol's example location.

## Authoring

When authoring examples, first place a block in the Dartdoc documentation for
the symbol you would like to attach it to. Here's what it might look like if you
wanted to add a new example to the `CupertinoActivityIndicator` class:

```dart
/// {@example /example/lib/activity_indicator/cupertino_activity_indicator.0.dart}
/// Write a description of the example here. This description will appear in the
/// API web documentation to introduce the example.
/// {@end-example}
```

The path parameter is from the root of the package when beginning with `/`,
otherwise it is relative to the current file.

Once that comment block is inserted in the source code, create a new file at the
appropriate path under [`example/lib`](./lib). See all of the existing examples
in that directory for different types of examples with some best practices
applied.

The filename should match the location of the source file it is linked from, and
is named for the symbol it is attached to, in lower_snake_case, with an index
relating to their order within the doc comment. So, for the
`CupertinoActivityIndicator` example above, since it's in a file called
`activity_indicator.dart`, and it's the first example, it should have the name
`example/lib/activity_indicator/cupertino_activity_indicator.0.dart`.

You should also add tests for your example code under [`example/test`](./test),
that matches their location under [lib](./lib), ending in `_test.dart`. See the
section on [writing tests](#writing-tests) for more information on what kinds of
tests to write.

The entire example should be in a single file.

Only packages that can be loaded by Dartpad may be imported. If you use one that
hasn't been used in an example before, you may have to add it to the
[pubspec.yaml](pubspec.yaml) in the [example](./) directory.

## Writing Tests

Examples are required to have tests. There is already a "smoke test" that simply
builds and runs all the API examples, just to make sure that they start up
without crashing. Test coverage is required for examples, but should take care
not to complicate the example strictly for the purpose of testing.

As an example, in regular framework code, you might include a parameter for a
`Platform` object that can be overridden by a test to supply a dummy platform,
but in the example. This would be unnecessarily complex for the example. In all
other ways, these are just normal tests. You don't need to re-test the
functionality of the widget being used in the example, but you should test the
functionality and integrity of the example itself.

Tests go into a directory under [test](./test) that matches their location under
[lib](./lib). They are named the same as the example they are testing, with
`_test.dart` at the end, like other tests. For instance, an
`CupertinoActivityIndicator` example that resides in
[`lib/activity_indicator/cupertino_activity_indicator.0.dart`]( ./lib/activity_indicator/cupertino_activity_indicator.0.dart) would
have its tests in a file named
[`test/activity_indicator/cupertino_activity_indicator.0_test.dart`](
./test/activity_indicator/cupertino_activity_indicator.0_test.dart)
