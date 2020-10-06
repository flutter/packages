# Pigeon Examples

## HostApi Example

This example gives an overview of how to use Pigeon to call into the
host-platform from Flutter.

### message.dart

This is the Pigeon file that describes the interface that will be used to call
from Flutter to the host-platform.

```dart
import 'package:pigeon/pigeon.dart';

class SearchRequest {
  String query;
}

class SearchReply {
  String result;
}

@HostApi()
abstract class Api {
  SearchReply search(SearchRequest request);
}
```

### invocation

This is the call to Pigeon that will injest `message.dart` and generate the code
for iOS and Android.

```sh
flutter pub run pigeon \
  --input pigeons/message.dart \
  --dart_out lib/pigeon.dart \
  --objc_header_out ios/Runner/pigeon.h \
  --objc_source_out ios/Runner/pigeon.m \
  --java_out ./android/app/src/main/java/dev/flutter/pigeon/Pigeon.java \
  --java_package "dev.flutter.pigeon"
```

### AppDelegate.m

This is the code that will use the generated Objective-C code to recieve calls
from Flutter.

```objc
#import "AppDelegate.h"
#import <Flutter/Flutter.h>
#import "pigeon.h"

@interface MyApi : NSObject <Api>
@end

@implementation MyApi
-(SearchReply*)search:(SearchRequest*)request error:(FlutterError **)error {
  SearchReply *reply = [[SearchReply alloc] init];
  reply.result =
      [NSString stringWithFormat:@"Hi %@!", request.query];
  return reply;
}
@end

- (BOOL)application:(UIApplication *)application 
didFinishLaunchingWithOptions:(NSDictionary<UIApplicationLaunchOptionsKey, id> *)launchOptions {
  MyApi *api = [[MyApi alloc] init];
  ApiSetup(getFlutterEngine().binaryMessenger, api);
  return YES;
}
```

### StartActivity.java

This is the code that will use the generated Java code to receive calls from Flutter.

```java
import dev.flutter.pigeon.Pigeon;

public class StartActivity extends Activity {
  private class MyApi extends Pigeon.Api {
    Pigeon.SearchReply search(Pigeon.SearchRequest request) {
      Pigeon.SearchReply reply = new Pigeon.SearchReply();
      reply.result = String.format("Hi %s!", request.query);
      return reply;
    }
  }

  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    Pigeon.SetupApi(getBinaryMessenger(), new MyApi());
  }
}
```

### test.dart

This is the Dart code that will call into the host-platform using the generated
Dart code.

```dart
import 'pigeon.dart';

void main() {
  testWidgets("test pigeon", (WidgetTester tester) async {
    SearchRequest request = SearchRequest()..query = "Aaron";
    Api api = Api();
    SearchReply reply = await api.search(request);
    expect(reply.result, equals("Hi Aaron!"));
  });
}

```

## Swift / Kotlin Plugin Example

A downloadable example of using Pigeon to create a Flutter Plugin with Swift and
Kotlin can be found at
[gaaclarke/flutter_plugin_example](https://github.com/gaaclarke/pigeon_plugin_example).

## Swift Add-to-app Example

A full example of using Pigeon for add-to-app with Swift on iOS can be found at
[gaaclarke/GiantsA2A](https://github.com/gaaclarke/GiantsA2A).
