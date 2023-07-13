
#import "CacheSessionManager.h"

@interface CacheSessionManager ()

@property(nonatomic, strong) NSOperationQueue *downloadQueue;

@end

@implementation CacheSessionManager

+ (instancetype)shared {
  static id instance = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    instance = [[self alloc] init];
  });

  return instance;
}

- (instancetype)init {
  self = [super init];
  if (self) {
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    queue.name = @"video_player.download_cache_queue";
    _downloadQueue = queue;
  }
  return self;
}

@end
