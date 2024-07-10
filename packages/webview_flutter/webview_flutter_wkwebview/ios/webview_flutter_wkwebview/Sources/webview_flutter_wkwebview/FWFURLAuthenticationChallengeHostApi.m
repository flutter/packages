// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "./include/webview_flutter_wkwebview/FWFURLAuthenticationChallengeHostApi.h"
#import "./include/webview_flutter_wkwebview/FWFURLProtectionSpaceHostApi.h"

@interface FWFURLAuthenticationChallengeFlutterApiImpl ()
// BinaryMessenger must be weak to prevent a circular reference with the host API it
// references.
@property(nonatomic, weak) id<FlutterBinaryMessenger> binaryMessenger;
// InstanceManager must be weak to prevent a circular reference with the object it stores.
@property(nonatomic, weak) FWFInstanceManager *instanceManager;
@end

@implementation FWFURLAuthenticationChallengeFlutterApiImpl
- (instancetype)initWithBinaryMessenger:(id<FlutterBinaryMessenger>)binaryMessenger
                        instanceManager:(FWFInstanceManager *)instanceManager {
  self = [self init];
  if (self) {
    _binaryMessenger = binaryMessenger;
    _instanceManager = instanceManager;
    _api =
        [[FWFNSUrlAuthenticationChallengeFlutterApi alloc] initWithBinaryMessenger:binaryMessenger];
  }
  return self;
}

- (void)createWithInstance:(NSURLAuthenticationChallenge *)instance
           protectionSpace:(NSURLProtectionSpace *)protectionSpace
                completion:(void (^)(FlutterError *_Nullable))completion {
  if ([self.instanceManager containsInstance:instance]) {
    return;
  }

  FWFURLProtectionSpaceFlutterApiImpl *protectionSpaceApi =
      [[FWFURLProtectionSpaceFlutterApiImpl alloc] initWithBinaryMessenger:self.binaryMessenger
                                                           instanceManager:self.instanceManager];
  [protectionSpaceApi createWithInstance:protectionSpace
                                    host:protectionSpace.host
                                   realm:protectionSpace.realm
                    authenticationMethod:protectionSpace.authenticationMethod
                              completion:^(FlutterError *error) {
                                NSAssert(!error, @"%@", error);
                              }];

  [self.api createWithIdentifier:[self.instanceManager addHostCreatedInstance:instance]
       protectionSpaceIdentifier:[self.instanceManager
                                     identifierWithStrongReferenceForInstance:protectionSpace]
                      completion:completion];
}
@end
