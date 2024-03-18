// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <Flutter/Flutter.h>

#import "CoreTests.gen.h"

@interface AlternateLanguageTestPlugin : NSObject <FlutterPlugin, FLTHostIntegrationCoreApi>
@end

@interface AlternateLanguageTestAPIWithSuffix : NSObject <FLTHostSmallApi>
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar
                       suffix:(NSString *)suffix;
@end
