// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <XCTest/XCTest.h>

static const NSTimeInterval kWaitTime = 60;

@interface RunnerUITests : XCTestCase

@end

@implementation RunnerUITests

- (void)testMarkerDraggingCallbacks {
  XCUIApplication *application = [[XCUIApplication alloc] init];
  [application launch];
  XCUIElement *placeMarkerButton = application.staticTexts[@"Place marker"];
  if (![placeMarkerButton waitForExistenceWithTimeout:kWaitTime]) {
    NSLog(@"application.debugDescription: %@", application.debugDescription);
    XCTFail(@"Failed to find the Place marker button.");
  }
  [placeMarkerButton tap];

  XCUIElement *Add = application.buttons[@"Add"];
  if (![Add waitForExistenceWithTimeout:kWaitTime]) {
    NSLog(@"application.debugDescription: %@", application.debugDescription);
    XCTFail(@"Failed to find the Add button.");
  }
  [Add tap];

  XCUIElement *marker = application.buttons[@"marker_id_1"];
  if (![marker waitForExistenceWithTimeout:kWaitTime]) {
    NSLog(@"application.debugDescription: %@", application.debugDescription);
    XCTFail(@"Failed to find the marker.");
  }
  [marker tap];

  XCUIElement *toggleDraggable = application.buttons[@"toggle draggable"];
  if (![toggleDraggable waitForExistenceWithTimeout:kWaitTime]) {
    NSLog(@"application.debugDescription: %@", application.debugDescription);
    XCTFail(@"Failed to find the toggle draggable.");
  }
  [toggleDraggable tap];

  // Drag marker to center
  [marker pressForDuration:5 thenDragToElement:application];

  NSPredicate *predicateDragStart =
      [NSPredicate predicateWithFormat:@"label CONTAINS[c] %@", @"_onMarkerDragStart"];
  NSPredicate *predicateDrag =
      [NSPredicate predicateWithFormat:@"label CONTAINS[c] %@", @"_onMarkerDrag called"];
  NSPredicate *predicateDragEnd =
      [NSPredicate predicateWithFormat:@"label CONTAINS[c] %@", @"_onMarkerDragEnd"];

  XCUIElement *dragStart = [application.staticTexts matchingPredicate:predicateDragStart].element;
  if (![dragStart waitForExistenceWithTimeout:kWaitTime]) {
    NSLog(@"application.debugDescription: %@", application.debugDescription);
    XCTFail(@"Failed to find the _onMarkerDragStart.");
  }
  XCTAssertTrue(dragStart.exists);

  XCUIElement *drag = [application.staticTexts matchingPredicate:predicateDrag].element;
  if (![drag waitForExistenceWithTimeout:kWaitTime]) {
    NSLog(@"application.debugDescription: %@", application.debugDescription);
    XCTFail(@"Failed to find the _onMarkerDrag.");
  }
  XCTAssertTrue(drag.exists);

  XCUIElement *dragEnd = [application.staticTexts matchingPredicate:predicateDragEnd].element;
  if (![dragEnd waitForExistenceWithTimeout:kWaitTime]) {
    NSLog(@"application.debugDescription: %@", application.debugDescription);
    XCTFail(@"Failed to find the _onMarkerDragEnd.");
  }
  XCTAssertTrue(dragEnd.exists);
}

@end
