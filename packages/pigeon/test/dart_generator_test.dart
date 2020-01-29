import 'package:test/test.dart';
import 'package:pigeon/dart_generator.dart';
import 'package:pigeon/ast.dart';

void main() {
  test('gen one class', () {
    Class klass = Class()
      ..name = 'Foobar'
      ..fields = [
        Field()
          ..name = "field1"
          ..dataType = "dataType1"
      ];
    Root root = Root()
      ..apis = List<Api>()
      ..classes = [klass];
    StringBuffer sink = StringBuffer();
    generateDart(root, sink);
    String code = sink.toString();
    expect(code, contains("class Foobar"));
    expect(code, contains("  dataType1 field1;"));
  });

  test('gen one host api', () {
    Root root = Root(apis: [
      Api(name: 'Api', location: ApiLocation.host, functions: [
        Func(name: 'doSomething', argType: 'Input', returnType: 'Output')
      ])
    ], classes: [
      Class(name: 'Input', fields: [Field(name: 'input', dataType: 'String')]),
      Class(name: 'Output', fields: [Field(name: 'output', dataType: 'String')])
    ]);
    StringBuffer sink = StringBuffer();
    generateDart(root, sink);
    String code = sink.toString();
    expect(code, contains("class Api"));
    expect(code, matches('Output.*doSomething.*Input'));
  });

  test('nested class', () {
    Root root = Root(apis: [], classes: [
      Class(name: 'Input', fields: [Field(name: 'input', dataType: 'String')]),
      Class(name: 'Nested', fields: [Field(name: 'nested', dataType: 'Input')])
    ]);
    StringBuffer sink = StringBuffer();
    generateDart(root, sink);
    String code = sink.toString();
    expect(code, contains('dartleMap["nested"] = nested._toMap()'));
    expect(
        code, contains('result.nested = Input._fromMap(dartleMap["nested"]);'));
  });
}
