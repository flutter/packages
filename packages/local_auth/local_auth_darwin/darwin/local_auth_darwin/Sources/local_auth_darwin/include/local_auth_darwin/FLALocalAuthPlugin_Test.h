// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <Flutter/Flutter.h>
#import <LocalAuthentication/LocalAuthentication.h>

NS_ASSUME_NONNULL_BEGIN

/// Protocol for interacting with LAContext instances, abstracted to allow using mock/fake instances
/// in unit tests.
@protocol FLADAuthContext <NSObject>
@required
@property(nonatomic, nullable, copy) NSString *localizedFallbackTitle;
@property(nonatomic, readonly) LABiometryType biometryType;
- (BOOL)canEvaluatePolicy:(LAPolicy)policy error:(NSError *__autoreleasing *)error;
- (void)evaluatePolicy:(LAPolicy)policy
       localizedReason:(NSString *)localizedReason
                 reply:(void (^)(BOOL success, NSError *__nullable error))reply;
@end

/// Protocol for a source of FLADAuthContext instances. Used to allow context injection in unit
/// tests.
@protocol FLADAuthContextFactory <NSObject>
@required
- (id<FLADAuthContext>)createAuthContext;
@end

@interface FLALocalAuthPlugin ()
/// Returns an instance that uses the given factory to create LAContexts.
- (instancetype)initWithContextFactory:(NSObject<FLADAuthContextFactory> *)factory
    NS_DESIGNATED_INITIALIZER;
@end

NS_ASSUME_NONNULL_END
