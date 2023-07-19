
#import "CacheConfiguration.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "CacheManager.h"

static NSString *kFileNameKey = @"kFileNameKey";
static NSString *kCacheFragmentsKey = @"kCacheFragmentsKey";
static NSString *kDownloadInfoKey = @"kDownloadInfoKey";
static NSString *kContentInfoKey = @"kContentInfoKey";
static NSString *kURLKey = @"kURLKey";

@interface CacheConfiguration () <NSCoding>

@property(nonatomic, copy) NSString *filePath;
@property(nonatomic, copy) NSString *fileName;
@property(nonatomic, copy) NSArray<NSValue *> *internalCacheFragments;
@property(nonatomic, copy) NSArray *downloadInfo;

@end

@implementation CacheConfiguration

+ (instancetype)configurationWithFilePath:(NSString *)filePath error:(NSError **)error {
  filePath = [self configurationFilePathForFilePath:filePath];
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    CacheConfiguration *configuration = [NSKeyedUnarchiver unarchivedObjectOfClass:[CacheConfiguration class] fromData:data error:error];
    

  if (!configuration) {
    configuration = [[CacheConfiguration alloc] init];
    configuration.fileName = [filePath lastPathComponent];
  }
  configuration.filePath = filePath;

  return configuration;
}

+ (NSString *)configurationFilePathForFilePath:(NSString *)filePath {
  return [filePath stringByAppendingPathExtension:@"mt_cfg"];
}

- (NSArray<NSValue *> *)internalCacheFragments {
  if (!_internalCacheFragments) {
    _internalCacheFragments = [NSArray array];
  }
  return _internalCacheFragments;
}

- (NSArray *)downloadInfo {
  if (!_downloadInfo) {
    _downloadInfo = [NSArray array];
  }
  return _downloadInfo;
}

- (NSArray<NSValue *> *)cacheFragments {
  return [_internalCacheFragments copy];
}

#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)aCoder {
  [aCoder encodeObject:self.fileName forKey:kFileNameKey];
  [aCoder encodeObject:self.internalCacheFragments forKey:kCacheFragmentsKey];
  [aCoder encodeObject:self.downloadInfo forKey:kDownloadInfoKey];
  [aCoder encodeObject:self.contentInfo forKey:kContentInfoKey];
  [aCoder encodeObject:self.url forKey:kURLKey];
}

- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder {
  self = [super init];
  if (self) {
    _fileName = [aDecoder decodeObjectForKey:kFileNameKey];
    _internalCacheFragments = [[aDecoder decodeObjectForKey:kCacheFragmentsKey] mutableCopy];
    if (!_internalCacheFragments) {
      _internalCacheFragments = [NSArray array];
    }
    _downloadInfo = [aDecoder decodeObjectForKey:kDownloadInfoKey];
    _contentInfo = [aDecoder decodeObjectForKey:kContentInfoKey];
    _url = [aDecoder decodeObjectForKey:kURLKey];
  }
  return self;
}

#pragma mark - NSCopying

- (id)copyWithZone:(nullable NSZone *)zone {
  CacheConfiguration *configuration = [[CacheConfiguration allocWithZone:zone] init];
  configuration.fileName = self.fileName;
  configuration.filePath = self.filePath;
  configuration.internalCacheFragments = self.internalCacheFragments;
  configuration.downloadInfo = self.downloadInfo;
  configuration.url = self.url;
  configuration.contentInfo = self.contentInfo;

  return configuration;
}

#pragma mark - Update

- (void)save {
  [[self class] cancelPreviousPerformRequestsWithTarget:self
                                               selector:@selector(archiveData)
                                                 object:nil];
  [self performSelector:@selector(archiveData) withObject:nil afterDelay:1.0];
}

- (void)archiveData {
  @synchronized(self.internalCacheFragments) {
      NSError *error;
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self requiringSecureCoding:NO error:&error];
      
      if (error) {
          NSLog(@"%@", error);
      }
    [data writeToFile:self.filePath options:NSDataWritingAtomic error:&error];
      if (error) {
          NSLog(@"%@", error);
      }
  }
}

- (void)addCacheFragment:(NSRange)fragment {
  if (fragment.location == NSNotFound || fragment.length == 0) {
    return;
  }

  @synchronized(self.internalCacheFragments) {
    NSMutableArray *internalCacheFragments = [self.internalCacheFragments mutableCopy];

    NSValue *fragmentValue = [NSValue valueWithRange:fragment];
    NSInteger count = self.internalCacheFragments.count;
    if (count == 0) {
      [internalCacheFragments addObject:fragmentValue];
    } else {
      NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
      [internalCacheFragments
          enumerateObjectsUsingBlock:^(NSValue *_Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
            NSRange range = obj.rangeValue;
            if ((fragment.location + fragment.length) <= range.location) {
              if (indexSet.count == 0) {
                [indexSet addIndex:idx];
              }
              *stop = YES;
            } else if (fragment.location <= (range.location + range.length) &&
                       (fragment.location + fragment.length) > range.location) {
              [indexSet addIndex:idx];
            } else if (fragment.location >= range.location + range.length) {
              if (idx == count - 1) {  // Append to last index
                [indexSet addIndex:idx];
              }
            }
          }];

      if (indexSet.count > 1) {
        NSRange firstRange = self.internalCacheFragments[indexSet.firstIndex].rangeValue;
        NSRange lastRange = self.internalCacheFragments[indexSet.lastIndex].rangeValue;
        NSInteger location = MIN(firstRange.location, fragment.location);
        NSInteger endOffset =
            MAX(lastRange.location + lastRange.length, fragment.location + fragment.length);
        NSRange combineRange = NSMakeRange(location, endOffset - location);
        [internalCacheFragments removeObjectsAtIndexes:indexSet];
        [internalCacheFragments insertObject:[NSValue valueWithRange:combineRange]
                                     atIndex:indexSet.firstIndex];
      } else if (indexSet.count == 1) {
        NSRange firstRange = self.internalCacheFragments[indexSet.firstIndex].rangeValue;

        NSRange expandFirstRange = NSMakeRange(firstRange.location, firstRange.length + 1);
        NSRange expandFragmentRange = NSMakeRange(fragment.location, fragment.length + 1);
        NSRange intersectionRange = NSIntersectionRange(expandFirstRange, expandFragmentRange);
        if (intersectionRange.length > 0) {  // Should combine
          NSInteger location = MIN(firstRange.location, fragment.location);
          NSInteger endOffset =
              MAX(firstRange.location + firstRange.length, fragment.location + fragment.length);
          NSRange combineRange = NSMakeRange(location, endOffset - location);
          [internalCacheFragments removeObjectAtIndex:indexSet.firstIndex];
          [internalCacheFragments insertObject:[NSValue valueWithRange:combineRange]
                                       atIndex:indexSet.firstIndex];
        } else {
          if (firstRange.location > fragment.location) {
            [internalCacheFragments insertObject:fragmentValue atIndex:[indexSet lastIndex]];
          } else {
            [internalCacheFragments insertObject:fragmentValue atIndex:[indexSet lastIndex] + 1];
          }
        }
      }
    }

    self.internalCacheFragments = [internalCacheFragments copy];
  }
}

- (void)addDownloadedBytes:(long long)bytes spent:(NSTimeInterval)time {
  @synchronized(self.downloadInfo) {
    self.downloadInfo = [self.downloadInfo arrayByAddingObject:@[ @(bytes), @(time) ]];
  }
}

@end

@implementation CacheConfiguration (Convenient)

+ (BOOL)createAndSaveDownloadedConfigurationForURL:(NSURL *)url error:(NSError **)error {
  NSString *filePath = [CacheManager cachedFilePathForURL:url];
  NSFileManager *fileManager = [NSFileManager defaultManager];
  NSDictionary<NSFileAttributeKey, id> *attributes = [fileManager attributesOfItemAtPath:filePath
                                                                                   error:error];
  if (!attributes) {
    return NO;
  }

  NSUInteger fileSize = (NSUInteger)attributes.fileSize;
  NSRange range = NSMakeRange(0, fileSize);

    CacheConfiguration *configuration = [CacheConfiguration configurationWithFilePath:filePath error:error];
  configuration.url = url;

  ContentInfo *contentInfo = [ContentInfo new];

  NSString *fileExtension = [url pathExtension];
  NSString *UTI = (__bridge_transfer NSString *)UTTypeCreatePreferredIdentifierForTag(
      kUTTagClassFilenameExtension, (__bridge CFStringRef)fileExtension, NULL);
  NSString *contentType = (__bridge_transfer NSString *)UTTypeCopyPreferredTagWithClass(
      (__bridge CFStringRef)UTI, kUTTagClassMIMEType);
  if (!contentType) {
    contentType = @"application/octet-stream";
  }
  contentInfo.contentType = contentType;

  contentInfo.contentLength = fileSize;
  contentInfo.byteRangeAccessSupported = YES;
  contentInfo.downloadedContentLength = fileSize;
  configuration.contentInfo = contentInfo;

  [configuration addCacheFragment:range];
  [configuration save];

  return YES;
}

@end
