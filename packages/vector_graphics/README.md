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

## SVG filters

Filter sources preserve geometry independently of paint, including unpainted
paths and text. Vector-only operations keep one picture across layout and DPR
changes. Unsupported primitives fail decoding with an explicit diagnostic;
use `errorBuilder` for an application fallback.

Run `python3 tool/filter_web_tests.py` for the Chrome/CanvasKit filter suites.
Reference provenance is recorded in `test/filters/reference/sources.json`.

This unreleased series must use matching source revisions of the codec, compiler,
runtime and flutter_svg. Before publication, assign coordinated release versions
and dependency lower bounds; NEXT entries and existing versions are provisional.
