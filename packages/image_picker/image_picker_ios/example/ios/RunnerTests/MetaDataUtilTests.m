// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "ImagePickerTestImages.h"

@import image_picker_ios;
#if __has_include(<image_picker_ios/image_picker_ios-umbrella.h>)
@import image_picker_ios.Test;
#endif
@import XCTest;

@interface MetaDataUtilTests : XCTestCase
@end

@implementation MetaDataUtilTests

- (void)testGetImageMIMETypeFromImageData {
  // test jpeg
  XCTAssertEqual(
      [FLTImagePickerMetaDataUtil getImageMIMETypeFromImageData:ImagePickerTestImages.JPGTestData],
      FLTImagePickerMIMETypeJPEG);

  // test png
  XCTAssertEqual(
      [FLTImagePickerMetaDataUtil getImageMIMETypeFromImageData:ImagePickerTestImages.PNGTestData],
      FLTImagePickerMIMETypePNG);

  // test gif
  XCTAssertEqual(
      [FLTImagePickerMetaDataUtil getImageMIMETypeFromImageData:ImagePickerTestImages.GIFTestData],
      FLTImagePickerMIMETypeGIF);
}

- (void)testSuffixFromType {
  // test jpeg
  XCTAssertEqualObjects(
      [FLTImagePickerMetaDataUtil imageTypeSuffixFromType:FLTImagePickerMIMETypeJPEG], @".jpg");

  // test png
  XCTAssertEqualObjects(
      [FLTImagePickerMetaDataUtil imageTypeSuffixFromType:FLTImagePickerMIMETypePNG], @".png");

  // test gif
  XCTAssertEqualObjects(
      [FLTImagePickerMetaDataUtil imageTypeSuffixFromType:FLTImagePickerMIMETypeGIF], @".gif");

  // test other
  XCTAssertNil([FLTImagePickerMetaDataUtil imageTypeSuffixFromType:FLTImagePickerMIMETypeOther]);
}

- (void)testGetMetaData {
  NSDictionary *metaData =
      [FLTImagePickerMetaDataUtil getMetaDataFromImageData:ImagePickerTestImages.JPGTestData];
  NSDictionary *exif = [metaData objectForKey:(__bridge NSString *)kCGImagePropertyExifDictionary];
  XCTAssertEqual([exif[(__bridge NSString *)kCGImagePropertyExifPixelXDimension] integerValue], 12);
}

- (void)testWriteMetaData {
  NSData *dataJPG = ImagePickerTestImages.JPGTestData;

  NSDictionary *metaData = [FLTImagePickerMetaDataUtil getMetaDataFromImageData:dataJPG];
  NSString *tmpFile = [NSString stringWithFormat:@"image_picker_test.jpg"];
  NSString *tmpDirectory = NSTemporaryDirectory();
  NSString *tmpPath = [tmpDirectory stringByAppendingPathComponent:tmpFile];
  NSData *newData = [FLTImagePickerMetaDataUtil imageFromImage:dataJPG withMetaData:metaData];
  if ([[NSFileManager defaultManager] createFileAtPath:tmpPath contents:newData attributes:nil]) {
    NSData *savedTmpImageData = [NSData dataWithContentsOfFile:tmpPath];
    NSDictionary *tmpMetaData =
        [FLTImagePickerMetaDataUtil getMetaDataFromImageData:savedTmpImageData];
    XCTAssert([tmpMetaData isEqualToDictionary:metaData]);
  } else {
    XCTAssert(NO);
  }
}

- (void)testUpdateMetaDataBadData {
  NSData *imageData = [NSData data];

  NSDictionary *metaData = [FLTImagePickerMetaDataUtil getMetaDataFromImageData:imageData];
  NSData *newData = [FLTImagePickerMetaDataUtil imageFromImage:imageData withMetaData:metaData];
  XCTAssertNil(newData);
}

- (void)testConvertImageToData {
  UIImage *imageJPG = [UIImage imageWithData:ImagePickerTestImages.JPGTestData];
  NSData *convertedDataJPG = [FLTImagePickerMetaDataUtil convertImage:imageJPG
                                                            usingType:FLTImagePickerMIMETypeJPEG
                                                              quality:@(0.5)];
  XCTAssertEqual([FLTImagePickerMetaDataUtil getImageMIMETypeFromImageData:convertedDataJPG],
                 FLTImagePickerMIMETypeJPEG);

  NSData *convertedDataPNG = [FLTImagePickerMetaDataUtil convertImage:imageJPG
                                                            usingType:FLTImagePickerMIMETypePNG
                                                              quality:nil];
  XCTAssertEqual([FLTImagePickerMetaDataUtil getImageMIMETypeFromImageData:convertedDataPNG],
                 FLTImagePickerMIMETypePNG);

  NSData *convertedJPEGDefaultQuality =
      [FLTImagePickerMetaDataUtil convertImage:imageJPG
                                     usingType:FLTImagePickerMIMETypeJPEG
                                       quality:nil];
  XCTAssertEqual(
      [FLTImagePickerMetaDataUtil getImageMIMETypeFromImageData:convertedJPEGDefaultQuality],
      FLTImagePickerMIMETypeJPEG);
}

- (void)testGetImageMIMETypeFromImageDataUnknownReturnsOther {
  uint8_t bytes[] = {0x00};
  NSData *data = [NSData dataWithBytes:bytes length:1];
  XCTAssertEqual([FLTImagePickerMetaDataUtil getImageMIMETypeFromImageData:data],
                 FLTImagePickerMIMETypeOther);
}

- (void)testConvertImageIgnoresQualityForPNG {
  UIImage *imageJPG = [UIImage imageWithData:ImagePickerTestImages.JPGTestData];
  NSData *convertedDataPNG = [FLTImagePickerMetaDataUtil convertImage:imageJPG
                                                            usingType:FLTImagePickerMIMETypePNG
                                                              quality:@(0.5)];
  XCTAssertEqual([FLTImagePickerMetaDataUtil getImageMIMETypeFromImageData:convertedDataPNG],
                 FLTImagePickerMIMETypePNG);
}

- (void)testConvertImageDefaultsNonJPEGNonPNGToJPEG {
  UIImage *imageJPG = [UIImage imageWithData:ImagePickerTestImages.JPGTestData];
  NSData *convertedGIF = [FLTImagePickerMetaDataUtil convertImage:imageJPG
                                                        usingType:FLTImagePickerMIMETypeGIF
                                                          quality:@(0.5)];
  XCTAssertEqual([FLTImagePickerMetaDataUtil getImageMIMETypeFromImageData:convertedGIF],
                 FLTImagePickerMIMETypeJPEG);

  NSData *convertedOther = [FLTImagePickerMetaDataUtil convertImage:imageJPG
                                                          usingType:FLTImagePickerMIMETypeOther
                                                            quality:nil];
  XCTAssertEqual([FLTImagePickerMetaDataUtil getImageMIMETypeFromImageData:convertedOther],
                 FLTImagePickerMIMETypeJPEG);
}

@end
