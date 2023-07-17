
#import "ContentCacheWorker.h"
#import "CacheAction.h"
#import "CacheManager.h"

@import UIKit;

static NSInteger const kPackageLength = 512 * 1024;  // 512 kb per package
static NSString *kMCMediaCacheResponseKey = @"kContentCacheResponseKey";
static NSString *MediaCacheErrorDomain = @"video_player_cache";

@interface ContentCacheWorker ()

@property(nonatomic, strong) NSFileHandle *readFileHandle;
@property(nonatomic, strong) NSFileHandle *writeFileHandle;
@property(nonatomic, strong, readwrite) NSError *setupError;
@property(nonatomic, copy) NSString *filePath;
@property(nonatomic, strong) CacheConfiguration *internalCacheConfiguration;

@property(nonatomic) long long currentOffset;

@property(nonatomic, strong) NSDate *startWriteDate;
@property(nonatomic) float writeBytes;
@property(nonatomic) BOOL writting;

@end

@implementation ContentCacheWorker

- (void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self];
  [self save];
  [_readFileHandle closeFile];
  [_writeFileHandle closeFile];
}

- (instancetype)initWithURL:(NSURL *)url {
  self = [super init];
  if (self) {
    NSString *path = [CacheManager cachedFilePathForURL:url];
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
          _internalCacheConfiguration = [CacheConfiguration configurationWithFilePath:path error:&error];
        _internalCacheConfiguration.url = url;
      }
    }

    _setupError = error;
  }
  return self;
}

- (CacheConfiguration *)cacheConfiguration {
  return self.internalCacheConfiguration;
}

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

- (NSArray<CacheAction *> *)cachedDataActionsForRange:(NSRange)range {
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
            CacheAction *action = [CacheAction new];
            action.cacheType = CacheTypeLocal;

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
    CacheAction *action = [CacheAction new];
    action.cacheType = CacheTypeRemote;
    action.range = range;
    [actions addObject:action];
  } else {
    // Add remote fragments
    NSMutableArray *localRemoteActions = [NSMutableArray array];
    [actions enumerateObjectsUsingBlock:^(CacheAction *_Nonnull obj, NSUInteger idx,
                                          BOOL *_Nonnull stop) {
      NSRange actionRange = obj.range;
      if (idx == 0) {
        if (range.location < actionRange.location) {
          CacheAction *action = [CacheAction new];
          action.cacheType = CacheTypeRemote;
          action.range = NSMakeRange(range.location, actionRange.location - range.location);
          [localRemoteActions addObject:action];
        }
        [localRemoteActions addObject:obj];
      } else {
        CacheAction *lastAction = [localRemoteActions lastObject];
        NSInteger lastOffset = lastAction.range.location + lastAction.range.length;
        if (actionRange.location > lastOffset) {
          CacheAction *action = [CacheAction new];
          action.cacheType = CacheTypeRemote;
          action.range = NSMakeRange(lastOffset, actionRange.location - lastOffset);
          [localRemoteActions addObject:action];
        }
        [localRemoteActions addObject:obj];
      }

      if (idx == actions.count - 1) {
        NSInteger localEndOffset = actionRange.location + actionRange.length;
        if (endOffset > localEndOffset) {
          CacheAction *action = [CacheAction new];
          action.cacheType = CacheTypeRemote;
          action.range = NSMakeRange(localEndOffset, endOffset - localEndOffset);
          [localRemoteActions addObject:action];
        }
      }
    }];

    actions = localRemoteActions;
  }

  return [actions copy];
}

- (void)setContentInfo:(ContentInfo *)contentInfo error:(NSError **)error {
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
  if (!self.writting) {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidEnterBackground:)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
  }
  self.writting = YES;
  self.startWriteDate = [NSDate date];
  self.writeBytes = 0;
}

- (void)finishWritting {
  if (self.writting) {
    self.writting = NO;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    NSTimeInterval time = [[NSDate date] timeIntervalSinceDate:self.startWriteDate];
    [self.internalCacheConfiguration addDownloadedBytes:self.writeBytes spent:time];
  }
}

#pragma mark - Notification

- (void)applicationDidEnterBackground:(NSNotification *)notification {
  [self save];
}

@end
