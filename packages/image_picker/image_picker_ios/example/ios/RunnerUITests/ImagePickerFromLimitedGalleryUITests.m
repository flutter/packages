// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <XCTest/XCTest.h>
#import <os/log.h>

const int kLimitedElementWaitingTime = 30;

@interface ImagePickerFromLimitedGalleryUITests : XCTestCase

@property(nonatomic, strong) XCUIApplication *app;

@property(nonatomic, assign) BOOL interceptedPermissionInterruption;

@end

@implementation ImagePickerFromLimitedGalleryUITests

- (void)setUp {
  [super setUp];

  self.continueAfterFailure = NO;
  self.app = [[XCUIApplication alloc] init];
  if (@available(iOS 13.4, *)) {
    // Reset the authorization status for Photos to test permission popups
    [self.app resetAuthorizationStatusForResource:XCUIProtectedResourcePhotos];
  }
  [self.app launch];
  __weak typeof(self) weakSelf = self;
  [self addUIInterruptionMonitorWithDescription:@"Permission popups"
                                        handler:^BOOL(XCUIElement *_Nonnull interruptingElement) {
                                          XCUIElement *limitedPhotoPermission =
                                              [interruptingElement.buttons elementBoundByIndex:0];
                                          if (![limitedPhotoPermission
                                                  waitForExistenceWithTimeout:
                                                      kLimitedElementWaitingTime]) {
                                            os_log_error(OS_LOG_DEFAULT, "%@",
                                                         weakSelf.app.debugDescription);
                                            XCTFail(@"Failed due to not able to find "
                                                    @"selectPhotos button with %@ seconds",
                                                    @(kLimitedElementWaitingTime));
                                          }
                                          [limitedPhotoPermission tap];
                                          weakSelf.interceptedPermissionInterruption = YES;
                                          return YES;
                                        }];
}

- (void)tearDown {
  [super tearDown];
  [self.app terminate];
}

- (void)handlePermissionInterruption {
  // addUIInterruptionMonitorWithDescription is only invoked when trying to interact with an element
  // (the app in this case) the alert is blocking. We expect a permission popup here so do a swipe
  // up action (which should be harmless).
  [self.app swipeUp];

  if (@available(iOS 17, *)) {
    // addUIInterruptionMonitorWithDescription does not work consistently on Xcode 15 simulators, so
    // use a backup method of accepting permissions popup.

    if (self.interceptedPermissionInterruption == YES) {
      return;
    }

    // If cancel button exists, permission has already been given.
    XCUIElement *cancelButton = self.app.buttons[@"Cancel"].firstMatch;
    if ([cancelButton waitForExistenceWithTimeout:kLimitedElementWaitingTime]) {
      return;
    }

    XCUIApplication *springboardApp =
        [[XCUIApplication alloc] initWithBundleIdentifier:@"com.apple.springboard"];
    XCUIElement *allowButton = springboardApp.buttons[@"Limit Access…"];
    if (![allowButton waitForExistenceWithTimeout:kLimitedElementWaitingTime]) {
      os_log_error(OS_LOG_DEFAULT, "%@", self.app.debugDescription);
      XCTFail(@"Failed due to not able to find Limit Access button with %@ seconds",
              @(kLimitedElementWaitingTime));
    }
    [allowButton tap];
  }
}

// Test the `Select Photos` button which is available after iOS 14.
- (void)testSelectingFromGallery API_AVAILABLE(ios(14)) {
  // Find and tap on the pick from gallery button.
  XCUIElement *imageFromGalleryButton =
      self.app.otherElements[@"image_picker_example_from_gallery"].firstMatch;
  if (![imageFromGalleryButton waitForExistenceWithTimeout:kLimitedElementWaitingTime]) {
    os_log_error(OS_LOG_DEFAULT, "%@", self.app.debugDescription);
    XCTFail(@"Failed due to not able to find image from gallery button with %@ seconds",
            @(kLimitedElementWaitingTime));
  }
  [imageFromGalleryButton tap];

  // Find and tap on the `pick` button.
  XCUIElement *pickButton = self.app.buttons[@"PICK"].firstMatch;
  if (![pickButton waitForExistenceWithTimeout:kLimitedElementWaitingTime]) {
    os_log_error(OS_LOG_DEFAULT, "%@", self.app.debugDescription);
    XCTSkip(@"Pick button isn't found so the test is skipped...");
  }
  [pickButton tap];

  // Find an image and tap on it.
  NSPredicate *imagePredicate = [NSPredicate predicateWithFormat:@"label BEGINSWITH 'Photo, '"];
  XCUIElementQuery *imageQuery = [self.app.images matchingPredicate:imagePredicate];
  XCUIElement *aImage = imageQuery.firstMatch;
  os_log_error(OS_LOG_DEFAULT, "description before picking image %@", self.app.debugDescription);
  if (![aImage waitForExistenceWithTimeout:kLimitedElementWaitingTime]) {
    os_log_error(OS_LOG_DEFAULT, "%@", self.app.debugDescription);
    XCTFail(@"Failed due to not able to find an image with %@ seconds",
            @(kLimitedElementWaitingTime));
  }

  [aImage tap];

  // Find the picked image.
  XCUIElement *pickedImage = self.app.images[@"image_picker_example_picked_image"].firstMatch;
  if (![pickedImage waitForExistenceWithTimeout:kLimitedElementWaitingTime]) {
    os_log_error(OS_LOG_DEFAULT, "%@", self.app.debugDescription);
    XCTFail(@"Failed due to not able to find pickedImage with %@ seconds",
            @(kLimitedElementWaitingTime));
  }
}

@end
