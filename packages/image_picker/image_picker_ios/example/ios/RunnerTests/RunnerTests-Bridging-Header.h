// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "ImagePickerTestImages.h"

@import image_picker_ios;

// Exposes the GIF writer so tests can make CGImageDestinationCreateWithURL fail.
@interface FLTImagePickerPhotoAssetUtil (Test)
+ (nullable NSString *)saveImageWithMetaData:(nullable NSDictionary *)metaData
                                     gifInfo:(GIFInfo *)gifInfo
                                        path:(NSString *)path;
@end
