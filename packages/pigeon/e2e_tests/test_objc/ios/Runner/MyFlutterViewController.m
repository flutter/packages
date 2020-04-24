#import "MyFlutterViewController.h"
#import "MyApi.h"
#import "MyNestedApi.h"
#import "dartle.h"

@interface MyFlutterViewController ()
@end

@implementation MyFlutterViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  ACApiSetup(self.engine.binaryMessenger, [[MyApi alloc] init]);
  ACNestedApiSetup(self.engine.binaryMessenger, [[MyNestedApi alloc] init]);
}

@end
