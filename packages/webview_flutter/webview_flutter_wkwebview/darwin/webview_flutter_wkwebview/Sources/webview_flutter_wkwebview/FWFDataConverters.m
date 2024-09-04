// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "./include/webview_flutter_wkwebview/FWFDataConverters.h"

#if TARGET_OS_OSX
#import <FlutterMacOS/FlutterMacOS.h>
#else
#import <Flutter/Flutter.h>
#endif

NSURLRequest *_Nullable FWFNativeNSURLRequestFromRequestData(FWFNSUrlRequestData *data) {
  NSURL *url = [NSURL URLWithString:data.url];
  if (!url) {
    return nil;
  }

  NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
  if (!request) {
    return nil;
  }

  if (data.httpMethod) {
    [request setHTTPMethod:data.httpMethod];
  }
  if (data.httpBody) {
    [request setHTTPBody:data.httpBody.data];
  }
  [request setAllHTTPHeaderFields:data.allHttpHeaderFields];

  return request;
}

extern NSHTTPCookie *_Nullable FWFNativeNSHTTPCookieFromCookieData(FWFNSHttpCookieData *data) {
  NSMutableDictionary<NSHTTPCookiePropertyKey, id> *properties = [NSMutableDictionary dictionary];
  for (int i = 0; i < data.propertyKeys.count; i++) {
    NSHTTPCookiePropertyKey cookieKey =
        FWFNativeNSHTTPCookiePropertyKeyFromEnumData(data.propertyKeys[i]);
    if (!cookieKey) {
      // Some keys aren't supported on all versions, so this ignores keys
      // that require a higher version or are unsupported.
      continue;
    }
    [properties setObject:data.propertyValues[i] forKey:cookieKey];
  }
  return [NSHTTPCookie cookieWithProperties:properties];
}

NSKeyValueObservingOptions FWFNativeNSKeyValueObservingOptionsFromEnumData(
    FWFNSKeyValueObservingOptionsEnumData *data) {
  switch (data.value) {
    case FWFNSKeyValueObservingOptionsEnumNewValue:
      return NSKeyValueObservingOptionNew;
    case FWFNSKeyValueObservingOptionsEnumOldValue:
      return NSKeyValueObservingOptionOld;
    case FWFNSKeyValueObservingOptionsEnumInitialValue:
      return NSKeyValueObservingOptionInitial;
    case FWFNSKeyValueObservingOptionsEnumPriorNotification:
      return NSKeyValueObservingOptionPrior;
  }

  return -1;
}

NSHTTPCookiePropertyKey _Nullable FWFNativeNSHTTPCookiePropertyKeyFromEnumData(
    FWFNSHttpCookiePropertyKeyEnumData *data) {
  switch (data.value) {
    case FWFNSHttpCookiePropertyKeyEnumComment:
      return NSHTTPCookieComment;
    case FWFNSHttpCookiePropertyKeyEnumCommentUrl:
      return NSHTTPCookieCommentURL;
    case FWFNSHttpCookiePropertyKeyEnumDiscard:
      return NSHTTPCookieDiscard;
    case FWFNSHttpCookiePropertyKeyEnumDomain:
      return NSHTTPCookieDomain;
    case FWFNSHttpCookiePropertyKeyEnumExpires:
      return NSHTTPCookieExpires;
    case FWFNSHttpCookiePropertyKeyEnumMaximumAge:
      return NSHTTPCookieMaximumAge;
    case FWFNSHttpCookiePropertyKeyEnumName:
      return NSHTTPCookieName;
    case FWFNSHttpCookiePropertyKeyEnumOriginUrl:
      return NSHTTPCookieOriginURL;
    case FWFNSHttpCookiePropertyKeyEnumPath:
      return NSHTTPCookiePath;
    case FWFNSHttpCookiePropertyKeyEnumPort:
      return NSHTTPCookiePort;
    case FWFNSHttpCookiePropertyKeyEnumSameSitePolicy:
      if (@available(iOS 13.0, macOS 10.15, *)) {
        return NSHTTPCookieSameSitePolicy;
      } else {
        return nil;
      }
    case FWFNSHttpCookiePropertyKeyEnumSecure:
      return NSHTTPCookieSecure;
    case FWFNSHttpCookiePropertyKeyEnumValue:
      return NSHTTPCookieValue;
    case FWFNSHttpCookiePropertyKeyEnumVersion:
      return NSHTTPCookieVersion;
  }

  return nil;
}

extern WKUserScript *FWFNativeWKUserScriptFromScriptData(FWFWKUserScriptData *data) {
  return [[WKUserScript alloc]
        initWithSource:data.source
         injectionTime:FWFNativeWKUserScriptInjectionTimeFromEnumData(data.injectionTime)
      forMainFrameOnly:data.isMainFrameOnly];
}

WKUserScriptInjectionTime FWFNativeWKUserScriptInjectionTimeFromEnumData(
    FWFWKUserScriptInjectionTimeEnumData *data) {
  switch (data.value) {
    case FWFWKUserScriptInjectionTimeEnumAtDocumentStart:
      return WKUserScriptInjectionTimeAtDocumentStart;
    case FWFWKUserScriptInjectionTimeEnumAtDocumentEnd:
      return WKUserScriptInjectionTimeAtDocumentEnd;
  }

  return -1;
}

WKAudiovisualMediaTypes FWFNativeWKAudiovisualMediaTypeFromEnumData(
    FWFWKAudiovisualMediaTypeEnumData *data) {
  switch (data.value) {
    case FWFWKAudiovisualMediaTypeEnumNone:
      return WKAudiovisualMediaTypeNone;
    case FWFWKAudiovisualMediaTypeEnumAudio:
      return WKAudiovisualMediaTypeAudio;
    case FWFWKAudiovisualMediaTypeEnumVideo:
      return WKAudiovisualMediaTypeVideo;
    case FWFWKAudiovisualMediaTypeEnumAll:
      return WKAudiovisualMediaTypeAll;
  }

  return -1;
}

NSString *_Nullable FWFNativeWKWebsiteDataTypeFromEnumData(FWFWKWebsiteDataTypeEnumData *data) {
  switch (data.value) {
    case FWFWKWebsiteDataTypeEnumCookies:
      return WKWebsiteDataTypeCookies;
    case FWFWKWebsiteDataTypeEnumMemoryCache:
      return WKWebsiteDataTypeMemoryCache;
    case FWFWKWebsiteDataTypeEnumDiskCache:
      return WKWebsiteDataTypeDiskCache;
    case FWFWKWebsiteDataTypeEnumOfflineWebApplicationCache:
      return WKWebsiteDataTypeOfflineWebApplicationCache;
    case FWFWKWebsiteDataTypeEnumLocalStorage:
      return WKWebsiteDataTypeLocalStorage;
    case FWFWKWebsiteDataTypeEnumSessionStorage:
      return WKWebsiteDataTypeSessionStorage;
    case FWFWKWebsiteDataTypeEnumWebSQLDatabases:
      return WKWebsiteDataTypeWebSQLDatabases;
    case FWFWKWebsiteDataTypeEnumIndexedDBDatabases:
      return WKWebsiteDataTypeIndexedDBDatabases;
  }

  return nil;
}

FWFWKNavigationActionData *FWFWKNavigationActionDataFromNativeWKNavigationAction(
    WKNavigationAction *action) {
  return [FWFWKNavigationActionData
      makeWithRequest:FWFNSUrlRequestDataFromNativeNSURLRequest(action.request)
          targetFrame:FWFWKFrameInfoDataFromNativeWKFrameInfo(action.targetFrame)
       navigationType:FWFWKNavigationTypeFromNativeWKNavigationType(action.navigationType)];
}

FWFNSUrlRequestData *FWFNSUrlRequestDataFromNativeNSURLRequest(NSURLRequest *request) {
  return [FWFNSUrlRequestData
              makeWithUrl:request.URL.absoluteString == nil ? @"" : request.URL.absoluteString
               httpMethod:request.HTTPMethod
                 httpBody:request.HTTPBody
                              ? [FlutterStandardTypedData typedDataWithBytes:request.HTTPBody]
                              : nil
      allHttpHeaderFields:request.allHTTPHeaderFields ? request.allHTTPHeaderFields : @{}];
}

FWFWKFrameInfoData *FWFWKFrameInfoDataFromNativeWKFrameInfo(WKFrameInfo *info) {
  return [FWFWKFrameInfoData
      makeWithIsMainFrame:info.isMainFrame
                  request:FWFNSUrlRequestDataFromNativeNSURLRequest(info.request)];
}

FWFWKNavigationResponseData *FWFWKNavigationResponseDataFromNativeNavigationResponse(
    WKNavigationResponse *response) {
  return [FWFWKNavigationResponseData
      makeWithResponse:FWFNSHttpUrlResponseDataFromNativeNSURLResponse(response.response)
          forMainFrame:response.forMainFrame];
}

/// Cast the NSURLResponse object to NSHTTPURLResponse.
///
/// NSURLResponse doesn't contain the status code so it must be cast to NSHTTPURLResponse.
/// This cast will always succeed because the NSURLResponse object actually is an instance of
/// NSHTTPURLResponse. See:
/// https://developer.apple.com/documentation/foundation/nsurlresponse#overview
FWFNSHttpUrlResponseData *FWFNSHttpUrlResponseDataFromNativeNSURLResponse(NSURLResponse *response) {
  NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
  return [FWFNSHttpUrlResponseData makeWithStatusCode:httpResponse.statusCode];
}

WKNavigationActionPolicy FWFNativeWKNavigationActionPolicyFromEnumData(
    FWFWKNavigationActionPolicyEnumData *data) {
  switch (data.value) {
    case FWFWKNavigationActionPolicyEnumAllow:
      return WKNavigationActionPolicyAllow;
    case FWFWKNavigationActionPolicyEnumCancel:
      return WKNavigationActionPolicyCancel;
  }

  return -1;
}

FWFNSErrorData *FWFNSErrorDataFromNativeNSError(NSError *error) {
  NSMutableDictionary *userInfo;
  if (error.userInfo) {
    userInfo = [NSMutableDictionary dictionary];
    for (NSErrorUserInfoKey key in error.userInfo.allKeys) {
      NSObject *value = error.userInfo[key];
      if ([value isKindOfClass:[NSString class]]) {
        userInfo[key] = value;
      } else {
        userInfo[key] = [NSString stringWithFormat:@"Unsupported Type: %@", value.description];
      }
    }
  }
  return [FWFNSErrorData makeWithCode:error.code domain:error.domain userInfo:userInfo];
}

WKNavigationResponsePolicy FWFNativeWKNavigationResponsePolicyFromEnum(
    FWFWKNavigationResponsePolicyEnum policy) {
  switch (policy) {
    case FWFWKNavigationResponsePolicyEnumAllow:
      return WKNavigationResponsePolicyAllow;
    case FWFWKNavigationResponsePolicyEnumCancel:
      return WKNavigationResponsePolicyCancel;
  }

  return -1;
}

FWFNSKeyValueChangeKeyEnumData *FWFNSKeyValueChangeKeyEnumDataFromNativeNSKeyValueChangeKey(
    NSKeyValueChangeKey key) {
  if ([key isEqualToString:NSKeyValueChangeIndexesKey]) {
    return [FWFNSKeyValueChangeKeyEnumData makeWithValue:FWFNSKeyValueChangeKeyEnumIndexes];
  } else if ([key isEqualToString:NSKeyValueChangeKindKey]) {
    return [FWFNSKeyValueChangeKeyEnumData makeWithValue:FWFNSKeyValueChangeKeyEnumKind];
  } else if ([key isEqualToString:NSKeyValueChangeNewKey]) {
    return [FWFNSKeyValueChangeKeyEnumData makeWithValue:FWFNSKeyValueChangeKeyEnumNewValue];
  } else if ([key isEqualToString:NSKeyValueChangeNotificationIsPriorKey]) {
    return [FWFNSKeyValueChangeKeyEnumData
        makeWithValue:FWFNSKeyValueChangeKeyEnumNotificationIsPrior];
  } else if ([key isEqualToString:NSKeyValueChangeOldKey]) {
    return [FWFNSKeyValueChangeKeyEnumData makeWithValue:FWFNSKeyValueChangeKeyEnumOldValue];
  } else {
    return [FWFNSKeyValueChangeKeyEnumData makeWithValue:FWFNSKeyValueChangeKeyEnumUnknown];
  }

  return nil;
}

FWFWKScriptMessageData *FWFWKScriptMessageDataFromNativeWKScriptMessage(WKScriptMessage *message) {
  return [FWFWKScriptMessageData makeWithName:message.name body:message.body];
}

FWFWKNavigationType FWFWKNavigationTypeFromNativeWKNavigationType(WKNavigationType type) {
  switch (type) {
    case WKNavigationTypeLinkActivated:
      return FWFWKNavigationTypeLinkActivated;
    case WKNavigationTypeFormSubmitted:
      return FWFWKNavigationTypeFormResubmitted;
    case WKNavigationTypeBackForward:
      return FWFWKNavigationTypeBackForward;
    case WKNavigationTypeReload:
      return FWFWKNavigationTypeReload;
    case WKNavigationTypeFormResubmitted:
      return FWFWKNavigationTypeFormResubmitted;
    case WKNavigationTypeOther:
      return FWFWKNavigationTypeOther;
  }

  return FWFWKNavigationTypeUnknown;
}

FWFWKSecurityOriginData *FWFWKSecurityOriginDataFromNativeWKSecurityOrigin(
    WKSecurityOrigin *origin) {
  return [FWFWKSecurityOriginData makeWithHost:origin.host
                                          port:origin.port
                                      protocol:origin.protocol];
}

WKPermissionDecision FWFNativeWKPermissionDecisionFromData(FWFWKPermissionDecisionData *data) {
  switch (data.value) {
    case FWFWKPermissionDecisionDeny:
      return WKPermissionDecisionDeny;
    case FWFWKPermissionDecisionGrant:
      return WKPermissionDecisionGrant;
    case FWFWKPermissionDecisionPrompt:
      return WKPermissionDecisionPrompt;
  }

  return -1;
}

FWFWKMediaCaptureTypeData *FWFWKMediaCaptureTypeDataFromNativeWKMediaCaptureType(
    WKMediaCaptureType type) {
  switch (type) {
    case WKMediaCaptureTypeCamera:
      return [FWFWKMediaCaptureTypeData makeWithValue:FWFWKMediaCaptureTypeCamera];
    case WKMediaCaptureTypeMicrophone:
      return [FWFWKMediaCaptureTypeData makeWithValue:FWFWKMediaCaptureTypeMicrophone];
    case WKMediaCaptureTypeCameraAndMicrophone:
      return [FWFWKMediaCaptureTypeData makeWithValue:FWFWKMediaCaptureTypeCameraAndMicrophone];
    default:
      return [FWFWKMediaCaptureTypeData makeWithValue:FWFWKMediaCaptureTypeUnknown];
  }

  return nil;
}

NSURLSessionAuthChallengeDisposition
FWFNativeNSURLSessionAuthChallengeDispositionFromFWFNSUrlSessionAuthChallengeDisposition(
    FWFNSUrlSessionAuthChallengeDisposition value) {
  switch (value) {
    case FWFNSUrlSessionAuthChallengeDispositionUseCredential:
      return NSURLSessionAuthChallengeUseCredential;
    case FWFNSUrlSessionAuthChallengeDispositionPerformDefaultHandling:
      return NSURLSessionAuthChallengePerformDefaultHandling;
    case FWFNSUrlSessionAuthChallengeDispositionCancelAuthenticationChallenge:
      return NSURLSessionAuthChallengeCancelAuthenticationChallenge;
    case FWFNSUrlSessionAuthChallengeDispositionRejectProtectionSpace:
      return NSURLSessionAuthChallengeRejectProtectionSpace;
  }

  return -1;
}

NSURLCredentialPersistence FWFNativeNSURLCredentialPersistenceFromFWFNSUrlCredentialPersistence(
    FWFNSUrlCredentialPersistence value) {
  switch (value) {
    case FWFNSUrlCredentialPersistenceNone:
      return NSURLCredentialPersistenceNone;
    case FWFNSUrlCredentialPersistenceSession:
      return NSURLCredentialPersistenceForSession;
    case FWFNSUrlCredentialPersistencePermanent:
      return NSURLCredentialPersistencePermanent;
    case FWFNSUrlCredentialPersistenceSynchronizable:
      return NSURLCredentialPersistenceSynchronizable;
  }

  return -1;
}
