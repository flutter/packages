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

class Nested {
  SearchRequest request;
}

@HostApi()
abstract class NestedApi {
  SearchReply search(Nested nested);
}

void setupDartle(DartleOptions options) {
  options.objc_options.prefix = 'AC';
}
