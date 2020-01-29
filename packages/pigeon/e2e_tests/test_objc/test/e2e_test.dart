import 'package:e2e/e2e.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:test_objc/dartle.dart';

void main() {
  E2EWidgetsFlutterBinding.ensureInitialized();
  testWidgets("simple call", (WidgetTester tester) async {
    SearchRequest request = SearchRequest()..query = "Aaron";
    Api api = Api();
    SearchReply reply = await api.search(request);
    expect(reply.result, equals("Hello Aaron!"));
  });

  testWidgets("simple nested", (WidgetTester tester) async {
    SearchRequest request = SearchRequest()..query = "Aaron";
    Nested nested = Nested()..request = request;
    NestedApi api = NestedApi();
    SearchReply reply = await api.search(nested);
    expect(reply.result, equals("Hello Aaron!"));
  });
}
