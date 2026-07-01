#import <Foundation/Foundation.h>
#import <objc/message.h>
#include <stdint.h>
#import "../../example/native_interop_app/ios/Runner_objc_gen/Runner.h"

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

Protocol *_x6jxzu_MessageFlutterApiBridge(void) { return @protocol(MessageFlutterApiBridge); }

typedef id (^_ProtocolTrampoline)(void *sel, id arg1, id arg2);
__attribute__((visibility("default"))) __attribute__((used)) id
_x6jxzu_protocolTrampoline_zi5eed(id target, void *sel, id arg1, id arg2) {
  return ((_ProtocolTrampoline)((id(*)(id, SEL, SEL))objc_msgSend)(
      target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1, arg2);
}

typedef void (^_ListenerTrampoline)(id arg0);
__attribute__((visibility("default"))) __attribute__((used)) _ListenerTrampoline
_x6jxzu_wrapListenerBlock_xtuoz7(_ListenerTrampoline block) NS_RETURNS_RETAINED {
  return ^void(id arg0) {
    objc_retainBlock(block);
    block((__bridge id)(__bridge_retained void *)(arg0));
  };
}

typedef void (^_BlockingTrampoline)(void *waiter, id arg0);
__attribute__((visibility("default"))) __attribute__((used)) _ListenerTrampoline
_x6jxzu_wrapBlockingBlock_xtuoz7(_BlockingTrampoline block, _BlockingTrampoline listenerBlock,
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
