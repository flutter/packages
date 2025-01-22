// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "./include/webview_flutter_wkwebview/FWFHTTPCookieStoreHostApi.h"
#import "./include/webview_flutter_wkwebview/FWFDataConverters.h"
#import "./include/webview_flutter_wkwebview/FWFWebsiteDataStoreHostApi.h"

@interface FWFHTTPCookieStoreHostApiImpl ()
// InstanceManager must be weak to prevent a circular reference with the object it stores.
@property(nonatomic, weak) FWFInstanceManager *instanceManager;
@end

@implementation FWFHTTPCookieStoreHostApiImpl
- (instancetype)initWithInstanceManager:(FWFInstanceManager *)instanceManager {
  self = [self init];
  if (self) {
    _instanceManager = instanceManager;
  }
  return self;
}

- (WKHTTPCookieStore *)HTTPCookieStoreForIdentifier:(NSInteger)identifier {
  return (WKHTTPCookieStore *)[self.instanceManager instanceForIdentifier:identifier];
}

- (void)createFromWebsiteDataStoreWithIdentifier:(NSInteger)identifier
                             dataStoreIdentifier:(NSInteger)websiteDataStoreIdentifier
                                           error:(FlutterError *_Nullable __autoreleasing *_Nonnull)
                                                     error {
  WKWebsiteDataStore *dataStore =
      (WKWebsiteDataStore *)[self.instanceManager instanceForIdentifier:websiteDataStoreIdentifier];
  [self.instanceManager addDartCreatedInstance:dataStore.httpCookieStore withIdentifier:identifier];
}

- (void)setCookieForStoreWithIdentifier:(NSInteger)identifier
                                 cookie:(nonnull FWFNSHttpCookieData *)cookie
                             completion:(nonnull void (^)(FlutterError *_Nullable))completion {
  NSHTTPCookie *nsCookie = FWFNativeNSHTTPCookieFromCookieData(cookie);

  [[self HTTPCookieStoreForIdentifier:identifier] setCookie:nsCookie
                                          completionHandler:^{
                                            completion(nil);
                                          }];
}
@end
