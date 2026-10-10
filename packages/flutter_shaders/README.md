# flutter_shaders

A collection of utilities to make working with the FragmentProgram API easier.


## Available Shaders

This package includes a number of shaders that can be optionally included into your
application by declaring them in the pubspec.yaml:

### Pixelation

The pixelation shader reduces the provided sampler to MxN samples. This can be used with the [AnimatedSampler] widget. The required uniforms are:

Floats:
  * The number of pixels in the X coordinate space.
  * The number of pixels in the Y coordinate space.
  * The width of the sampled area.
  * The height of the sampled area.
Samplers:
  * The child widget, captured as a texture.

To include this shader in your application, add the following line to
your pubspec.yaml

```yaml
flutter:
  shaders:
    - packages/flutter_shaders/shaders/pixelation.frag

```
