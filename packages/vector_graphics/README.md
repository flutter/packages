# vector_graphics

A vector graphics rendering runtime for Flutter. This package is intended for
use with output from the `package:vector_graphics_compiler` and encoded via
a tightly coupled version of `package:vector_graphics_codec`.

## Commemoration

This package was originally authored by
[Dan Field](https://github.com/dnfield) and has been forked here
from [dnfield/vector_graphics](https://github.com/dnfield/vector_graphics).
Dan was a member of the Flutter team at Google from 2018 until his death
in 2024. Dan’s impact and contributions to Flutter were immeasurable, and we
honor his memory by continuing to publish and maintain this package.

## Static SVG filters

Supports `feOffset`, `feColorMatrix`, `feFlood`.
Filters use version 2 vector assets; version 1 assets remain supported.
Filter regions, named inputs, solid `FillPaint` and `StrokePaint`, local template
references, and inline styles are supported. Other contributing primitives,
`BackgroundImage`, `BackgroundAlpha`, and gradient or pattern paint inputs
produce a decode error. Animation, external stylesheets, and CSS filter functions
are outside this static SVG implementation.
