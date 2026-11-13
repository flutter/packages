#import <Foundation/Foundation.h>
#import <objc/message.h>
#include <stdint.h>
#import "url_launcher_ios.h"

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
@interface _9oi0pc_BlockArgs_xtuoz7 : NSObject
@property(copy) id block;
@property(strong) id arg0;
@end
@implementation _9oi0pc_BlockArgs_xtuoz7
@end

typedef void (^_ListenerTrampoline)(id arg0);
__attribute__((visibility("default"))) __attribute__((used)) _ListenerTrampoline
_9oi0pc_wrapListenerBlock_xtuoz7(int64_t port, DOBJC_Context *ctx) NS_RETURNS_RETAINED {
  __block __weak _ListenerTrampoline weakSelfBlock = nil;
  _ListenerTrampoline strongSelfBlock = [^void(id arg0) {
    @autoreleasepool {
      _9oi0pc_BlockArgs_xtuoz7 *args = [[_9oi0pc_BlockArgs_xtuoz7 alloc] init];
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
_9oi0pc_wrapBlockingBlock_xtuoz7(int64_t port, DOBJC_Context *ctx,
                                 void (*directInvoke)(void *)) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(
      ctx, _ListenerTrampoline, ^void(id arg0),
      {
        @autoreleasepool {
          _9oi0pc_BlockArgs_xtuoz7 *args = [[_9oi0pc_BlockArgs_xtuoz7 alloc] init];
          args.block = weakSelfBlock;
          args.arg0 = arg0;
          directInvoke((__bridge_retained void *)args);
        }
      },
      {
        @autoreleasepool {
          _9oi0pc_BlockArgs_xtuoz7 *args = [[_9oi0pc_BlockArgs_xtuoz7 alloc] init];
          args.block = weakSelfBlock;
          args.arg0 = arg0;
          ctx->invokeBlockingPortBlock(port, (__bridge_retained void *)args, waiter);
        }
      });
}
#undef BLOCKING_BLOCK_IMPL

#pragma clang diagnostic pop
