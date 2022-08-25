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
This new layouts allow you to have the following:

GIF OF wrap Layout
GIF OF Staggered Layout

## Getting started

TODO(DavBot02): List prerequisites and provide or point to information on how to
start using the package.

## Usage

In this package, we use *DynamicGridViews* that are a class that is inherited 

### Wrap

```dart
final List<Widget> children = List.generate(
   250,
   (index) => Container(
     height: index.isEven ? 100 : 50,
     width: index.isEven ? 95 : 180,
     color: index.isEven ? Colors.redAccent[100] : Colors.tealAccent[100],
     child:
     Center(child: Text('Item $index')),
   ),
 );

DynamicGridView.wrap(
     mainAxisSpacing: 10,
     crossAxisSpacing: 20,
     children: children,
);
```

```dart
DynamicGridView.builder(
     gridDelegate: const SliverGridDelegateWithWrapping(
       crossAxisSpacing: 20,
       mainAxisSpacing: 20,
     ),
     itemBuilder: (BuildContext context, int index) {
       return Container(
         height: index.isEven ? 100 : 200,
         width: index.isEven ? 200: 100,
         color: index.isEven ? Colors.amber : Colors.blue,
         child: Center(
           child: Text('$index'),
         ),
       );
     },
   );
```

### Staggered

## Additional information

TODO(DavBot02): Tell users more about the package: where to find more information, how to
contribute to the package, how to file issues, what response they can expect
from the package authors, and more.
