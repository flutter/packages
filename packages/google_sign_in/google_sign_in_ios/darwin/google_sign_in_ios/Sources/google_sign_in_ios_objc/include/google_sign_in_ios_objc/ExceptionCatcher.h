// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// Runs `block` and returns any thrown NSException, or nil if none was thrown.
///
/// Swift cannot catch Objective-C exceptions, so this helper is used to preserve
/// the plugin's existing NSException-to-FlutterError mapping.
NSException *_Nullable GoogleSignInCatchException(void(NS_NOESCAPE ^ block)(void));

NS_ASSUME_NONNULL_END
