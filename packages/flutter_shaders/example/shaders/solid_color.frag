// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
#version 460 core

precision highp float;

layout(location = 0) uniform vec4 uColor;

out vec4 fragColor;

void main() {
  fragColor = uColor;
}
