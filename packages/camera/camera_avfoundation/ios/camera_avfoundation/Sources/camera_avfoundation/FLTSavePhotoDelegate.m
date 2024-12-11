// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "./include/camera_avfoundation/FLTSavePhotoDelegate.h"
#import "./include/camera_avfoundation/FLTSavePhotoDelegate_Test.h"
#import "./include/camera_avfoundation/Protocols/FLTPhotoData.h"


@interface FLTSavePhotoDelegate ()
/// The file path for the captured photo.
@property(readonly, nonatomic) NSString *path;
/// The queue on which captured photos are written to disk.
@property(readonly, nonatomic) dispatch_queue_t ioQueue;
@end

@implementation FLTSavePhotoDelegate

- (instancetype)initWithPath:(NSString *)path
                     ioQueue:(dispatch_queue_t)ioQueue
           completionHandler:(FLTSavePhotoDelegateCompletionHandler)completionHandler {
  self = [super init];
  NSAssert(self, @"super init cannot be nil");
  _path = path;
  _ioQueue = ioQueue;
  _completionHandler = completionHandler;
  return self;
}

- (void)handlePhotoCaptureResultWithError:(NSError *)error
                        photoDataProvider:(id<FLTPhotoData> (^)(void))photoDataProvider {
  if (error) {
    self.completionHandler(nil, error);
    return;
  }
  __weak typeof(self) weakSelf = self;
  dispatch_async(self.ioQueue, ^{
    typeof(self) strongSelf = weakSelf;
    if (!strongSelf) return;

    id<FLTPhotoData> data = photoDataProvider();
    NSError *ioError;
    if ([data writeToFile:strongSelf.path options:NSDataWritingAtomic error:&ioError]) {
      strongSelf.completionHandler(self.path, nil);
    } else {
      strongSelf.completionHandler(nil, ioError);
    }
  });
}

- (void)captureOutput:(AVCapturePhotoOutput *)output
    didFinishProcessingPhoto:(AVCapturePhoto *)photo
                       error:(NSError *)error {
  [self handlePhotoCaptureResultWithError:error
                        photoDataProvider:^id<FLTPhotoData> {
                          NSData *data = [photo fileDataRepresentation];
                          return [[FLTDefaultPhotoData alloc] init];
                        }];
}

- (NSString *)filePath {
  return self.path;
}
@end
