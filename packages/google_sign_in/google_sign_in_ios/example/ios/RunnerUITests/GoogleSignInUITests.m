// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import os.log;
@import XCTest;

@interface GoogleSignInUITests : XCTestCase
@property(nonatomic, strong) XCUIApplication *app;
@end

@implementation GoogleSignInUITests

- (void)setUp {
  self.continueAfterFailure = NO;

  self.app = [[XCUIApplication alloc] init];
  [self.app launch];
}

- (void)testSignInPopUp {
  XCUIApplication *app = self.app;

  XCUIElement *signInButton = app.buttons[@"SIGN IN"];
  if (![signInButton waitForExistenceWithTimeout:30.0]) {
    os_log_error(OS_LOG_DEFAULT, "%@", app.debugDescription);
    XCTFail(@"Failed due to not able to find Sign In button");
  }
  [signInButton tap];

  [self allowSignInPermissions];
}

- (void)allowSignInPermissions {
  // The "Sign In" system permissions pop up isn't caught by
  // addUIInterruptionMonitorWithDescription.
  XCUIApplication *springboard =
      [[XCUIApplication alloc] initWithBundleIdentifier:@"com.apple.springboard"];
  XCUIElement *permissionAlert = springboard.alerts.firstMatch;
  if ([permissionAlert waitForExistenceWithTimeout:5.0]) {
    // The alert is titled in the simulator's language, so the confirmation
    // button can't be looked up by name. It is the last of the alert's two
    // buttons ("Cancel" and "Continue") in every localization.
    XCUIElementQuery *alertButtons = permissionAlert.buttons;
    NSUInteger buttonCount = alertButtons.count;
    if (buttonCount == 0) {
      XCTFail(@"Sign In permission alert has no buttons");
    }
    [[alertButtons elementBoundByIndex:buttonCount - 1] tap];
  } else {
    os_log(OS_LOG_DEFAULT, "Permission alert not detected, continuing.");
  }
}

@end
