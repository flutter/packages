// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// If Swift Package Manager is in use, Objective-C headers are available under the
// GoogleMapsUtilsObjC package. When using CocoaPods, the headers are provided by the
// GoogleMapsUtils package.
#ifdef FGM_USING_COCOAPODS
@import GoogleMapsUtils;
#else
@import GoogleMapsUtilsObjC;
#endif
