/// Specular highlight sharpness for liquid glass surfaces.
///
/// Controls how tightly focused the specular highlight is on the glass rim.
/// Each variant maps to a fixed power-of-2 exponent that the GPU resolves
/// using a zero-transcendental multiply chain — no `exp(n·log(x))` overhead.
///
/// ## Why not a `double`?
///
/// A float uniform is a runtime variable to the GPU compiler; it cannot
/// optimise `pow(x, uniform)` regardless of the value. By restricting to a
/// small set of known exponents, the shader can use fully-unrolled multiply
/// chains per branch with no transcendental operations. With wave coherency
/// (all fragments in a glass surface share the same value) the GPU driver also
/// eliminates the dead branches for that draw call entirely.
///
/// ## Choosing a value
///
/// | Variant | Exponent | Visual |
/// |---------|----------|--------|
/// | [soft]  | n=8      | Wide, diffuse — frosted glass, blurry highlight |
/// | [medium]| n=16     | Default — matches iOS 26 glass highlight |
/// | [sharp] | n=32     | Tight, polished — mirror-like glass surface |
enum GlassSpecularSharpness {
  /// Wide, diffuse specular lobe (n=8).
  ///
  /// Suitable for frosted, matte, or low-reflectivity glass surfaces.
  soft,

  /// Default iOS 26-calibrated highlight (n=16).
  ///
  /// Matches Apple's liquid glass specular model. Use for most surfaces.
  medium,

  /// Tight, mirror-like highlight (n=32).
  ///
  /// For polished, high-reflectivity surfaces where the specular point
  /// should be a tight bright dot rather than a broad glow.
  sharp;

  /// The GLSL integer passed as a uniform (0, 1, 2).
  /// Used internally by the shader writer — not part of the public API.
  int get glslIndex => index;
}
