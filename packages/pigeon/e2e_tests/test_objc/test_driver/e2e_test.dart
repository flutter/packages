import 'package:e2e/e2e.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:test_objc/dartle.dart';

void main() {
  E2EWidgetsFlutterBinding.ensureInitialized();
  testWidgets('simple call', (WidgetTester tester) async {
    final SearchRequest request = SearchRequest()..query = 'Aaron';
    final Api api = Api();
    final SearchReply reply = await api.search(request);
    expect(reply.result, equals('Hello Aaron!'));
  });

  testWidgets('simple nested', (WidgetTester tester) async {
    final SearchRequest request = SearchRequest()..query = 'Aaron';
    final Nested nested = Nested()..request = request;
    final NestedApi api = NestedApi();
    final SearchReply reply = await api.search(nested);
    expect(reply.result, equals('Hello Aaron!'));
  });

  testWidgets('throws', (WidgetTester tester) async {
    final SearchRequest request = SearchRequest()..query = 'error';
    final Api api = Api();
    SearchReply reply;
    expect(() async {
      reply = await api.search(request);
    }, throwsException);
    expect(reply, isNull);
  });
}
