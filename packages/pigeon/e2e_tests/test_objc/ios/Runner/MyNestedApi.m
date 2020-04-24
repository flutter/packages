#import "MyNestedApi.h"

@implementation MyNestedApi
- (ACSearchReply *)search:(ACNested *)input error:(FlutterError **)error {
  ACSearchReply *reply = [[ACSearchReply alloc] init];
  reply.result = [NSString stringWithFormat:@"Hello %@!", input.request.query];
  return reply;
}
@end
