// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "FVPContentCacheWorker.h"
#import "FVPCacheAction.h"
#import "FVPCacheManager.h"

@import UIKit;

static NSInteger const kPackageLength = 512 * 1024;  // 512 kb per package
static NSString *kMCMediaCacheResponseKey = @"kContentCacheResponseKey";
static NSString *MediaCacheErrorDomain = @"video_player_cache";

@interface FVPContentCacheWorker ()

@property(nonatomic, strong) NSFileHandle *readFileHandle;
@property(nonatomic, strong) NSFileHandle *writeFileHandle;
@property(nonatomic, copy) NSString *filePath;
@property (nonatomic, strong, readwrite) NSError *setupError;
@property(nonatomic, strong) FVPCacheConfiguration *internalCacheConfiguration;

@property(nonatomic) long long currentOffset;

@property(nonatomic, strong) NSDate *startWriteDate;
@property(nonatomic) float writeBytes;
@property(nonatomic) BOOL isWritting;

@end

@implementation FVPContentCacheWorker

- (void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self];
  [self save];
  [_readFileHandle closeFile];
  [_writeFileHandle closeFile];
}

- (instancetype)init NS_UNAVAILABLE {
  NSAssert(NO, @"Use - initWithURL: instead");
  return nil;
}

- (instancetype)initWithURL:(NSURL *)url {
  self = [super init];
  if (self) {
    NSString *path = [FVPCacheManager cachedFilePathForURL:url];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    _filePath = path;
    NSError *error;
    NSString *cacheFolder = [path stringByDeletingLastPathComponent];
    if (![fileManager fileExistsAtPath:cacheFolder]) {
      [fileManager createDirectoryAtPath:cacheFolder
             withIntermediateDirectories:YES
                              attributes:nil
                                   error:&error];
    }

    if (!error) {
      if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        [[NSFileManager defaultManager] createFileAtPath:path contents:nil attributes:nil];
      }
      NSURL *fileURL = [NSURL fileURLWithPath:path];
      _readFileHandle = [NSFileHandle fileHandleForReadingFromURL:fileURL error:&error];
      if (!error) {
        _writeFileHandle = [NSFileHandle fileHandleForWritingToURL:fileURL error:&error];

        // retrieve (or creates) the configuration that belongs to the url
        _internalCacheConfiguration = [FVPCacheConfiguration configurationWithFilePath:path
                                                                                 error:&error];
        _internalCacheConfiguration.url = url;
      }
    }
      
  _setupError = error;
  }
  return self;
}

// Stores (cache) data for fragement or NSError
- (void)cacheData:(NSData *)data forRange:(NSRange)range error:(NSError **)error {
  @synchronized(self.writeFileHandle) {
    @try {
      [self.writeFileHandle seekToFileOffset:range.location];
      [self.writeFileHandle writeData:data];
      self.writeBytes += data.length;
      [self.internalCacheConfiguration addCacheFragment:range];
    } @catch (NSException *exception) {
      NSLog(@"write to file error");
      *error = [NSError errorWithDomain:exception.name
                                   code:123
                               userInfo:@{
                                 NSLocalizedDescriptionKey : exception.reason,
                                 @"exception" : exception
                               }];
    }
  }
}

// returns cached data for fragement or NSError
- (NSData *)cachedDataForRange:(NSRange)range error:(NSError **)error {
  @synchronized(self.readFileHandle) {
    @try {
      [self.readFileHandle seekToFileOffset:range.location];
      NSData *data = [self.readFileHandle readDataOfLength:range.length];
      return data;
    } @catch (NSException *exception) {
      NSLog(@"read cached data error %@", exception);
      *error = [NSError errorWithDomain:exception.name
                                   code:123
                               userInfo:@{
                                 NSLocalizedDescriptionKey : exception.reason,
                                 @"exception" : exception
                               }];
    }
  }
  return nil;
}

// returns cacheActions for fragement or NSError
- (NSArray<FVPCacheAction *> *)cachedDataActionsForRange:(NSRange)range {
  NSArray *cachedFragments = [self.internalCacheConfiguration cacheFragments];
  NSMutableArray *actions = [NSMutableArray array];

  if (range.location == NSNotFound) {
    return [actions copy];
  }
  NSInteger endOffset = range.location + range.length;
  // Delete header and footer not in range
  [cachedFragments
      enumerateObjectsUsingBlock:^(NSValue *_Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
        NSRange fragmentRange = obj.rangeValue;
        NSRange intersectionRange = NSIntersectionRange(range, fragmentRange);
        if (intersectionRange.length > 0) {
          NSInteger package = intersectionRange.length / kPackageLength;
          for (NSInteger i = 0; i <= package; i++) {
              
              
            FVPCacheAction *action = [FVPCacheAction new];
            action.cacheType = FVPCacheTypeUseLocal;

            NSInteger offset = i * kPackageLength;
            NSInteger offsetLocation = intersectionRange.location + offset;
            NSInteger maxLocation = intersectionRange.location + intersectionRange.length;
            NSInteger length = (offsetLocation + kPackageLength) > maxLocation
                                   ? (maxLocation - offsetLocation)
                                   : kPackageLength;
            action.range = NSMakeRange(offsetLocation, length);

            [actions addObject:action];
          }
        } else if (fragmentRange.location >= endOffset) {
          *stop = YES;
        }
      }];
  if (actions.count == 0) {
    FVPCacheAction *action = [FVPCacheAction new];
    action.cacheType = FVPCacheTypeIgnoreLocal;
    action.range = range;
    [actions addObject:action];
  } else {
    // Add remote fragments
    NSMutableArray *localRemoteActions = [NSMutableArray array];
    [actions enumerateObjectsUsingBlock:^(FVPCacheAction *_Nonnull obj, NSUInteger idx,
                                          BOOL *_Nonnull stop) {
      NSRange actionRange = obj.range;
      if (idx == 0) {
        if (range.location < actionRange.location) {
          FVPCacheAction *action = [FVPCacheAction new];
          action.cacheType = FVPCacheTypeIgnoreLocal;
          action.range = NSMakeRange(range.location, actionRange.location - range.location);
          [localRemoteActions addObject:action];
        }
        [localRemoteActions addObject:obj];
      } else {
        FVPCacheAction *lastAction = [localRemoteActions lastObject];
        NSInteger lastOffset = lastAction.range.location + lastAction.range.length;
        if (actionRange.location > lastOffset) {
          FVPCacheAction *action = [FVPCacheAction new];
          action.cacheType = FVPCacheTypeIgnoreLocal;
          action.range = NSMakeRange(lastOffset, actionRange.location - lastOffset);
          [localRemoteActions addObject:action];
        }
        [localRemoteActions addObject:obj];
      }

      if (idx == actions.count - 1) {
        NSInteger localEndOffset = actionRange.location + actionRange.length;
        if (endOffset > localEndOffset) {
          FVPCacheAction *action = [FVPCacheAction new];
          action.cacheType = FVPCacheTypeIgnoreLocal;
          action.range = NSMakeRange(localEndOffset, endOffset - localEndOffset);
          [localRemoteActions addObject:action];
        }
      }
    }];

    actions = localRemoteActions;
  }

  return [actions copy];
}

// stores content info
- (void)setContentInfo:(FVPContentInfo *)contentInfo error:(NSError **)error {
  self.internalCacheConfiguration.contentInfo = contentInfo;
  @try {
    [self.writeFileHandle truncateFileAtOffset:contentInfo.contentLength];
    [self.writeFileHandle synchronizeFile];
  } @catch (NSException *exception) {
    NSLog(@"read cached data error %@", exception);
    *error = [NSError
        errorWithDomain:exception.name
                   code:123
               userInfo:@{NSLocalizedDescriptionKey : exception.reason, @"exception" : exception}];
  }
}

- (void)save {
  @synchronized(self.writeFileHandle) {
    [self.writeFileHandle synchronizeFile];
    [self.internalCacheConfiguration save];
  }
}

- (void)startWritting {
  if (!self.isWritting) {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidEnterBackground:)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
  }
  self.isWritting = YES;
  self.startWriteDate = [NSDate date];
  self.writeBytes = 0;
}

- (void)finishWritting {
  if (self.isWritting) {
    self.isWritting = NO;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    NSTimeInterval time = [[NSDate date] timeIntervalSinceDate:self.startWriteDate];
    [self.internalCacheConfiguration addDownloadedBytes:self.writeBytes spent:time];
  }
}

#pragma mark - Notification

// This callback is triggered when the application enters the background. It saves the cache data
// when the application is about to move to the background state to ensure data integrity.
- (void)applicationDidEnterBackground:(NSNotification *)notification {
  [self save];
}

@end
