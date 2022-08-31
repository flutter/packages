<!--
TODO(DavBot02 & snat-s):

This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/guides/libraries/writing-package-pages).

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-library-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/developing-packages).
-->

<!-- TODO(DavBot02): Put a short description of the package here that helps potential users
know whether this package might be useful for them.-->

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

<!-- TODO(DavBot02): List prerequisites and provide or point to information on how to start using the package. -->

## Usage

Use `DynamicGridView`s to access this layouts.
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

<!-- TODO(DavBot02): Tell users more about the package: where to find more information, how to
contribute to the package, how to file issues, what response they can expect
from the package authors, and more. -->
