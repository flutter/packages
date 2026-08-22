// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>
#import <objc/message.h>
#include <stdint.h>

#if !__has_feature(objc_arc)
#error "This file must be compiled with ARC enabled"
#endif

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"

typedef struct {
  int64_t version;
  void *(*newWaiter)(void);
  void (*awaitWaiter)(void *);
  void *(*currentIsolate)(void);
  void (*enterIsolate)(void *);
  void (*exitIsolate)(void);
  int64_t (*getMainPortId)(void);
  bool (*getCurrentThreadOwnsIsolate)(int64_t);
  void (*invokeListenerPortBlock)(int64_t port, void *);
  void (*invokeBlockingPortBlock)(int64_t port, void *, void *);
} DOBJC_Context;

id objc_retainBlock(id);

#define BLOCKING_BLOCK_IMPL(ctx, TYPE, SIG, INVOKE_DIRECT, INVOKE_LISTENER)                      \
  assert(ctx->version >= 1);                                                                     \
  void *targetIsolate = ctx->currentIsolate();                                                   \
  int64_t targetPort = ctx->getMainPortId == NULL ? 0 : ctx->getMainPortId();                    \
  __block __weak TYPE weakSelfBlock = nil;                                                       \
  TYPE strongSelfBlock = [SIG {                                                                  \
    void *currentIsolate = ctx->currentIsolate();                                                \
    bool mayEnterIsolate = currentIsolate == NULL && ctx->getCurrentThreadOwnsIsolate != NULL && \
                           ctx->getCurrentThreadOwnsIsolate(targetPort);                         \
    if (currentIsolate == targetIsolate || mayEnterIsolate) {                                    \
      if (mayEnterIsolate) {                                                                     \
        ctx->enterIsolate(targetIsolate);                                                        \
      }                                                                                          \
      INVOKE_DIRECT;                                                                             \
      if (mayEnterIsolate) {                                                                     \
        ctx->exitIsolate();                                                                      \
      }                                                                                          \
    } else {                                                                                     \
      void *waiter = ctx->newWaiter();                                                           \
      TYPE selfRetain = [weakSelfBlock copy];                                                    \
      INVOKE_LISTENER;                                                                           \
      ctx->awaitWaiter(waiter);                                                                  \
      (void)selfRetain;                                                                          \
    }                                                                                            \
  } copy];                                                                                       \
  weakSelfBlock = strongSelfBlock;                                                               \
  return strongSelfBlock;

__attribute__((visibility("default")))
@interface _1w5ousu_BlockArgs_xtuoz7 : NSObject
@property(copy) id block;
@property(strong) id arg0;
@end
@implementation _1w5ousu_BlockArgs_xtuoz7
@end

typedef void (^_ListenerTrampoline)(id arg0);
__attribute__((visibility("default"))) __attribute__((used)) _ListenerTrampoline
_1w5ousu_wrapListenerBlock_xtuoz7(int64_t port, DOBJC_Context *ctx) NS_RETURNS_RETAINED {
  __block __weak _ListenerTrampoline weakSelfBlock = nil;
  _ListenerTrampoline strongSelfBlock = [^void(id arg0) {
    @autoreleasepool {
      _1w5ousu_BlockArgs_xtuoz7 *args = [[_1w5ousu_BlockArgs_xtuoz7 alloc] init];
      args.block = weakSelfBlock;
      args.arg0 = arg0;
      ctx->invokeListenerPortBlock(port, (__bridge_retained void *)args);
    }
  } copy];
  weakSelfBlock = strongSelfBlock;
  return strongSelfBlock;
}

typedef void (^_BlockingTrampoline)(void *waiter, id arg0);
__attribute__((visibility("default"))) __attribute__((used)) _ListenerTrampoline
_1w5ousu_wrapBlockingBlock_xtuoz7(int64_t port, DOBJC_Context *ctx,
                                  void (*directInvoke)(void *)) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(
      ctx, _ListenerTrampoline, ^void(id arg0),
      {
        @autoreleasepool {
          _1w5ousu_BlockArgs_xtuoz7 *args = [[_1w5ousu_BlockArgs_xtuoz7 alloc] init];
          args.block = weakSelfBlock;
          args.arg0 = arg0;
          directInvoke((__bridge_retained void *)args);
        }
      },
      {
        @autoreleasepool {
          _1w5ousu_BlockArgs_xtuoz7 *args = [[_1w5ousu_BlockArgs_xtuoz7 alloc] init];
          args.block = weakSelfBlock;
          args.arg0 = arg0;
          ctx->invokeBlockingPortBlock(port, (__bridge_retained void *)args, waiter);
        }
      });
}

__attribute__((visibility("default")))
@interface _1w5ousu_BlockArgs_10c3wkj : NSObject
@property(copy) id block;
@property(strong) id arg0;
@property(strong) id arg1;
@property CGImagePropertyOrientation arg2;
@property(strong) id arg3;
@end
@implementation _1w5ousu_BlockArgs_10c3wkj
@end

typedef void (^_ListenerTrampoline_1)(id arg0, id arg1, CGImagePropertyOrientation arg2, id arg3);
__attribute__((visibility("default"))) __attribute__((used)) _ListenerTrampoline_1
_1w5ousu_wrapListenerBlock_10c3wkj(int64_t port, DOBJC_Context *ctx) NS_RETURNS_RETAINED {
  __block __weak _ListenerTrampoline_1 weakSelfBlock = nil;
  _ListenerTrampoline_1 strongSelfBlock =
      [^void(id arg0, id arg1, CGImagePropertyOrientation arg2, id arg3) {
        @autoreleasepool {
          _1w5ousu_BlockArgs_10c3wkj *args = [[_1w5ousu_BlockArgs_10c3wkj alloc] init];
          args.block = weakSelfBlock;
          args.arg0 = arg0;
          args.arg1 = arg1;
          args.arg2 = arg2;
          args.arg3 = arg3;
          ctx->invokeListenerPortBlock(port, (__bridge_retained void *)args);
        }
      } copy];
  weakSelfBlock = strongSelfBlock;
  return strongSelfBlock;
}

typedef void (^_BlockingTrampoline_1)(void *waiter, id arg0, id arg1,
                                      CGImagePropertyOrientation arg2, id arg3);
__attribute__((visibility("default"))) __attribute__((used)) _ListenerTrampoline_1
_1w5ousu_wrapBlockingBlock_10c3wkj(int64_t port, DOBJC_Context *ctx,
                                   void (*directInvoke)(void *)) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(
      ctx, _ListenerTrampoline_1, ^void(id arg0, id arg1, CGImagePropertyOrientation arg2, id arg3),
      {
        @autoreleasepool {
          _1w5ousu_BlockArgs_10c3wkj *args = [[_1w5ousu_BlockArgs_10c3wkj alloc] init];
          args.block = weakSelfBlock;
          args.arg0 = arg0;
          args.arg1 = arg1;
          args.arg2 = arg2;
          args.arg3 = arg3;
          directInvoke((__bridge_retained void *)args);
        }
      },
      {
        @autoreleasepool {
          _1w5ousu_BlockArgs_10c3wkj *args = [[_1w5ousu_BlockArgs_10c3wkj alloc] init];
          args.block = weakSelfBlock;
          args.arg0 = arg0;
          args.arg1 = arg1;
          args.arg2 = arg2;
          args.arg3 = arg3;
          ctx->invokeBlockingPortBlock(port, (__bridge_retained void *)args, waiter);
        }
      });
}

__attribute__((visibility("default")))
@interface _1w5ousu_BlockArgs_pfv6jd : NSObject
@property(copy) id block;
@property(strong) id arg0;
@property(strong) id arg1;
@end
@implementation _1w5ousu_BlockArgs_pfv6jd
@end

typedef void (^_ListenerTrampoline_2)(id arg0, id arg1);
__attribute__((visibility("default"))) __attribute__((used)) _ListenerTrampoline_2
_1w5ousu_wrapListenerBlock_pfv6jd(int64_t port, DOBJC_Context *ctx) NS_RETURNS_RETAINED {
  __block __weak _ListenerTrampoline_2 weakSelfBlock = nil;
  _ListenerTrampoline_2 strongSelfBlock = [^void(id arg0, id arg1) {
    @autoreleasepool {
      _1w5ousu_BlockArgs_pfv6jd *args = [[_1w5ousu_BlockArgs_pfv6jd alloc] init];
      args.block = weakSelfBlock;
      args.arg0 = arg0;
      args.arg1 = arg1;
      ctx->invokeListenerPortBlock(port, (__bridge_retained void *)args);
    }
  } copy];
  weakSelfBlock = strongSelfBlock;
  return strongSelfBlock;
}

typedef void (^_BlockingTrampoline_2)(void *waiter, id arg0, id arg1);
__attribute__((visibility("default"))) __attribute__((used)) _ListenerTrampoline_2
_1w5ousu_wrapBlockingBlock_pfv6jd(int64_t port, DOBJC_Context *ctx,
                                  void (*directInvoke)(void *)) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(
      ctx, _ListenerTrampoline_2, ^void(id arg0, id arg1),
      {
        @autoreleasepool {
          _1w5ousu_BlockArgs_pfv6jd *args = [[_1w5ousu_BlockArgs_pfv6jd alloc] init];
          args.block = weakSelfBlock;
          args.arg0 = arg0;
          args.arg1 = arg1;
          directInvoke((__bridge_retained void *)args);
        }
      },
      {
        @autoreleasepool {
          _1w5ousu_BlockArgs_pfv6jd *args = [[_1w5ousu_BlockArgs_pfv6jd alloc] init];
          args.block = weakSelfBlock;
          args.arg0 = arg0;
          args.arg1 = arg1;
          ctx->invokeBlockingPortBlock(port, (__bridge_retained void *)args, waiter);
        }
      });
}
#undef BLOCKING_BLOCK_IMPL

#pragma clang diagnostic pop
