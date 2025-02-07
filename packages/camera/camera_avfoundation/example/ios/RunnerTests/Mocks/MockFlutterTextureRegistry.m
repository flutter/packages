// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "MockFlutterTextureRegistry.h"

@implementation MockFlutterTextureRegistry

- (int64_t)registerTexture:(nonnull NSObject<FlutterTexture> *)texture {
  return 0;
}

- (void)textureFrameAvailable:(int64_t)textureId {
}

- (void)unregisterTexture:(int64_t)textureId {
}

@end
