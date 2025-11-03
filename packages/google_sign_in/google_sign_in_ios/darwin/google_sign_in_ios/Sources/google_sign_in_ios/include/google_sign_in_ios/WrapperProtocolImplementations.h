// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import GoogleSignIn;

#import "FSIGoogleSignInProtocols.h"
#import "FSIViewProvider.h"

NS_ASSUME_NONNULL_BEGIN

// TODO(stuarmorgan): Replace these with protocol extensions when migrating to Swift.
// https://github.com/flutter/flutter/issues/119103

/// Implementation of @c FSIViewProvider that passes through to the registrar.
@interface FSIDefaultViewProvider : NSObject <FSIViewProvider>
/// Returns a provider backed by the given registrar.
- (instancetype)initWithRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar
    NS_DESIGNATED_INITIALIZER;
- (instancetype)init NS_UNAVAILABLE;

/// The registrar backing the provider.
@property(readonly) NSObject<FlutterPluginRegistrar> *registrar;
@end

#pragma mark -

/// Implementation of @c FSIGIDSignIn that passes through to GIDSignIn.
@interface FSIGIDSignInWrapper : NSObject <FSIGIDSignIn>

/// The underlying GIDSignIn instance.
@property(readonly) GIDSignIn *signIn;

@end

/// Implementation of @c FSIGIDSignInResult that passes through to GIDSignInResult.
@interface FSIGIDSignInResultWrapper : NSObject <FSIGIDSignInResult>

- (nullable instancetype)initWithResult:(nullable GIDSignInResult *)result
    NS_DESIGNATED_INITIALIZER;
- (instancetype)init NS_UNAVAILABLE;

/// The underlying GIDSignInResult instance.
@property(nonatomic, nullable) GIDSignInResult *result;

@end

#pragma mark -

/// Implementation of @c FSIGIDGoogleUser that passes through to GIDGoogleUser.
@interface FSIGIDGoogleUserWrapper : NSObject <FSIGIDGoogleUser>

- (nullable instancetype)initWithUser:(nullable GIDGoogleUser *)user NS_DESIGNATED_INITIALIZER;
- (instancetype)init NS_UNAVAILABLE;

/// The underlying GIDGoogleUser instance.
@property(nonatomic, nullable) GIDGoogleUser *user;

@end

#pragma mark -

/// Implementation of @c FSIGIDProfileData that passes through to GIDProfileData.
@interface FSIGIDProfileDataWrapper : NSObject <FSIGIDProfileData>

- (nullable instancetype)initWithProfileData:(nullable GIDProfileData *)profileData
    NS_DESIGNATED_INITIALIZER;
- (instancetype)init NS_UNAVAILABLE;

/// The underlying GIDProfileData instance.
@property(nonatomic, nullable) GIDProfileData *profileData;

@end

#pragma mark -

/// Implementation of @c FSIGIDToken that passes through to GIDToken.
@interface FSIGIDTokenWrapper : NSObject <FSIGIDToken>

- (nullable instancetype)initWithToken:(nullable GIDToken *)token NS_DESIGNATED_INITIALIZER;
- (instancetype)init NS_UNAVAILABLE;

/// The underlying GIDToken instance.
@property(nonatomic, nullable) GIDToken *token;

@end

NS_ASSUME_NONNULL_END
