# vector_graphics_compiler

A compiler for `package:vector_graphics`.

This package parses SVG files into a format that the vector_graphics runtime
can render.

## Features

Supported SVG features:

- Groups, paths, and basic shapes are all supported.
- References, including out of order references.
- Linear and radial gradients, including radial gradients with focal points.
- Text
- Symbols
- Images
- Patterns

Unsupported SVG features:

- Filters
- Some text processing attributes

Optimizations:

- Opacity peepholing
- Transformation inlining (except for text and radial gradients)
- Group collapsing
- Mask and clip elimination

## Commemoration

This package was originally authored by
[Dan Field](https://github.com/dnfield) and has been forked here
from [dnfield/vector_graphics](https://github.com/dnfield/vector_graphics).
Dan was a member of the Flutter team at Google from 2018 until his death
in 2024. Dan’s impact and contributions to Flutter were immeasurable, and we
honor his memory by continuing to publish and maintain this package.
