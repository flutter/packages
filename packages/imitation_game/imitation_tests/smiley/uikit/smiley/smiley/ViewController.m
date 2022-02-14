// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "ViewController.h"
#import <mach/mach.h>
#import <sys/sysctl.h>
#import <sys/types.h>

static int64_t loadStartupTime(NSError **error) {
  pid_t pid = [[NSProcessInfo processInfo] processIdentifier];
  int mib[4] = {CTL_KERN, KERN_PROC, KERN_PROC_PID, pid};
  struct kinfo_proc proc;
  size_t size = sizeof(proc);
  int err = sysctl(mib, 4, &proc, &size, NULL, 0);
  if (err != 0) {
    int errCode = errno;
    if (error) {
      *error = [NSError errorWithDomain:@"smiley" code:errCode userInfo:@{}];
    }
    return 0;
  }

  struct timeval startTime = proc.kp_proc.p_starttime;
  int64_t microsecondsInSecond = 1000000LL;
  int64_t microsecondsSinceEpoch =
      (int64_t)(startTime.tv_sec * microsecondsInSecond) + (int64_t)startTime.tv_usec;

  return microsecondsSinceEpoch;
}

static NSString *loadIpAddress() {
#if TARGET_IPHONE_SIMULATOR
  return @"127.0.0.1:4040";
#else
  NSString *ipPath = [[NSBundle mainBundle] pathForResource:@"ip" ofType:@"txt"];
  NSError *err;
  NSString *ipAddress = [NSString stringWithContentsOfFile:ipPath
                                                  encoding:NSUTF8StringEncoding
                                                     error:&err];
  assert(err == nil);
  return
      [ipAddress stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
#endif
}

static void sendResults(NSTimeInterval result) {
  NSLog(@"send results:%f", result);
  NSString *ipAddress = loadIpAddress();
  NSString *url = [NSString stringWithFormat:@"http://%@", ipAddress];
  NSMutableURLRequest *urlRequest =
      [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:url]];
  NSDictionary *payload = @{
    @"test" : @"smiley",
    @"platform" : @"uikit",
    @"results" : @{
      @"ios_startup_time" : @(result),
    }
  };
  NSError *error;
  NSData *jsonData = [NSJSONSerialization dataWithJSONObject:payload options:0 error:&error];
  assert(error == nil && jsonData);
  [urlRequest setHTTPMethod:@"POST"];
  [urlRequest setHTTPBody:jsonData];

  NSURLSession *session = [NSURLSession sharedSession];
  NSURLSessionDataTask *dataTask =
      [session dataTaskWithRequest:urlRequest
                 completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                   NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
                   if (httpResponse.statusCode != 200) {
                     NSLog(@"Error %@ '%@'", error, url);
                   }
                 }];
  [dataTask resume];
}

@interface ViewController ()
@property(nonatomic, strong) CADisplayLink *displayLink;
@end

@implementation ViewController {
  BOOL _waitingForDraw;
}

- (void)viewDidLoad {
  [super viewDidLoad];
}

- (void)loadView {
  [super loadView];
  self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(onTick:)];
  [self.displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
  self.imageView.image = [UIImage imageNamed:@"smiley"];
  _waitingForDraw = YES;
}

- (BOOL)prefersStatusBarHidden {
  return YES;
}

- (void)onTick:(CADisplayLink *)sender {
  if (_waitingForDraw) {
    int64_t epochTime = loadStartupTime(nil);
    NSTimeInterval epocTimeSeconds = (double)epochTime / 1000000.0;
    NSDate *startTime = [NSDate dateWithTimeIntervalSince1970:epocTimeSeconds];
    NSTimeInterval runTime = [[NSDate now] timeIntervalSinceDate:startTime];
    sendResults(runTime);
    _waitingForDraw = NO;
    [self.displayLink invalidate];
    self.displayLink = nil;
  }
}

@end
