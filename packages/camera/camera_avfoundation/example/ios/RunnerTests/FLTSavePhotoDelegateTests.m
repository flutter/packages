// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import camera_avfoundation;
#if __has_include(<camera_avfoundation/camera_avfoundation-umbrella.h>)
@import camera_avfoundation.Test;
#endif
@import AVFoundation;
@import XCTest;

#import "MockPhotoData.h"

@interface FLTSavePhotoDelegateTests : XCTestCase

@end

@implementation FLTSavePhotoDelegateTests

- (void)testHandlePhotoCaptureResult_mustCompleteWithErrorIfFailedToCapture {
  XCTestExpectation *completionExpectation =
      [self expectationWithDescription:@"Must complete with error if failed to capture photo."];

  NSError *captureError = [NSError errorWithDomain:@"test" code:0 userInfo:nil];
  dispatch_queue_t ioQueue = dispatch_queue_create("test", NULL);
  FLTSavePhotoDelegate *delegate = [[FLTSavePhotoDelegate alloc]
           initWithPath:@"test"
                ioQueue:ioQueue
      completionHandler:^(NSString *_Nullable path, NSError *_Nullable error) {
        XCTAssertEqualObjects(captureError, error);
        XCTAssertNil(path);
        [completionExpectation fulfill];
      }];

  [delegate handlePhotoCaptureResultWithError:captureError
                            photoDataProvider:^id<FLTPhotoData> {
                              return nil;
                            }];
  [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void)testHandlePhotoCaptureResult_mustCompleteWithErrorIfFailedToWrite {
  XCTestExpectation *completionExpectation =
      [self expectationWithDescription:@"Must complete with error if failed to write file."];
  dispatch_queue_t ioQueue = dispatch_queue_create("test", NULL);

  NSError *ioError = [NSError errorWithDomain:@"IOError"
                                         code:0
                                     userInfo:@{NSLocalizedDescriptionKey : @"Localized IO Error"}];
  FLTSavePhotoDelegate *delegate = [[FLTSavePhotoDelegate alloc]
           initWithPath:@"test"
                ioQueue:ioQueue
      completionHandler:^(NSString *_Nullable path, NSError *_Nullable error) {
        XCTAssertEqualObjects(ioError, error);
        XCTAssertNil(path);
        [completionExpectation fulfill];
      }];

  MockPhotoData *mockData = [[MockPhotoData alloc] init];
  mockData.writeToFileStub = ^BOOL(NSString *path, NSDataWritingOptions options, NSError **error) {
    *error = ioError;
    return NO;
  };

  [delegate handlePhotoCaptureResultWithError:nil
                            photoDataProvider:^id<FLTPhotoData> {
                              return mockData;
                            }];
  [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void)testHandlePhotoCaptureResult_mustCompleteWithFilePathIfSuccessToWrite {
  XCTestExpectation *completionExpectation =
      [self expectationWithDescription:@"Must complete with file path if success to write file."];

  dispatch_queue_t ioQueue = dispatch_queue_create("test", NULL);
  NSString *filePath = @"test";
  FLTSavePhotoDelegate *delegate = [[FLTSavePhotoDelegate alloc]
           initWithPath:filePath
                ioQueue:ioQueue
      completionHandler:^(NSString *_Nullable path, NSError *_Nullable error) {
        XCTAssertNil(error);
        XCTAssertEqualObjects(filePath, path);
        [completionExpectation fulfill];
      }];

  MockPhotoData *mockData = [[MockPhotoData alloc] init];
  mockData.writeToFileStub = ^BOOL(NSString *path, NSDataWritingOptions options, NSError **error) {
    return YES;
  };

  [delegate handlePhotoCaptureResultWithError:nil
                            photoDataProvider:^id<FLTPhotoData> {
                              return mockData;
                            }];
  [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void)testHandlePhotoCaptureResult_bothProvideDataAndSaveFileMustRunOnIOQueue {
  XCTestExpectation *dataProviderQueueExpectation =
      [self expectationWithDescription:@"Data provider must run on io queue."];
  XCTestExpectation *writeFileQueueExpectation =
      [self expectationWithDescription:@"File writing must run on io queue"];
  XCTestExpectation *completionExpectation =
      [self expectationWithDescription:@"Must complete with file path if success to write file."];

  dispatch_queue_t ioQueue = dispatch_queue_create("test", NULL);
  const char *ioQueueSpecific = "io_queue_specific";
  dispatch_queue_set_specific(ioQueue, ioQueueSpecific, (void *)ioQueueSpecific, NULL);

  MockPhotoData *mockData = [[MockPhotoData alloc] init];
  mockData.writeToFileStub = ^BOOL(NSString *path, NSDataWritingOptions options, NSError **error) {
    if (dispatch_get_specific(ioQueueSpecific)) {
      [writeFileQueueExpectation fulfill];
    }
    return YES;
  };

  NSString *filePath = @"test";
  FLTSavePhotoDelegate *delegate = [[FLTSavePhotoDelegate alloc]
           initWithPath:filePath
                ioQueue:ioQueue
      completionHandler:^(NSString *_Nullable path, NSError *_Nullable error) {
        [completionExpectation fulfill];
      }];

  [delegate handlePhotoCaptureResultWithError:nil
                            photoDataProvider:^id<FLTPhotoData> {
                              if (dispatch_get_specific(ioQueueSpecific)) {
                                [dataProviderQueueExpectation fulfill];
                              }
                              return mockData;
                            }];

  [self waitForExpectationsWithTimeout:1 handler:nil];
}

@end
