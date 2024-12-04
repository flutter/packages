// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import camera_avfoundation;
#if __has_include(<camera_avfoundation/camera_avfoundation-umbrella.h>)
@import camera_avfoundation.Test;
#endif
@import AVFoundation;
@import XCTest;
#import "CameraTestUtils.h"
#import "FLTPermissionService.h"
#import "FLTCameraPermissionManager.h"

@interface MockPermissionService : NSObject <FLTPermissionService>
@property (nonatomic, assign) AVAuthorizationStatus cameraAuthorizationStatusStub;
@property (nonatomic, assign) AVAuthorizationStatus audioAuthorizationStatusStub;

@property (nonatomic, assign) BOOL cameraGrantAccessStub;
@property (nonatomic, assign) BOOL audioGrantAccessStub;
@end

@implementation MockPermissionService
- (AVAuthorizationStatus)authorizationStatusForMediaType:(AVMediaType)mediaType {
  if (mediaType == AVMediaTypeVideo) {
    return self.cameraAuthorizationStatusStub;
  } else if (mediaType == AVMediaTypeAudio) {
    return self.audioAuthorizationStatusStub;
  }
  @throw [NSException exceptionWithName:@"UnexpectedMediaType"
                                 reason:@"Unexpected media type was used"
                               userInfo:nil];
}

- (void)requestAccessForMediaType:(AVMediaType)mediaType
               completionHandler:(void (^)(BOOL granted))handler {
  if (mediaType == AVMediaTypeVideo) {
    handler(self.cameraGrantAccessStub);
  } else if (mediaType == AVMediaTypeAudio) {
    handler(self.audioGrantAccessStub);
  }
}
@end

@interface CameraPermissionTests : XCTestCase
@property (nonatomic, strong) FLTCameraPermissionManager *permissionManager;
@property (nonatomic, strong) MockPermissionService *mockService;
@end

@implementation CameraPermissionTests

- (void)setUp {
    [super setUp];
    self.mockService = [[MockPermissionService alloc] init];
    self.permissionManager = [[FLTCameraPermissionManager alloc]
                              initWithPermissionService:self.mockService];
}

#pragma mark - camera permissions

- (void)testRequestCameraPermission_completeWithoutErrorIfPreviouslyAuthorized {
  XCTestExpectation *expectation =
      [self expectationWithDescription:
                @"Must copmlete without error if camera access was previously authorized."];

  self.mockService.cameraAuthorizationStatusStub = AVAuthorizationStatusAuthorized;

  [self.permissionManager requestCameraPermissionWithCompletionHandler:^(FlutterError *error) {
    if (error == nil) {
      [expectation fulfill];
    }
  }];
  [self waitForExpectationsWithTimeout:1 handler:nil];
}
- (void)testRequestCameraPermission_completeWithErrorIfPreviouslyDenied {
  XCTestExpectation *expectation =
      [self expectationWithDescription:
                @"Must complete with error if camera access was previously denied."];
  FlutterError *expectedError =
      [FlutterError errorWithCode:@"CameraAccessDeniedWithoutPrompt"
                          message:@"User has previously denied the camera access request. Go to "
                                  @"Settings to enable camera access."
                          details:nil];

  self.mockService.cameraAuthorizationStatusStub = AVAuthorizationStatusDenied;
  
  [self.permissionManager requestCameraPermissionWithCompletionHandler:^(FlutterError *error) {
    if ([error isEqual:expectedError]) {
      [expectation fulfill];
    }
  }];
  [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void)testRequestCameraPermission_completeWithErrorIfRestricted {
  XCTestExpectation *expectation =
      [self expectationWithDescription:@"Must complete with error if camera access is restricted."];
  FlutterError *expectedError = [FlutterError errorWithCode:@"CameraAccessRestricted"
                                                    message:@"Camera access is restricted. "
                                                    details:nil];

  self.mockService.cameraAuthorizationStatusStub = AVAuthorizationStatusRestricted;

  [self.permissionManager requestCameraPermissionWithCompletionHandler:^(FlutterError *error) {
    if ([error isEqual:expectedError]) {
      [expectation fulfill];
    }
  }];
  [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void)testRequestCameraPermission_completeWithoutErrorIfUserGrantAccess {
  XCTestExpectation *grantedExpectation = [self
      expectationWithDescription:@"Must complete without error if user choose to grant access"];

  self.mockService.cameraAuthorizationStatusStub = AVAuthorizationStatusNotDetermined;

  // Mimic user choosing "allow" in permission dialog.
  self.mockService.cameraGrantAccessStub = YES;

  [self.permissionManager requestCameraPermissionWithCompletionHandler:^(FlutterError *error) {
      if (error == nil) {
        [grantedExpectation fulfill];
      }
    }];
  [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void)testRequestCameraPermission_completeWithErrorIfUserDenyAccess {
  XCTestExpectation *expectation =
      [self expectationWithDescription:@"Must complete with error if user choose to deny access"];
  FlutterError *expectedError =
      [FlutterError errorWithCode:@"CameraAccessDenied"
                          message:@"User denied the camera access request."
                          details:nil];

  self.mockService.cameraAuthorizationStatusStub = AVAuthorizationStatusNotDetermined;

  // Mimic user choosing "deny" in permission dialog.
  self.mockService.cameraGrantAccessStub = NO;

  [self.permissionManager requestCameraPermissionWithCompletionHandler:^(FlutterError *error) {
    if ([error isEqual:expectedError]) {
      [expectation fulfill];
    }
   }];

  [self waitForExpectationsWithTimeout:1 handler:nil];
}

#pragma mark - audio permissions

- (void)testRequestAudioPermission_completeWithoutErrorIfPrevoiuslyAuthorized {
  XCTestExpectation *expectation =
      [self expectationWithDescription:
                @"Must copmlete without error if audio access was previously authorized."];

  self.mockService.audioAuthorizationStatusStub = AVAuthorizationStatusAuthorized;

  [self.permissionManager requestAudioPermissionWithCompletionHandler:^(FlutterError *error) {
    if (error == nil) {
      [expectation fulfill];
    }
  }];
  [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void)testRequestAudioPermission_completeWithErrorIfPreviouslyDenied {
  XCTestExpectation *expectation =
      [self expectationWithDescription:
                @"Must complete with error if audio access was previously denied."];
  FlutterError *expectedError =
      [FlutterError errorWithCode:@"AudioAccessDeniedWithoutPrompt"
                          message:@"User has previously denied the audio access request. Go to "
                                  @"Settings to enable audio access."
                          details:nil];

  self.mockService.audioAuthorizationStatusStub = AVAuthorizationStatusDenied;

  [self.permissionManager requestAudioPermissionWithCompletionHandler:^(FlutterError *error) {
    if ([error isEqual:expectedError]) {
      [expectation fulfill];
    }
  }];
  [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void)testRequestAudioPermission_completeWithErrorIfRestricted {
  XCTestExpectation *expectation =
      [self expectationWithDescription:@"Must complete with error if audio access is restricted."];
  FlutterError *expectedError = [FlutterError errorWithCode:@"AudioAccessRestricted"
                                                    message:@"Audio access is restricted. "
                                                    details:nil];

  self.mockService.audioAuthorizationStatusStub = AVAuthorizationStatusRestricted;

  [self.permissionManager requestAudioPermissionWithCompletionHandler:^(FlutterError *error) {
    if ([error isEqual:expectedError]) {
      [expectation fulfill];
    }
  }];
  [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void)testRequestAudioPermission_completeWithoutErrorIfUserGrantAccess {
  XCTestExpectation *grantedExpectation = [self
      expectationWithDescription:@"Must complete without error if user choose to grant access"];

  self.mockService.audioAuthorizationStatusStub = AVAuthorizationStatusNotDetermined;

  // Mimic user choosing "allow" in permission dialog.
  self.mockService.audioGrantAccessStub = YES;

  [self.permissionManager requestAudioPermissionWithCompletionHandler:^(FlutterError *error) {
    if (error == nil) {
      [grantedExpectation fulfill];
    }
  }];
  [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void)testRequestAudioPermission_completeWithErrorIfUserDenyAccess {
  XCTestExpectation *expectation =
      [self expectationWithDescription:@"Must complete with error if user choose to deny access"];
  FlutterError *expectedError = [FlutterError errorWithCode:@"AudioAccessDenied"
                                                    message:@"User denied the audio access request."
                                                    details:nil];

  self.mockService.audioAuthorizationStatusStub = AVAuthorizationStatusNotDetermined;

  // Mimic user choosing "deny" in permission dialog.
  self.mockService.audioGrantAccessStub = NO;

  [self.permissionManager requestAudioPermissionWithCompletionHandler:^(FlutterError *error) {
    if ([error isEqual:expectedError]) {
      [expectation fulfill];
    }
  }];
  [self waitForExpectationsWithTimeout:1 handler:nil];
}

@end
