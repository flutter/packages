#import "MyFlutterViewController.h"
#import "MyApi.h"
#import "MyEngineControl.h"
#import "MyNestedApi.h"
#import "dartle.h"

@interface MyFlutterViewController ()
@end

@implementation MyFlutterViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  ACApiSetup(self.engine.binaryMessenger, [[MyApi alloc] init]);
  ACNestedApiSetup(self.engine.binaryMessenger, [[MyNestedApi alloc] init]);
  ACEngineControlSetup(self.engine.binaryMessenger, [[MyEngineControl alloc] init]);
}

@end
