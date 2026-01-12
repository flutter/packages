// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// This header is available in the Test module. Import via "@import google_sign_in.Test;"

#import <google_sign_in_ios/FLTGoogleSignInPlugin.h>

#import <GoogleSignIn/GoogleSignIn.h>

NS_ASSUME_NONNULL_BEGIN

@class GIDSignIn;

/// Methods exposed for unit testing.
@interface FLTGoogleSignInPlugin ()

// Instance used to manage Google Sign In authentication including
// sign in, sign out, and requesting additional scopes.
@property(strong, readonly) GIDSignIn *signIn;

// A mapping of user IDs to GIDGoogleUser instances to use for follow-up calls.
@property(nonatomic) NSMutableDictionary<NSString *, GIDGoogleUser *> *usersByIdentifier;

/// Inject @c FlutterPluginRegistrar for testing.
- (instancetype)initWithRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar;

/// Inject @c GIDSignIn for testing.
- (instancetype)initWithSignIn:(GIDSignIn *)signIn
                     registrar:(NSObject<FlutterPluginRegistrar> *)registrar;

/// Inject @c GIDSignIn and @c googleServiceProperties for testing.
- (instancetype)initWithSignIn:(GIDSignIn *)signIn
                     registrar:(NSObject<FlutterPluginRegistrar> *)registrar
       googleServiceProperties:(nullable NSDictionary<NSString *, id> *)googleServiceProperties
    NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
