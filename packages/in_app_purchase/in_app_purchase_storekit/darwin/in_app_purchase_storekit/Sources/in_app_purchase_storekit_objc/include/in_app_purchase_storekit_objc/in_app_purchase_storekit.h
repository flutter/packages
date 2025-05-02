// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// This has to be here b/c of this cocoapods issue -
// https://github.com/CocoaPods/CocoaPods/issues/3767
// Without this file, the generated "in_app_purchase_storekit-Swift.h" will keep
// trying to import an "in_app_purchase_storekit.h" which doesn't exist.
#ifndef in_app_purchase_storekit_h
#define in_app_purchase_storekit_h

#if __has_include("in_app_purchase_storekit-umbrella.h")
#import "in_app_purchase_storekit-umbrella.h"
#endif

#endif /* in_app_purchase_storekit_h */
