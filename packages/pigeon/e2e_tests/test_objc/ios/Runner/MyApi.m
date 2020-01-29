#import "MyApi.h"

@implementation MyApi
-(ACSearchReply*)search:(ACSearchRequest*)input {
  ACSearchReply* reply = [[ACSearchReply alloc] init];
  reply.result = [NSString stringWithFormat:@"Hello %@!", input.query];
  return reply;
}
@end
