// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
#version 460 core

precision mediump float;

#include <flutter/runtime_effect.glsl>

uniform float uAnimation;
uniform vec4 uColor;
uniform float uRadius;
uniform vec2 uCenter;

out vec4 fragColor;

void main() {
  float scale = distance(FlutterFragCoord(), uCenter) / uRadius;
  fragColor = mix(vec4(1.0), uColor, scale) * (1.0 - uAnimation);
}
