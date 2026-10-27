// Copyright 2025 Tim Lehmann for whynotmake.it
//
// SPDX-License-Identifier: MIT
//
// Originally from liquid_glass_renderer (whynotmake.it).
// Maintained and evolved in-tree for liquid_glass_widgets.
// See lib/src/third_party/liquid_glass_renderer/ATTRIBUTION.md for provenance and modification history.

import 'package:flutter/foundation.dart' show kDebugMode;

export '../engine/glass_glow.dart'
    show GlassGlow, GlassGlowLayer, GlassGlowLayerState;
export '../engine/liquid_glass.dart' show LiquidGlass;
export '../engine/liquid_glass_blend_group.dart' show LiquidGlassBlendGroup;
export '../engine/liquid_glass_layer.dart' show LiquidGlassLayer;
export '../engine/liquid_glass_settings.dart'
    show
        GlassBodyMode,
        GlassLensModel,
        LiquidGlassSettings,
        PlatformViewGlassMode;
export '../engine/liquid_shape.dart';
export '../engine/stretch.dart'
    show
        AnchorStretchSettings,
        LiquidStretch,
        OffsetResistanceExtension,
        RawLiquidStretch;

export 'glass_materialize_scope.dart' show GlassMaterializeScope;
export 'liquid_glass_self_scale_scope.dart' show LiquidGlassSelfScaleScope;

/// Whether to paint the liquid glass geometry texture for debugging purposes.
///
/// When enabled, geometry textures will be drawn directly instead of the
/// liquid glass effect.
///
/// Will be set to `false` in release builds.
@pragma('vm:platform-const-if', !kDebugMode)
bool debugPaintLiquidGlassGeometry = false;
