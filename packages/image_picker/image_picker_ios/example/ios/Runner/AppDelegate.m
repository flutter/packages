// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#include "AppDelegate.h"
#include "GeneratedPluginRegistrant.h"

@import Photos;
@import os.log;

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  [GeneratedPluginRegistrant registerWithRegistry:self];
  if (@available(iOS 14, *)) {
    // Seed the photo library with at least one image for tests to operate on.
    NSString *photoAddedKey = @"PhotoAdded";
    BOOL photoAdded = [NSUserDefaults.standardUserDefaults boolForKey:photoAddedKey];
    if (!photoAdded) {
      NSBundle *bundle = [NSBundle bundleForClass:[self class]];
      __block NSError *saveError = nil;
      [PHPhotoLibrary
          requestAuthorizationForAccessLevel:PHAccessLevelAddOnly
                                     handler:^(PHAuthorizationStatus status) {
                                       if ([PHPhotoLibrary.sharedPhotoLibrary
                                               performChangesAndWait:^{
                                                 NSURL *jpgImageTall =
                                                     [bundle URLForResource:@"jpgImageTall"
                                                              withExtension:@"jpg"];
                                                 [PHAssetChangeRequest
                                                     creationRequestForAssetFromImageAtFileURL:
                                                         jpgImageTall];
                                               }
                                                               error:&saveError]) {
                                         [NSUserDefaults.standardUserDefaults
                                             setBool:YES
                                              forKey:photoAddedKey];
                                       } else {
                                         os_log_error(OS_LOG_DEFAULT, "%@", saveError);
                                       }
                                     }];
    }
  }
  return [super application:application didFinishLaunchingWithOptions:launchOptions];
}

@end
