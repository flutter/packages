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

TODO(DavBot02): Put a short description of the package here that helps potential users
know whether this package might be useful for them.

## Features

TODO(snat-s): List what your package can do. Maybe include images, gifs, or videos.
This package provides support for multi sized tiles and different layouts.
Currently the layouts that are implemented in this package are `Staggered` and
`Wrap`.

You can have reversed and with horizontal Grids with this layouts.

The following are some demos of how each of the grids look.

A staggered grid demo:

<video src="assets/staggered_grid_demo.mov">

A wrap demo:

<video src="assets/wrap_demo.mov">

### Staggered Features

Because `DynamicGridView` is a child class of `GridView` that gives you access
to the `SliverGridDelegates` that are already implemented in the Flutter
Framework like `SliverGridDelegateWithMaxCrossAxisExtent` and
`SliverGridDelegateWithFixedCrossAxisCount`. This layout can be used with
`DynamicGridView.stagger`.


### Wrap Features

The Wrap layout is able to do runs of different elements and adapt acordingly with
the sizes of the children. It can leave spacing with `mainAxisSpacing` and
`crossAxisSpacing`.

The possibility to only have one of the axis be a decided by the children is possible by
changing the values of `childCrossAxisExtent` and `childMainAxisExtent`. This
values by default are ignored, but if you change `childCrossAxisExtent` to be
100 pixels, all of the children are going to be 100 pixels in the main axis.
This layout can be used with `DynamicGridView.wrap`.

## Getting started

TODO(DavBot02): List prerequisites and provide or point to information on how to
start using the package.

## Usage

In this package, we use `DynamicGridViews` that are a class that is inherited
from the normal `GridView`. You can use this `DynamicGridView` with
constructors that have the specific `SliverGridDelegate` like
`DynamicGridView.wrap` or if you want to have a more efficient option you can
still use `DynamicGridView.builder` that works the same as `GridView.builder`.

### Wrap

The following are simple examples of how to use `DynamicGridView.wrap` and
`DynamicGridView.builder` with the `SliverGridDelegateWithWrapping` delegate.

<?code-excerpt "dynamic_grid_view_wrap.dart" (Example)?>
```dart
final List<Widget> children = List.generate(
   250,
   (index) => Container(
     height: index.isEven ? 100 : 50,
     width: index.isEven ? 95 : 180,
     color: index.isEven ? Colors.red : Colors.blue,
     child: Center(child: Text('Item $index')),
   ),
 );

DynamicGridView.wrap(
     mainAxisSpacing: 10,
     crossAxisSpacing: 20,
     children: children,
);
```

Here is the result of the code:

<video src="assets/simple_wrap_demo.mov">

<?code-excerpt "dynamic_grid_view_builder.dart (Example)"?>
```dart
DynamicGridView.builder(
     gridDelegate: const SliverGridDelegateWithWrapping(
        mainAxisSpacing: 20,
        childMainAxisExtent: 250,
        childCrossAxisExtent: 50,
     ),
     itemBuilder: (BuildContext context, int index) {
       return Container(
         height: 200,
         color: index.isEven ? Colors.amber : Colors.blue,
         child: Center(
           child: Text('$index'),
         ),
       );
     },
   ),
```

Here is the result of the code:

<video src="assets/wrap_demo_with_one_fixed_axis.mov">

### Staggered

Using the Staggered layout is simple. It can be used with the
`DynamicGridView.stagger` and you can still use the delegates from `GridView`
like `SliverGridDelegateWithMaxCrossAxisExtent` and
`SliverGridDelegateWithFixedCrossAxisCount`.

<?code-excerpt "dynamic_grid_view_stagger.dart (Example)"?>
```dart
DynamicGridView.stagger(
      crossAxisCount: 4,
      mainAxisSpacing: 10.0,
      crossAxisSpacing: 10.0,
      children: children,
);
```

<!-- TODO(snat-s): Add a video of DynamicGrid.stagger -->

## Additional information

TODO(DavBot02): Tell users more about the package: where to find more information, how to
contribute to the package, how to file issues, what response they can expect
from the package authors, and more.
