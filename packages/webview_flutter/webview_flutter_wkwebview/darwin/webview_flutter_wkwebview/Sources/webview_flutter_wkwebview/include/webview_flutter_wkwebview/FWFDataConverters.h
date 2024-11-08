// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "FWFGeneratedWebKitApis.h"

#import <WebKit/WebKit.h>

NS_ASSUME_NONNULL_BEGIN

/// Converts an FWFNSUrlRequestData to an NSURLRequest.
///
/// @param data The data object containing information to create an NSURLRequest.
///
/// @return An NSURLRequest or nil if data could not be converted.
extern NSURLRequest *_Nullable FWFNativeNSURLRequestFromRequestData(FWFNSUrlRequestData *data);

/// Converts an FWFNSHttpCookieData to an NSHTTPCookie.
///
/// @param data The data object containing information to create an NSHTTPCookie.
///
/// @return An NSHTTPCookie or nil if data could not be converted.
extern NSHTTPCookie *_Nullable FWFNativeNSHTTPCookieFromCookieData(FWFNSHttpCookieData *data);

/// Converts an FWFNSKeyValueObservingOptionsEnumData to an NSKeyValueObservingOptions.
///
/// @param data The data object containing information to create an NSKeyValueObservingOptions.
///
/// @return An NSKeyValueObservingOptions or -1 if data could not be converted.
extern NSKeyValueObservingOptions FWFNativeNSKeyValueObservingOptionsFromEnumData(
    FWFNSKeyValueObservingOptionsEnumData *data);

/// Converts an FWFNSHTTPCookiePropertyKeyEnumData to an NSHTTPCookiePropertyKey.
///
/// @param data The data object containing information to create an NSHTTPCookiePropertyKey.
///
/// @return An NSHttpCookiePropertyKey or nil if data could not be converted.
extern NSHTTPCookiePropertyKey _Nullable FWFNativeNSHTTPCookiePropertyKeyFromEnumData(
    FWFNSHttpCookiePropertyKeyEnumData *data);

/// Converts a WKUserScriptData to a WKUserScript.
///
/// @param data The data object containing information to create a WKUserScript.
///
/// @return A WKUserScript or nil if data could not be converted.
extern WKUserScript *FWFNativeWKUserScriptFromScriptData(FWFWKUserScriptData *data);

/// Converts an FWFWKUserScriptInjectionTimeEnumData to a WKUserScriptInjectionTime.
///
/// @param data The data object containing information to create a WKUserScriptInjectionTime.
///
/// @return A WKUserScriptInjectionTime or -1 if data could not be converted.
extern WKUserScriptInjectionTime FWFNativeWKUserScriptInjectionTimeFromEnumData(
    FWFWKUserScriptInjectionTimeEnumData *data);

/// Converts an FWFWKAudiovisualMediaTypeEnumData to a WKAudiovisualMediaTypes.
///
/// @param data The data object containing information to create a WKAudiovisualMediaTypes.
///
/// @return A WKAudiovisualMediaType or -1 if data could not be converted.
extern WKAudiovisualMediaTypes FWFNativeWKAudiovisualMediaTypeFromEnumData(
    FWFWKAudiovisualMediaTypeEnumData *data);

/// Converts an FWFWKWebsiteDataTypeEnumData to a WKWebsiteDataType.
///
/// @param data The data object containing information to create a WKWebsiteDataType.
///
/// @return A WKWebsiteDataType or nil if data could not be converted.
extern NSString *_Nullable FWFNativeWKWebsiteDataTypeFromEnumData(
    FWFWKWebsiteDataTypeEnumData *data);

/// Converts a WKNavigationAction to an FWFWKNavigationActionData.
///
/// @param action The object containing information to create a WKNavigationActionData.
///
/// @return A FWFWKNavigationActionData.
extern FWFWKNavigationActionData *FWFWKNavigationActionDataFromNativeWKNavigationAction(
    WKNavigationAction *action);

/// Converts a NSURLRequest to an FWFNSUrlRequestData.
///
/// @param request The object containing information to create a WKNavigationActionData.
///
/// @return A FWFNSUrlRequestData.
extern FWFNSUrlRequestData *FWFNSUrlRequestDataFromNativeNSURLRequest(NSURLRequest *request);

/**
 * Converts a WKNavigationResponse to an FWFWKNavigationResponseData.
 *
 * @param response The object containing information to create a WKNavigationResponseData.
 *
 * @return A FWFWKNavigationResponseData.
 */
extern FWFWKNavigationResponseData *FWFWKNavigationResponseDataFromNativeNavigationResponse(
    WKNavigationResponse *response);
/**
 * Converts a NSURLResponse to an FWFNSHttpUrlResponseData.
 *
 * @param response The object containing information to create a WKNavigationActionData.
 *
 * @return A FWFNSHttpUrlResponseData.
 */
extern FWFNSHttpUrlResponseData *FWFNSHttpUrlResponseDataFromNativeNSURLResponse(
    NSURLResponse *response);

/**
 * Converts a WKFrameInfo to an FWFWKFrameInfoData.
 *
 * @param info The object containing information to create a FWFWKFrameInfoData.
 *
 * @return A FWFWKFrameInfoData.
 */
extern FWFWKFrameInfoData *FWFWKFrameInfoDataFromNativeWKFrameInfo(WKFrameInfo *info);

/// Converts an FWFWKNavigationActionPolicyEnumData to a WKNavigationActionPolicy.
///
/// @param data The data object containing information to create a WKNavigationActionPolicy.
///
/// @return A WKNavigationActionPolicy or -1 if data could not be converted.
extern WKNavigationActionPolicy FWFNativeWKNavigationActionPolicyFromEnumData(
    FWFWKNavigationActionPolicyEnumData *data);

/**
 * Converts an FWFWKNavigationResponsePolicyEnumData to a WKNavigationResponsePolicy.
 *
 * @param policy The data object containing information to create a WKNavigationResponsePolicy.
 *
 * @return A WKNavigationResponsePolicy or -1 if data could not be converted.
 */
extern WKNavigationResponsePolicy FWFNativeWKNavigationResponsePolicyFromEnum(
    FWFWKNavigationResponsePolicyEnum policy);

/**
 * Converts a NSError to an FWFNSErrorData.
 *
 * @param error The object containing information to create a FWFNSErrorData.
 *
 * @return A FWFNSErrorData.
 */
extern FWFNSErrorData *FWFNSErrorDataFromNativeNSError(NSError *error);

/// Converts an NSKeyValueChangeKey to a FWFNSKeyValueChangeKeyEnumData.
///
/// @param key The data object containing information to create a FWFNSKeyValueChangeKeyEnumData.
///
/// @return A FWFNSKeyValueChangeKeyEnumData.
extern FWFNSKeyValueChangeKeyEnumData *FWFNSKeyValueChangeKeyEnumDataFromNativeNSKeyValueChangeKey(
    NSKeyValueChangeKey key);

/// Converts a WKScriptMessage to an FWFWKScriptMessageData.
///
/// @param message The object containing information to create a FWFWKScriptMessageData.
///
/// @return A FWFWKScriptMessageData.
extern FWFWKScriptMessageData *FWFWKScriptMessageDataFromNativeWKScriptMessage(
    WKScriptMessage *message);

/// Converts a WKNavigationType to an FWFWKNavigationType.
///
/// @param type The object containing information to create a FWFWKNavigationType
///
/// @return A FWFWKNavigationType.
extern FWFWKNavigationType FWFWKNavigationTypeFromNativeWKNavigationType(WKNavigationType type);

/// Converts a WKSecurityOrigin to an FWFWKSecurityOriginData.
///
/// @param origin The object containing information to create an FWFWKSecurityOriginData.
///
/// @return An FWFWKSecurityOriginData.
extern FWFWKSecurityOriginData *FWFWKSecurityOriginDataFromNativeWKSecurityOrigin(
    WKSecurityOrigin *origin);

/// Converts an FWFWKPermissionDecisionData to a WKPermissionDecision.
///
/// @param data The data object containing information to create a WKPermissionDecision.
///
/// @return A WKPermissionDecision or -1 if data could not be converted.
API_AVAILABLE(ios(15.0), macos(12))
extern WKPermissionDecision FWFNativeWKPermissionDecisionFromData(
    FWFWKPermissionDecisionData *data);

/// Converts an WKMediaCaptureType to a FWFWKMediaCaptureTypeData.
///
/// @param type The data object containing information to create a FWFWKMediaCaptureTypeData.
///
/// @return A FWFWKMediaCaptureTypeData or nil if data could not be converted.
API_AVAILABLE(ios(15.0), macos(12))
extern FWFWKMediaCaptureTypeData *FWFWKMediaCaptureTypeDataFromNativeWKMediaCaptureType(
    WKMediaCaptureType type);

/// Converts an FWFNSUrlSessionAuthChallengeDisposition to an NSURLSessionAuthChallengeDisposition.
///
/// @param value The object containing information to create an
/// NSURLSessionAuthChallengeDisposition.
///
/// @return A NSURLSessionAuthChallengeDisposition or -1 if data could not be converted.
extern NSURLSessionAuthChallengeDisposition
FWFNativeNSURLSessionAuthChallengeDispositionFromFWFNSUrlSessionAuthChallengeDisposition(
    FWFNSUrlSessionAuthChallengeDisposition value);

/// Converts an FWFNSUrlCredentialPersistence to an NSURLCredentialPersistence.
///
/// @param value The object containing information to create an NSURLCredentialPersistence.
///
/// @return A NSURLCredentialPersistence or -1 if data could not be converted.
extern NSURLCredentialPersistence
FWFNativeNSURLCredentialPersistenceFromFWFNSUrlCredentialPersistence(
    FWFNSUrlCredentialPersistence value);

NS_ASSUME_NONNULL_END
