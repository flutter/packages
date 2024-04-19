// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import file_selector_ios;
@import file_selector_ios.Test;
@import XCTest;

@interface TestPresenter : NSObject <FFSViewPresenter>
@property(nonatomic) UIViewController *presentedController;
@end

@implementation TestPresenter
- (void)presentViewController:(UIViewController *)viewControllerToPresent
                     animated:(BOOL)animated
                   completion:(void (^__nullable)(void))completion {
  self.presentedController = viewControllerToPresent;
}
@end

#pragma mark -

@interface FileSelectorTests : XCTestCase

@end

@implementation FileSelectorTests

- (void)testPickerPresents {
  FFSFileSelectorPlugin *plugin = [[FFSFileSelectorPlugin alloc] init];
  UIDocumentPickerViewController *picker =
      [[UIDocumentPickerViewController alloc] initWithDocumentTypes:@[]
                                                             inMode:UIDocumentPickerModeImport];
  TestPresenter *presenter = [[TestPresenter alloc] init];
  plugin.documentPickerViewControllerOverride = picker;
  plugin.viewPresenterOverride = presenter;

  [plugin openFileSelectorWithConfig:[FFSFileSelectorConfig makeWithUtis:@[] allowMultiSelection:NO]
                          completion:^(NSArray<NSString *> *paths, FlutterError *error){
                          }];

  XCTAssertEqualObjects(picker.delegate, plugin);
  XCTAssertEqualObjects(presenter.presentedController, picker);
}

- (void)testReturnsPickedFiles {
  FFSFileSelectorPlugin *plugin = [[FFSFileSelectorPlugin alloc] init];
  XCTestExpectation *completionWasCalled = [self expectationWithDescription:@"completion"];
  UIDocumentPickerViewController *picker =
      [[UIDocumentPickerViewController alloc] initWithDocumentTypes:@[]
                                                             inMode:UIDocumentPickerModeImport];
  plugin.documentPickerViewControllerOverride = picker;
  [plugin openFileSelectorWithConfig:[FFSFileSelectorConfig makeWithUtis:@[]
                                                     allowMultiSelection:YES]
                          completion:^(NSArray<NSString *> *paths, FlutterError *error) {
                            NSArray *expectedPaths = @[ @"/file1.txt", @"/file2.txt" ];
                            XCTAssertEqualObjects(paths, expectedPaths);
                            [completionWasCalled fulfill];
                          }];
  [plugin documentPicker:picker
      didPickDocumentsAtURLs:@[
        [NSURL URLWithString:@"file:///file1.txt"], [NSURL URLWithString:@"file:///file2.txt"]
      ]];
  [self waitForExpectationsWithTimeout:1.0 handler:nil];
}

- (void)testCancellingPickerReturnsNil {
  FFSFileSelectorPlugin *plugin = [[FFSFileSelectorPlugin alloc] init];
  UIDocumentPickerViewController *picker =
      [[UIDocumentPickerViewController alloc] initWithDocumentTypes:@[]
                                                             inMode:UIDocumentPickerModeImport];
  plugin.documentPickerViewControllerOverride = picker;

  XCTestExpectation *completionWasCalled = [self expectationWithDescription:@"completion"];
  [plugin openFileSelectorWithConfig:[FFSFileSelectorConfig makeWithUtis:@[] allowMultiSelection:NO]
                          completion:^(NSArray<NSString *> *paths, FlutterError *error) {
                            XCTAssertEqual(paths.count, 0);
                            [completionWasCalled fulfill];
                          }];
  [plugin documentPickerWasCancelled:picker];
  [self waitForExpectationsWithTimeout:1.0 handler:nil];
}

@end
