#if TARGET_OS_OSX
#import <FlutterMacOS/FlutterMacOS.h>
#else
#import <Flutter/Flutter.h>
#endif

NS_ASSUME_NONNULL_BEGIN
@protocol MethodChannel <NSObject>
// Invokes the specified Flutter method with the specified arguments, expecting
// an asynchronous result.
- (void)invokeMethod:(NSString *)method arguments:(id _Nullable)arguments;
- (void)invokeMethod:(NSString *)method
           arguments:(id _Nullable)arguments
              result:(FlutterResult _Nullable)callback;
@end

@interface DefaultMethodChannel : NSObject <MethodChannel>
@property(strong, nonatomic) FlutterMethodChannel *channel;
- (instancetype)initWithChannel:(FlutterMethodChannel *)channel;
@end

NS_ASSUME_NONNULL_END
