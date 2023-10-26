// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <Flutter/Flutter.h>

#import "messages.g.h"

#import <GoogleSignIn/GoogleSignIn.h>

@interface FLTGoogleSignInPlugin : NSObject <FlutterPlugin, FSIGoogleSignInApi>

// Configuration wrapping Google Cloud Console, Google Apps, OpenID,
// and other initialization metadata.
// @property(strong) GIDConfiguration *configuration;
@property(strong, nonatomic) GIDConfiguration *configuration;

@end
