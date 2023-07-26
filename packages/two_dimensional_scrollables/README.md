# Two Dimensional Scrollables

A package that provides widgets that scroll in two dimensions, built on the
two-dimensional foundation of the Flutter framework.

## Features

This package provides support for a TableView widget that scrolls in both the
vertical and horizontal axes.

### TableView

`TableView` is a subclass of `TwoDimensionalScrollView`, building its provided
children lazily in a `TwoDimensionalViewport`. This widget can

- Scroll diagonally, or lock axes
- Apply decorations to rows and columns
- Handle gestures & custom pointers for rows and columns
- Pin rows and columns

## Getting started

### Depend on it

Run this command with Flutter:

```sh
$ flutter pub add two_dimensional_scrollables
```

### Import it

Now in your Dart code, you can use:

```sh
import 'package:two_dimensional_scrollables/two_dimensional_scrollables.dart';
```

## Usage

### TableView

The code in `example/` shows a `TableView` of initially 400 cells, each varying
in sizes with a few `TableSpanDecoration`s like background colors and borders. The
`builder` constructor is called on demand for the cells that are visible in the
TableView. Additional rows can be added on demand while the vertical position
can jump between the first and last row using the buttons at the bottom of the
screen.

## Changelog

See the
[Changelog](https://github.com/flutter/packages/blob/main/packages/two_dimensional_scrollables/CHANGELOG.md)
for a list of new features and breaking changes.

## Roadmap

See the [GitHub project](https://github.com/orgs/flutter/projects/32/) for a
prioritized list of feature requests and known issues.

## Additional information

The package uses the two-dimensional foundation from the Flutter framework,
meaning most of the core functionality of 2D scrolling is not implemented here.
This also means any subclass of the foundation can create different 2D scrolling
widgets and be added to the collection. If you want to contribute to
this package, you can open a pull request in [Flutter Packages](https://github.com/flutter/packages)
and add the tag "p: two_dimensional_scrollables".
