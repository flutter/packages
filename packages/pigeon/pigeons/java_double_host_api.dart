import 'package:pigeon/pigeon.dart';

class Response {
  int? result;
}

@HostApi()
abstract class BridgeApi1 {
  @async
  Response call();
}

@HostApi()
abstract class BridgeApi2 {
  @async
  Response call();
}
