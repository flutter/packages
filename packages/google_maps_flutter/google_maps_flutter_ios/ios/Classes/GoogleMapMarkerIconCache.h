#import <Flutter/Flutter.h>
#import <GoogleMaps/GoogleMaps.h>

@interface GoogleMapMarkerIconCache : NSObject
- (instancetype)initWithRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar
                      screenScale:(CGFloat)screenScale;
- (UIImage *)getImage:(NSArray *)iconData;
@end

@interface IconData : NSObject
- (instancetype)init:(NSArray *)iconData;
@end
