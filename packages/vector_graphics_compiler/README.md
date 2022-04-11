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

Unsupported SVG features:

- Images
- The pattern element

Optimizations:

- Opacity peepholing
- Transformation inlining (except for text and radial gradients)
- Group collapsing
