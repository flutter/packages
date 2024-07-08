// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
#import "./include/local_auth_darwin/FLALocalAuthPlugin.h"
#import "./include/local_auth_darwin/FLALocalAuthPlugin_Test.h"

#import <LocalAuthentication/LocalAuthentication.h>

typedef void (^FLADAuthCompletion)(FLADAuthResultDetails *_Nullable, FlutterError *_Nullable);

/// A default auth context that wraps LAContext.
// TODO(stuartmorgan): When converting to Swift, eliminate this class and use an extension to make
// LAContext declare conformance to FLADAuthContext.
@interface FLADefaultAuthContext : NSObject <FLADAuthContext>
/// Returns a wrapper for the given LAContext.
- (instancetype)initWithContext:(LAContext *)context NS_DESIGNATED_INITIALIZER;
- (instancetype)init NS_UNAVAILABLE;

/// The wrapped auth context.
@property(nonatomic) LAContext *context;
@end

@implementation FLADefaultAuthContext
- (instancetype)initWithContext:(LAContext *)context {
  self = [super init];
  if (self) {
    _context = context;
  }
  return self;
}

#pragma mark FLADAuthContext implementation

- (NSString *)localizedFallbackTitle {
  return self.context.localizedFallbackTitle;
}

- (void)setLocalizedFallbackTitle:(NSString *)localizedFallbackTitle {
  self.context.localizedFallbackTitle = localizedFallbackTitle;
}

- (LABiometryType)biometryType {
  return self.context.biometryType;
}

- (BOOL)canEvaluatePolicy:(LAPolicy)policy error:(NSError *__autoreleasing *)error {
  return [self.context canEvaluatePolicy:policy error:error];
}

- (void)evaluatePolicy:(LAPolicy)policy
       localizedReason:(NSString *)localizedReason
                 reply:(void (^)(BOOL success, NSError *__nullable error))reply {
  [self.context evaluatePolicy:policy localizedReason:localizedReason reply:reply];
}

@end

/// A default context factory that wraps standard LAContext allocation.
@interface FLADefaultAuthContextFactory : NSObject <FLADAuthContextFactory>
@end

@implementation FLADefaultAuthContextFactory
- (id<FLADAuthContext>)createAuthContext {
  // TODO(stuartmorgan): When converting to Swift, just return LAContext here.
  return [[FLADefaultAuthContext alloc] initWithContext:[[LAContext alloc] init]];
}
@end

#pragma mark -

#if TARGET_OS_OSX
/// A default alert that wraps NSAlert.
// TODO(stuartmorgan): When converting to Swift, eliminate this class and use an extension to make
// NSAlert declare conformance to FLANSAlert.
@interface FLADefaultNSAlert : NSObject <FLANSAlert>
/// Returns a wrapper for the given NSAlert.
- (instancetype)initWithAlert:(NSAlert *)alert NS_DESIGNATED_INITIALIZER;
- (instancetype)init NS_UNAVAILABLE;

/// The wrapped alert.
@property(nonatomic) NSAlert *alert;
@end

@implementation FLADefaultNSAlert
- (NSString *)messageText {
  return self.alert.messageText;
}

- (void)setMessageText:(NSString *)messageText {
  self.alert.messageText = messageText;
}

- (NSButton *)addButtonWithTitle:(NSString *)title {
  [self.alert addButtonWithTitle:title];
}

- (void)beginSheetModalForWindow:(NSWindow *)sheetWindow
               completionHandler:(void (^_Nullable)(NSModalResponse returnCode))handler {
  [self.alert beginSheetModalForWindow:sheetWindow completionHandler:handler];
}
@end
#elif TARGET_OS_IOS
/// A default alert controller that wraps UIAlertController.
// TODO(stuartmorgan): When converting to Swift, eliminate this class and use an extension to make
// UIAlertController declare conformance to FLAUIAlertController.
@interface FLADefaultUIAlertController : NSObject <FLAUIAlertController>
/// Returns a wrapper for the given UIAlertController.
- (instancetype)initWithAlertController:(UIAlertController *)controller NS_DESIGNATED_INITIALIZER;
- (instancetype)init NS_UNAVAILABLE;

/// The wrapped alert controller.
@property(nonatomic) UIAlertController *controller;
@end

@implementation FLADefaultUIAlertController
- (void)addAction:(UIAlertAction *)action {
  [self.controller addAction:action];
}

- (void)presentOnViewController:(UIViewController *)presentingViewController
                       animated:(BOOL)flag
                     completion:(void (^__nullable)(void))completion {
  [presentingViewController presentViewController:self.controller
                                         animated:flag
                                       completion:completion];
}
@end
#endif

/// A default alert factory that wraps standard UIAlertController and NSAlert allocation for iOS and
/// macOS respectfully.
@interface FLADefaultAlertFactory : NSObject <FLADAlertFactory>
@end

@implementation FLADefaultAlertFactory

#if TARGET_OS_OSX
- (NSObject<FLANSAlert> *)createAlert {
  // TODO(stuartmorgan): When converting to Swift, just return NSAlert here.
  return [[FLADefaultNSAlert alloc] initWithAlert:[[NSAlert alloc] init]];
}
#elif TARGET_OS_IOS
- (NSObject<FLAUIAlertController> *)createAlertControllerWithTitle:(nullable NSString *)title
                                                           message:(nullable NSString *)message
                                                    preferredStyle:
                                                        (UIAlertControllerStyle)preferredStyle {
  // TODO(stuartmorgan): When converting to Swift, just return UIAlertController here.
  return [[FLADefaultUIAlertController alloc]
      initWithAlertController:[UIAlertController alertControllerWithTitle:title
                                                                  message:message
                                                           preferredStyle:preferredStyle]];
}
#endif
@end

#pragma mark -

/// A data container for sticky auth state.
@interface FLAStickyAuthState : NSObject
@property(nonatomic, strong, nonnull) FLADAuthOptions *options;
@property(nonatomic, strong, nonnull) FLADAuthStrings *strings;
@property(nonatomic, copy, nonnull) FLADAuthCompletion resultHandler;
- (instancetype)initWithOptions:(nonnull FLADAuthOptions *)options
                        strings:(nonnull FLADAuthStrings *)strings
                  resultHandler:(nonnull FLADAuthCompletion)resultHandler;
@end

@implementation FLAStickyAuthState
- (instancetype)initWithOptions:(nonnull FLADAuthOptions *)options
                        strings:(nonnull FLADAuthStrings *)strings
                  resultHandler:(nonnull FLADAuthCompletion)resultHandler {
  self = [super init];
  if (self) {
    _options = options;
    _strings = strings;
    _resultHandler = resultHandler;
  }
  return self;
}
@end

#pragma mark -

/// A flutter plugin for local authentication.
@interface FLALocalAuthPlugin ()

/// Manages the last call state for sticky auth.
@property(nonatomic, strong, nullable) FLAStickyAuthState *lastCallState;

/// The factory to create LAContexts.
@property(nonatomic, strong) NSObject<FLADAuthContextFactory> *authContextFactory;

/// The factory to create alerts.
@property(nonatomic, strong) NSObject<FLADAlertFactory> *alertFactory;

/// The flutter plugin registrar.
@property(nonatomic, strong) NSObject<FlutterPluginRegistrar> *registrar;
@end

@implementation FLALocalAuthPlugin

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar {
  NSObject<FLADAlertFactory> *alertFactory = [[FLADefaultAlertFactory alloc] init];
  NSObject<FLADAuthContextFactory> *authContextFactory =
      [[FLADefaultAuthContextFactory alloc] init];
  FLALocalAuthPlugin *instance =
      [[FLALocalAuthPlugin alloc] initWithContextFactory:authContextFactory
                                            alertFactory:alertFactory
                                               registrar:registrar];
  [registrar addApplicationDelegate:instance];
  SetUpFLADLocalAuthApi([registrar messenger], instance);
}

/// Returns an instance that uses the given factory to create LAContexts.
- (instancetype)initWithContextFactory:(NSObject<FLADAuthContextFactory> *)authFactory
                          alertFactory:(NSObject<FLADAlertFactory> *)alertFactory
                             registrar:(NSObject<FlutterPluginRegistrar> *)registrar {
  self = [super init];
  if (self) {
    _registrar = registrar;
    _authContextFactory = authFactory;
    _alertFactory = alertFactory;
  }
  return self;
}

#pragma mark FLADLocalAuthApi

- (void)authenticateWithOptions:(nonnull FLADAuthOptions *)options
                        strings:(nonnull FLADAuthStrings *)strings
                     completion:(nonnull void (^)(FLADAuthResultDetails *_Nullable,
                                                  FlutterError *_Nullable))completion {
  id<FLADAuthContext> context = [self.authContextFactory createAuthContext];
  NSError *authError = nil;
  self.lastCallState = nil;
  context.localizedFallbackTitle = strings.localizedFallbackTitle;

  LAPolicy policy = options.biometricOnly ? LAPolicyDeviceOwnerAuthenticationWithBiometrics
                                          : LAPolicyDeviceOwnerAuthentication;
  if ([context canEvaluatePolicy:policy error:&authError]) {
    [context evaluatePolicy:policy
            localizedReason:strings.reason
                      reply:^(BOOL success, NSError *error) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                          [self handleAuthReplyWithSuccess:success
                                                     error:error
                                                   options:options
                                                   strings:strings
                                                completion:completion];
                        });
                      }];
  } else {
    [self handleError:authError withOptions:options strings:strings completion:completion];
  }
}

- (nullable NSNumber *)deviceCanSupportBiometricsWithError:
    (FlutterError *_Nullable __autoreleasing *_Nonnull)error {
  id<FLADAuthContext> context = [self.authContextFactory createAuthContext];
  NSError *authError = nil;
  // Check if authentication with biometrics is possible.
  if ([context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics
                           error:&authError]) {
    if (authError == nil) {
      return @YES;
    }
  }
  // If not, check if it is because no biometrics are enrolled (but still present).
  if (authError != nil) {
    if (authError.code == LAErrorBiometryNotEnrolled) {
      return @YES;
    }
  }

  return @NO;
}

- (nullable NSArray<FLADAuthBiometricWrapper *> *)getEnrolledBiometricsWithError:
    (FlutterError *_Nullable __autoreleasing *_Nonnull)error {
  id<FLADAuthContext> context = [self.authContextFactory createAuthContext];
  NSError *authError = nil;
  NSMutableArray<FLADAuthBiometricWrapper *> *biometrics = [[NSMutableArray alloc] init];
  if ([context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics
                           error:&authError]) {
    if (authError == nil) {
      if (@available(macOS 10.15, iOS 11.0, *)) {
        if (context.biometryType == LABiometryTypeFaceID) {
          [biometrics addObject:[FLADAuthBiometricWrapper makeWithValue:FLADAuthBiometricFace]];
          return biometrics;
        }
      }
      if (context.biometryType == LABiometryTypeTouchID) {
        [biometrics
            addObject:[FLADAuthBiometricWrapper makeWithValue:FLADAuthBiometricFingerprint]];
      }
    }
  }
  return biometrics;
}

- (nullable NSNumber *)isDeviceSupportedWithError:
    (FlutterError *_Nullable __autoreleasing *_Nonnull)error {
  id<FLADAuthContext> context = [self.authContextFactory createAuthContext];
  return @([context canEvaluatePolicy:LAPolicyDeviceOwnerAuthentication error:NULL]);
}

#pragma mark Private Methods

- (void)showAlertWithMessage:(NSString *)message
          dismissButtonTitle:(NSString *)dismissButtonTitle
     openSettingsButtonTitle:(NSString *)openSettingsButtonTitle
                  completion:(FLADAuthCompletion)completion {
#if TARGET_OS_OSX
  id<FLANSAlert> alert = [_alertFactory createAlert];
  alert.messageText = message;
  [alert addButtonWithTitle:dismissButtonTitle];
  NSWindow *window = self.registrar.view.window;
  [alert beginSheetModalForWindow:window
                completionHandler:^(NSModalResponse returnCode) {
                  [self handleSucceeded:NO withCompletion:completion];
                }];
  return;
#elif TARGET_OS_IOS
  id<FLAUIAlertController> alert =
      [_alertFactory createAlertControllerWithTitle:@""
                                            message:message
                                     preferredStyle:UIAlertControllerStyleAlert];

  UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:dismissButtonTitle
                                                          style:UIAlertActionStyleDefault
                                                        handler:^(UIAlertAction *action) {
                                                          [self handleSucceeded:NO
                                                                 withCompletion:completion];
                                                        }];

  [alert addAction:defaultAction];
  if (openSettingsButtonTitle != nil) {
    UIAlertAction *additionalAction = [UIAlertAction
        actionWithTitle:openSettingsButtonTitle
                  style:UIAlertActionStyleDefault
                handler:^(UIAlertAction *action) {
                  NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                  [[UIApplication sharedApplication] openURL:url
                                                     options:@{}
                                           completionHandler:NULL];
                  [self handleSucceeded:NO withCompletion:completion];
                }];
    [alert addAction:additionalAction];
  }
  [alert
      presentOnViewController:[UIApplication sharedApplication].delegate.window.rootViewController
                     animated:YES
                   completion:nil];
#endif
}

- (void)handleAuthReplyWithSuccess:(BOOL)success
                             error:(NSError *)error
                           options:(FLADAuthOptions *)options
                           strings:(FLADAuthStrings *)strings
                        completion:(nonnull FLADAuthCompletion)completion {
  NSAssert([NSThread isMainThread], @"Response handling must be done on the main thread.");
  if (success) {
    [self handleSucceeded:YES withCompletion:completion];
  } else {
    switch (error.code) {
      case LAErrorBiometryNotAvailable:
      case LAErrorBiometryNotEnrolled:
      case LAErrorBiometryLockout:
      case LAErrorUserFallback:
      case LAErrorPasscodeNotSet:
      case LAErrorAuthenticationFailed:
        [self handleError:error withOptions:options strings:strings completion:completion];
        return;
      case LAErrorSystemCancel:
        if (options.sticky) {
          _lastCallState = [[FLAStickyAuthState alloc] initWithOptions:options
                                                               strings:strings
                                                         resultHandler:completion];
        } else {
          [self handleSucceeded:NO withCompletion:completion];
        }
        return;
    }
    [self handleError:error withOptions:options strings:strings completion:completion];
  }
}

- (void)handleSucceeded:(BOOL)succeeded withCompletion:(nonnull FLADAuthCompletion)completion {
  completion([FLADAuthResultDetails
                 makeWithResult:(succeeded ? FLADAuthResultSuccess : FLADAuthResultFailure)
                   errorMessage:nil
                   errorDetails:nil],
             nil);
}

- (void)handleError:(NSError *)authError
        withOptions:(FLADAuthOptions *)options
            strings:(FLADAuthStrings *)strings
         completion:(nonnull FLADAuthCompletion)completion {
  FLADAuthResult result = FLADAuthResultErrorNotAvailable;
  switch (authError.code) {
    case LAErrorPasscodeNotSet:
    case LAErrorBiometryNotEnrolled:
      if (options.useErrorDialogs) {
        [self showAlertWithMessage:strings.goToSettingsDescription
                 dismissButtonTitle:strings.cancelButton
            openSettingsButtonTitle:strings.goToSettingsButton
                         completion:completion];
        return;
      }
      result = authError.code == LAErrorPasscodeNotSet ? FLADAuthResultErrorPasscodeNotSet
                                                       : FLADAuthResultErrorNotEnrolled;
      break;
    case LAErrorBiometryLockout:
      [self showAlertWithMessage:strings.lockOut
               dismissButtonTitle:strings.cancelButton
          openSettingsButtonTitle:nil
                       completion:completion];
      return;
  }
  completion([FLADAuthResultDetails makeWithResult:result
                                      errorMessage:authError.localizedDescription
                                      errorDetails:authError.domain],
             nil);
}

#pragma mark - AppDelegate

// This method is called when the app is resumed from the background only on iOS
#if TARGET_OS_IOS
- (void)applicationDidBecomeActive:(UIApplication *)application {
  if (self.lastCallState != nil) {
    [self authenticateWithOptions:_lastCallState.options
                          strings:_lastCallState.strings
                       completion:_lastCallState.resultHandler];
  }
}
#endif

@end
