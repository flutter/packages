# BSDiff

[![pub package](https://img.shields.io/pub/v/bsdiff.svg)](
https://pub.dartlang.org/packages/bsdiff)

Binary diff/patch algorithm based on
[bsdiff 4.3](http://www.daemonology.net/bsdiff/) by Colin Percival.
It's very effective at compressesing incremental changes in binaries.

This implementation has the following differences from Colin's code,
to make it easier to read and apply patches in Java and Objective C:

* Using gzip instead of bzip2 because gzip is included in JDK by default
* Using big- instead of little-endian serialization to simplify Java code
* Using two's complement instead of high-bit coding for negatives numbers

## Usage
To use this package, add `bsdiff` as a
[dependency in your pubspec.yaml file](https://flutter.io/platform-plugins/).

## Example

Import the library via
``` dart
import 'package:bsdiff/bsdiff.dart';
```

Then use the `bsdiff` and `bspatch` Dart functions in your code. To see how this is done,
check out the [example app](example/main.dart).
