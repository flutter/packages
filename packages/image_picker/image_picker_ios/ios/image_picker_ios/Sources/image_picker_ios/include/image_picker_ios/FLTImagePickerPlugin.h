// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <Flutter/Flutter.h>
#import <PhotosUI/PhotosUI.h>

NS_ASSUME_NONNULL_BEGIN

@interface FLTImagePickerPlugin : NSObject <FlutterPlugin>
/// FLTImagePickerPlugin has no public initializers, as it should not be
/// created directly by plugin clients.
- (instancetype)init NS_UNAVAILABLE;
@end

NS_ASSUME_NONNULL_END
