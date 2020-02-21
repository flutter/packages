# Pigeon iOS / Android Example

## message.dart

```dart
import 'package:pigeon/pigeon_lib.dart';

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

## invocation

```sh
flutter pub run pigeon \
  --input pigeons/message.dart \
  --dart_out lib/pigeon.dart \
  --objc_header_out ios/Runner/pigeon.h \
  --objc_source_out ios/Runner/pigeon.m \
  --java_out ./android/app/src/main/java/dev/flutter/pigeon/Pigeon.java \
  --java_package "dev.flutter.pigeon"
```

## AppDelegate.m

```objc
#import "AppDelegate.h"
#import <Flutter/Flutter.h>
#import "pigeon.h"

@interface MyApi : NSObject <Api>
@end

@implementation MyApi
-(SearchReply*)search:(SearchRequest*)request {
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

## StartActivity.java

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

## test.dart

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
