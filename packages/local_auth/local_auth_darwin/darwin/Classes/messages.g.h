// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
// Autogenerated from Pigeon (v13.1.2), do not edit directly.
// See also: https://pub.dev/packages/pigeon

#import <Foundation/Foundation.h>

@protocol FlutterBinaryMessenger;
@protocol FlutterMessageCodec;
@class FlutterError;
@class FlutterStandardTypedData;

NS_ASSUME_NONNULL_BEGIN

/// Possible outcomes of an authentication attempt.
typedef NS_ENUM(NSUInteger, FLADAuthResult) {
  /// The user authenticated successfully.
  FLADAuthResultSuccess = 0,
  /// The user failed to successfully authenticate.
  FLADAuthResultFailure = 1,
  /// The authentication system was not available.
  FLADAuthResultErrorNotAvailable = 2,
  /// No biometrics are enrolled.
  FLADAuthResultErrorNotEnrolled = 3,
  /// No passcode is set.
  FLADAuthResultErrorPasscodeNotSet = 4,
};

/// Wrapper for FLADAuthResult to allow for nullability.
@interface FLADAuthResultBox : NSObject
@property(nonatomic, assign) FLADAuthResult value;
- (instancetype)initWithValue:(FLADAuthResult)value;
@end

/// Pigeon equivalent of the subset of BiometricType used by iOS.
typedef NS_ENUM(NSUInteger, FLADAuthBiometric) {
  FLADAuthBiometricFace = 0,
  FLADAuthBiometricFingerprint = 1,
};

/// Wrapper for FLADAuthBiometric to allow for nullability.
@interface FLADAuthBiometricBox : NSObject
@property(nonatomic, assign) FLADAuthBiometric value;
- (instancetype)initWithValue:(FLADAuthBiometric)value;
@end

@class FLADAuthStrings;
@class FLADAuthOptions;
@class FLADAuthResultDetails;
@class FLADAuthBiometricWrapper;

/// Pigeon version of IOSAuthMessages, plus the authorization reason.
///
/// See auth_messages_ios.dart for details.
@interface FLADAuthStrings : NSObject
/// `init` unavailable to enforce nonnull fields, see the `make` class method.
- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)makeWithReason:(NSString *)reason
    lockOut:(NSString *)lockOut
    goToSettingsButton:(nullable NSString *)goToSettingsButton
    goToSettingsDescription:(nullable NSString *)goToSettingsDescription
    cancelButton:(NSString *)cancelButton
    localizedFallbackTitle:(nullable NSString *)localizedFallbackTitle;
@property(nonatomic, copy) NSString * reason;
@property(nonatomic, copy) NSString * lockOut;
@property(nonatomic, copy, nullable) NSString * goToSettingsButton;
@property(nonatomic, copy, nullable) NSString * goToSettingsDescription;
@property(nonatomic, copy) NSString * cancelButton;
@property(nonatomic, copy, nullable) NSString * localizedFallbackTitle;
@end

@interface FLADAuthOptions : NSObject
/// `init` unavailable to enforce nonnull fields, see the `make` class method.
- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)makeWithBiometricOnly:(BOOL )biometricOnly
    sticky:(BOOL )sticky
    useErrorDialogs:(BOOL )useErrorDialogs;
@property(nonatomic, assign) BOOL  biometricOnly;
@property(nonatomic, assign) BOOL  sticky;
@property(nonatomic, assign) BOOL  useErrorDialogs;
@end

@interface FLADAuthResultDetails : NSObject
/// `init` unavailable to enforce nonnull fields, see the `make` class method.
- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)makeWithResult:(FLADAuthResult)result
    errorMessage:(nullable NSString *)errorMessage
    errorDetails:(nullable NSString *)errorDetails;
/// The result of authenticating.
@property(nonatomic, assign) FLADAuthResult result;
/// A system-provided error message, if any.
@property(nonatomic, copy, nullable) NSString * errorMessage;
/// System-provided error details, if any.
@property(nonatomic, copy, nullable) NSString * errorDetails;
@end

@interface FLADAuthBiometricWrapper : NSObject
/// `init` unavailable to enforce nonnull fields, see the `make` class method.
- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)makeWithValue:(FLADAuthBiometric)value;
@property(nonatomic, assign) FLADAuthBiometric value;
@end

/// The codec used by FLADLocalAuthApi.
NSObject<FlutterMessageCodec> *FLADLocalAuthApiGetCodec(void);

@protocol FLADLocalAuthApi
/// Returns true if this device supports authentication.
///
/// @return `nil` only when `error != nil`.
- (nullable NSNumber *)isDeviceSupportedWithError:(FlutterError *_Nullable *_Nonnull)error;
/// Returns true if this device can support biometric authentication, whether
/// any biometrics are enrolled or not.
///
/// @return `nil` only when `error != nil`.
- (nullable NSNumber *)deviceCanSupportBiometricsWithError:(FlutterError *_Nullable *_Nonnull)error;
/// Returns the biometric types that are enrolled, and can thus be used
/// without additional setup.
///
/// @return `nil` only when `error != nil`.
- (nullable NSArray<FLADAuthBiometricWrapper *> *)getEnrolledBiometricsWithError:(FlutterError *_Nullable *_Nonnull)error;
/// Attempts to authenticate the user with the provided [options], and using
/// [strings] for any UI.
- (void)authenticateWithOptions:(FLADAuthOptions *)options strings:(FLADAuthStrings *)strings completion:(void (^)(FLADAuthResultDetails *_Nullable, FlutterError *_Nullable))completion;
@end

extern void SetUpFLADLocalAuthApi(id<FlutterBinaryMessenger> binaryMessenger, NSObject<FLADLocalAuthApi> *_Nullable api);

NS_ASSUME_NONNULL_END
