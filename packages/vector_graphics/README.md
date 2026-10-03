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

Supports `feOffset`, `feColorMatrix` (`matrix`, `saturate`, `hueRotate`,
`luminanceToAlpha`), `feFlood`, and `feMerge`, including their combinations.
Filters are compiled to version 2 vector assets; existing version 1 assets
remain supported. Filter regions, primitive regions, `filterUnits`,
`primitiveUnits`, named results, `SourceGraphic`, `SourceAlpha`, and
`color-interpolation-filters` (`linearRGB` by default, or `sRGB`) are resolved
for each filtered element. Inline styles and local filter template references
are supported.

`FillPaint` and `StrokePaint` support solid colors and `none`. Gradient and
pattern paint inputs, `BackgroundImage`, `BackgroundAlpha`, and other filter
primitives produce a decode error when they contribute to the final result.
Disconnected primitives are omitted. External stylesheets, CSS filter functions,
and animation are outside this static SVG implementation.

Short graphs retain vector pictures. Repeated or deeply nested graph inputs and
expensive nested masks are materialized to bound replay work. Intermediate
textures are limited to 8192 pixels per dimension and 16 million retained pixels
per decode. `filterRasterScale` controls this resolution; widgets choose it
from layout and device pixel ratio by default.

```xml
<filter id="coloredOffset" color-interpolation-filters="sRGB">
  <feOffset dx="4" dy="4" result="shifted"/>
  <feColorMatrix in="shifted" type="saturate" values="0"/>
  <feMerge>
    <feMergeNode/>
    <feMergeNode in="SourceGraphic"/>
  </feMerge>
</filter>
```
