// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "TestAssetProvider.h"

static NSString *const kTestAssetKey = @"testAssetKey";

@interface TestAssetProvider ()
@property(readonly, nonatomic) UIImage *image;
@property(readonly, nonatomic) NSString *assetName;
@property(readonly, nonatomic) NSString *package;
@end

@implementation TestAssetProvider

- (instancetype)initWithImage:(UIImage *)image
                 forAssetName:(NSString *)assetName
                      package:(nullable NSString *)package {
  self = [super init];
  if (self) {
    _image = image;
    _assetName = assetName;
    _package = package;
  }
  return self;
}

- (NSString *)lookupKeyForAsset:(NSString *)asset {
  if ([asset isEqualToString:self.assetName]) {
    return kTestAssetKey;
  }
  return nil;
}

- (NSString *)lookupKeyForAsset:(NSString *)asset fromPackage:(NSString *)package {
  if ([asset isEqualToString:self.assetName] && [package isEqualToString:self.package]) {
    return kTestAssetKey;
  }
  return nil;
}

- (UIImage *)imageNamed:(NSString *)name {
  if ([name isEqualToString:kTestAssetKey]) {
    return self.image;
  }
  return nil;
}

@end
