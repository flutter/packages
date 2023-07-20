#import <Foundation/Foundation.h>

@interface ContentInfo : NSObject <NSCoding>

@property(nonatomic, copy) NSString *contentType;
@property(nonatomic, assign) BOOL byteRangeAccessSupported;
@property(nonatomic, assign) unsigned long long contentLength;
@property(nonatomic) unsigned long long downloadedContentLength;

@end
