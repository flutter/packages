// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#if TARGET_OS_OSX
#import <FlutterMacOS/FlutterMacOS.h>
#else
#import <Flutter/Flutter.h>
#endif

#import <LocalAuthentication/LocalAuthentication.h>

/// Protocol for a source of LAContext instances. Used to allow context injection in unit tests.
@protocol FLADAuthContextFactory <NSObject>
- (LAContext *)createAuthContext;
@end

@protocol FLADAlertFactory <NSObject>

#if TARGET_OS_OSX
- (NSAlert *)createNSAlert;
#elif TARGET_OS_IOS
- (UIAlertController *)createUIAlert:(NSString *)message;
#endif

@end

@interface FLALocalAuthPlugin ()
/// Returns an instance that uses the given factory to create LAContexts.
- (instancetype)initWithContextFactory:(NSObject<FLADAuthContextFactory> *)authFactory
                          andRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar
                       andAlertFactory:(NSObject<FLADAlertFactory> *)alertFactory
    NS_DESIGNATED_INITIALIZER;
@end
