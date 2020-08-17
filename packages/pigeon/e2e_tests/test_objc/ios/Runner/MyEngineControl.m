// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "MyEngineControl.h"
#import "MyPlugin.h"

#if !__has_feature(objc_arc)
#error ARC must be enabled!
#endif

@implementation MyEngineControl
- (void)createDestroyContextThenDeallocEngine:(FlutterError* _Nullable* _Nonnull)error {
  @autoreleasepool {
    FlutterEngine* engine =
        [[FlutterEngine alloc] initWithName:@"createDestroyContextThenDeallocEngine"];
    [engine run];
    [MyPlugin registerWithRegistrar:[engine registrarForPlugin:@"MyPlugin"]];
    [engine destroyContext];
  }
}
@end
