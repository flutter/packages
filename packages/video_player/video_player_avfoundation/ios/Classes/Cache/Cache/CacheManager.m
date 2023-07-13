
#import "CacheManager.h"
#import "ContentDownloader.h"

NSString *CacheConfigurationKey = @"CacheConfigurationKey";

static NSString *kMContentCacheDirectory;

@implementation CacheManager

+ (void)load {
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    [self setCacheDirectory:[NSTemporaryDirectory() stringByAppendingPathComponent:
                                                        @"video_player_temporary_cache_directory"]];
  });
}

+ (void)setCacheDirectory:(NSString *)cacheDirectory {
  kMContentCacheDirectory = cacheDirectory;
}

+ (NSString *)cacheDirectory {
  return kMContentCacheDirectory;
}

+ (NSString *)cachedFilePathForURL:(NSURL *)url {
  NSLog(@"%@", url);
  NSString *pathComponent = url.absoluteString;
  return [[self cacheDirectory] stringByAppendingPathComponent:pathComponent];
}

+ (CacheConfiguration *)cacheConfigurationForURL:(NSURL *)url error:(NSError **)error {
  NSString *filePath = [self cachedFilePathForURL:url];
    CacheConfiguration *configuration = [CacheConfiguration configurationWithFilePath:filePath error:error];
  return configuration;
}

+ (unsigned long long)calculateCachedSizeWithError:(NSError **)error {
  NSFileManager *fileManager = [NSFileManager defaultManager];
  NSString *cacheDirectory = [self cacheDirectory];
  NSArray *files = [fileManager contentsOfDirectoryAtPath:cacheDirectory error:error];
  unsigned long long size = 0;
  if (files) {
    for (NSString *path in files) {
      NSString *filePath = [cacheDirectory stringByAppendingPathComponent:path];
      NSDictionary<NSFileAttributeKey, id> *attribute = [fileManager attributesOfItemAtPath:filePath
                                                                                      error:error];
      if (!attribute) {
        size = -1;
        break;
      }

      size += [attribute fileSize];
    }
  }
  return size;
}

+ (void)cleanAllCacheWithError:(NSError **)error {
  // Find downloaing file
  NSMutableSet *downloadingFiles = [NSMutableSet set];
  [[[ContentDownloaderStatus shared] urls]
      enumerateObjectsUsingBlock:^(NSURL *_Nonnull obj, BOOL *_Nonnull stop) {
        NSString *file = [self cachedFilePathForURL:obj];
        [downloadingFiles addObject:file];
        NSString *configurationPath = [CacheConfiguration configurationFilePathForFilePath:file];
        [downloadingFiles addObject:configurationPath];
      }];

  // Remove files
  NSFileManager *fileManager = [NSFileManager defaultManager];
  NSString *cacheDirectory = [self cacheDirectory];

  NSArray *files = [fileManager contentsOfDirectoryAtPath:cacheDirectory error:error];
  if (files) {
    for (NSString *path in files) {
      NSString *filePath = [cacheDirectory stringByAppendingPathComponent:path];
      if ([downloadingFiles containsObject:filePath]) {
        continue;
      }
      if (![fileManager removeItemAtPath:filePath error:error]) {
        break;
      }
    }
  }
}

@end
