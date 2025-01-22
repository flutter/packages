// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <XCTest/XCTest.h>
#import <os/log.h>

const int kElementWaitingTime = 30;

@interface ImagePickerFromGalleryUITests : XCTestCase

@property(nonatomic, strong) XCUIApplication *app;

@property(nonatomic, assign) BOOL interceptedPermissionInterruption;

@end

@implementation ImagePickerFromGalleryUITests

- (void)setUp {
  [super setUp];

  self.continueAfterFailure = NO;
  self.app = [[XCUIApplication alloc] init];
  if (@available(iOS 13.4, *)) {
    // Reset the authorization status for Photos to test permission popups
    [self.app resetAuthorizationStatusForResource:XCUIProtectedResourcePhotos];
  }
  [self.app launch];
  self.interceptedPermissionInterruption = NO;
  __weak typeof(self) weakSelf = self;
  [self addUIInterruptionMonitorWithDescription:@"Permission popups"
                                        handler:^BOOL(XCUIElement *_Nonnull interruptingElement) {
                                          if (@available(iOS 14, *)) {
                                            XCUIElement *allPhotoPermission =
                                                interruptingElement
                                                    .buttons[weakSelf.allowAccessPermissionText];
                                            if (![allPhotoPermission waitForExistenceWithTimeout:
                                                                         kElementWaitingTime]) {
                                              os_log_error(OS_LOG_DEFAULT, "%@",
                                                           weakSelf.app.debugDescription);
                                              XCTFail(@"Failed due to not able to find "
                                                      @"allPhotoPermission button with %@ seconds",
                                                      @(kElementWaitingTime));
                                            }
                                            [allPhotoPermission tap];
                                          } else {
                                            XCUIElement *ok = interruptingElement.buttons[@"OK"];
                                            if (![ok waitForExistenceWithTimeout:
                                                         kElementWaitingTime]) {
                                              os_log_error(OS_LOG_DEFAULT, "%@",
                                                           weakSelf.app.debugDescription);
                                              XCTFail(@"Failed due to not able to find ok button "
                                                      @"with %@ seconds",
                                                      @(kElementWaitingTime));
                                            }
                                            [ok tap];
                                          }
                                          weakSelf.interceptedPermissionInterruption = YES;
                                          return YES;
                                        }];
}

- (void)tearDown {
  [super tearDown];
  [self.app terminate];
}

- (NSString *)allowAccessPermissionText {
  NSString *fullAccessButtonText = @"Allow Access to All Photos";
  if (@available(iOS 17, *)) {
    fullAccessButtonText = @"Allow Full Access";
  }
  return fullAccessButtonText;
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
    if ([cancelButton waitForExistenceWithTimeout:kElementWaitingTime]) {
      return;
    }

    XCUIApplication *springboardApp =
        [[XCUIApplication alloc] initWithBundleIdentifier:@"com.apple.springboard"];
    XCUIElement *allowButton = springboardApp.buttons[self.allowAccessPermissionText];
    if (![allowButton waitForExistenceWithTimeout:kElementWaitingTime]) {
      os_log_error(OS_LOG_DEFAULT, "%@", self.app.debugDescription);
      XCTFail(@"Failed due to not able to find Allow Access button with %@ seconds",
              @(kElementWaitingTime));
    }
    [allowButton tap];
  }
}

- (void)testCancel {
  // Find and tap on the pick from gallery button.
  XCUIElement *imageFromGalleryButton =
      self.app.otherElements[@"image_picker_example_from_gallery"].firstMatch;
  if (![imageFromGalleryButton waitForExistenceWithTimeout:kElementWaitingTime]) {
    os_log_error(OS_LOG_DEFAULT, "%@", self.app.debugDescription);
    XCTFail(@"Failed due to not able to find image from gallery button with %@ seconds",
            @(kElementWaitingTime));
  }

  [imageFromGalleryButton tap];

  // Find and tap on the `pick` button.
  XCUIElement *pickButton = self.app.buttons[@"PICK"].firstMatch;
  if (![pickButton waitForExistenceWithTimeout:kElementWaitingTime]) {
    os_log_error(OS_LOG_DEFAULT, "%@", self.app.debugDescription);
    XCTFail(@"Failed due to not able to find pick button with %@ seconds", @(kElementWaitingTime));
  }

  [pickButton tap];

  [self handlePermissionInterruption];

  // Find and tap on the `Cancel` button.
  XCUIElement *cancelButton = self.app.buttons[@"Cancel"].firstMatch;
  if (![cancelButton waitForExistenceWithTimeout:kElementWaitingTime]) {
    os_log_error(OS_LOG_DEFAULT, "%@", self.app.debugDescription);
    XCTFail(@"Failed due to not able to find Cancel button with %@ seconds",
            @(kElementWaitingTime));
  }

  [cancelButton tap];

  // Find the "not picked image text".
  XCUIElement *imageNotPickedText =
      self.app.staticTexts[@"You have not yet picked an image."].firstMatch;
  if (![imageNotPickedText waitForExistenceWithTimeout:kElementWaitingTime]) {
    os_log_error(OS_LOG_DEFAULT, "%@", self.app.debugDescription);
    XCTFail(@"Failed due to not able to find imageNotPickedText with %@ seconds",
            @(kElementWaitingTime));
  }
}

- (void)testPickingFromGallery {
  [self launchPickerAndPickWithMaxWidth:nil maxHeight:nil quality:nil];
}

- (void)testPickingWithContraintsFromGallery {
  [self launchPickerAndPickWithMaxWidth:@200 maxHeight:@100 quality:@50];
}

- (void)launchPickerAndPickWithMaxWidth:(NSNumber *)maxWidth
                              maxHeight:(NSNumber *)maxHeight
                                quality:(NSNumber *)quality {
  // Find and tap on the pick from gallery button.
  XCUIElement *imageFromGalleryButton =
      self.app.otherElements[@"image_picker_example_from_gallery"].firstMatch;
  if (![imageFromGalleryButton waitForExistenceWithTimeout:kElementWaitingTime]) {
    os_log_error(OS_LOG_DEFAULT, "%@", self.app.debugDescription);
    XCTFail(@"Failed due to not able to find image from gallery button with %@ seconds",
            @(kElementWaitingTime));
  }
  [imageFromGalleryButton tap];

  if (maxWidth != nil) {
    XCUIElement *field = self.app.textFields[@"Enter maxWidth if desired"].firstMatch;
    [field tap];
    [field typeText:maxWidth.stringValue];
  }

  if (maxHeight != nil) {
    XCUIElement *field = self.app.textFields[@"Enter maxHeight if desired"].firstMatch;
    [field tap];
    [field typeText:maxHeight.stringValue];
  }

  if (quality != nil) {
    XCUIElement *field = self.app.textFields[@"Enter quality if desired"].firstMatch;
    [field tap];
    [field typeText:quality.stringValue];
  }

  // Find and tap on the `pick` button.
  XCUIElement *pickButton = self.app.buttons[@"PICK"].firstMatch;
  if (![pickButton waitForExistenceWithTimeout:kElementWaitingTime]) {
    os_log_error(OS_LOG_DEFAULT, "%@", self.app.debugDescription);
    XCTFail(@"Failed due to not able to find pick button with %@ seconds", @(kElementWaitingTime));
  }
  [pickButton tap];

  [self handlePermissionInterruption];

  // Find an image and tap on it. (IOS 14 UI, images are showing directly)
  XCUIElement *aImage;
  if (@available(iOS 14, *)) {
    NSPredicate *imagePredicate = [NSPredicate predicateWithFormat:@"label BEGINSWITH 'Photo, '"];
    aImage = [self.app.images matchingPredicate:imagePredicate].firstMatch;
  } else {
    XCUIElement *allPhotosCell = self.app.cells[@"All Photos"].firstMatch;
    if (![allPhotosCell waitForExistenceWithTimeout:kElementWaitingTime]) {
      os_log_error(OS_LOG_DEFAULT, "%@", self.app.debugDescription);
      XCTFail(@"Failed due to not able to find \"All Photos\" cell with %@ seconds",
              @(kElementWaitingTime));
    }
    [allPhotosCell tap];
    aImage = [self.app.collectionViews elementMatchingType:XCUIElementTypeCollectionView
                                                identifier:@"PhotosGridView"]
                 .cells.firstMatch;
  }
  os_log_error(OS_LOG_DEFAULT, "description before picking image %@", self.app.debugDescription);
  if (![aImage waitForExistenceWithTimeout:kElementWaitingTime]) {
    os_log_error(OS_LOG_DEFAULT, "%@", self.app.debugDescription);
    XCTFail(@"Failed due to not able to find an image with %@ seconds", @(kElementWaitingTime));
  }
  [aImage tap];

  // Find the picked image.
  XCUIElement *pickedImage = self.app.images[@"image_picker_example_picked_image"].firstMatch;
  if (![pickedImage waitForExistenceWithTimeout:kElementWaitingTime]) {
    os_log_error(OS_LOG_DEFAULT, "%@", self.app.debugDescription);
    XCTFail(@"Failed due to not able to find pickedImage with %@ seconds", @(kElementWaitingTime));
  }
}

@end
