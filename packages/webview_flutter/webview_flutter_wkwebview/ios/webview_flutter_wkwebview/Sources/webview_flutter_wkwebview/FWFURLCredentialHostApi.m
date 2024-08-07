// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "./include/webview_flutter_wkwebview/FWFURLCredentialHostApi.h"

@interface FWFURLCredentialHostApiImpl ()
// BinaryMessenger must be weak to prevent a circular reference with the host API it
// references.
@property(nonatomic, weak) id<FlutterBinaryMessenger> binaryMessenger;
// InstanceManager must be weak to prevent a circular reference with the object it stores.
@property(nonatomic, weak) FWFInstanceManager *instanceManager;
@end

@implementation FWFURLCredentialHostApiImpl
- (instancetype)initWithBinaryMessenger:(id<FlutterBinaryMessenger>)binaryMessenger
                        instanceManager:(FWFInstanceManager *)instanceManager {
  self = [self init];
  if (self) {
    _binaryMessenger = binaryMessenger;
    _instanceManager = instanceManager;
  }
  return self;
}

- (void)createWithUserWithIdentifier:(NSInteger)identifier
                                user:(nonnull NSString *)user
                            password:(nonnull NSString *)password
                         persistence:(FWFNSUrlCredentialPersistence)persistence
                               error:(FlutterError *_Nullable __autoreleasing *_Nonnull)error {
  [self.instanceManager
      addDartCreatedInstance:
          [NSURLCredential
              credentialWithUser:user
                        password:password
                     persistence:
                         FWFNativeNSURLCredentialPersistenceFromFWFNSUrlCredentialPersistence(
                             persistence)]
              withIdentifier:identifier];
}

- (nullable NSURL *)credentialForIdentifier:(NSNumber *)identifier
                                      error:
                                          (FlutterError *_Nullable __autoreleasing *_Nonnull)error {
  NSURL *instance = (NSURL *)[self.instanceManager instanceForIdentifier:identifier.longValue];

  if (!instance) {
    NSString *message =
        [NSString stringWithFormat:@"InstanceManager does not contain an NSURL with identifier: %@",
                                   identifier];
    *error = [FlutterError errorWithCode:NSInternalInconsistencyException
                                 message:message
                                 details:nil];
  }

  return instance;
}
@end
