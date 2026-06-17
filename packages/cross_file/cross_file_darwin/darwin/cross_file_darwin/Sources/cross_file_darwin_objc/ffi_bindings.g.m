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
} DOBJC_Context;

id objc_retainBlock(id);

#define BLOCKING_BLOCK_IMPL(ctx, BLOCK_SIG, INVOKE_DIRECT, INVOKE_LISTENER)                      \
  assert(ctx->version >= 1);                                                                     \
  void *targetIsolate = ctx->currentIsolate();                                                   \
  int64_t targetPort = ctx->getMainPortId == NULL ? 0 : ctx->getMainPortId();                    \
  return BLOCK_SIG {                                                                             \
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
      INVOKE_LISTENER;                                                                           \
      ctx->awaitWaiter(waiter);                                                                  \
    }                                                                                            \
  };

typedef void (^_ListenerTrampoline)(id arg0, id arg1);
__attribute__((visibility("default"))) __attribute__((used)) _ListenerTrampoline
_NativeLibrary_wrapListenerBlock_pfv6jd(_ListenerTrampoline block) NS_RETURNS_RETAINED {
  return ^void(id arg0, id arg1) {
    objc_retainBlock(block);
    block((__bridge id)(__bridge_retained void *)(arg0),
          (__bridge id)(__bridge_retained void *)(arg1));
  };
}

typedef void (^_BlockingTrampoline)(void *waiter, id arg0, id arg1);
__attribute__((visibility("default"))) __attribute__((used)) _ListenerTrampoline
_NativeLibrary_wrapBlockingBlock_pfv6jd(_BlockingTrampoline block,
                                        _BlockingTrampoline listenerBlock,
                                        DOBJC_Context *ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(
      ctx, ^void(id arg0, id arg1),
      {
        objc_retainBlock(block);
        block(nil, (__bridge id)(__bridge_retained void *)(arg0),
              (__bridge id)(__bridge_retained void *)(arg1));
      },
      {
        objc_retainBlock(listenerBlock);
        listenerBlock(waiter, (__bridge id)(__bridge_retained void *)(arg0),
                      (__bridge id)(__bridge_retained void *)(arg1));
      });
}

typedef void (^_ListenerTrampoline_1)(id arg0, id arg1, CGImagePropertyOrientation arg2, id arg3);
__attribute__((visibility("default"))) __attribute__((used)) _ListenerTrampoline_1
_NativeLibrary_wrapListenerBlock_10c3wkj(_ListenerTrampoline_1 block) NS_RETURNS_RETAINED {
  return ^void(id arg0, id arg1, CGImagePropertyOrientation arg2, id arg3) {
    objc_retainBlock(block);
    block((__bridge id)(__bridge_retained void *)(arg0),
          (__bridge id)(__bridge_retained void *)(arg1), arg2,
          (__bridge id)(__bridge_retained void *)(arg3));
  };
}

typedef void (^_BlockingTrampoline_1)(void *waiter, id arg0, id arg1,
                                      CGImagePropertyOrientation arg2, id arg3);
__attribute__((visibility("default"))) __attribute__((used)) _ListenerTrampoline_1
_NativeLibrary_wrapBlockingBlock_10c3wkj(_BlockingTrampoline_1 block,
                                         _BlockingTrampoline_1 listenerBlock,
                                         DOBJC_Context *ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(
      ctx, ^void(id arg0, id arg1, CGImagePropertyOrientation arg2, id arg3),
      {
        objc_retainBlock(block);
        block(nil, (__bridge id)(__bridge_retained void *)(arg0),
              (__bridge id)(__bridge_retained void *)(arg1), arg2,
              (__bridge id)(__bridge_retained void *)(arg3));
      },
      {
        objc_retainBlock(listenerBlock);
        listenerBlock(waiter, (__bridge id)(__bridge_retained void *)(arg0),
                      (__bridge id)(__bridge_retained void *)(arg1), arg2,
                      (__bridge id)(__bridge_retained void *)(arg3));
      });
}

typedef void (^_ListenerTrampoline_2)(id arg0);
__attribute__((visibility("default"))) __attribute__((used)) _ListenerTrampoline_2
_NativeLibrary_wrapListenerBlock_xtuoz7(_ListenerTrampoline_2 block) NS_RETURNS_RETAINED {
  return ^void(id arg0) {
    objc_retainBlock(block);
    block((__bridge id)(__bridge_retained void *)(arg0));
  };
}

typedef void (^_BlockingTrampoline_2)(void *waiter, id arg0);
__attribute__((visibility("default"))) __attribute__((used)) _ListenerTrampoline_2
_NativeLibrary_wrapBlockingBlock_xtuoz7(_BlockingTrampoline_2 block,
                                        _BlockingTrampoline_2 listenerBlock,
                                        DOBJC_Context *ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(
      ctx, ^void(id arg0),
      {
        objc_retainBlock(block);
        block(nil, (__bridge id)(__bridge_retained void *)(arg0));
      },
      {
        objc_retainBlock(listenerBlock);
        listenerBlock(waiter, (__bridge id)(__bridge_retained void *)(arg0));
      });
}
#undef BLOCKING_BLOCK_IMPL

#pragma clang diagnostic pop
