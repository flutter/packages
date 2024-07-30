// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <FlutterMacOS/FlutterMacOS.h>

#import "CoreTests.gen.h"

@interface AlternateLanguageTestPlugin : NSObject <FlutterPlugin, HostIntegrationCoreApi>
@end

@interface AlternateLanguageTestAPIWithSuffix : NSObject <HostSmallApi>
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar
                       suffix:(NSString *)suffix;
@end
