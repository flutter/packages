## 0.1.3

* Remove unecessary location decorations for pixelation shader.

## 0.1.2

* Ensure constructed ui.Picture objects are disposed after usage.
* Add [SetUniforms] to help constructing FragmentShader uniform data.

## 0.1.1

* Fix `AnimatedSampler` offset assertion to no longer trigger incorrectly when shader is disabled.
* Fix runtime exception when the `AnimatedSampler` was asked to construct an image with no size.

## 0.1.0

* Update URLs in pubspec.yaml.

## 0.0.6

* Fix bug in `AnimatedSampler` that caused children with non-zero offsets to
  be rendered offscreen.
* Removed `offset` parameter from `AnimatedSamplerBuilder`. The offset will
  always be `Offset.zero` now and this is no longer necessary.


## 0.0.5

* Remove restriction on `AnimatedSampler` child repainting.

## 0.0.4

* Added `ShaderInkFeatureFactory` and `ShaderInkFeature` to allow configuration of a
  material inkwell splash with a developer authored fragment shader and configuration
  callback

## 0.0.3

* Updated documentation on `AnimatedSampler` to account for `FragmentShader` breaking
  API changes.

## 0.0.2

 * Add pixelation shader.

## 0.0.1

 * First published version
