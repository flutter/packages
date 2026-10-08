/// Rendering quality for glass effects.
///
/// Controls the rendering method used for glass effects, balancing
/// visual quality with performance and compatibility.
enum GlassQuality {
  /// Lightweight shader-based rendering for optimal performance.
  ///
  /// **Use when:**
  /// - Widget is in a scrollable list (ListView, GridView, etc.)
  /// - Inside forms or settings pages
  /// - Performance is important
  /// - Widget needs to work reliably in all contexts
  ///
  /// **Characteristics:**
  /// - Uses lightweight fragment shader
  /// - 5-10x faster than BackdropFilter
  /// - Better visual quality than BackdropFilter
  /// - Works correctly during scrolling
  /// - Suitable for interactive widgets
  /// - Universal platform support (Skia, Impeller, Web)
  ///
  /// This is the recommended default for most use cases.
  standard,

  /// High-quality shader-based glass rendering.
  ///
  /// **Use when:**
  /// - Widget is in a static header or footer
  /// - Creating hero sections or showcase UI
  /// - Visual quality is paramount
  /// - Widget won't be scrolled
  /// - Device is iPhone 13 / A15 Bionic or newer (iOS)
  /// - Device is Pixel 6 / Tensor G1 or newer (Android)
  ///
  /// **Characteristics:**
  /// - Uses custom shaders and texture capture
  /// - Higher visual quality with specular highlights and chromatic aberration
  /// - More computationally expensive
  /// - May not render correctly in scrollable contexts
  ///
  /// Only use in static, non-scrollable layouts on modern hardware.
  /// On pre-A15 devices, sustained animations at this quality may exceed
  /// GPU budget — consider [standard] or [minimal] for broader compatibility.
  premium,

  /// Shader-free fallback rendering. Zero custom shader activity.
  ///
  /// **Use when:**
  ///
  /// *Device compatibility* — when even [standard] is too heavy:
  /// - Targeting very old Android devices with limited shader driver support
  /// - Devices where custom fragment shaders fail to compile entirely
  /// - `ImageFilter.isShaderFilterSupported` returns `false`
  ///
  /// *GPU budget management* — when you have many glass surfaces on one screen:
  /// - List items with glass cards (each scroll frame would invoke the shader
  ///   once per visible card — [minimal] keeps the cumulative cost flat)
  /// - Screens with 10+ simultaneous glass widgets where total shader load
  ///   matters more than individual widget quality
  /// - Background panels or decorative containers where the frosted blur
  ///   is the entire intended effect and specular highlights aren't noticed
  /// - Simple UI surfaces where visual richness is secondary to smoothness
  ///
  /// A good pattern: use [standard] or [premium] for focal elements (the
  /// primary widget the user is interacting with) and [minimal] for
  /// background or supporting surfaces on the same screen.
  ///
  /// **Characteristics:**
  /// - Uses [BackdropFilter] blur + Rec. 709 saturation + specular rim stroke
  /// - Zero custom fragment shader execution or compilation
  /// - Cross-platform: works on Skia, Impeller, Web, Windows, Linux
  /// - Visually similar to frosted glass — saturation and specular rim match
  ///   the upstream FakeGlass approach (whynotmake.it)
  ///
  /// This is the safe mode tier. Prefer it whenever [standard] still feels
  /// heavy, or when you want to keep shader load low on busy screens.
  minimal,
}

/// Extension to convert [GlassQuality] to the underlying rendering method.
extension GlassQualityExtension on GlassQuality {
  /// Whether to use the lightweight fragment shader.
  ///
  /// - [GlassQuality.standard]  → true  (lightweight shader)
  /// - [GlassQuality.premium]   → false (full LiquidGlass shader pipeline)
  /// - [GlassQuality.minimal]   → false (no shader at all — BackdropFilter only)
  bool get usesLightweightShader {
    switch (this) {
      case GlassQuality.standard:
        return true;
      case GlassQuality.premium:
      case GlassQuality.minimal:
        return false;
    }
  }

  /// Whether this quality level uses any custom fragment shader.
  ///
  /// - [GlassQuality.standard]  → true  (lightweight shader)
  /// - [GlassQuality.premium]   → true  (full LiquidGlass shader)
  /// - [GlassQuality.minimal]   → false (BackdropFilter only, zero shaders)
  bool get usesAnyShader {
    switch (this) {
      case GlassQuality.standard:
      case GlassQuality.premium:
        return true;
      case GlassQuality.minimal:
        return false;
    }
  }
}
