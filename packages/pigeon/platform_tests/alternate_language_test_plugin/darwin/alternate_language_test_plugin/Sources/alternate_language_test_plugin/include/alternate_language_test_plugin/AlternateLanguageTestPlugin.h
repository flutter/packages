// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#if TARGET_OS_OSX
#import <FlutterMacOS/FlutterMacOS.h>
#else
#import <Flutter/Flutter.h>
#endif

#import "CoreTests.gen.h"

@interface AlternateLanguageTestPlugin : NSObject <FlutterPlugin, FLTHostIntegrationCoreApi>
@end

@interface AlternateLanguageTestAPIWithSuffix : NSObject <FLTHostSmallApi>
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar
                       suffix:(NSString *)suffix;
@end
