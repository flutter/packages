// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import AVFoundation;
@import Foundation;

NS_ASSUME_NONNULL_BEGIN

/// Services the FairPlay key requests that AVFoundation makes for a protected asset.
///
/// AVFoundation surfaces the `skd://` key URI from the HLS manifest as a resource loading request
/// rather than fetching it. This delegate answers those requests by fetching the application
/// certificate, generating the SPC, exchanging it for a CKC with the license server, and handing
/// the CKC back to AVFoundation.
///
/// Only the standard FairPlay exchange is implemented: the SPC is POSTed as an
/// `application/octet-stream` body, and the response body is used as the CKC as-is.
@interface FVPFairPlayResourceLoaderDelegate : NSObject <AVAssetResourceLoaderDelegate>

/// Creates a delegate that fetches the application certificate from `certificateURL` and exchanges
/// SPCs for CKCs at `licenseURL`.
///
/// `licenseHeaders` are attached to each license request. If `contentId` is nil, the content
/// identifier is derived from the `skd://` URL of the request being serviced.
- (instancetype)initWithCertificateURL:(NSURL *)certificateURL
                            licenseURL:(NSURL *)licenseURL
                        licenseHeaders:
                            (nullable NSDictionary<NSString *, NSString *> *)licenseHeaders
                             contentId:(nullable NSString *)contentId
    NS_SWIFT_NAME(init(certificateURL:licenseURL:licenseHeaders:contentId:))
        NS_DESIGNATED_INITIALIZER;

- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
