// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "ImagePickerTestImages.h"

@import image_picker_ios;
#if __has_include(<image_picker_ios/image_picker_ios-umbrella.h>)
@import image_picker_ios.Test;
#endif
@import UniformTypeIdentifiers;
@import XCTest;

#import <OCMock/OCMock.h>

@interface MockViewController : UIViewController
@property(nonatomic, retain) UIViewController *mockPresented;
@end

@implementation MockViewController
@synthesize mockPresented;

- (UIViewController *)presentedViewController {
  return mockPresented;
}

@end

@interface StubViewProvider : NSObject <FIPViewProvider>
- (instancetype)initWithViewController:(UIViewController *)viewController;
@property(nonatomic, nullable) UIViewController *viewController;
@end

@implementation StubViewProvider
- (instancetype)initWithViewController:(UIViewController *)viewController {
  self = [super init];
  _viewController = viewController;
  return self;
}
@end

@interface ImagePickerPluginTests : XCTestCase

@end

@implementation ImagePickerPluginTests

- (void)testPluginPickImageDeviceBack {
  id mockUIImagePicker = OCMClassMock([UIImagePickerController class]);
  id mockAVCaptureDevice = OCMClassMock([AVCaptureDevice class]);
  // UIImagePickerControllerSourceTypeCamera is supported
  OCMStub(ClassMethod(
              [mockUIImagePicker isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]))
      .andReturn(YES);

  // UIImagePickerControllerCameraDeviceRear is supported
  OCMStub(ClassMethod(
              [mockUIImagePicker isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear]))
      .andReturn(YES);

  // AVAuthorizationStatusAuthorized is supported
  OCMStub([mockAVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo])
      .andReturn(AVAuthorizationStatusAuthorized);

  // Run test
  FLTImagePickerPlugin *plugin =
      [[FLTImagePickerPlugin alloc] initWithViewProvider:[[StubViewProvider alloc] init]];
  UIImagePickerController *controller = [[UIImagePickerController alloc] init];
  [plugin setImagePickerControllerOverrides:@[ controller ]];

  [plugin pickImageWithSource:[FLTSourceSpecification makeWithType:FLTSourceTypeCamera
                                                            camera:FLTSourceCameraRear]
                      maxSize:[[FLTMaxSize alloc] init]
                      quality:nil
                 fullMetadata:YES
                   completion:^(NSString *_Nullable result, FlutterError *_Nullable error){
                   }];

  XCTAssertEqual(controller.cameraDevice, UIImagePickerControllerCameraDeviceRear);
}

- (void)testPluginPickImageDeviceFront {
  id mockUIImagePicker = OCMClassMock([UIImagePickerController class]);
  id mockAVCaptureDevice = OCMClassMock([AVCaptureDevice class]);
  // UIImagePickerControllerSourceTypeCamera is supported
  OCMStub(ClassMethod(
              [mockUIImagePicker isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]))
      .andReturn(YES);

  // UIImagePickerControllerCameraDeviceFront is supported
  OCMStub(ClassMethod(
              [mockUIImagePicker isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront]))
      .andReturn(YES);

  // AVAuthorizationStatusAuthorized is supported
  OCMStub([mockAVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo])
      .andReturn(AVAuthorizationStatusAuthorized);

  // Run test
  FLTImagePickerPlugin *plugin =
      [[FLTImagePickerPlugin alloc] initWithViewProvider:[[StubViewProvider alloc] init]];
  UIImagePickerController *controller = [[UIImagePickerController alloc] init];
  [plugin setImagePickerControllerOverrides:@[ controller ]];

  [plugin pickImageWithSource:[FLTSourceSpecification makeWithType:FLTSourceTypeCamera
                                                            camera:FLTSourceCameraFront]
                      maxSize:[[FLTMaxSize alloc] init]
                      quality:nil
                 fullMetadata:YES
                   completion:^(NSString *_Nullable result, FlutterError *_Nullable error){
                   }];

  XCTAssertEqual(controller.cameraDevice, UIImagePickerControllerCameraDeviceFront);
}

- (void)testPluginPickVideoDeviceBack {
  id mockUIImagePicker = OCMClassMock([UIImagePickerController class]);
  id mockAVCaptureDevice = OCMClassMock([AVCaptureDevice class]);
  // UIImagePickerControllerSourceTypeCamera is supported
  OCMStub(ClassMethod(
              [mockUIImagePicker isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]))
      .andReturn(YES);

  // UIImagePickerControllerCameraDeviceRear is supported
  OCMStub(ClassMethod(
              [mockUIImagePicker isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear]))
      .andReturn(YES);

  // AVAuthorizationStatusAuthorized is supported
  OCMStub([mockAVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo])
      .andReturn(AVAuthorizationStatusAuthorized);

  // Run test
  FLTImagePickerPlugin *plugin =
      [[FLTImagePickerPlugin alloc] initWithViewProvider:[[StubViewProvider alloc] init]];
  UIImagePickerController *controller = [[UIImagePickerController alloc] init];
  [plugin setImagePickerControllerOverrides:@[ controller ]];

  [plugin pickVideoWithSource:[FLTSourceSpecification makeWithType:FLTSourceTypeCamera
                                                            camera:FLTSourceCameraRear]
                  maxDuration:nil
                   completion:^(NSString *_Nullable result, FlutterError *_Nullable error){
                   }];

  XCTAssertEqual(controller.cameraDevice, UIImagePickerControllerCameraDeviceRear);
}

- (void)testPluginPickVideoDeviceFront {
  id mockUIImagePicker = OCMClassMock([UIImagePickerController class]);
  id mockAVCaptureDevice = OCMClassMock([AVCaptureDevice class]);

  // UIImagePickerControllerSourceTypeCamera is supported
  OCMStub(ClassMethod(
              [mockUIImagePicker isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]))
      .andReturn(YES);

  // UIImagePickerControllerCameraDeviceFront is supported
  OCMStub(ClassMethod(
              [mockUIImagePicker isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront]))
      .andReturn(YES);

  // AVAuthorizationStatusAuthorized is supported
  OCMStub([mockAVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo])
      .andReturn(AVAuthorizationStatusAuthorized);

  // Run test
  FLTImagePickerPlugin *plugin =
      [[FLTImagePickerPlugin alloc] initWithViewProvider:[[StubViewProvider alloc] init]];
  UIImagePickerController *controller = [[UIImagePickerController alloc] init];
  [plugin setImagePickerControllerOverrides:@[ controller ]];

  [plugin pickVideoWithSource:[FLTSourceSpecification makeWithType:FLTSourceTypeCamera
                                                            camera:FLTSourceCameraFront]
                  maxDuration:nil
                   completion:^(NSString *_Nullable result, FlutterError *_Nullable error){
                   }];

  XCTAssertEqual(controller.cameraDevice, UIImagePickerControllerCameraDeviceFront);
}

- (void)testPickMultiImageShouldUseUIImagePickerControllerOnPreiOS14 {
  if (@available(iOS 14, *)) {
    return;
  }

  id mockUIImagePicker = OCMClassMock([UIImagePickerController class]);
  id photoLibrary = OCMClassMock([PHPhotoLibrary class]);
  OCMStub(ClassMethod([photoLibrary authorizationStatus]))
      .andReturn(PHAuthorizationStatusAuthorized);

  FLTImagePickerPlugin *plugin =
      [[FLTImagePickerPlugin alloc] initWithViewProvider:[[StubViewProvider alloc] init]];
  [plugin setImagePickerControllerOverrides:@[ mockUIImagePicker ]];

  [plugin pickMultiImageWithMaxSize:[FLTMaxSize makeWithWidth:@(100) height:@(200)]
                            quality:@(50)
                       fullMetadata:YES
                              limit:nil
                         completion:^(NSArray<NSString *> *_Nullable result,
                                      FlutterError *_Nullable error){
                         }];
  OCMVerify(times(1),
            [mockUIImagePicker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary]);
}

- (void)testPickMediaShouldUseUIImagePickerControllerOnPreiOS14 {
  if (@available(iOS 14, *)) {
    return;
  }

  id mockUIImagePicker = OCMClassMock([UIImagePickerController class]);
  id photoLibrary = OCMClassMock([PHPhotoLibrary class]);
  OCMStub(ClassMethod([photoLibrary authorizationStatus]))
      .andReturn(PHAuthorizationStatusAuthorized);

  FLTImagePickerPlugin *plugin =
      [[FLTImagePickerPlugin alloc] initWithViewProvider:[[StubViewProvider alloc] init]];
  [plugin setImagePickerControllerOverrides:@[ mockUIImagePicker ]];
  FLTMediaSelectionOptions *mediaSelectionOptions =
      [FLTMediaSelectionOptions makeWithMaxSize:[FLTMaxSize makeWithWidth:@(100) height:@(200)]
                                   imageQuality:@(50)
                            requestFullMetadata:YES
                                  allowMultiple:YES
                                          limit:nil];

  [plugin pickMediaWithMediaSelectionOptions:mediaSelectionOptions
                                  completion:^(NSArray<NSString *> *_Nullable result,
                                               FlutterError *_Nullable error){
                                  }];
  OCMVerify(times(1),
            [mockUIImagePicker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary]);
}

- (void)testPickImageWithoutFullMetadata {
  id mockUIImagePicker = OCMClassMock([UIImagePickerController class]);
  id photoLibrary = OCMClassMock([PHPhotoLibrary class]);

  FLTImagePickerPlugin *plugin =
      [[FLTImagePickerPlugin alloc] initWithViewProvider:[[StubViewProvider alloc] init]];
  [plugin setImagePickerControllerOverrides:@[ mockUIImagePicker ]];

  [plugin pickImageWithSource:[FLTSourceSpecification makeWithType:FLTSourceTypeGallery
                                                            camera:FLTSourceCameraFront]
                      maxSize:[[FLTMaxSize alloc] init]
                      quality:nil
                 fullMetadata:NO
                   completion:^(NSString *_Nullable result, FlutterError *_Nullable error){
                   }];

  OCMVerify(times(0), [photoLibrary authorizationStatus]);
}

- (void)testPickMultiImageWithoutFullMetadata {
  id mockUIImagePicker = OCMClassMock([UIImagePickerController class]);
  id photoLibrary = OCMClassMock([PHPhotoLibrary class]);

  FLTImagePickerPlugin *plugin =
      [[FLTImagePickerPlugin alloc] initWithViewProvider:[[StubViewProvider alloc] init]];
  [plugin setImagePickerControllerOverrides:@[ mockUIImagePicker ]];

  [plugin pickMultiImageWithMaxSize:[[FLTMaxSize alloc] init]
                            quality:nil
                       fullMetadata:NO
                              limit:nil
                         completion:^(NSArray<NSString *> *_Nullable result,
                                      FlutterError *_Nullable error){
                         }];

  OCMVerify(times(0), [photoLibrary authorizationStatus]);
}

- (void)testPickMediaWithoutFullMetadata {
  id mockUIImagePicker = OCMClassMock([UIImagePickerController class]);
  id photoLibrary = OCMClassMock([PHPhotoLibrary class]);

  FLTImagePickerPlugin *plugin =
      [[FLTImagePickerPlugin alloc] initWithViewProvider:[[StubViewProvider alloc] init]];
  [plugin setImagePickerControllerOverrides:@[ mockUIImagePicker ]];

  FLTMediaSelectionOptions *mediaSelectionOptions =
      [FLTMediaSelectionOptions makeWithMaxSize:[FLTMaxSize makeWithWidth:@(100) height:@(200)]
                                   imageQuality:@(50)
                            requestFullMetadata:YES
                                  allowMultiple:YES
                                          limit:nil];

  [plugin pickMediaWithMediaSelectionOptions:mediaSelectionOptions

                                  completion:^(NSArray<NSString *> *_Nullable result,
                                               FlutterError *_Nullable error){
                                  }];

  OCMVerify(times(0), [photoLibrary authorizationStatus]);
}

#pragma mark - Test camera devices, no op on simulators

- (void)testPluginPickImageDeviceCancelClickMultipleTimes {
  if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
    return;
  }
  FLTImagePickerPlugin *plugin =
      [[FLTImagePickerPlugin alloc] initWithViewProvider:[[StubViewProvider alloc] init]];
  UIImagePickerController *controller = [[UIImagePickerController alloc] init];
  plugin.imagePickerControllerOverrides = @[ controller ];

  [plugin pickImageWithSource:[FLTSourceSpecification makeWithType:FLTSourceTypeCamera
                                                            camera:FLTSourceCameraRear]
                      maxSize:[[FLTMaxSize alloc] init]
                      quality:nil
                 fullMetadata:YES
                   completion:^(NSString *_Nullable result, FlutterError *_Nullable error){
                   }];

  // To ensure the flow does not crash by multiple cancel call
  [plugin imagePickerControllerDidCancel:controller];
  [plugin imagePickerControllerDidCancel:controller];
}

#pragma mark - Test video duration

- (void)testPickingVideoWithDuration {
  FLTImagePickerPlugin *plugin =
      [[FLTImagePickerPlugin alloc] initWithViewProvider:[[StubViewProvider alloc] init]];
  UIImagePickerController *controller = [[UIImagePickerController alloc] init];
  [plugin setImagePickerControllerOverrides:@[ controller ]];

  [plugin pickVideoWithSource:[FLTSourceSpecification makeWithType:FLTSourceTypeCamera
                                                            camera:FLTSourceCameraRear]
                  maxDuration:@(95)
                   completion:^(NSString *_Nullable result, FlutterError *_Nullable error){
                   }];

  XCTAssertEqual(controller.videoMaximumDuration, 95);
}

- (void)testPickingMultiVideoWithDuration {
  FLTImagePickerPlugin *plugin =
      [[FLTImagePickerPlugin alloc] initWithViewProvider:[[StubViewProvider alloc] init]];

  [plugin
      pickMultiVideoWithMaxDuration:@(95)
                              limit:nil
                         completion:^(NSArray<NSString *> *result, FlutterError *_Nullable error){
                         }];

  XCTAssertEqual(plugin.callContext.maxDuration, 95);
}

- (void)testPluginMultiImagePathHasNullItem {
  FLTImagePickerPlugin *plugin =
      [[FLTImagePickerPlugin alloc] initWithViewProvider:[[StubViewProvider alloc] init]];

  XCTestExpectation *resultExpectation = [self expectationWithDescription:@"result"];
  plugin.callContext = [[FLTImagePickerMethodCallContext alloc]
      initWithResult:^(NSArray<NSString *> *_Nullable result, FlutterError *_Nullable error) {
        XCTAssertEqualObjects(error.code, @"create_error");
        [resultExpectation fulfill];
      }];
  [plugin sendCallResultWithSavedPathList:@[ [NSNull null] ]];

  [self waitForExpectationsWithTimeout:30 handler:nil];
}

- (void)testPluginMultiImagePathHasItem {
  FLTImagePickerPlugin *plugin =
      [[FLTImagePickerPlugin alloc] initWithViewProvider:[[StubViewProvider alloc] init]];
  NSArray *pathList = @[ @"test" ];

  XCTestExpectation *resultExpectation = [self expectationWithDescription:@"result"];

  plugin.callContext = [[FLTImagePickerMethodCallContext alloc]
      initWithResult:^(NSArray<NSString *> *_Nullable result, FlutterError *_Nullable error) {
        XCTAssertEqualObjects(result, pathList);
        [resultExpectation fulfill];
      }];
  [plugin sendCallResultWithSavedPathList:pathList];

  [self waitForExpectationsWithTimeout:30 handler:nil];
}

- (void)testPluginMediaPathHasNoItem {
  FLTImagePickerPlugin *plugin =
      [[FLTImagePickerPlugin alloc] initWithViewProvider:[[StubViewProvider alloc] init]];

  XCTestExpectation *resultExpectation = [self expectationWithDescription:@"result"];
  plugin.callContext = [[FLTImagePickerMethodCallContext alloc]
      initWithResult:^(NSArray<NSString *> *_Nullable result, FlutterError *_Nullable error) {
        XCTAssertEqualObjects(result, @[]);
        [resultExpectation fulfill];
      }];
  [plugin sendCallResultWithSavedPathList:@[]];

  [self waitForExpectationsWithTimeout:30 handler:nil];
}

- (void)testPluginMediaPathConvertsNilToEmptyList {
  FLTImagePickerPlugin *plugin =
      [[FLTImagePickerPlugin alloc] initWithViewProvider:[[StubViewProvider alloc] init]];

  XCTestExpectation *resultExpectation = [self expectationWithDescription:@"result"];
  plugin.callContext = [[FLTImagePickerMethodCallContext alloc]
      initWithResult:^(NSArray<NSString *> *_Nullable result, FlutterError *_Nullable error) {
        XCTAssertEqualObjects(result, @[]);
        [resultExpectation fulfill];
      }];
  [plugin sendCallResultWithSavedPathList:nil];

  [self waitForExpectationsWithTimeout:30 handler:nil];
}

- (void)testPluginMediaPathHasItem {
  FLTImagePickerPlugin *plugin =
      [[FLTImagePickerPlugin alloc] initWithViewProvider:[[StubViewProvider alloc] init]];
  NSArray *pathList = @[ @"test" ];

  XCTestExpectation *resultExpectation = [self expectationWithDescription:@"result"];

  plugin.callContext = [[FLTImagePickerMethodCallContext alloc]
      initWithResult:^(NSArray<NSString *> *_Nullable result, FlutterError *_Nullable error) {
        XCTAssertEqualObjects(result, pathList);
        [resultExpectation fulfill];
      }];
  [plugin sendCallResultWithSavedPathList:pathList];

  [self waitForExpectationsWithTimeout:30 handler:nil];
}

- (void)testSendsImageInvalidSourceError API_AVAILABLE(ios(14)) {
  id mockPickerViewController = OCMClassMock([PHPickerViewController class]);

  id mockItemProvider = OCMClassMock([NSItemProvider class]);
  // Does not conform to image, invalid source.
  OCMStub([mockItemProvider hasItemConformingToTypeIdentifier:OCMOCK_ANY]).andReturn(NO);

  PHPickerResult *failResult1 = OCMClassMock([PHPickerResult class]);
  OCMStub([failResult1 itemProvider]).andReturn(mockItemProvider);

  PHPickerResult *failResult2 = OCMClassMock([PHPickerResult class]);
  OCMStub([failResult2 itemProvider]).andReturn(mockItemProvider);

  FLTImagePickerPlugin *plugin =
      [[FLTImagePickerPlugin alloc] initWithViewProvider:[[StubViewProvider alloc] init]];

  XCTestExpectation *resultExpectation = [self expectationWithDescription:@"result"];

  plugin.callContext = [[FLTImagePickerMethodCallContext alloc]
      initWithResult:^(NSArray<NSString *> *result, FlutterError *error) {
        XCTAssertTrue(NSThread.isMainThread);
        XCTAssertNil(result);
        XCTAssertEqualObjects(error.code, @"invalid_source");
        [resultExpectation fulfill];
      }];

  [plugin picker:mockPickerViewController didFinishPicking:@[ failResult1, failResult2 ]];

  [self waitForExpectationsWithTimeout:30 handler:nil];
}

- (void)testSendsImageInvalidErrorWhenOneFails API_AVAILABLE(ios(14)) {
  id mockPickerViewController = OCMClassMock([PHPickerViewController class]);
  NSError *loadDataError = [NSError errorWithDomain:@"PHPickerDomain" code:1234 userInfo:nil];

  id mockFailItemProvider = OCMClassMock([NSItemProvider class]);
  OCMStub([mockFailItemProvider hasItemConformingToTypeIdentifier:OCMOCK_ANY]).andReturn(YES);
  [[mockFailItemProvider stub]
      loadDataRepresentationForTypeIdentifier:OCMOCK_ANY
                            completionHandler:[OCMArg invokeBlockWithArgs:[NSNull null],
                                                                          loadDataError, nil]];

  PHPickerResult *failResult = OCMClassMock([PHPickerResult class]);
  OCMStub([failResult itemProvider]).andReturn(mockFailItemProvider);

  NSURL *tiffURL = [[NSBundle bundleForClass:[self class]] URLForResource:@"tiffImage"
                                                            withExtension:@"tiff"];
  NSItemProvider *tiffItemProvider = [[NSItemProvider alloc] initWithContentsOfURL:tiffURL];
  PHPickerResult *tiffResult = OCMClassMock([PHPickerResult class]);
  OCMStub([tiffResult itemProvider]).andReturn(tiffItemProvider);

  FLTImagePickerPlugin *plugin =
      [[FLTImagePickerPlugin alloc] initWithViewProvider:[[StubViewProvider alloc] init]];

  XCTestExpectation *resultExpectation = [self expectationWithDescription:@"result"];

  plugin.callContext = [[FLTImagePickerMethodCallContext alloc]
      initWithResult:^(NSArray<NSString *> *result, FlutterError *error) {
        XCTAssertTrue(NSThread.isMainThread);
        XCTAssertNil(result);
        XCTAssertEqualObjects(error.code, @"invalid_image");
        [resultExpectation fulfill];
      }];

  [plugin picker:mockPickerViewController didFinishPicking:@[ failResult, tiffResult ]];

  [self waitForExpectationsWithTimeout:30 handler:nil];
}

- (void)testSavesImages API_AVAILABLE(ios(14)) {
  id mockPickerViewController = OCMClassMock([PHPickerViewController class]);

  NSURL *tiffURL = [[NSBundle bundleForClass:[self class]] URLForResource:@"tiffImage"
                                                            withExtension:@"tiff"];
  NSItemProvider *tiffItemProvider = [[NSItemProvider alloc] initWithContentsOfURL:tiffURL];
  PHPickerResult *tiffResult = OCMClassMock([PHPickerResult class]);
  OCMStub([tiffResult itemProvider]).andReturn(tiffItemProvider);

  NSURL *pngURL = [[NSBundle bundleForClass:[self class]] URLForResource:@"pngImage"
                                                           withExtension:@"png"];
  NSItemProvider *pngItemProvider = [[NSItemProvider alloc] initWithContentsOfURL:pngURL];
  PHPickerResult *pngResult = OCMClassMock([PHPickerResult class]);
  OCMStub([pngResult itemProvider]).andReturn(pngItemProvider);

  FLTImagePickerPlugin *plugin =
      [[FLTImagePickerPlugin alloc] initWithViewProvider:[[StubViewProvider alloc] init]];

  XCTestExpectation *resultExpectation = [self expectationWithDescription:@"result"];

  plugin.callContext = [[FLTImagePickerMethodCallContext alloc]
      initWithResult:^(NSArray<NSString *> *result, FlutterError *error) {
        XCTAssertTrue(NSThread.isMainThread);
        XCTAssertEqual(result.count, 2);
        XCTAssertNil(error);
        [resultExpectation fulfill];
      }];

  [plugin picker:mockPickerViewController didFinishPicking:@[ tiffResult, pngResult ]];

  [self waitForExpectationsWithTimeout:30 handler:nil];
}

- (void)testPickImageDoesntRequestAuthorization API_AVAILABLE(ios(14)) {
  id mockPhotoLibrary = OCMClassMock([PHPhotoLibrary class]);
  OCMStub([mockPhotoLibrary authorizationStatusForAccessLevel:PHAccessLevelReadWrite])
      .andReturn(PHAuthorizationStatusNotDetermined);
  OCMReject([mockPhotoLibrary requestAuthorizationForAccessLevel:PHAccessLevelReadWrite
                                                         handler:OCMOCK_ANY]);

  FLTImagePickerPlugin *plugin =
      [[FLTImagePickerPlugin alloc] initWithViewProvider:[[StubViewProvider alloc] init]];

  [plugin pickImageWithSource:[FLTSourceSpecification makeWithType:FLTSourceTypeGallery
                                                            camera:FLTSourceCameraFront]
                      maxSize:[[FLTMaxSize alloc] init]
                      quality:nil
                 fullMetadata:YES
                   completion:^(NSString *result, FlutterError *error){
                   }];
  OCMVerifyAll(mockPhotoLibrary);
}

- (void)testPickMultiImageDuplicateCallCancels API_AVAILABLE(ios(14)) {
  id mockPhotoLibrary = OCMClassMock([PHPhotoLibrary class]);
  OCMStub([mockPhotoLibrary authorizationStatusForAccessLevel:PHAccessLevelReadWrite])
      .andReturn(PHAuthorizationStatusNotDetermined);
  OCMExpect([mockPhotoLibrary requestAuthorizationForAccessLevel:PHAccessLevelReadWrite
                                                         handler:OCMOCK_ANY]);

  FLTImagePickerPlugin *plugin =
      [[FLTImagePickerPlugin alloc] initWithViewProvider:[[StubViewProvider alloc] init]];

  XCTestExpectation *firstCallExpectation = [self expectationWithDescription:@"first call"];
  [plugin pickMultiImageWithMaxSize:[FLTMaxSize makeWithWidth:@100 height:@100]
                            quality:nil
                       fullMetadata:YES
                              limit:nil
                         completion:^(NSArray<NSString *> *result, FlutterError *error) {
                           XCTAssertNotNil(error);
                           XCTAssertEqualObjects(error.code, @"multiple_request");
                           [firstCallExpectation fulfill];
                         }];
  [plugin pickMultiImageWithMaxSize:[FLTMaxSize makeWithWidth:@100 height:@100]
                            quality:nil
                       fullMetadata:YES
                              limit:nil
                         completion:^(NSArray<NSString *> *result, FlutterError *error){
                         }];
  [self waitForExpectationsWithTimeout:30 handler:nil];
}

- (void)testPickMediaDuplicateCallCancels API_AVAILABLE(ios(14)) {
  id mockPhotoLibrary = OCMClassMock([PHPhotoLibrary class]);
  OCMStub([mockPhotoLibrary authorizationStatusForAccessLevel:PHAccessLevelReadWrite])
      .andReturn(PHAuthorizationStatusNotDetermined);
  OCMExpect([mockPhotoLibrary requestAuthorizationForAccessLevel:PHAccessLevelReadWrite
                                                         handler:OCMOCK_ANY]);

  FLTImagePickerPlugin *plugin =
      [[FLTImagePickerPlugin alloc] initWithViewProvider:[[StubViewProvider alloc] init]];

  FLTMediaSelectionOptions *options =
      [FLTMediaSelectionOptions makeWithMaxSize:[FLTMaxSize makeWithWidth:@(100) height:@(200)]
                                   imageQuality:@(50)
                            requestFullMetadata:YES
                                  allowMultiple:YES
                                          limit:nil];
  XCTestExpectation *firstCallExpectation = [self expectationWithDescription:@"first call"];
  [plugin pickMediaWithMediaSelectionOptions:options
                                  completion:^(NSArray<NSString *> *result, FlutterError *error) {
                                    XCTAssertNotNil(error);
                                    XCTAssertEqualObjects(error.code, @"multiple_request");
                                    [firstCallExpectation fulfill];
                                  }];
  [plugin pickMediaWithMediaSelectionOptions:options
                                  completion:^(NSArray<NSString *> *result, FlutterError *error){
                                  }];
  [self waitForExpectationsWithTimeout:30 handler:nil];
}

- (void)testPickVideoDuplicateCallCancels API_AVAILABLE(ios(14)) {
  id mockPhotoLibrary = OCMClassMock([AVCaptureDevice class]);
  OCMStub([mockPhotoLibrary authorizationStatusForMediaType:AVMediaTypeVideo])
      .andReturn(AVAuthorizationStatusNotDetermined);

  FLTImagePickerPlugin *plugin =
      [[FLTImagePickerPlugin alloc] initWithViewProvider:[[StubViewProvider alloc] init]];

  FLTSourceSpecification *source = [FLTSourceSpecification makeWithType:FLTSourceTypeCamera
                                                                 camera:FLTSourceCameraRear];
  XCTestExpectation *firstCallExpectation = [self expectationWithDescription:@"first call"];
  [plugin pickVideoWithSource:source
                  maxDuration:nil
                   completion:^(NSString *result, FlutterError *error) {
                     XCTAssertNotNil(error);
                     XCTAssertEqualObjects(error.code, @"multiple_request");
                     [firstCallExpectation fulfill];
                   }];
  [plugin pickVideoWithSource:source
                  maxDuration:nil
                   completion:^(NSString *result, FlutterError *error){
                   }];
  [self waitForExpectationsWithTimeout:30 handler:nil];
}

- (void)testPickMultiImageWithLimit {
  FLTImagePickerPlugin *plugin =
      [[FLTImagePickerPlugin alloc] initWithViewProvider:[[StubViewProvider alloc] init]];
  [plugin pickMultiImageWithMaxSize:[[FLTMaxSize alloc] init]
                            quality:nil
                       fullMetadata:NO
                              limit:@(2)
                         completion:^(NSArray<NSString *> *_Nullable result,
                                      FlutterError *_Nullable error){
                         }];
  XCTAssertEqual(plugin.callContext.maxItemCount, 2);
}

- (void)testPickMediaWithLimitAllowsMultiple {
  FLTImagePickerPlugin *plugin =
      [[FLTImagePickerPlugin alloc] initWithViewProvider:[[StubViewProvider alloc] init]];
  FLTMediaSelectionOptions *mediaSelectionOptions =
      [FLTMediaSelectionOptions makeWithMaxSize:[FLTMaxSize makeWithWidth:@(100) height:@(200)]
                                   imageQuality:nil
                            requestFullMetadata:NO
                                  allowMultiple:YES
                                          limit:@(2)];

  [plugin pickMediaWithMediaSelectionOptions:mediaSelectionOptions
                                  completion:^(NSArray<NSString *> *_Nullable result,
                                               FlutterError *_Nullable error){
                                  }];

  XCTAssertEqual(plugin.callContext.maxItemCount, 2);
}

- (void)testPickMediaWithLimitMultipleNotAllowed {
  FLTImagePickerPlugin *plugin =
      [[FLTImagePickerPlugin alloc] initWithViewProvider:[[StubViewProvider alloc] init]];
  FLTMediaSelectionOptions *mediaSelectionOptions =
      [FLTMediaSelectionOptions makeWithMaxSize:[FLTMaxSize makeWithWidth:@(100) height:@(200)]
                                   imageQuality:nil
                            requestFullMetadata:NO
                                  allowMultiple:NO
                                          limit:@(2)];

  [plugin pickMediaWithMediaSelectionOptions:mediaSelectionOptions
                                  completion:^(NSArray<NSString *> *_Nullable result,
                                               FlutterError *_Nullable error){
                                  }];

  XCTAssertEqual(plugin.callContext.maxItemCount, 1);
}

- (void)testPickMultiImageWithoutLimit {
  FLTImagePickerPlugin *plugin =
      [[FLTImagePickerPlugin alloc] initWithViewProvider:[[StubViewProvider alloc] init]];
  [plugin pickMultiImageWithMaxSize:[[FLTMaxSize alloc] init]
                            quality:nil
                       fullMetadata:NO
                              limit:nil
                         completion:^(NSArray<NSString *> *_Nullable result,
                                      FlutterError *_Nullable error){
                         }];
  XCTAssertEqual(plugin.callContext.maxItemCount, 0);
}

- (void)testPickMediaWithoutLimitAllowsMultiple {
  FLTImagePickerPlugin *plugin =
      [[FLTImagePickerPlugin alloc] initWithViewProvider:[[StubViewProvider alloc] init]];
  FLTMediaSelectionOptions *mediaSelectionOptions =
      [FLTMediaSelectionOptions makeWithMaxSize:[FLTMaxSize makeWithWidth:@(100) height:@(200)]
                                   imageQuality:nil
                            requestFullMetadata:NO
                                  allowMultiple:YES
                                          limit:nil];

  [plugin pickMediaWithMediaSelectionOptions:mediaSelectionOptions
                                  completion:^(NSArray<NSString *> *_Nullable result,
                                               FlutterError *_Nullable error){
                                  }];

  XCTAssertEqual(plugin.callContext.maxItemCount, 0);
}

- (void)testPickMultiVideoWithLimit {
  FLTImagePickerPlugin *plugin =
      [[FLTImagePickerPlugin alloc] initWithViewProvider:[[StubViewProvider alloc] init]];
  [plugin pickMultiVideoWithMaxDuration:nil
                                  limit:@(2)
                             completion:^(NSArray<NSString *> *_Nullable result,
                                          FlutterError *_Nullable error){
                             }];
  XCTAssertEqual(plugin.callContext.maxItemCount, 2);
}

- (void)testPickMultiVideoWithoutLimit {
  FLTImagePickerPlugin *plugin =
      [[FLTImagePickerPlugin alloc] initWithViewProvider:[[StubViewProvider alloc] init]];
  [plugin pickMultiVideoWithMaxDuration:nil
                                  limit:nil
                             completion:^(NSArray<NSString *> *_Nullable result,
                                          FlutterError *_Nullable error){
                             }];
  XCTAssertEqual(plugin.callContext.maxItemCount, 0);
}

- (void)testPickVideoSetsCurrentRepresentationMode API_AVAILABLE(ios(14)) {
  id mockPickerViewController = OCMClassMock([PHPickerViewController class]);
  OCMStub(ClassMethod([mockPickerViewController alloc])).andReturn(mockPickerViewController);
  OCMExpect([mockPickerViewController
                initWithConfiguration:[OCMArg checkWithBlock:^BOOL(PHPickerConfiguration *config) {
                  return config.preferredAssetRepresentationMode ==
                         PHPickerConfigurationAssetRepresentationModeCurrent;
                }]])
      .andReturn(mockPickerViewController);

  id mockViewController = OCMClassMock([UIViewController class]);
  StubViewProvider *viewProvider =
      [[StubViewProvider alloc] initWithViewController:mockViewController];
  FLTImagePickerPlugin *plugin = [[FLTImagePickerPlugin alloc] initWithViewProvider:viewProvider];

  [plugin pickVideoWithSource:[FLTSourceSpecification makeWithType:FLTSourceTypeGallery
                                                            camera:FLTSourceCameraRear]
                  maxDuration:nil
                   completion:^(NSString *_Nullable result, FlutterError *_Nullable error){
                   }];

  OCMVerifyAll(mockPickerViewController);
}

#pragma mark - Test immediate picker close detection

- (void)testUIImagePickerImmediateCloseReturnsEmptyArray {
  FLTImagePickerPlugin *plugin =
      [[FLTImagePickerPlugin alloc] initWithViewProvider:[[StubViewProvider alloc] init]];

  UIImagePickerController *controller = [[UIImagePickerController alloc] init];
  [plugin setImagePickerControllerOverrides:@[ controller ]];

  // Mock camera access to avoid permission dialogs and device-specific logic.
  id mockUIImagePicker = OCMClassMock([UIImagePickerController class]);
  OCMStub(ClassMethod(
              [mockUIImagePicker isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]))
      .andReturn(YES);
  OCMStub(ClassMethod(
              [mockUIImagePicker isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear]))
      .andReturn(YES);
  id mockAVCaptureDevice = OCMClassMock([AVCaptureDevice class]);
  OCMStub([mockAVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo])
      .andReturn(AVAuthorizationStatusAuthorized);

  XCTestExpectation *resultExpectation = [self expectationWithDescription:@"result"];

  FLTSourceSpecification *source = [FLTSourceSpecification makeWithType:FLTSourceTypeCamera
                                                                 camera:FLTSourceCameraRear];
  [plugin pickImageWithSource:source
                      maxSize:[[FLTMaxSize alloc] init]
                      quality:nil
                 fullMetadata:NO
                   completion:^(NSString *_Nullable result, FlutterError *_Nullable error) {
                     XCTAssertNil(result);
                     XCTAssertNil(error);
                     [resultExpectation fulfill];
                   }];

  // The `pickImage` call will attach the observer. Now, simulate dismissal.
  // This needs to happen on the next run loop to ensure the observer is attached.
  dispatch_async(dispatch_get_main_queue(), ^{
    UIWindow *testWindow = [[UIWindow alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    testWindow.hidden = NO;
    [testWindow addSubview:controller.view];

    [testWindow setNeedsLayout];
    [testWindow layoutIfNeeded];

    // Simulate the picker being removed from the window hierarchy
    [controller.view removeFromSuperview];
  });

  [self waitForExpectationsWithTimeout:1.0 handler:nil];
}

- (void)testPHPickerImmediateCloseReturnsEmptyArray API_AVAILABLE(ios(14)) {
  id photoLibrary = OCMClassMock([PHPhotoLibrary class]);
  OCMStub(ClassMethod([photoLibrary authorizationStatus]))
      .andReturn(PHAuthorizationStatusAuthorized);

  FLTImagePickerPlugin *plugin =
      [[FLTImagePickerPlugin alloc] initWithViewProvider:[[StubViewProvider alloc] init]];

  XCTestExpectation *resultExpectation = [self expectationWithDescription:@"result"];

  [plugin pickMultiImageWithMaxSize:[[FLTMaxSize alloc] init]
                            quality:nil
                       fullMetadata:NO
                              limit:nil
                         completion:^(NSArray<NSString *> *_Nullable result,
                                      FlutterError *_Nullable error) {
                           XCTAssertNotNil(result);
                           XCTAssertEqual(result.count, 0);
                           XCTAssertNil(error);
                           [resultExpectation fulfill];
                         }];

  id mockPresentationController = OCMClassMock([UIPresentationController class]);
  [plugin presentationControllerDidDismiss:mockPresentationController];

  [self waitForExpectationsWithTimeout:1.0 handler:nil];
}

- (void)testObserverDoesNotInterfereWhenProcessingSelection API_AVAILABLE(ios(14)) {
  id photoLibrary = OCMClassMock([PHPhotoLibrary class]);
  OCMStub(ClassMethod([photoLibrary authorizationStatus]))
      .andReturn(PHAuthorizationStatusAuthorized);

  FLTImagePickerPlugin *plugin =
      [[FLTImagePickerPlugin alloc] initWithViewProvider:[[StubViewProvider alloc] init]];

  XCTestExpectation *resultExpectation = [self expectationWithDescription:@"result"];
  __block BOOL emptyResultReceived = NO;

  [plugin pickMultiImageWithMaxSize:[[FLTMaxSize alloc] init]
                            quality:nil
                       fullMetadata:NO
                              limit:nil
                         completion:^(NSArray<NSString *> *_Nullable result,
                                      FlutterError *_Nullable error) {
                           if (result != nil && result.count > 0) {
                             emptyResultReceived = NO;
                             [resultExpectation fulfill];
                           } else if (result != nil && result.count == 0) {
                             emptyResultReceived = YES;
                           }
                         }];

  NSURL *tiffURL = [[NSBundle bundleForClass:[self class]] URLForResource:@"tiffImage"
                                                            withExtension:@"tiff"];
  NSItemProvider *tiffItemProvider = [[NSItemProvider alloc] initWithContentsOfURL:tiffURL];
  PHPickerResult *tiffResult = OCMClassMock([PHPickerResult class]);
  OCMStub([tiffResult itemProvider]).andReturn(tiffItemProvider);

  id mockPickerViewController = OCMClassMock([PHPickerViewController class]);

  [plugin picker:mockPickerViewController didFinishPicking:@[ tiffResult ]];

  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)),
                 dispatch_get_main_queue(), ^{
                   if (!resultExpectation.inverted) {
                     XCTAssertFalse(emptyResultReceived,
                                    @"Observer should not fire when processing selection");
                   }
                 });

  [self waitForExpectationsWithTimeout:5.0 handler:nil];
}

- (void)testObserverRespectsContextClearing {
  id photoLibrary = OCMClassMock([PHPhotoLibrary class]);
  OCMStub(ClassMethod([photoLibrary authorizationStatus]))
      .andReturn(PHAuthorizationStatusAuthorized);

  FLTImagePickerPlugin *plugin =
      [[FLTImagePickerPlugin alloc] initWithViewProvider:[[StubViewProvider alloc] init]];
  UIImagePickerController *controller = [[UIImagePickerController alloc] init];
  [plugin setImagePickerControllerOverrides:@[ controller ]];

  XCTestExpectation *resultExpectation = [self expectationWithDescription:@"result"];
  __block NSInteger completionCallCount = 0;

  [plugin pickImageWithSource:[FLTSourceSpecification makeWithType:FLTSourceTypeGallery
                                                            camera:FLTSourceCameraRear]
                      maxSize:[[FLTMaxSize alloc] init]
                      quality:nil
                 fullMetadata:NO
                   completion:^(NSString *_Nullable result, FlutterError *_Nullable error) {
                     completionCallCount++;
                     [resultExpectation fulfill];
                   }];

  XCTAssertNotNil(plugin.callContext, @"Context should be set after pickImage call");

  plugin.callContext = nil;

  UIView *controllerView = controller.view;
  if (controllerView) {
    UIWindow *testWindow = [[UIWindow alloc] init];
    [testWindow addSubview:controllerView];
    [controllerView removeFromSuperview];
  }

  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)),
                 dispatch_get_main_queue(), ^{
                   XCTAssertLessThanOrEqual(completionCallCount, 1,
                                            @"Observer should not fire after context is cleared");
                   if (completionCallCount == 0) {
                     [resultExpectation fulfill];
                   }
                 });

  [self waitForExpectationsWithTimeout:1.0 handler:nil];
}

- (void)testObserverDelayAllowsDelegateMethodsToRunFirst {
  id photoLibrary = OCMClassMock([PHPhotoLibrary class]);
  OCMStub(ClassMethod([photoLibrary authorizationStatus]))
      .andReturn(PHAuthorizationStatusAuthorized);

  FLTImagePickerPlugin *plugin =
      [[FLTImagePickerPlugin alloc] initWithViewProvider:[[StubViewProvider alloc] init]];
  UIImagePickerController *controller = [[UIImagePickerController alloc] init];
  [plugin setImagePickerControllerOverrides:@[ controller ]];

  XCTestExpectation *resultExpectation = [self expectationWithDescription:@"result"];
  __block NSInteger callCount = 0;

  [plugin pickImageWithSource:[FLTSourceSpecification makeWithType:FLTSourceTypeGallery
                                                            camera:FLTSourceCameraRear]
                      maxSize:[[FLTMaxSize alloc] init]
                      quality:nil
                 fullMetadata:NO
                   completion:^(NSString *_Nullable result, FlutterError *_Nullable error) {
                     callCount++;
                     if (callCount == 1) {
                       XCTAssertNil(result);
                       XCTAssertNil(error);

                       UIView *controllerView = controller.view;
                       if (controllerView) {
                         UIWindow *testWindow = [[UIWindow alloc] init];
                         [testWindow addSubview:controllerView];
                         [controllerView removeFromSuperview];
                       }

                       dispatch_after(
                           dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)),
                           dispatch_get_main_queue(), ^{
                             XCTAssertEqual(
                                 callCount, 1,
                                 @"Observer should not fire after context cleared by cancel");
                             [resultExpectation fulfill];
                           });
                     }
                   }];

  [plugin imagePickerControllerDidCancel:controller];

  [self waitForExpectationsWithTimeout:1.0 handler:nil];
}

@end
