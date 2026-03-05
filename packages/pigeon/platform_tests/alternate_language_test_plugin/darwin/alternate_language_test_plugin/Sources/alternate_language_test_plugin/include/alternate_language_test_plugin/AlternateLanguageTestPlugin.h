// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#if !defined(TARGET_OS_OSX) || TARGET_OS_OSX == 1
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
