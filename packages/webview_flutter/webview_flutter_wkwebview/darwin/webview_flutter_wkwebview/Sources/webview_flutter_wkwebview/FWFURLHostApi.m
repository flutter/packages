// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "./include/webview_flutter_wkwebview/FWFURLHostApi.h"

@interface FWFURLHostApiImpl ()
// BinaryMessenger must be weak to prevent a circular reference with the host API it
// references.
@property(nonatomic, weak) id<FlutterBinaryMessenger> binaryMessenger;
// InstanceManager must be weak to prevent a circular reference with the object it stores.
@property(nonatomic, weak) FWFInstanceManager *instanceManager;
@end

@interface FWFURLFlutterApiImpl ()
// InstanceManager must be weak to prevent a circular reference with the object it stores.
@property(nonatomic, weak) FWFInstanceManager *instanceManager;
@end

@implementation FWFURLHostApiImpl
- (instancetype)initWithBinaryMessenger:(id<FlutterBinaryMessenger>)binaryMessenger
                        instanceManager:(FWFInstanceManager *)instanceManager {
  self = [self init];
  if (self) {
    _binaryMessenger = binaryMessenger;
    _instanceManager = instanceManager;
  }
  return self;
}

- (nullable NSString *)
    absoluteStringForNSURLWithIdentifier:(NSInteger)identifier
                                   error:(FlutterError *_Nullable __autoreleasing *_Nonnull)error {
  NSURL *instance = [self urlForIdentifier:identifier error:error];
  if (*error) {
    return nil;
  }

  return instance.absoluteString;
}

- (nullable NSURL *)urlForIdentifier:(NSInteger)identifier
                               error:(FlutterError *_Nullable __autoreleasing *_Nonnull)error {
  NSURL *instance = (NSURL *)[self.instanceManager instanceForIdentifier:identifier];

  if (!instance) {
    NSString *message = [NSString
        stringWithFormat:@"InstanceManager does not contain an NSURL with identifier: %li",
                         (long)identifier];
    *error = [FlutterError errorWithCode:NSInternalInconsistencyException
                                 message:message
                                 details:nil];
  }

  return instance;
}
@end

@implementation FWFURLFlutterApiImpl
- (instancetype)initWithBinaryMessenger:(id<FlutterBinaryMessenger>)binaryMessenger
                        instanceManager:(FWFInstanceManager *)instanceManager {
  self = [self init];
  if (self) {
    _instanceManager = instanceManager;
    _api = [[FWFNSUrlFlutterApi alloc] initWithBinaryMessenger:binaryMessenger];
  }
  return self;
}

- (void)create:(NSURL *)instance completion:(void (^)(FlutterError *_Nullable))completion {
  [self.api createWithIdentifier:[self.instanceManager addHostCreatedInstance:instance]
                      completion:completion];
}
@end
