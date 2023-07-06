
#import "CacheManager.h"
#import "ContentDownloader.h"

NSString *CacheManagerDidUpdateCacheNotification = @"CacheManagerDidUpdateCacheNotification";
NSString *CacheManagerDidFinishCacheNotification = @"CacheManagerDidFinishCacheNotification";

NSString *CacheConfigurationKey = @"CacheConfigurationKey";
NSString *CacheFinishedErrorKey = @"CacheFinishedErrorKey";

static NSString *kMContentCacheDirectory;
static NSTimeInterval kMCContentCacheNotifyInterval;
static NSString *(^kMCFileNameRules)(NSURL *url);

@implementation CacheManager

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self setCacheDirectory:[NSTemporaryDirectory() stringByAppendingPathComponent:@"media"]];
        [self setCacheUpdateNotifyInterval:0.1];
    });
}

+ (void)setCacheDirectory:(NSString *)cacheDirectory {
    kMContentCacheDirectory = cacheDirectory;
}

+ (NSString *)cacheDirectory {
    return kMContentCacheDirectory;
}

+ (void)setCacheUpdateNotifyInterval:(NSTimeInterval)interval {
    kMCContentCacheNotifyInterval = interval;
}

+ (NSTimeInterval)cacheUpdateNotifyInterval {
    return kMCContentCacheNotifyInterval;
}

+ (void)setFileNameRules:(NSString *(^)(NSURL *url))rules {
    kMCFileNameRules = rules;
}

+ (NSString *)cachedFilePathForURL:(NSURL *)url {
    NSLog(@"%@", url);
    NSString *pathComponent = nil;
    if (kMCFileNameRules) {
        pathComponent = kMCFileNameRules(url);
    } else {
        pathComponent = url.absoluteString;
//        pathComponent = [pathComponent stringByAppendingPathExtension:url.pathExtension];
    }
    return [[self cacheDirectory] stringByAppendingPathComponent:pathComponent];
}

+ (CacheConfiguration *)cacheConfigurationForURL:(NSURL *)url {
    NSString *filePath = [self cachedFilePathForURL:url];
    CacheConfiguration *configuration = [CacheConfiguration configurationWithFilePath:filePath];
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
            NSDictionary<NSFileAttributeKey, id> *attribute = [fileManager attributesOfItemAtPath:filePath error:error];
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
    [[[ContentDownloaderStatus shared] urls] enumerateObjectsUsingBlock:^(NSURL * _Nonnull obj, BOOL * _Nonnull stop) {
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

+ (void)cleanCacheForURL:(NSURL *)url error:(NSError **)error {
    //check if url is still downloading.
    if ([[ContentDownloaderStatus shared] containsURL:url]) {
        NSString *description = [NSString stringWithFormat:NSLocalizedString(@"Url: `%@` still downloading, unable to clean cache", nil), url];
        if (error) {
            *error = [NSError errorWithDomain:@"video_player" code:2 userInfo:@{NSLocalizedDescriptionKey: description}];
        }
        return;
    }
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *filePath = [self cachedFilePathForURL:url];
    
    if ([fileManager fileExistsAtPath:filePath]) {
        if (![fileManager removeItemAtPath:filePath error:error]) {
            return;
        }
    }
    
    NSString *configurationPath = [CacheConfiguration configurationFilePathForFilePath:filePath];
    if ([fileManager fileExistsAtPath:configurationPath]) {
        if (![fileManager removeItemAtPath:configurationPath error:error]) {
            return;
        }
    }
}

//+ (BOOL)addCacheFile:(NSString *)filePath forURL:(NSURL *)url error:(NSError **)error {
//    NSFileManager *fileManager = [NSFileManager defaultManager];
//
//    NSString *cachePath = [CacheManager cachedFilePathForURL:url];
//    NSString *cacheFolder = [cachePath stringByDeletingLastPathComponent];
//    if (![fileManager fileExistsAtPath:cacheFolder]) {
//        if (![fileManager createDirectoryAtPath:cacheFolder
//                    withIntermediateDirectories:YES
//                                     attributes:nil
//                                          error:error]) {
//            return NO;
//        }
//    }
//
//    if (![fileManager copyItemAtPath:filePath toPath:cachePath error:error]) {
//        return NO;
//    }
//
//    if (![CacheConfiguration createAndSaveDownloadedConfigurationForURL:url error:error]) {
//        [fileManager removeItemAtPath:cachePath error:nil]; // if remove failed, there is nothing we can do.
//        return NO;
//    }
//
//    return YES;
//}

@end
