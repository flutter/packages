#if TARGET_OS_OSX
#import <FlutterMacOS/FlutterMacOS.h>
#else
#import <Flutter/Flutter.h>
#endif

NS_ASSUME_NONNULL_BEGIN

@protocol MethodChannel <NSObject>
- (void)invokeMethod:(NSString *)method arguments:(id _Nullable)arguments;
- (void)invokeMethod:(NSString *)method
           arguments:(id _Nullable)arguments
              result:(FlutterResult _Nullable)callback;
@end

@interface DefaultMethodChannel : NSObject <MethodChannel>
- (instancetype)initWithChannel:(FlutterMethodChannel *)channel;
@property FlutterMethodChannel *channel;
@end

NS_ASSUME_NONNULL_END
