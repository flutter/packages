# Two Dimensional Scrollables

A package that provides widgets that scroll in two dimensions, built on the
two-dimensional foundation of the Flutter framework.

## Features

This package provides support for TableView and TreeView widgets that scroll
in both the vertical and horizontal axes.

### TableView

`TableView` is a subclass of `TwoDimensionalScrollView`, building its provided
children lazily in a `TwoDimensionalViewport`. This widget can

- Scroll diagonally, or lock axes
- Build infinite rows and columns
- Apply decorations to rows and columns
- Handle gestures & custom pointers for rows and columns
- Pin rows and columns
- Merge table cells

### TreeView

`TreeView` is a subclass of `TwoDimensionalScrollView`, building its provided
children lazily in a `TwoDimensionalViewport`. This widget can

- Scroll diagonally, or lock axes
- Apply decorations to tree rows
- Handle gestures & custom pointers for tree rows
- Animate TreeViewNodes in and out of view

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

The code in `example/lib/table_view` has three `TableView` samples, each
showcasing different features. The `TableExample` demonstrates adding and
removing rows from the table, and applying `TableSpanDecoration`s. The
`MergedTableExample` demonstrates pinned and merged `TableViewCell`s.
Lastly, the `InfiniteTableExample` demonstrates an infinite `TableView`.

### TreeView

The code in `example/lib/tree_view` has two `TreeView` samples, each
showcasing different features. The `TreeExample` demonstrates most of
the default builders and animations. The `CustomTreeExample` demonstrates
a highly customized tree, utilizing `TreeView.treeNodeBuilder`,
`TreeView.treeRowBuilder` and `TreeView.onNodeToggle`.

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
