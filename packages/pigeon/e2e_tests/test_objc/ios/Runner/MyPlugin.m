// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "MyPlugin.h"


@implementation MyPlugin

+ (void)registerWithRegistrar:(nonnull NSObject<FlutterPluginRegistrar> *)registrar {
  MyPlugin* instance = [[MyPlugin alloc] initWithRegistrar:registrar];
  [registrar publish:instance];
  ACApiSetup(registrar.messenger, instance);
}

- (instancetype)initWithRegistrar:(nonnull NSObject<FlutterPluginRegistrar> *)registrar {
  self = [super init];
  return self;
}

- (nonnull ACSearchReply *)search:(nonnull ACSearchRequest *)input error:(FlutterError * _Nullable __autoreleasing * _Nonnull)error {
  ACSearchReply* reply = [[ACSearchReply alloc] init];
  return reply;
}

- (void)detachFromEngineForRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  ACApiSetup(registrar.messenger, nil);
}

@end
