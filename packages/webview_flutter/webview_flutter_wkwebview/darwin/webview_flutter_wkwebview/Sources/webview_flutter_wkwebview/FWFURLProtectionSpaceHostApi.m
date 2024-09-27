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
@end
