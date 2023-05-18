// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
#import "FLTLocalAuthPlugin.h"
#import "FLTLocalAuthPlugin_Test.h"

#import <LocalAuthentication/LocalAuthentication.h>

typedef void (^FLAAuthCompletion)(FLAAuthResultDetails *_Nullable, FlutterError *_Nullable);

/**
 * A default context factory that wraps standard LAContext allocation.
 */
@interface FLADefaultAuthContextFactory : NSObject <FLAAuthContextFactory>
@end

@implementation FLADefaultAuthContextFactory
- (LAContext *)createAuthContext {
  return [[LAContext alloc] init];
}
@end

#pragma mark -

/**
 * A data container for sticky auth state.
 */
@interface FLAStickyAuthState : NSObject
@property(nonatomic, strong, nonnull) FLAAuthOptions *options;
@property(nonatomic, strong, nonnull) FLAAuthStrings *strings;
@property(nonatomic, copy, nonnull) FLAAuthCompletion resultHandler;
- (instancetype)initWithOptions:(nonnull FLAAuthOptions *)options
                        strings:(nonnull FLAAuthStrings *)strings
                  resultHandler:(nonnull FLAAuthCompletion)resultHandler;
@end

@implementation FLAStickyAuthState
- (instancetype)initWithOptions:(nonnull FLAAuthOptions *)options
                        strings:(nonnull FLAAuthStrings *)strings
                  resultHandler:(nonnull FLAAuthCompletion)resultHandler {
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

@interface FLTLocalAuthPlugin ()
@property(nonatomic, strong, nullable) FLAStickyAuthState *lastCallState;
@property(nonatomic, strong) NSObject<FLAAuthContextFactory> *authContextFactory;
@end

@implementation FLTLocalAuthPlugin

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar {
  FLTLocalAuthPlugin *instance = [[FLTLocalAuthPlugin alloc] init];
  [registrar addApplicationDelegate:instance];
  FLALocalAuthApiSetup([registrar messenger], instance);
}

- (instancetype)init {
  return [self initWithContextFactory:[[FLADefaultAuthContextFactory alloc] init]];
}

- (instancetype)initWithContextFactory:(NSObject<FLAAuthContextFactory> *)factory {
  self = [super init];
  if (self) {
    _authContextFactory = factory;
  }
  return self;
}

#pragma mark FLALocalAuthApi

- (void)authenticateWithOptions:(nonnull FLAAuthOptions *)options
                        strings:(nonnull FLAAuthStrings *)strings
                     completion:(nonnull void (^)(FLAAuthResultDetails *_Nullable,
                                                  FlutterError *_Nullable))completion {
  LAContext *context = [self.authContextFactory createAuthContext];
  NSError *authError = nil;
  self.lastCallState = nil;
  context.localizedFallbackTitle = strings.localizedFallbackTitle;

  LAPolicy policy = options.biometricOnly.boolValue
                        ? LAPolicyDeviceOwnerAuthenticationWithBiometrics
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
  LAContext *context = [self.authContextFactory createAuthContext];
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

- (nullable NSArray<FLAAuthBiometricWrapper *> *)getEnrolledBiometricsWithError:
    (FlutterError *_Nullable __autoreleasing *_Nonnull)error {
  LAContext *context = [self.authContextFactory createAuthContext];
  NSError *authError = nil;
  NSMutableArray<FLAAuthBiometricWrapper *> *biometrics = [[NSMutableArray alloc] init];
  if ([context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics
                           error:&authError]) {
    if (authError == nil) {
      if (context.biometryType == LABiometryTypeFaceID) {
        [biometrics addObject:[FLAAuthBiometricWrapper makeWithValue:FLAAuthBiometricFace]];
      } else if (context.biometryType == LABiometryTypeTouchID) {
        [biometrics addObject:[FLAAuthBiometricWrapper makeWithValue:FLAAuthBiometricFingerprint]];
      }
    }
  }
  return biometrics;
}

- (nullable NSNumber *)isDeviceSupportedWithError:
    (FlutterError *_Nullable __autoreleasing *_Nonnull)error {
  // TODO(stuartmorgan): Fix this to check for biometrics or passcode; see
  // https://github.com/flutter/flutter/issues/116179
  return @YES;
}

#pragma mark Private Methods

- (void)showAlertWithMessage:(NSString *)message
          dismissButtonTitle:(NSString *)dismissButtonTitle
     openSettingsButtonTitle:(NSString *)openSettingsButtonTitle
                  completion:(FLAAuthCompletion)completion {
  UIAlertController *alert =
      [UIAlertController alertControllerWithTitle:@""
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
  [[UIApplication sharedApplication].delegate.window.rootViewController presentViewController:alert
                                                                                     animated:YES
                                                                                   completion:nil];
}

- (void)handleAuthReplyWithSuccess:(BOOL)success
                             error:(NSError *)error
                           options:(FLAAuthOptions *)options
                           strings:(FLAAuthStrings *)strings
                        completion:(nonnull FLAAuthCompletion)completion {
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
        if ([options.sticky boolValue]) {
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

- (void)handleSucceeded:(BOOL)succeeded withCompletion:(nonnull FLAAuthCompletion)completion {
  completion(
      [FLAAuthResultDetails makeWithResult:(succeeded ? FLAAuthResultSuccess : FLAAuthResultFailure)
                              errorMessage:nil
                              errorDetails:nil],
      nil);
}

- (void)handleError:(NSError *)authError
        withOptions:(FLAAuthOptions *)options
            strings:(FLAAuthStrings *)strings
         completion:(nonnull FLAAuthCompletion)completion {
  FLAAuthResult result = FLAAuthResultErrorNotAvailable;
  switch (authError.code) {
    case LAErrorPasscodeNotSet:
    case LAErrorBiometryNotEnrolled:
      if (options.useErrorDialogs.boolValue) {
        [self showAlertWithMessage:strings.goToSettingsDescription
                 dismissButtonTitle:strings.cancelButton
            openSettingsButtonTitle:strings.goToSettingsButton
                         completion:completion];
        return;
      }
      result = authError.code == LAErrorPasscodeNotSet ? FLAAuthResultErrorPasscodeNotSet
                                                       : FLAAuthResultErrorNotEnrolled;
      break;
    case LAErrorBiometryLockout:
      [self showAlertWithMessage:strings.lockOut
               dismissButtonTitle:strings.cancelButton
          openSettingsButtonTitle:nil
                       completion:completion];
      return;
  }
  completion([FLAAuthResultDetails makeWithResult:result
                                     errorMessage:authError.localizedDescription
                                     errorDetails:authError.domain],
             nil);
}

#pragma mark - AppDelegate

- (void)applicationDidBecomeActive:(UIApplication *)application {
  if (self.lastCallState != nil) {
    [self authenticateWithOptions:_lastCallState.options
                          strings:_lastCallState.strings
                       completion:_lastCallState.resultHandler];
  }
}

@end
