// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "IosPlatformImagesPlugin.h"

#if !__has_feature(objc_arc)
#error ARC must be enabled!
#endif

@interface IosPlatformImagesPlugin ()
@end

@implementation IosPlatformImagesPlugin

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar {
  FPIPlatformImagesApiSetup(registrar.messenger, [[IosPlatformImagesPlugin alloc] init]);
}

- (nullable FPIPlatformImageData *)
    loadImageWithName:(nonnull NSString *)name
                error:(FlutterError *_Nullable __autoreleasing *_Nonnull)error {
  UIImage *image = [UIImage imageNamed:name];
  NSData *data = UIImagePNGRepresentation(image);
  if (!data) {
    return nil;
  }
  return [FPIPlatformImageData makeWithData:[FlutterStandardTypedData typedDataWithBytes:data]
                                      scale:@(image.scale)];
}

- (nullable NSString *)resolveURLForResource:(nonnull NSString *)name
                               withExtension:(nullable NSString *)extension
                                       error:(FlutterError *_Nullable __autoreleasing *_Nonnull)
                                                 error {
  NSURL *url = [[NSBundle mainBundle] URLForResource:name withExtension:extension];
  return url.absoluteString;
}

@end
