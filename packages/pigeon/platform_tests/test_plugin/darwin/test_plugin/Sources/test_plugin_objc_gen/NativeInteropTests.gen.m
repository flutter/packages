#import <Foundation/Foundation.h>
#import <objc/message.h>
#include <stdint.h>
#import "test_plugin.h"

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

__attribute__((visibility("default"))) __attribute__((used)) Protocol *
_julz8q_NativeInteropFlutterIntegrationCoreApiBridge(void) {
  return @protocol(NativeInteropFlutterIntegrationCoreApiBridge);
}

__attribute__((visibility("default"))) __attribute__((used)) Protocol *
_julz8q_NativeInteropReservedNamesFlutterApiBridge(void) {
  return @protocol(NativeInteropReservedNamesFlutterApiBridge);
}

__attribute__((visibility("default"))) __attribute__((used)) Protocol *
_julz8q_NativeInteropSealedClassFlutterApiBridge(void) {
  return @protocol(NativeInteropSealedClassFlutterApiBridge);
}

typedef id (^_ProtocolTrampoline)(void *sel, id arg1, id arg2);
__attribute__((visibility("default"))) __attribute__((used)) id _julz8q_protocolTrampoline_zi5eed(
    id target, void *sel, id arg1, id arg2) {
  return ((_ProtocolTrampoline)((id(*)(id, SEL, SEL))objc_msgSend)(
      target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2);
}

typedef id (^_ProtocolTrampoline_1)(void *sel, id arg1, id arg2, id arg3, id arg4);
__attribute__((visibility("default"))) __attribute__((used)) id _julz8q_protocolTrampoline_qfyidt(
    id target, void *sel, id arg1, id arg2, id arg3, id arg4) {
  return ((_ProtocolTrampoline_1)((id(*)(id, SEL, SEL))objc_msgSend)(
      target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2, arg3, arg4);
}

typedef id (^_ProtocolTrampoline_2)(void *sel, id arg1);
__attribute__((visibility("default"))) __attribute__((used)) id _julz8q_protocolTrampoline_xr62hr(
    id target, void *sel, id arg1) {
  return ((_ProtocolTrampoline_2)((id(*)(id, SEL, SEL))objc_msgSend)(
      target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1);
}

typedef id (^_ProtocolTrampoline_3)(void *sel, int64_t arg1, id arg2);
__attribute__((visibility("default"))) __attribute__((used)) id _julz8q_protocolTrampoline_1o0u9up(
    id target, void *sel, int64_t arg1, id arg2) {
  return ((_ProtocolTrampoline_3)((id(*)(id, SEL, SEL))objc_msgSend)(
      target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2);
}

typedef id (^_ProtocolTrampoline_4)(void *sel, BOOL arg1, id arg2);
__attribute__((visibility("default"))) __attribute__((used)) id _julz8q_protocolTrampoline_1vs8olj(
    id target, void *sel, BOOL arg1, id arg2) {
  return ((_ProtocolTrampoline_4)((id(*)(id, SEL, SEL))objc_msgSend)(
      target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2);
}

typedef id (^_ProtocolTrampoline_5)(void *sel, double arg1, id arg2);
__attribute__((visibility("default"))) __attribute__((used)) id _julz8q_protocolTrampoline_nq0aac(
    id target, void *sel, double arg1, id arg2) {
  return ((_ProtocolTrampoline_5)((id(*)(id, SEL, SEL))objc_msgSend)(
      target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2);
}

__attribute__((visibility("default")))
@interface _julz8q_BlockArgs_1pl9qdv : NSObject
@property(copy) id block;

@end
@implementation _julz8q_BlockArgs_1pl9qdv
@end

typedef void (^_ListenerTrampoline)(void);
__attribute__((visibility("default"))) __attribute__((used)) _ListenerTrampoline
_julz8q_wrapListenerBlock_1pl9qdv(int64_t port, DOBJC_Context *ctx) NS_RETURNS_RETAINED {
  __block __weak _ListenerTrampoline weakSelfBlock = nil;
  _ListenerTrampoline strongSelfBlock = [^void() {
    @autoreleasepool {
      _julz8q_BlockArgs_1pl9qdv *args = [[_julz8q_BlockArgs_1pl9qdv alloc] init];
      args.block = weakSelfBlock;

      ctx->invokeListenerPortBlock(port, (__bridge_retained void *)args);
    }
  } copy];
  weakSelfBlock = strongSelfBlock;
  return strongSelfBlock;
}

typedef void (^_BlockingTrampoline)(void *waiter);
__attribute__((visibility("default"))) __attribute__((used)) _ListenerTrampoline
_julz8q_wrapBlockingBlock_1pl9qdv(int64_t port, DOBJC_Context *ctx,
                                  void (*directInvoke)(void *)) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(
      ctx, _ListenerTrampoline, ^void(),
      {
        @autoreleasepool {
          _julz8q_BlockArgs_1pl9qdv *args = [[_julz8q_BlockArgs_1pl9qdv alloc] init];
          args.block = weakSelfBlock;

          directInvoke((__bridge_retained void *)args);
        }
      },
      {
        @autoreleasepool {
          _julz8q_BlockArgs_1pl9qdv *args = [[_julz8q_BlockArgs_1pl9qdv alloc] init];
          args.block = weakSelfBlock;

          ctx->invokeBlockingPortBlock(port, (__bridge_retained void *)args, waiter);
        }
      });
}

__attribute__((visibility("default")))
@interface _julz8q_BlockArgs_xtuoz7 : NSObject
@property(copy) id block;
@property(strong) id arg0;
@end
@implementation _julz8q_BlockArgs_xtuoz7
@end

typedef void (^_ListenerTrampoline_1)(id arg0);
__attribute__((visibility("default"))) __attribute__((used)) _ListenerTrampoline_1
_julz8q_wrapListenerBlock_xtuoz7(int64_t port, DOBJC_Context *ctx) NS_RETURNS_RETAINED {
  __block __weak _ListenerTrampoline_1 weakSelfBlock = nil;
  _ListenerTrampoline_1 strongSelfBlock = [^void(id arg0) {
    @autoreleasepool {
      _julz8q_BlockArgs_xtuoz7 *args = [[_julz8q_BlockArgs_xtuoz7 alloc] init];
      args.block = weakSelfBlock;
      args.arg0 = arg0;
      ctx->invokeListenerPortBlock(port, (__bridge_retained void *)args);
    }
  } copy];
  weakSelfBlock = strongSelfBlock;
  return strongSelfBlock;
}

typedef void (^_BlockingTrampoline_1)(void *waiter, id arg0);
__attribute__((visibility("default"))) __attribute__((used)) _ListenerTrampoline_1
_julz8q_wrapBlockingBlock_xtuoz7(int64_t port, DOBJC_Context *ctx,
                                 void (*directInvoke)(void *)) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(
      ctx, _ListenerTrampoline_1, ^void(id arg0),
      {
        @autoreleasepool {
          _julz8q_BlockArgs_xtuoz7 *args = [[_julz8q_BlockArgs_xtuoz7 alloc] init];
          args.block = weakSelfBlock;
          args.arg0 = arg0;
          directInvoke((__bridge_retained void *)args);
        }
      },
      {
        @autoreleasepool {
          _julz8q_BlockArgs_xtuoz7 *args = [[_julz8q_BlockArgs_xtuoz7 alloc] init];
          args.block = weakSelfBlock;
          args.arg0 = arg0;
          ctx->invokeBlockingPortBlock(port, (__bridge_retained void *)args, waiter);
        }
      });
}

__attribute__((visibility("default")))
@interface _julz8q_BlockArgs_1aroy1q : NSObject
@property(copy) id block;
@property void *arg0;
@property int64_t arg1;
@property(strong) id arg2;
@property(copy) id arg3;
@end
@implementation _julz8q_BlockArgs_1aroy1q
@end

typedef void (^_ListenerTrampoline_2)(void *arg0, int64_t arg1, id arg2, id arg3);
__attribute__((visibility("default"))) __attribute__((used)) _ListenerTrampoline_2
_julz8q_wrapListenerBlock_1aroy1q(int64_t port, DOBJC_Context *ctx) NS_RETURNS_RETAINED {
  __block __weak _ListenerTrampoline_2 weakSelfBlock = nil;
  _ListenerTrampoline_2 strongSelfBlock = [^void(void *arg0, int64_t arg1, id arg2, id arg3) {
    @autoreleasepool {
      _julz8q_BlockArgs_1aroy1q *args = [[_julz8q_BlockArgs_1aroy1q alloc] init];
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

typedef void (^_BlockingTrampoline_2)(void *waiter, void *arg0, int64_t arg1, id arg2, id arg3);
__attribute__((visibility("default"))) __attribute__((used)) _ListenerTrampoline_2
_julz8q_wrapBlockingBlock_1aroy1q(int64_t port, DOBJC_Context *ctx,
                                  void (*directInvoke)(void *)) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(
      ctx, _ListenerTrampoline_2, ^void(void *arg0, int64_t arg1, id arg2, id arg3),
      {
        @autoreleasepool {
          _julz8q_BlockArgs_1aroy1q *args = [[_julz8q_BlockArgs_1aroy1q alloc] init];
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
          _julz8q_BlockArgs_1aroy1q *args = [[_julz8q_BlockArgs_1aroy1q alloc] init];
          args.block = weakSelfBlock;
          args.arg0 = arg0;
          args.arg1 = arg1;
          args.arg2 = arg2;
          args.arg3 = arg3;
          ctx->invokeBlockingPortBlock(port, (__bridge_retained void *)args, waiter);
        }
      });
}

typedef void (^_ProtocolTrampoline_6)(void *sel, int64_t arg1, id arg2, id arg3);
__attribute__((visibility("default"))) __attribute__((used)) void
_julz8q_protocolTrampoline_1aroy1q(id target, void *sel, int64_t arg1, id arg2, id arg3) {
  return ((_ProtocolTrampoline_6)((id(*)(id, SEL, SEL))objc_msgSend)(
      target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2, arg3);
}

__attribute__((visibility("default")))
@interface _julz8q_BlockArgs_bklti2 : NSObject
@property(copy) id block;
@property void *arg0;
@property(strong) id arg1;
@property(strong) id arg2;
@property(copy) id arg3;
@end
@implementation _julz8q_BlockArgs_bklti2
@end

typedef void (^_ListenerTrampoline_3)(void *arg0, id arg1, id arg2, id arg3);
__attribute__((visibility("default"))) __attribute__((used)) _ListenerTrampoline_3
_julz8q_wrapListenerBlock_bklti2(int64_t port, DOBJC_Context *ctx) NS_RETURNS_RETAINED {
  __block __weak _ListenerTrampoline_3 weakSelfBlock = nil;
  _ListenerTrampoline_3 strongSelfBlock = [^void(void *arg0, id arg1, id arg2, id arg3) {
    @autoreleasepool {
      _julz8q_BlockArgs_bklti2 *args = [[_julz8q_BlockArgs_bklti2 alloc] init];
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

typedef void (^_BlockingTrampoline_3)(void *waiter, void *arg0, id arg1, id arg2, id arg3);
__attribute__((visibility("default"))) __attribute__((used)) _ListenerTrampoline_3
_julz8q_wrapBlockingBlock_bklti2(int64_t port, DOBJC_Context *ctx,
                                 void (*directInvoke)(void *)) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(
      ctx, _ListenerTrampoline_3, ^void(void *arg0, id arg1, id arg2, id arg3),
      {
        @autoreleasepool {
          _julz8q_BlockArgs_bklti2 *args = [[_julz8q_BlockArgs_bklti2 alloc] init];
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
          _julz8q_BlockArgs_bklti2 *args = [[_julz8q_BlockArgs_bklti2 alloc] init];
          args.block = weakSelfBlock;
          args.arg0 = arg0;
          args.arg1 = arg1;
          args.arg2 = arg2;
          args.arg3 = arg3;
          ctx->invokeBlockingPortBlock(port, (__bridge_retained void *)args, waiter);
        }
      });
}

typedef void (^_ProtocolTrampoline_7)(void *sel, id arg1, id arg2, id arg3);
__attribute__((visibility("default"))) __attribute__((used)) void _julz8q_protocolTrampoline_bklti2(
    id target, void *sel, id arg1, id arg2, id arg3) {
  return ((_ProtocolTrampoline_7)((id(*)(id, SEL, SEL))objc_msgSend)(
      target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2, arg3);
}

__attribute__((visibility("default")))
@interface _julz8q_BlockArgs_18v1jvf : NSObject
@property(copy) id block;
@property void *arg0;
@property(strong) id arg1;
@end
@implementation _julz8q_BlockArgs_18v1jvf
@end

typedef void (^_ListenerTrampoline_4)(void *arg0, id arg1);
__attribute__((visibility("default"))) __attribute__((used)) _ListenerTrampoline_4
_julz8q_wrapListenerBlock_18v1jvf(int64_t port, DOBJC_Context *ctx) NS_RETURNS_RETAINED {
  __block __weak _ListenerTrampoline_4 weakSelfBlock = nil;
  _ListenerTrampoline_4 strongSelfBlock = [^void(void *arg0, id arg1) {
    @autoreleasepool {
      _julz8q_BlockArgs_18v1jvf *args = [[_julz8q_BlockArgs_18v1jvf alloc] init];
      args.block = weakSelfBlock;
      args.arg0 = arg0;
      args.arg1 = arg1;
      ctx->invokeListenerPortBlock(port, (__bridge_retained void *)args);
    }
  } copy];
  weakSelfBlock = strongSelfBlock;
  return strongSelfBlock;
}

typedef void (^_BlockingTrampoline_4)(void *waiter, void *arg0, id arg1);
__attribute__((visibility("default"))) __attribute__((used)) _ListenerTrampoline_4
_julz8q_wrapBlockingBlock_18v1jvf(int64_t port, DOBJC_Context *ctx,
                                  void (*directInvoke)(void *)) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(
      ctx, _ListenerTrampoline_4, ^void(void *arg0, id arg1),
      {
        @autoreleasepool {
          _julz8q_BlockArgs_18v1jvf *args = [[_julz8q_BlockArgs_18v1jvf alloc] init];
          args.block = weakSelfBlock;
          args.arg0 = arg0;
          args.arg1 = arg1;
          directInvoke((__bridge_retained void *)args);
        }
      },
      {
        @autoreleasepool {
          _julz8q_BlockArgs_18v1jvf *args = [[_julz8q_BlockArgs_18v1jvf alloc] init];
          args.block = weakSelfBlock;
          args.arg0 = arg0;
          args.arg1 = arg1;
          ctx->invokeBlockingPortBlock(port, (__bridge_retained void *)args, waiter);
        }
      });
}

typedef void (^_ProtocolTrampoline_8)(void *sel, id arg1);
__attribute__((visibility("default"))) __attribute__((used)) void
_julz8q_protocolTrampoline_18v1jvf(id target, void *sel, id arg1) {
  return ((_ProtocolTrampoline_8)((id(*)(id, SEL, SEL))objc_msgSend)(
      target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1);
}

__attribute__((visibility("default")))
@interface _julz8q_BlockArgs_jk1ljc : NSObject
@property(copy) id block;
@property void *arg0;
@property(strong) id arg1;
@property(copy) id arg2;
@end
@implementation _julz8q_BlockArgs_jk1ljc
@end

typedef void (^_ListenerTrampoline_5)(void *arg0, id arg1, id arg2);
__attribute__((visibility("default"))) __attribute__((used)) _ListenerTrampoline_5
_julz8q_wrapListenerBlock_jk1ljc(int64_t port, DOBJC_Context *ctx) NS_RETURNS_RETAINED {
  __block __weak _ListenerTrampoline_5 weakSelfBlock = nil;
  _ListenerTrampoline_5 strongSelfBlock = [^void(void *arg0, id arg1, id arg2) {
    @autoreleasepool {
      _julz8q_BlockArgs_jk1ljc *args = [[_julz8q_BlockArgs_jk1ljc alloc] init];
      args.block = weakSelfBlock;
      args.arg0 = arg0;
      args.arg1 = arg1;
      args.arg2 = arg2;
      ctx->invokeListenerPortBlock(port, (__bridge_retained void *)args);
    }
  } copy];
  weakSelfBlock = strongSelfBlock;
  return strongSelfBlock;
}

typedef void (^_BlockingTrampoline_5)(void *waiter, void *arg0, id arg1, id arg2);
__attribute__((visibility("default"))) __attribute__((used)) _ListenerTrampoline_5
_julz8q_wrapBlockingBlock_jk1ljc(int64_t port, DOBJC_Context *ctx,
                                 void (*directInvoke)(void *)) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(
      ctx, _ListenerTrampoline_5, ^void(void *arg0, id arg1, id arg2),
      {
        @autoreleasepool {
          _julz8q_BlockArgs_jk1ljc *args = [[_julz8q_BlockArgs_jk1ljc alloc] init];
          args.block = weakSelfBlock;
          args.arg0 = arg0;
          args.arg1 = arg1;
          args.arg2 = arg2;
          directInvoke((__bridge_retained void *)args);
        }
      },
      {
        @autoreleasepool {
          _julz8q_BlockArgs_jk1ljc *args = [[_julz8q_BlockArgs_jk1ljc alloc] init];
          args.block = weakSelfBlock;
          args.arg0 = arg0;
          args.arg1 = arg1;
          args.arg2 = arg2;
          ctx->invokeBlockingPortBlock(port, (__bridge_retained void *)args, waiter);
        }
      });
}

typedef void (^_ProtocolTrampoline_9)(void *sel, id arg1, id arg2);
__attribute__((visibility("default"))) __attribute__((used)) void _julz8q_protocolTrampoline_jk1ljc(
    id target, void *sel, id arg1, id arg2) {
  return ((_ProtocolTrampoline_9)((id(*)(id, SEL, SEL))objc_msgSend)(
      target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2);
}

__attribute__((visibility("default")))
@interface _julz8q_BlockArgs_ymbgmo : NSObject
@property(copy) id block;
@property void *arg0;
@property BOOL arg1;
@property(strong) id arg2;
@property(copy) id arg3;
@end
@implementation _julz8q_BlockArgs_ymbgmo
@end

typedef void (^_ListenerTrampoline_6)(void *arg0, BOOL arg1, id arg2, id arg3);
__attribute__((visibility("default"))) __attribute__((used)) _ListenerTrampoline_6
_julz8q_wrapListenerBlock_ymbgmo(int64_t port, DOBJC_Context *ctx) NS_RETURNS_RETAINED {
  __block __weak _ListenerTrampoline_6 weakSelfBlock = nil;
  _ListenerTrampoline_6 strongSelfBlock = [^void(void *arg0, BOOL arg1, id arg2, id arg3) {
    @autoreleasepool {
      _julz8q_BlockArgs_ymbgmo *args = [[_julz8q_BlockArgs_ymbgmo alloc] init];
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

typedef void (^_BlockingTrampoline_6)(void *waiter, void *arg0, BOOL arg1, id arg2, id arg3);
__attribute__((visibility("default"))) __attribute__((used)) _ListenerTrampoline_6
_julz8q_wrapBlockingBlock_ymbgmo(int64_t port, DOBJC_Context *ctx,
                                 void (*directInvoke)(void *)) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(
      ctx, _ListenerTrampoline_6, ^void(void *arg0, BOOL arg1, id arg2, id arg3),
      {
        @autoreleasepool {
          _julz8q_BlockArgs_ymbgmo *args = [[_julz8q_BlockArgs_ymbgmo alloc] init];
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
          _julz8q_BlockArgs_ymbgmo *args = [[_julz8q_BlockArgs_ymbgmo alloc] init];
          args.block = weakSelfBlock;
          args.arg0 = arg0;
          args.arg1 = arg1;
          args.arg2 = arg2;
          args.arg3 = arg3;
          ctx->invokeBlockingPortBlock(port, (__bridge_retained void *)args, waiter);
        }
      });
}

typedef void (^_ProtocolTrampoline_10)(void *sel, BOOL arg1, id arg2, id arg3);
__attribute__((visibility("default"))) __attribute__((used)) void _julz8q_protocolTrampoline_ymbgmo(
    id target, void *sel, BOOL arg1, id arg2, id arg3) {
  return ((_ProtocolTrampoline_10)((id(*)(id, SEL, SEL))objc_msgSend)(
      target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2, arg3);
}

__attribute__((visibility("default")))
@interface _julz8q_BlockArgs_omyb6r : NSObject
@property(copy) id block;
@property void *arg0;
@property double arg1;
@property(strong) id arg2;
@property(copy) id arg3;
@end
@implementation _julz8q_BlockArgs_omyb6r
@end

typedef void (^_ListenerTrampoline_7)(void *arg0, double arg1, id arg2, id arg3);
__attribute__((visibility("default"))) __attribute__((used)) _ListenerTrampoline_7
_julz8q_wrapListenerBlock_omyb6r(int64_t port, DOBJC_Context *ctx) NS_RETURNS_RETAINED {
  __block __weak _ListenerTrampoline_7 weakSelfBlock = nil;
  _ListenerTrampoline_7 strongSelfBlock = [^void(void *arg0, double arg1, id arg2, id arg3) {
    @autoreleasepool {
      _julz8q_BlockArgs_omyb6r *args = [[_julz8q_BlockArgs_omyb6r alloc] init];
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

typedef void (^_BlockingTrampoline_7)(void *waiter, void *arg0, double arg1, id arg2, id arg3);
__attribute__((visibility("default"))) __attribute__((used)) _ListenerTrampoline_7
_julz8q_wrapBlockingBlock_omyb6r(int64_t port, DOBJC_Context *ctx,
                                 void (*directInvoke)(void *)) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(
      ctx, _ListenerTrampoline_7, ^void(void *arg0, double arg1, id arg2, id arg3),
      {
        @autoreleasepool {
          _julz8q_BlockArgs_omyb6r *args = [[_julz8q_BlockArgs_omyb6r alloc] init];
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
          _julz8q_BlockArgs_omyb6r *args = [[_julz8q_BlockArgs_omyb6r alloc] init];
          args.block = weakSelfBlock;
          args.arg0 = arg0;
          args.arg1 = arg1;
          args.arg2 = arg2;
          args.arg3 = arg3;
          ctx->invokeBlockingPortBlock(port, (__bridge_retained void *)args, waiter);
        }
      });
}

typedef void (^_ProtocolTrampoline_11)(void *sel, double arg1, id arg2, id arg3);
__attribute__((visibility("default"))) __attribute__((used)) void _julz8q_protocolTrampoline_omyb6r(
    id target, void *sel, double arg1, id arg2, id arg3) {
  return ((_ProtocolTrampoline_11)((id(*)(id, SEL, SEL))objc_msgSend)(
      target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2, arg3);
}
#undef BLOCKING_BLOCK_IMPL

#pragma clang diagnostic pop
