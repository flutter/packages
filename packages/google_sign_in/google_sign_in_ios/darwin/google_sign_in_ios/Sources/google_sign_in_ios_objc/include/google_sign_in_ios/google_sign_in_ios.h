// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// This has to be here b/c of this cocoapods issue -
// https://github.com/CocoaPods/CocoaPods/issues/3767
// Without this file, the generated "google_sign_in_ios-Swift.h" will keep
// trying to import a "google_sign_in_ios.h" which doesn't exist.
#ifndef google_sign_in_ios_h
#define google_sign_in_ios_h

#if __has_include("google_sign_in_ios-umbrella.h")
#import "google_sign_in_ios-umbrella.h"
#endif

#endif /* google_sign_in_ios_h */
