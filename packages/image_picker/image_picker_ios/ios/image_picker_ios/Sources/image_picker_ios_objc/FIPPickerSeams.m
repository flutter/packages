// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "./include/image_picker_ios/FIPPickerSeams.h"

@interface PHPickerResult (FIPPickerItem) <FIPPickerItem>
@end

@implementation PHPickerResult (FIPPickerItem)
@end

@implementation FIPDefaultImageDataRequester
- (void)requestImageDataAndOrientationForAsset:(PHAsset *)asset
                                       options:(nullable PHImageRequestOptions *)options
                                 resultHandler:
                                     (void (^)(NSData *_Nullable imageData,
                                               NSString *_Nullable dataUTI,
                                               CGImagePropertyOrientation orientation,
                                               NSDictionary *_Nullable info))resultHandler {
  [[PHImageManager defaultManager] requestImageDataAndOrientationForAsset:asset
                                                                  options:options
                                                            resultHandler:resultHandler];
}
@end
