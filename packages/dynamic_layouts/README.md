A package that provides two dynamic grid layouts: wrap and staggered.

## Features
This package provides support for multi sized tiles and different layouts.
Currently the layouts that are implemented in this package are `Stagger` and
`Wrap`.

The following are some demos of how each of the grids look.

A stagger grid demo:

<!-- TODO(snat-s): Add stagger video demo -->

A wrap demo:

<!-- TODO(snat-s): Add wrap video demo -->

### Stagger Features

`DynamicGridView` is a subclass of `GridView` and gives access
to the `SliverGridDelegate`s that are already implemented in the Flutter
Framework. Some `SliverGridDelegate`s are `SliverGridDelegateWithMaxCrossAxisExtent` and
`SliverGridDelegateWithFixedCrossAxisCount`. This layout can be used with
`DynamicGridView.stagger`.

### Wrap Features

The Wrap layout is able to do runs of different widgets and adapt accordingly with
the sizes of the children. It can leave spacing with `mainAxisSpacing` and
`crossAxisSpacing`.

Having different sizes in only one of the axis is possible by
changing the values of `childCrossAxisExtent` and `childMainAxisExtent`. These
values by default are set to have loose constraints, but by giving `childCrossAxisExtent` a specific value like
100 pixels, it will make all of the children 100 pixels in the main axis.
This layout can be used with `DynamicGridView.wrap` and with
`DynamicGridView.builder` and `SliverGridDelegateWithWrapping` as the delegate.

## Getting started

### Depend on it

Run this command with Flutter:
```sh
$ flutter pub add dynamic_layouts
```
### Import it

Now in your Dart code, you can use:

```sh
import 'package:dynamic_layouts/dynamic_layouts.dart';
```
## Usage

Use `DynamicGridView`s to access these layouts.
`DynamicGridView` has some constructors that use  `SliverChildListDelegate` like
`.wrap` and `.stagger`. For a more efficient option that uses `SliverChildBuilderDelegate` use
`.builder`, it works the same as `GridView.builder`.

### Wrap

The following are simple examples of how to use `DynamicGridView.wrap`.

The following example uses `DynamicGridView.builder` with
`SliverGridDelegateWithWrapping`.

By using `childCrossAxisExtent` and `childMainAxisExtent` the main axis
can be limited to have a specific size and the other can be set to loose
constraints.


### Stagger

The `Stagger` layout can be used with the constructor
`DynamicGridView.stagger` and still use the delegates from `GridView`
like `SliverGridDelegateWithMaxCrossAxisExtent` and
`SliverGridDelegateWithFixedCrossAxisCount`.

<!-- TODO(DavBot02): Add a code example of DynamicGrid.stagger -->

<!-- TODO(snat-s): Add a video of DynamicGrid.stagger -->

## Additional information

The staggered layout is similar to Android's [StaggeredGridLayoutManager](https://developer.android.com/reference/androidx/recyclerview/widget/StaggeredGridLayoutManager), while the wrap layout
emulates iOS' [UICollectionView](https://developer.apple.com/documentation/uikit/uicollectionview).

The inner functionality of this package is exposed, meaning that other dynamic layouts
can be created on top of it and added to the collection. If you want to contribute to
this package, you can open a pull request in [Flutter Packages](https://github.com/flutter/packages)
and add the tag "p: dynamic_layouts".
