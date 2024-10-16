// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "./include/webview_flutter_wkwebview/FWFURLProtectionSpaceHostApi.h"

@interface FWFURLProtectionSpaceFlutterApiImpl ()
// InstanceManager must be weak to prevent a circular reference with the object it stores.
@property(nonatomic, weak) FWFInstanceManager *instanceManager;
@end

@implementation FWFURLProtectionSpaceFlutterApiImpl
- (instancetype)initWithBinaryMessenger:(id<FlutterBinaryMessenger>)binaryMessenger
                        instanceManager:(FWFInstanceManager *)instanceManager {
  self = [self init];
  if (self) {
    _instanceManager = instanceManager;
    _api = [[FWFNSUrlProtectionSpaceFlutterApi alloc] initWithBinaryMessenger:binaryMessenger];
  }
  return self;
}

- (void)createWithInstance:(NSURLProtectionSpace *)instance
                      host:(nullable NSString *)host
                     realm:(nullable NSString *)realm
      authenticationMethod:(nullable NSString *)authenticationMethod
                completion:(void (^)(FlutterError *_Nullable))completion {
  if (![self.instanceManager containsInstance:instance]) {
    [self.api createWithIdentifier:[self.instanceManager addHostCreatedInstance:instance]
                              host:host
                             realm:realm
              authenticationMethod:authenticationMethod
                        completion:completion];
  }
}

- (void)createWithInstance:(NSURLProtectionSpace *)instance
                      sslErrorTypeBoxed:(nullable FWFSslErrorTypeDataBox *) sslErrorTypeBoxed
        x509CertificateDer:(FlutterStandardTypedData *) x509CertificateDer
                  protocol:(nullable NSString *)protocol
                  host:(nullable NSString *)host
                  port:(NSInteger)port
                completion:(void (^)(FlutterError *_Nullable))completion {
  if (![self.instanceManager containsInstance:instance]) {
    [self.api createWithIdentifier:[self.instanceManager addHostCreatedInstance:instance]
            sslErrorType:sslErrorTypeBoxed
      x509CertificateDer:x509CertificateDer
                          protocol:protocol
                             host:host
                              port:port
                        completion:completion];
  }
}

@end
