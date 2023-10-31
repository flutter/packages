// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import os.log;
@import XCTest;
@import CoreGraphics;

@interface VideoPlayerUITests : XCTestCase
@property(nonatomic, strong) XCUIApplication *app;
@end

@implementation VideoPlayerUITests

- (void)setUp {
  self.continueAfterFailure = NO;

  self.app = [[XCUIApplication alloc] init];
  [self.app launch];
}

- (void)testPlayVideo {
  XCUIApplication *app = self.app;

  XCUIElement *remoteTab = [app.otherElements
      elementMatchingPredicate:[NSPredicate predicateWithFormat:@"selected == YES"]];
  XCTAssertTrue([remoteTab waitForExistenceWithTimeout:30.0]);
  XCTAssertTrue([remoteTab.label containsString:@"Remote"]);

  XCUIElement *playButton = app.staticTexts[@"Play"];
  XCTAssertTrue([playButton waitForExistenceWithTimeout:30.0]);
  [playButton tap];

  NSPredicate *find1xButton = [NSPredicate predicateWithFormat:@"label CONTAINS '1.0x'"];
  XCUIElement *playbackSpeed1x = [app.staticTexts elementMatchingPredicate:find1xButton];
  BOOL foundPlaybackSpeed1x = [playbackSpeed1x waitForExistenceWithTimeout:30.0];
  XCTAssertTrue(foundPlaybackSpeed1x);
  [playbackSpeed1x tap];

  XCUIElement *playbackSpeed5xButton = app.buttons[@"5.0x"];
  XCTAssertTrue([playbackSpeed5xButton waitForExistenceWithTimeout:30.0]);
  [playbackSpeed5xButton tap];

  NSPredicate *find5xButton = [NSPredicate predicateWithFormat:@"label CONTAINS '5.0x'"];
  XCUIElement *playbackSpeed5x = [app.staticTexts elementMatchingPredicate:find5xButton];
  BOOL foundPlaybackSpeed5x = [playbackSpeed5x waitForExistenceWithTimeout:30.0];
  XCTAssertTrue(foundPlaybackSpeed5x);

  //  // Cycle through tabs.
  for (NSString *tabName in @[ @"Remote cache mp4", @"Remote enc m3u8", @"Asset mp4" ]) {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"label BEGINSWITH %@", tabName];
    XCUIElement *unselectedTab = [app.staticTexts elementMatchingPredicate:predicate];
    XCTAssertTrue([unselectedTab waitForExistenceWithTimeout:30.0]);
    XCTAssertFalse(unselectedTab.isSelected);
    [unselectedTab tap];

    XCUIElement *selectedTab = [app.otherElements
        elementMatchingPredicate:[NSPredicate predicateWithFormat:@"label BEGINSWITH %@", tabName]];
    XCTAssertTrue([selectedTab waitForExistenceWithTimeout:30.0]);
    XCTAssertTrue(selectedTab.isSelected);

    if ([remoteTab.label containsString:@"Remote cache mp4"]) {
      XCUIElement *playButtonCache = app.staticTexts[@"Play"];
      XCTAssertTrue([playButtonCache waitForExistenceWithTimeout:30.0]);
      [playButtonCache tap];

      NSPredicate *find1xButtonCache = [NSPredicate predicateWithFormat:@"label CONTAINS '1.0x'"];
      XCUIElement *playbackSpeed1xCache =
          [app.staticTexts elementMatchingPredicate:find1xButtonCache];
      BOOL foundPlaybackSpeed1xCache = [playbackSpeed1xCache waitForExistenceWithTimeout:30.0];
      XCTAssertTrue(foundPlaybackSpeed1xCache);
      [playbackSpeed1xCache tap];

      XCUIElement *playbackSpeed5xButtonCache = app.buttons[@"5.0x"];
      XCTAssertTrue([playbackSpeed5xButtonCache waitForExistenceWithTimeout:30.0]);
      [playbackSpeed5xButtonCache tap];

      NSPredicate *find5xButtonCache = [NSPredicate predicateWithFormat:@"label CONTAINS '5.0x'"];
      XCUIElement *playbackSpeed5xCache =
          [app.staticTexts elementMatchingPredicate:find5xButtonCache];
      BOOL foundPlaybackSpeed5xCache = [playbackSpeed5xCache waitForExistenceWithTimeout:30.0];
      XCTAssertTrue(foundPlaybackSpeed5xCache);

      XCUIElement *clearCacheButton = app.buttons[@"clear cache"];
      XCTAssertTrue([clearCacheButton waitForExistenceWithTimeout:30.0]);
      [clearCacheButton tap];
    }
  }
}
@end
