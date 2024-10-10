// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
#import <TargetConditionals.h>

#if TARGET_OS_OSX
#import <FlutterMacOS/FlutterMacOS.h>
#elif TARGET_OS_IOS
#import <Flutter/Flutter.h>
#endif

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
- (NSObject<FLADAuthContext> *)createAuthContext;
@end

#pragma mark -

#if TARGET_OS_OSX
/// Protocol for interacting with NSAlert instances, abstracted to allow using mock/fake instances
/// in unit tests.
@protocol FLANSAlert <NSObject>
@required
@property(copy) NSString *messageText;
- (NSButton *)addButtonWithTitle:(NSString *)title;
- (void)beginSheetModalForWindow:(NSWindow *)sheetWindow
               completionHandler:(void (^_Nullable)(NSModalResponse returnCode))handler;
@end
#endif  // TARGET_OS_OSX

#if TARGET_OS_IOS
/// Protocol for interacting with UIAlertController instances, abstracted to allow using mock/fake
/// instances in unit tests.
@protocol FLAUIAlertController <NSObject>
@required
- (void)addAction:(UIAlertAction *)action;
// Reversed wrapper of presentViewController:... since the protocol can't be passed to the real
// method.
- (void)presentOnViewController:(UIViewController *)presentingViewController
                       animated:(BOOL)flag
                     completion:(void (^__nullable)(void))completion NS_SWIFT_DISABLE_ASYNC;
@end
#endif  // TARGET_OS_IOS

/// Protocol for a source of alert factory that wraps standard UIAlertController and NSAlert
/// allocation for iOS and macOS respectfully. Used to allow context injection in unit tests.
@protocol FLADAlertFactory <NSObject>

#if TARGET_OS_OSX
- (NSObject<FLANSAlert> *)createAlert;
#elif TARGET_OS_IOS
- (NSObject<FLAUIAlertController> *)createAlertControllerWithTitle:(nullable NSString *)title
                                                           message:(nullable NSString *)message
                                                    preferredStyle:
                                                        (UIAlertControllerStyle)preferredStyle;
#endif

@end

/// Protocol for a provider of the view containing the Flutter content, abstracted to allow using
/// mock/fake instances in unit tests.
@protocol FLAViewProvider <NSObject>
@required
#if TARGET_OS_OSX
@property(readonly, nonatomic) NSView *view;
#elif TARGET_OS_IOS
// TODO(stuartmorgan): Add a view accessor once https://github.com/flutter/flutter/issues/104117
// is resolved, and use that in 'showAlertWithMessage:...'.
#endif

@end

#pragma mark -

@interface FLALocalAuthPlugin ()
/// Returns an instance that uses the given factory to create LAContexts.
- (instancetype _Nonnull)initWithContextFactory:(NSObject<FLADAuthContextFactory> *)authFactory
                                   alertFactory:(NSObject<FLADAlertFactory> *)alertFactory
                                   viewProvider:(NSObject<FLAViewProvider> *)viewProvider
    NS_DESIGNATED_INITIALIZER;
@end

NS_ASSUME_NONNULL_END
