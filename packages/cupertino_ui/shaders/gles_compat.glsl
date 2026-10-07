// Copyright 2026, Sebastian Degenaar for pixel-innovations.com (liquid_glass_widgets)
//
// SPDX-License-Identifier: MIT
//
// OpenGL ES texture-origin compatibility.
//
// ## Background
//
// Impeller's GLES backend used to store render-to-texture content with GL's
// native bottom-left origin, while Metal and Vulkan stored it top-down. Every
// fragment shader that sampled a Flutter-provided texture (a BackdropFilter
// snapshot, a `toImageSync` capture, a sampler bound via `setImageSampler`) had
// to compensate by hand:
//
//     #ifdef IMPELLER_TARGET_OPENGLES
//         uv.y = 1.0 - uv.y;
//     #endif
//
// Flutter PR #186556 ("[Impeller] Retire Y-coord-scale plumbing by flipping
// GLES at the vertex stage") absorbed that difference inside the GLES backend,
// so render-to-texture content is now stored top-down on *every* backend. The
// manual flip above became not merely unnecessary but actively wrong: it
// mirrors every sample vertically.
//
// That change shipped in **Flutter 3.46**. It is absent from 3.44 and 3.45.
//
// ## How to detect which convention the toolchain uses
//
// `impellerc` defines `IMPELLER_OPENGLES_UNFLIPPED_DEPRECATED` on the GLES
// runtime stages — and *only* on engines that have removed the flip (Flutter
// PR #187316 added it for exactly this purpose). Its presence therefore means
// "textures are already top-down; do not flip". Its absence on a GLES stage
// means we are being compiled by Flutter 3.44/3.45, which still needs the flip.
//
// [LGR_GLES_FLIP_SAMPLE_Y] encodes that decision once. Shaders sampling a
// Flutter-provided texture must gate their Y compensation on it rather than on
// `IMPELLER_TARGET_OPENGLES` directly:
//
//     #ifdef LGR_GLES_FLIP_SAMPLE_Y
//         uv.y = 1.0 - uv.y;
//     #endif
//
// Keeping the condition in one header means the eventual removal of the
// deprecated macro from Flutter (at which point the package can drop support
// for < 3.46) is a one-line change here, not a hunt across five shaders.
//
// NOTE: this is about the *texture sampling* convention only. It does not
// affect `FlutterFragCoord()`, which has always reported Y-down fragment
// positions on every backend.

#ifndef LGR_GLES_COMPAT_GLSL_
#define LGR_GLES_COMPAT_GLSL_

#if defined(IMPELLER_TARGET_OPENGLES) && \
    !defined(IMPELLER_OPENGLES_UNFLIPPED_DEPRECATED)
// Flutter 3.44 / 3.45 GLES: textures are bottom-left origin, flip by hand.
#define LGR_GLES_FLIP_SAMPLE_Y 1
#endif

#if defined(IMPELLER_TARGET_OPENGLES)
// Cap shape evaluation at 8 on OpenGL ES / ANGLE to avoid AST node explosion
// in runtime driver JIT compilers (e.g. Intel Arc ANGLE / PowerVR GE8320).
#define LGR_OPENGLES_CAP_SHAPES 1
#endif

#endif  // LGR_GLES_COMPAT_GLSL_
