#import "MyFlutterViewController.h"
#import "MyApi.h"
#import "dartle.h"

@interface MyNestedApi : NSObject <ACNestedApi>
- (ACSearchReply *)search:(ACNested *)input;
@end

@implementation MyNestedApi
- (ACSearchReply *)search:(ACNested *)input {
  ACSearchReply *reply = [[ACSearchReply alloc] init];
  reply.result = [NSString stringWithFormat:@"Hello %@!", input.request.query];
  return reply;
}
@end

@interface MyFlutterViewController ()
@end

@implementation MyFlutterViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  ACApiSetup(self.engine.binaryMessenger, [[MyApi alloc] init]);
  ACNestedApiSetup(self.engine.binaryMessenger, [[MyNestedApi alloc] init]);
}

@end
