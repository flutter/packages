// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <Foundation/Foundation.h>

@import AVFoundation;

NS_ASSUME_NONNULL_BEGIN

/// Handles FairPlay key loading for AVURLAsset resource loader requests.
@interface FVPFairPlayResourceLoaderDelegate : NSObject <AVAssetResourceLoaderDelegate>

- (instancetype)initWithCertificateURL:(NSURL *)certificateURL
                            licenseURL:(NSURL *)licenseURL
                        licenseHeaders:
                            (nullable NSDictionary<NSString *, NSString *> *)licenseHeaders
                             contentId:(nullable NSString *)contentId;

@end

NS_ASSUME_NONNULL_END
