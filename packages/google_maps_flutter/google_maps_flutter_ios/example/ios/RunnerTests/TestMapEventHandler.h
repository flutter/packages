// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import Foundation;
@import google_maps_flutter_ios;

NS_ASSUME_NONNULL_BEGIN

/// Fake implementation of FGMAssetProvider for unit tests.
@interface TestMapEventHandler : NSObject <FGMMapEventDelegate>
@end

NS_ASSUME_NONNULL_END
