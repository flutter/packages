# Pigeon Examples

## HostApi Example

This example gives an overview of how to use Pigeon to call into the
host-platform from Flutter.

For instructions to set up your own Pigeon usage see these [steps](https://pub.dev/packages/pigeon#usage).

### message.dart

This is the Pigeon file that describes the interface that will be used to call
from Flutter to the host-platform.

```dart
import 'package:pigeon/pigeon.dart';

class Book {
  String? title;
  String? author;
}

@HostApi()
abstract class BookApi {
  List<Book?> search(String keyword);
}
```

### invocation

This is the call to Pigeon that will ingest `message.dart` and generate the code
for iOS and Android.

```sh
flutter pub run pigeon \
  --input pigeons/message.dart \
  --dart_out lib/pigeon.dart \
  --objc_header_out ios/Runner/pigeon.h \
  --objc_source_out ios/Runner/pigeon.m \
  --experimental_swift_out ios/Runner/Pigeon.swift \
  --java_out ./android/app/src/main/java/dev/flutter/pigeon/Pigeon.java \
  --java_package "dev.flutter.pigeon"
```

### AppDelegate.m

This is the code that will use the generated Objective-C code to receive calls
from Flutter.

```objc
#import "AppDelegate.h"
#import <Flutter/Flutter.h>
#import "pigeon.h"

@interface MyApi : NSObject <BookApi>
@end

@implementation MyApi
-(NSArray<Book *> *)searchKeyword:(NSString *)keyword error:(FlutterError **)error {
  Book *result = [[Book alloc] init];
  result.title =
      [NSString stringWithFormat:@"%@'s Life", request.query];
  result.author = keyword;
  return @[ result ];
}
@end

@implementation AppDelegate
- (BOOL)application:(UIApplication *)application 
didFinishLaunchingWithOptions:(NSDictionary<UIApplicationLaunchOptionsKey, id> *)launchOptions {
  MyApi *api = [[MyApi alloc] init];
  BookApiSetup(getFlutterEngine().binaryMessenger, api);
  return YES;
}
@end
```

### AppDelegate.swift

This is the code that will use the generated Swift code to receive calls from Flutter.

```swift
import Flutter

class MyApi: NSObject, BookApi {
  func search(keyword: String) -> [Book] {
    let result = Book(title: "\(keyword)'s Life", author: keyword)
    return [result]
  }
}

class AppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?
  ) -> Bool {
    let api = MyApi()
    BookApiSetup.setUp(getFlutterEngine().binaryMessenger, api)
    return true
  }
}
```

### StartActivity.java

This is the code that will use the generated Java code to receive calls from Flutter.

```java
import dev.flutter.pigeon.Pigeon.*;
import java.util.Collections;

public class StartActivity extends Activity {
  private class MyApi implements BookApi {
    List<Book> search(String keyword) {
      Book result = new Book();
      result.author = keyword;
      result.title = String.format("%s's Life", keyword);
      return Collections.singletonList(result)
    }
  }

  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    BookApi.setup(getBinaryMessenger(), new MyApi());
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
    Api api = Api();
    List<Book?> reply = await api.search("Aaron");
    expect(reply[0].title, equals("Aaron's Life"));
  });
}

```

## Swift / Kotlin Plugin Example

A downloadable example of using Pigeon to create a Flutter Plugin with Swift and
Kotlin can be found at
[gaaclarke/flutter_plugin_example](https://github.com/gaaclarke/pigeon_plugin_example).

## Swift / Kotlin Add-to-app Example

A full example of using Pigeon for add-to-app with Swift on iOS can be found at
[samples/add_to_app/books](https://github.com/flutter/samples/tree/master/add_to_app/books).

## Video player plugin

A full real-world example can also be found in the
[video_player plugin](https://github.com/flutter/plugins/tree/main/packages/video_player).
