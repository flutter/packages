// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "./include/webview_flutter_wkwebview/FWFWebViewHostApi.h"
#import "./include/webview_flutter_wkwebview/FWFDataConverters.h"

@implementation FWFAssetManager
- (NSString *)lookupKeyForAsset:(NSString *)asset {
  return [FlutterDartProject lookupKeyForAsset:asset];
}
@end

@implementation FWFWebView
- (instancetype)initWithFrame:(CGRect)frame
                configuration:(nonnull WKWebViewConfiguration *)configuration
              binaryMessenger:(id<FlutterBinaryMessenger>)binaryMessenger
              instanceManager:(FWFInstanceManager *)instanceManager {
  self = [self initWithFrame:frame configuration:configuration];
  if (self) {
    _objectApi = [[FWFObjectFlutterApiImpl alloc] initWithBinaryMessenger:binaryMessenger
                                                          instanceManager:instanceManager];

#if TARGET_OS_IOS
    self.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    if (@available(iOS 13.0, *)) {
      self.scrollView.automaticallyAdjustsScrollIndicatorInsets = NO;
    }
#endif
  }
  return self;
}

- (void)setFrame:(CGRect)frame {
  [super setFrame:frame];
#if TARGET_OS_IOS
  // Prevents the contentInsets from being adjusted by iOS and gives control to Flutter.
  self.scrollView.contentInset = UIEdgeInsetsZero;

  // Adjust contentInset to compensate the adjustedContentInset so the sum will
  // always be 0.
  if (UIEdgeInsetsEqualToEdgeInsets(self.scrollView.adjustedContentInset, UIEdgeInsetsZero)) {
    return;
  }
  UIEdgeInsets insetToAdjust = self.scrollView.adjustedContentInset;
  self.scrollView.contentInset = UIEdgeInsetsMake(-insetToAdjust.top, -insetToAdjust.left,
                                                  -insetToAdjust.bottom, -insetToAdjust.right);
#endif
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

#pragma mark FlutterPlatformView

#if TARGET_OS_IOS
- (nonnull UIView *)view {
  return self;
}
#endif
@end

@interface FWFWebViewHostApiImpl ()
// BinaryMessenger must be weak to prevent a circular reference with the host API it
// references.
@property(nonatomic, weak) id<FlutterBinaryMessenger> binaryMessenger;
// InstanceManager must be weak to prevent a circular reference with the object it stores.
@property(nonatomic, weak) FWFInstanceManager *instanceManager;
@property NSBundle *bundle;
@property FWFAssetManager *assetManager;
@end

@implementation FWFWebViewHostApiImpl
- (instancetype)initWithBinaryMessenger:(id<FlutterBinaryMessenger>)binaryMessenger
                        instanceManager:(FWFInstanceManager *)instanceManager {
  return [self initWithBinaryMessenger:binaryMessenger
                       instanceManager:instanceManager
                                bundle:[NSBundle mainBundle]
                          assetManager:[[FWFAssetManager alloc] init]];
}

- (instancetype)initWithBinaryMessenger:(id<FlutterBinaryMessenger>)binaryMessenger
                        instanceManager:(FWFInstanceManager *)instanceManager
                                 bundle:(NSBundle *)bundle
                           assetManager:(FWFAssetManager *)assetManager {
  self = [self init];
  if (self) {
    _binaryMessenger = binaryMessenger;
    _instanceManager = instanceManager;
    _bundle = bundle;
    _assetManager = assetManager;
  }
  return self;
}

- (FWFWebView *)webViewForIdentifier:(NSInteger)identifier {
  return (FWFWebView *)[self.instanceManager instanceForIdentifier:identifier];
}

+ (nonnull FlutterError *)errorForURLString:(nonnull NSString *)string {
  NSString *errorDetails = [NSString stringWithFormat:@"Initializing NSURL with the supplied "
                                                      @"'%@' path resulted in a nil value.",
                                                      string];
  return [FlutterError errorWithCode:@"FWFURLParsingError"
                             message:@"Failed parsing file path."
                             details:errorDetails];
}

- (void)createWithIdentifier:(NSInteger)identifier
     configurationIdentifier:(NSInteger)configurationIdentifier
                       error:(FlutterError *_Nullable __autoreleasing *_Nonnull)error {
  WKWebViewConfiguration *configuration = (WKWebViewConfiguration *)[self.instanceManager
      instanceForIdentifier:configurationIdentifier];
  FWFWebView *webView = [[FWFWebView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)
                                            configuration:configuration
                                          binaryMessenger:self.binaryMessenger
                                          instanceManager:self.instanceManager];
  [self.instanceManager addDartCreatedInstance:webView withIdentifier:identifier];
}

- (void)loadRequestForWebViewWithIdentifier:(NSInteger)identifier
                                    request:(nonnull FWFNSUrlRequestData *)request
                                      error:
                                          (FlutterError *_Nullable __autoreleasing *_Nonnull)error {
  NSURLRequest *urlRequest = FWFNativeNSURLRequestFromRequestData(request);
  if (!urlRequest) {
    *error = [FlutterError errorWithCode:@"FWFURLRequestParsingError"
                                 message:@"Failed instantiating an NSURLRequest."
                                 details:[NSString stringWithFormat:@"URL was: '%@'", request.url]];
    return;
  }
  [[self webViewForIdentifier:identifier] loadRequest:urlRequest];
}

- (void)setCustomUserAgentForWebViewWithIdentifier:(NSInteger)identifier
                                         userAgent:(nullable NSString *)userAgent
                                             error:
                                                 (FlutterError *_Nullable __autoreleasing *_Nonnull)
                                                     error {
  [[self webViewForIdentifier:identifier] setCustomUserAgent:userAgent];
}

- (nullable NSNumber *)
    canGoBackForWebViewWithIdentifier:(NSInteger)identifier
                                error:(FlutterError *_Nullable __autoreleasing *_Nonnull)error {
  return @([self webViewForIdentifier:identifier].canGoBack);
}

- (nullable NSString *)
    URLForWebViewWithIdentifier:(NSInteger)identifier
                          error:(FlutterError *_Nullable __autoreleasing *_Nonnull)error {
  return [self webViewForIdentifier:identifier].URL.absoluteString;
}

- (nullable NSNumber *)
    canGoForwardForWebViewWithIdentifier:(NSInteger)identifier
                                   error:(FlutterError *_Nullable __autoreleasing *_Nonnull)error {
  return @([[self webViewForIdentifier:identifier] canGoForward]);
}

- (nullable NSNumber *)
    estimatedProgressForWebViewWithIdentifier:(NSInteger)identifier
                                        error:(FlutterError *_Nullable __autoreleasing *_Nonnull)
                                                  error {
  return @([[self webViewForIdentifier:identifier] estimatedProgress]);
}

- (void)evaluateJavaScriptForWebViewWithIdentifier:(NSInteger)identifier
                                  javaScriptString:(nonnull NSString *)javaScriptString
                                        completion:
                                            (nonnull void (^)(id _Nullable,
                                                              FlutterError *_Nullable))completion {
  [[self webViewForIdentifier:identifier]
      evaluateJavaScript:javaScriptString
       completionHandler:^(id _Nullable result, NSError *_Nullable error) {
         id returnValue = nil;
         FlutterError *flutterError = nil;
         if (!error) {
           if (!result || [result isKindOfClass:[NSString class]] ||
               [result isKindOfClass:[NSNumber class]]) {
             returnValue = result;
           } else if (![result isKindOfClass:[NSNull class]]) {
             NSString *className = NSStringFromClass([result class]);
             NSLog(@"Return type of evaluateJavaScript is not directly supported: %@. Returned "
                   @"description of value.",
                   className);
             returnValue = [result description];
           }
         } else {
           flutterError = [FlutterError errorWithCode:@"FWFEvaluateJavaScriptError"
                                              message:@"Failed evaluating JavaScript."
                                              details:FWFNSErrorDataFromNativeNSError(error)];
         }

         completion(returnValue, flutterError);
       }];
}

- (void)setInspectableForWebViewWithIdentifier:(NSInteger)identifier
                                   inspectable:(BOOL)inspectable
                                         error:(FlutterError *_Nullable *_Nonnull)error {
  if (@available(macOS 13.3, iOS 16.4, tvOS 16.4, *)) {
#if __MAC_OS_X_VERSION_MAX_ALLOWED >= 130300 || __IPHONE_OS_VERSION_MAX_ALLOWED >= 160400
    [[self webViewForIdentifier:identifier] setInspectable:inspectable];
#endif
  } else {
    *error = [FlutterError errorWithCode:@"FWFUnsupportedVersionError"
                                 message:@"setInspectable is only supported on versions 16.4+."
                                 details:nil];
  }
}

- (void)goBackForWebViewWithIdentifier:(NSInteger)identifier
                                 error:(FlutterError *_Nullable __autoreleasing *_Nonnull)error {
  [[self webViewForIdentifier:identifier] goBack];
}

- (void)goForwardForWebViewWithIdentifier:(NSInteger)identifier
                                    error:(FlutterError *_Nullable __autoreleasing *_Nonnull)error {
  [[self webViewForIdentifier:identifier] goForward];
}

- (void)loadAssetForWebViewWithIdentifier:(NSInteger)identifier
                                 assetKey:(nonnull NSString *)key
                                    error:(FlutterError *_Nullable __autoreleasing *_Nonnull)error {
  NSString *assetFilePath = [self.assetManager lookupKeyForAsset:key];

  NSURL *url = [self.bundle URLForResource:[assetFilePath stringByDeletingPathExtension]
                             withExtension:assetFilePath.pathExtension];
  if (!url) {
    *error = [FWFWebViewHostApiImpl errorForURLString:assetFilePath];
  } else {
    [[self webViewForIdentifier:identifier] loadFileURL:url
                                allowingReadAccessToURL:[url URLByDeletingLastPathComponent]];
  }
}

- (void)loadFileForWebViewWithIdentifier:(NSInteger)identifier
                                 fileURL:(nonnull NSString *)url
                           readAccessURL:(nonnull NSString *)readAccessUrl
                                   error:(FlutterError *_Nullable __autoreleasing *_Nonnull)error {
  NSURL *fileURL = [NSURL fileURLWithPath:url isDirectory:NO];
  NSURL *readAccessNSURL = [NSURL fileURLWithPath:readAccessUrl isDirectory:YES];

  if (!fileURL) {
    *error = [FWFWebViewHostApiImpl errorForURLString:url];
  } else if (!readAccessNSURL) {
    *error = [FWFWebViewHostApiImpl errorForURLString:readAccessUrl];
  } else {
    [[self webViewForIdentifier:identifier] loadFileURL:fileURL
                                allowingReadAccessToURL:readAccessNSURL];
  }
}

- (void)loadHTMLForWebViewWithIdentifier:(NSInteger)identifier
                              HTMLString:(nonnull NSString *)string
                                 baseURL:(nullable NSString *)baseUrl
                                   error:(FlutterError *_Nullable __autoreleasing *_Nonnull)error {
  [[self webViewForIdentifier:identifier] loadHTMLString:string
                                                 baseURL:[NSURL URLWithString:baseUrl]];
}

- (void)reloadWebViewWithIdentifier:(NSInteger)identifier
                              error:(FlutterError *_Nullable __autoreleasing *_Nonnull)error {
  [[self webViewForIdentifier:identifier] reload];
}

- (void)
    setAllowsBackForwardForWebViewWithIdentifier:(NSInteger)identifier
                                       isAllowed:(BOOL)allow
                                           error:(FlutterError *_Nullable __autoreleasing *_Nonnull)
                                                     error {
  [[self webViewForIdentifier:identifier] setAllowsBackForwardNavigationGestures:allow];
}

- (void)
    setNavigationDelegateForWebViewWithIdentifier:(NSInteger)identifier
                               delegateIdentifier:(nullable NSNumber *)navigationDelegateIdentifier
                                            error:
                                                (FlutterError *_Nullable __autoreleasing *_Nonnull)
                                                    error {
  id<WKNavigationDelegate> navigationDelegate = (id<WKNavigationDelegate>)[self.instanceManager
      instanceForIdentifier:navigationDelegateIdentifier.longValue];
  [[self webViewForIdentifier:identifier] setNavigationDelegate:navigationDelegate];
}

- (void)setUIDelegateForWebViewWithIdentifier:(NSInteger)identifier
                           delegateIdentifier:(nullable NSNumber *)uiDelegateIdentifier
                                        error:(FlutterError *_Nullable __autoreleasing *_Nonnull)
                                                  error {
  id<WKUIDelegate> navigationDelegate =
      (id<WKUIDelegate>)[self.instanceManager instanceForIdentifier:uiDelegateIdentifier.longValue];
  [[self webViewForIdentifier:identifier] setUIDelegate:navigationDelegate];
}

- (nullable NSString *)
    titleForWebViewWithIdentifier:(NSInteger)identifier
                            error:(FlutterError *_Nullable __autoreleasing *_Nonnull)error {
  return [[self webViewForIdentifier:identifier] title];
}

- (nullable NSString *)
    customUserAgentForWebViewWithIdentifier:(NSInteger)identifier
                                      error:
                                          (FlutterError *_Nullable __autoreleasing *_Nonnull)error {
  return [[self webViewForIdentifier:identifier] customUserAgent];
}
@end
