#import <Foundation/Foundation.h>
#import <objc/message.h>
#include <stdint.h>
#import "../../../../test_plugin/example/temp/test_plugin.h"

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

Protocol *_test_plugin_JniHostIntegrationCoreApi(void) {
  return @protocol(JniHostIntegrationCoreApi);
}

typedef void (^ListenerTrampoline)(void *arg0);
__attribute__((visibility("default"))) __attribute__((used)) ListenerTrampoline
_test_plugin_wrapListenerBlock_ovsamd(ListenerTrampoline block) NS_RETURNS_RETAINED {
  return ^void(void *arg0) {
    objc_retainBlock(block);
    block(arg0);
  };
}

typedef void (^BlockingTrampoline)(void *waiter, void *arg0);
__attribute__((visibility("default"))) __attribute__((used)) ListenerTrampoline
_test_plugin_wrapBlockingBlock_ovsamd(BlockingTrampoline block, BlockingTrampoline listenerBlock,
                                      DOBJC_Context *ctx) NS_RETURNS_RETAINED {
  BLOCKING_BLOCK_IMPL(
      ctx, ^void(void *arg0),
      {
        objc_retainBlock(block);
        block(nil, arg0);
      },
      {
        objc_retainBlock(listenerBlock);
        listenerBlock(waiter, arg0);
      });
}

typedef void (^ProtocolTrampoline)(void *sel);
__attribute__((visibility("default"))) __attribute__((used)) void
_test_plugin_protocolTrampoline_ovsamd(id target, void *sel) {
  return ((ProtocolTrampoline)((id (*)(id, SEL, SEL))objc_msgSend)(
      target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel);
}

typedef int64_t (^ProtocolTrampoline_1)(void *sel, int64_t arg1);
__attribute__((visibility("default"))) __attribute__((used)) int64_t
_test_plugin_protocolTrampoline_1citzfb(id target, void *sel, int64_t arg1) {
  return ((ProtocolTrampoline_1)((id (*)(id, SEL, SEL))objc_msgSend)(
      target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1);
}

typedef double (^ProtocolTrampoline_2)(void *sel, double arg1);
__attribute__((visibility("default"))) __attribute__((used)) double
_test_plugin_protocolTrampoline_1m6hrsr(id target, void *sel, double arg1) {
  return ((ProtocolTrampoline_2)((id (*)(id, SEL, SEL))objc_msgSend)(
      target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1);
}

typedef BOOL (^ProtocolTrampoline_3)(void *sel, BOOL arg1);
__attribute__((visibility("default"))) __attribute__((used)) BOOL
_test_plugin_protocolTrampoline_2pswnb(id target, void *sel, BOOL arg1) {
  return ((ProtocolTrampoline_3)((id (*)(id, SEL, SEL))objc_msgSend)(
      target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1);
}

typedef id (^ProtocolTrampoline_4)(void *sel, id arg1);
__attribute__((visibility("default"))) __attribute__((used)) id
_test_plugin_protocolTrampoline_xr62hr(id target, void *sel, id arg1) {
  return ((ProtocolTrampoline_4)((id (*)(id, SEL, SEL))objc_msgSend)(
      target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel, arg1);
}

typedef id (^ProtocolTrampoline_5)(void *sel);
__attribute__((visibility("default"))) __attribute__((used)) id
_test_plugin_protocolTrampoline_1mbt9g9(id target, void *sel) {
  return ((ProtocolTrampoline_5)((id (*)(id, SEL, SEL))objc_msgSend)(
      target, @selector(getDOBJCDartProtocolMethodForSelector:), sel))(sel);
}
#undef BLOCKING_BLOCK_IMPL

#pragma clang diagnostic pop
