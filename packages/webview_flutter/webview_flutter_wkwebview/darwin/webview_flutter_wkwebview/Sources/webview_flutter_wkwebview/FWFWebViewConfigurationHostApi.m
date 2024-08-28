// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "./include/webview_flutter_wkwebview/FWFWebViewConfigurationHostApi.h"
#import "./include/webview_flutter_wkwebview/FWFDataConverters.h"
#import "./include/webview_flutter_wkwebview/FWFWebViewConfigurationHostApi.h"

@interface FWFWebViewConfigurationFlutterApiImpl ()
// InstanceManager must be weak to prevent a circular reference with the object it stores.
@property(nonatomic, weak) FWFInstanceManager *instanceManager;
@end

@implementation FWFWebViewConfigurationFlutterApiImpl
- (instancetype)initWithBinaryMessenger:(id<FlutterBinaryMessenger>)binaryMessenger
                        instanceManager:(FWFInstanceManager *)instanceManager {
  self = [self initWithBinaryMessenger:binaryMessenger];
  if (self) {
    _instanceManager = instanceManager;
  }
  return self;
}

- (void)createWithConfiguration:(WKWebViewConfiguration *)configuration
                     completion:(void (^)(FlutterError *_Nullable))completion {
  long identifier = [self.instanceManager addHostCreatedInstance:configuration];
  [self createWithIdentifier:identifier completion:completion];
}
@end

@implementation FWFWebViewConfiguration
- (instancetype)initWithBinaryMessenger:(id<FlutterBinaryMessenger>)binaryMessenger
                        instanceManager:(FWFInstanceManager *)instanceManager {
  self = [self init];
  if (self) {
    _objectApi = [[FWFObjectFlutterApiImpl alloc] initWithBinaryMessenger:binaryMessenger
                                                          instanceManager:instanceManager];
  }
  return self;
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSKeyValueChangeKey, id> *)change
                       context:(void *)context {
  [self.objectApi observeValueForObject:self
                                keyPath:keyPath
                                 object:object
                                 change:change
                             completion:^(FlutterError *error) {
                               NSAssert(!error, @"%@", error);
                             }];
}
@end

@interface FWFWebViewConfigurationHostApiImpl ()
// BinaryMessenger must be weak to prevent a circular reference with the host API it
// references.
@property(nonatomic, weak) id<FlutterBinaryMessenger> binaryMessenger;
// InstanceManager must be weak to prevent a circular reference with the object it stores.
@property(nonatomic, weak) FWFInstanceManager *instanceManager;
@end

@implementation FWFWebViewConfigurationHostApiImpl
- (instancetype)initWithBinaryMessenger:(id<FlutterBinaryMessenger>)binaryMessenger
                        instanceManager:(FWFInstanceManager *)instanceManager {
  self = [self init];
  if (self) {
    _binaryMessenger = binaryMessenger;
    _instanceManager = instanceManager;
  }
  return self;
}

- (WKWebViewConfiguration *)webViewConfigurationForIdentifier:(NSInteger)identifier {
  return (WKWebViewConfiguration *)[self.instanceManager instanceForIdentifier:identifier];
}

- (void)createWithIdentifier:(NSInteger)identifier error:(FlutterError *_Nullable *_Nonnull)error {
  FWFWebViewConfiguration *webViewConfiguration =
      [[FWFWebViewConfiguration alloc] initWithBinaryMessenger:self.binaryMessenger
                                               instanceManager:self.instanceManager];
  [self.instanceManager addDartCreatedInstance:webViewConfiguration withIdentifier:identifier];
}

- (void)createFromWebViewWithIdentifier:(NSInteger)identifier
                      webViewIdentifier:(NSInteger)webViewIdentifier
                                  error:(FlutterError *_Nullable __autoreleasing *_Nonnull)error {
  WKWebView *webView = (WKWebView *)[self.instanceManager instanceForIdentifier:webViewIdentifier];
  [self.instanceManager addDartCreatedInstance:webView.configuration withIdentifier:identifier];
}

- (void)setAllowsInlineMediaPlaybackForConfigurationWithIdentifier:(NSInteger)identifier
                                                         isAllowed:(BOOL)allow
                                                             error:
                                                                 (FlutterError *_Nullable *_Nonnull)
                                                                     error {
#if TARGET_OS_IOS
  [[self webViewConfigurationForIdentifier:identifier] setAllowsInlineMediaPlayback:allow];
#endif
  // No-op, rather than error out, on macOS, since it's not a meaningful option on macOS and it's
  // easier for clients if it's just ignored.
}

- (void)setLimitsNavigationsToAppBoundDomainsForConfigurationWithIdentifier:(NSInteger)identifier
                                                                  isLimited:(BOOL)limit
                                                                      error:(FlutterError *_Nullable
                                                                                 *_Nonnull)error {
  if (@available(iOS 14, macOS 11, *)) {
    [[self webViewConfigurationForIdentifier:identifier]
        setLimitsNavigationsToAppBoundDomains:limit];
  } else {
    *error = [FlutterError errorWithCode:@"FWFUnsupportedVersionError"
                                 message:@"setLimitsNavigationsToAppBoundDomains is only supported "
                                         @"on iOS 14+ and macOS 11+."
                                 details:nil];
  }
}

- (void)
    setMediaTypesRequiresUserActionForConfigurationWithIdentifier:(NSInteger)identifier
                                                         forTypes:
                                                             (nonnull NSArray<
                                                                 FWFWKAudiovisualMediaTypeEnumData
                                                                     *> *)types
                                                            error:
                                                                (FlutterError *_Nullable *_Nonnull)
                                                                    error {
  NSAssert(types.count, @"Types must not be empty.");

  WKWebViewConfiguration *configuration =
      (WKWebViewConfiguration *)[self webViewConfigurationForIdentifier:identifier];
  WKAudiovisualMediaTypes typesInt = 0;
  for (FWFWKAudiovisualMediaTypeEnumData *data in types) {
    typesInt |= FWFNativeWKAudiovisualMediaTypeFromEnumData(data);
  }
  [configuration setMediaTypesRequiringUserActionForPlayback:typesInt];
}
@end
