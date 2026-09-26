// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "ImagePickerTestImages.h"

@import image_picker_ios;
#if __has_include(<image_picker_ios/image_picker_ios-umbrella.h>)
@import image_picker_ios.Test;
#endif
@import XCTest;

#import <OCMock/OCMock.h>

@interface FLTImagePickerPhotoAssetUtil (Test)
+ (nullable NSString *)saveImageWithMetaData:(nullable NSDictionary *)metaData
                                     gifInfo:(GIFInfo *)gifInfo
                                        path:(NSString *)path;
@end

@interface PhotoAssetUtilTests : XCTestCase
@end

@implementation PhotoAssetUtilTests

- (void)testGetAssetFromImagePickerInfoShouldReturnNilIfNotAvailable {
  NSDictionary *mockData = @{};
  XCTAssertNil([FLTImagePickerPhotoAssetUtil getAssetFromImagePickerInfo:mockData]);
}

- (void)testGetAssetFromImagePickerInfoShouldReturnAssetIfPresent {
  id mockAsset = OCMClassMock([PHAsset class]);
  NSDictionary *info = @{UIImagePickerControllerPHAsset : mockAsset};
  XCTAssertEqual([FLTImagePickerPhotoAssetUtil getAssetFromImagePickerInfo:info], mockAsset);
}

- (void)testSaveVideoFromURLReturnsNilWhenSourceIsUnreadable {
  NSURL *missing = [NSURL fileURLWithPath:@"/this/path/does/not/exist.mov"];
  XCTAssertNil([FLTImagePickerPhotoAssetUtil saveVideoFromURL:missing]);
}

- (void)testSaveVideoFromURLCopiesReadableFile {
  NSString *sourcePath = [NSTemporaryDirectory()
      stringByAppendingPathComponent:[[NSUUID UUID].UUIDString
                                         stringByAppendingPathExtension:@"mov"]];
  XCTAssertTrue([[NSFileManager defaultManager]
      createFileAtPath:sourcePath
              contents:[@"video" dataUsingEncoding:NSUTF8StringEncoding]
            attributes:nil]);
  NSURL *destination =
      [FLTImagePickerPhotoAssetUtil saveVideoFromURL:[NSURL fileURLWithPath:sourcePath]];
  XCTAssertNotNil(destination);
  if (destination) {
    XCTAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:destination.path]);
    [[NSFileManager defaultManager] removeItemAtURL:destination error:nil];
  }
  [[NSFileManager defaultManager] removeItemAtPath:sourcePath error:nil];
}

- (void)testSaveVideoFromURLReturnsNilWhenCopyFails {
  NSString *sourcePath = [NSTemporaryDirectory()
      stringByAppendingPathComponent:[[NSUUID UUID].UUIDString
                                         stringByAppendingPathExtension:@"mov"]];
  XCTAssertTrue([[NSFileManager defaultManager]
      createFileAtPath:sourcePath
              contents:[@"video" dataUsingEncoding:NSUTF8StringEncoding]
            attributes:nil]);

  id mockFileManager = OCMPartialMock([NSFileManager defaultManager]);
  NSError *copyError = [NSError errorWithDomain:@"PhotoAssetUtilTests" code:1 userInfo:nil];
  OCMStub([mockFileManager copyItemAtURL:OCMOCK_ANY
                                   toURL:OCMOCK_ANY
                                   error:[OCMArg setTo:copyError]])
      .andReturn(NO);

  XCTAssertNil([FLTImagePickerPhotoAssetUtil saveVideoFromURL:[NSURL fileURLWithPath:sourcePath]]);

  [mockFileManager stopMocking];
  [[NSFileManager defaultManager] removeItemAtPath:sourcePath error:nil];
}

- (void)testSaveImageWithOriginalImageDataNilUsesDefaultJPEG {
  UIImage *imageJPG = [UIImage imageWithData:ImagePickerTestImages.JPGTestData];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wnonnull"
  NSString *savedPath = [FLTImagePickerPhotoAssetUtil saveImageWithOriginalImageData:nil
                                                                               image:imageJPG
                                                                            maxWidth:nil
                                                                           maxHeight:nil
                                                                        imageQuality:nil];
#pragma clang diagnostic pop
  XCTAssertEqualObjects([NSURL fileURLWithPath:savedPath].pathExtension, @"jpg");
  if (savedPath) {
    [[NSFileManager defaultManager] removeItemAtPath:savedPath error:nil];
  }
}

- (void)testCreateFileReturnsNilWhenWriteFails {
  UIImage *imageJPG = [UIImage imageWithData:ImagePickerTestImages.JPGTestData];
  id mockFileManager = OCMPartialMock([NSFileManager defaultManager]);
  OCMStub([mockFileManager createFileAtPath:OCMOCK_ANY contents:OCMOCK_ANY attributes:OCMOCK_ANY])
      .andReturn(NO);

  NSString *savedPath = [FLTImagePickerPhotoAssetUtil saveImageWithPickerInfo:nil
                                                                        image:imageJPG
                                                                 imageQuality:nil];
  XCTAssertNil(savedPath);

  [mockFileManager stopMocking];
}

- (void)testSaveImageWithPickerInfoReturnsNilWhenImageCannotBeEncoded {
  // An image with no underlying bitmap cannot be encoded as JPEG, so there is no data to save.
  UIImage *image = [[UIImage alloc] init];
  NSString *savedPath = [FLTImagePickerPhotoAssetUtil saveImageWithPickerInfo:nil
                                                                        image:image
                                                                 imageQuality:nil];
  XCTAssertNil(
      savedPath, @"Returned a path to a %llu-byte file.",
      [[NSFileManager defaultManager] attributesOfItemAtPath:savedPath error:nil].fileSize);
  if (savedPath) {
    [[NSFileManager defaultManager] removeItemAtPath:savedPath error:nil];
  }
}

- (void)testSaveImageWithOriginalImageDataSavesImageWhenMetaDataUpdateFails {
  NSData *dataJPG = ImagePickerTestImages.JPGTestData;
  UIImage *imageJPG = [UIImage imageWithData:dataJPG];
  id mockMetaDataUtil = OCMClassMock([FLTImagePickerMetaDataUtil class]);
  OCMStub(ClassMethod([mockMetaDataUtil imageFromImage:OCMOCK_ANY withMetaData:OCMOCK_ANY]))
      .andReturn(nil);

  NSString *savedPath = [FLTImagePickerPhotoAssetUtil saveImageWithOriginalImageData:dataJPG
                                                                               image:imageJPG
                                                                            maxWidth:nil
                                                                           maxHeight:nil
                                                                        imageQuality:nil];
  OCMVerify(ClassMethod([mockMetaDataUtil imageFromImage:OCMOCK_ANY withMetaData:OCMOCK_ANY]));
  [mockMetaDataUtil stopMocking];

  XCTAssertNotNil(savedPath);
  NSData *savedData = [NSData dataWithContentsOfFile:savedPath];
  XCTAssertGreaterThan(savedData.length, 0U);
  XCTAssertNotNil([UIImage imageWithData:savedData]);
  if (savedPath) {
    [[NSFileManager defaultManager] removeItemAtPath:savedPath error:nil];
  }
}

- (void)testSaveImageWithOriginalImageDataReturnsNilWhenGIFCannotBeSaved {
  // Only the GIF header and logical screen descriptor, so there are no frames to write.
  NSData *truncatedGIF = [ImagePickerTestImages.GIFTestData subdataWithRange:NSMakeRange(0, 13)];
  XCTAssertNil([UIImage imageWithData:truncatedGIF]);

  NSString *savedPath = [FLTImagePickerPhotoAssetUtil saveImageWithOriginalImageData:truncatedGIF
                                                                               image:nil
                                                                            maxWidth:nil
                                                                           maxHeight:nil
                                                                        imageQuality:nil];
  XCTAssertNil(
      savedPath, @"Returned a path to a file that %@.",
      [[NSFileManager defaultManager] fileExistsAtPath:savedPath] ? @"exists" : @"does not exist");
  if (savedPath) {
    [[NSFileManager defaultManager] removeItemAtPath:savedPath error:nil];
  }
}

- (void)testSaveGIFReturnsNilWhenDestinationCannotBeCreated {
  UIImage *frame = [UIImage imageWithData:ImagePickerTestImages.GIFTestData];
  GIFInfo *gifInfo = [[GIFInfo alloc] initWithImages:@[ frame ] interval:0.1];
  XCTAssertNil([FLTImagePickerPhotoAssetUtil
      saveImageWithMetaData:nil
                    gifInfo:gifInfo
                       path:@"/this/path/does/not/exist.gif"]);
}

- (void)testSaveImageWithOriginalImageData_ShouldSaveWithTheCorrectExtentionAndMetaData {
  // test jpg
  NSData *dataJPG = ImagePickerTestImages.JPGTestData;
  UIImage *imageJPG = [UIImage imageWithData:dataJPG];
  NSString *savedPathJPG = [FLTImagePickerPhotoAssetUtil saveImageWithOriginalImageData:dataJPG
                                                                                  image:imageJPG
                                                                               maxWidth:nil
                                                                              maxHeight:nil
                                                                           imageQuality:nil];
  XCTAssertEqualObjects([NSURL URLWithString:savedPathJPG].pathExtension, @"jpg");

  NSDictionary *originalMetaDataJPG = [FLTImagePickerMetaDataUtil getMetaDataFromImageData:dataJPG];
  NSData *newDataJPG = [NSData dataWithContentsOfFile:savedPathJPG];
  NSDictionary *newMetaDataJPG = [FLTImagePickerMetaDataUtil getMetaDataFromImageData:newDataJPG];
  XCTAssertEqualObjects(originalMetaDataJPG[@"ProfileName"], newMetaDataJPG[@"ProfileName"]);

  // test png
  NSData *dataPNG = ImagePickerTestImages.PNGTestData;
  UIImage *imagePNG = [UIImage imageWithData:dataPNG];
  NSString *savedPathPNG = [FLTImagePickerPhotoAssetUtil saveImageWithOriginalImageData:dataPNG
                                                                                  image:imagePNG
                                                                               maxWidth:nil
                                                                              maxHeight:nil
                                                                           imageQuality:nil];
  XCTAssertEqualObjects([NSURL URLWithString:savedPathPNG].pathExtension, @"png");

  NSDictionary *originalMetaDataPNG = [FLTImagePickerMetaDataUtil getMetaDataFromImageData:dataPNG];
  NSData *newDataPNG = [NSData dataWithContentsOfFile:savedPathPNG];
  NSDictionary *newMetaDataPNG = [FLTImagePickerMetaDataUtil getMetaDataFromImageData:newDataPNG];
  XCTAssertEqualObjects(originalMetaDataPNG[@"ProfileName"], newMetaDataPNG[@"ProfileName"]);
}

- (void)testSaveImageWithPickerInfo_ShouldSaveWithDefaultExtention {
  UIImage *imageJPG = [UIImage imageWithData:ImagePickerTestImages.JPGTestData];
  NSString *savedPathJPG = [FLTImagePickerPhotoAssetUtil saveImageWithPickerInfo:nil
                                                                           image:imageJPG
                                                                    imageQuality:nil];
  // should be saved as
  XCTAssertEqualObjects([savedPathJPG substringFromIndex:savedPathJPG.length - 4],
                        kFLTImagePickerDefaultSuffix);
}

- (void)testSaveImageWithPickerInfo_ShouldSaveWithTheCorrectExtentionAndMetaData {
  NSDictionary *dummyInfo = @{
    UIImagePickerControllerMediaMetadata : @{
      (__bridge NSString *)kCGImagePropertyExifDictionary :
          @{(__bridge NSString *)kCGImagePropertyExifUserComment : @"aNote"}
    }
  };
  UIImage *imageJPG = [UIImage imageWithData:ImagePickerTestImages.JPGTestData];
  NSString *savedPathJPG = [FLTImagePickerPhotoAssetUtil saveImageWithPickerInfo:dummyInfo
                                                                           image:imageJPG
                                                                    imageQuality:nil];
  NSData *data = [NSData dataWithContentsOfFile:savedPathJPG];
  NSDictionary *meta = [FLTImagePickerMetaDataUtil getMetaDataFromImageData:data];
  XCTAssertEqualObjects(meta[(__bridge NSString *)kCGImagePropertyExifDictionary]
                            [(__bridge NSString *)kCGImagePropertyExifUserComment],
                        @"aNote");
}

- (void)testSaveImageWithOriginalImageData_ShouldSaveAsGifAnimation {
  // test gif
  NSData *dataGIF = ImagePickerTestImages.GIFTestData;
  UIImage *imageGIF = [UIImage imageWithData:dataGIF];
  CGImageSourceRef imageSource = CGImageSourceCreateWithData((__bridge CFDataRef)dataGIF, nil);

  size_t numberOfFrames = CGImageSourceGetCount(imageSource);

  NSString *savedPathGIF = [FLTImagePickerPhotoAssetUtil saveImageWithOriginalImageData:dataGIF
                                                                                  image:imageGIF
                                                                               maxWidth:nil
                                                                              maxHeight:nil
                                                                           imageQuality:nil];
  XCTAssertEqualObjects([NSURL URLWithString:savedPathGIF].pathExtension, @"gif");

  NSData *newDataGIF = [NSData dataWithContentsOfFile:savedPathGIF];

  CGImageSourceRef newImageSource =
      CGImageSourceCreateWithData((__bridge CFDataRef)newDataGIF, nil);

  size_t newNumberOfFrames = CGImageSourceGetCount(newImageSource);

  XCTAssertEqual(numberOfFrames, newNumberOfFrames);
}

- (void)testSaveImageWithOriginalImageData_ShouldSaveAsScalledGifAnimation {
  // test gif
  NSData *dataGIF = ImagePickerTestImages.GIFTestData;
  UIImage *imageGIF = [UIImage imageWithData:dataGIF];

  CGImageSourceRef imageSource = CGImageSourceCreateWithData((__bridge CFDataRef)dataGIF, nil);

  size_t numberOfFrames = CGImageSourceGetCount(imageSource);

  NSString *savedPathGIF = [FLTImagePickerPhotoAssetUtil saveImageWithOriginalImageData:dataGIF
                                                                                  image:imageGIF
                                                                               maxWidth:@3
                                                                              maxHeight:@2
                                                                           imageQuality:nil];
  NSData *newDataGIF = [NSData dataWithContentsOfFile:savedPathGIF];
  UIImage *newImage = [[UIImage alloc] initWithData:newDataGIF];

  XCTAssertEqual(newImage.size.width, 3);
  XCTAssertEqual(newImage.size.height, 2);

  CGImageSourceRef newImageSource =
      CGImageSourceCreateWithData((__bridge CFDataRef)newDataGIF, nil);

  size_t newNumberOfFrames = CGImageSourceGetCount(newImageSource);

  XCTAssertEqual(numberOfFrames, newNumberOfFrames);
}

@end
