# Pigeon

<aside class="warning">
Pigeon is experimental and unsupported.  It can be removed or changed at any time.
</aside>

Pigeon is a code generator tool to make communication between Flutter and the
host platform type-safe and easier.

## Supported Platforms

Currently Pigeon only supports generating Objective-C code for usage on iOS and calling host functions from Flutter.

## Runtime Requirements

Pigeon generates all the code that is needed to communicate between Flutter and the host platform, there is no extra runtime requirement.  A plugin author doesn't need to worry about conflicting versions of Pigeon.

## Usage

### Steps

1) Add Pigeon as a dev_dependency.
1) Make a ".dart" file outside of your "lib" directory for defining the communication interface.
1) Run pigeon on your ".dart" file to generate the required Dart and Objective-C code.
1) Add the generated code to your `ios/Runner.xcworkspace` XCode project for compilation.
1) Implement the generated iOS protocol for handling the calls on iOS, set it up
   as the handler for the messages.
1) Call the generated Dart methods.

### Rules for defining your communication interface

1) The file should contain no methods or function definitions.
1) Datatypes are defined as classes with fields of the supported datatypes (see
   the supported Datatypes section).
1) Api's should be defined as an `abstract class` with either `HostApi()` or
   `FlutterApi()` as metadata.  The former being for procedures that are defined
   on the host platform and the latter for procedures that are defined in Dart.
1) Method declarations on the Api classes should have one argument and a return
   value whose types are defined in the file.

### Example

#### message.dart

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

#### invocation

```sh
pub run pigeon \
  --input pigeons/message.dart \
  --dart_out lib/pigeon.dart \
  --objc_header_out ios/Runner/pigeon.h \
  --objc_source_out ios/Runner/pigeon.m
```

#### AppDelegate.m

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

#### test.dart

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

## Supported Datatypes

Pigeon uses the `StandardMessageCodec` so it supports any data-type platform
channels supports
[[documentation](https://flutter.dev/docs/development/platform-integration/platform-channels#codec)].  Nested data-types are supported, too.

Note: Generics for List and Map aren't supported yet.

## Feedback

File an issue in [flutter/flutter](https://github.com/flutter/flutter) with the
word 'pigeon' clearly in the title and cc **@gaaclarke**.
