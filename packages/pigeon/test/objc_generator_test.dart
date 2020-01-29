import 'package:test/test.dart';
import 'package:pigeon/objc_generator.dart';
import 'package:pigeon/ast.dart';

void main() {
  test('gen one class header', () {
    Root root = Root(apis: [], classes: [
      Class(
          name: 'Foobar', fields: [Field(name: 'field1', dataType: 'String')]),
    ]);
    StringBuffer sink = StringBuffer();
    generateObjcHeader(ObjcOptions(), root, sink);
    String code = sink.toString();
    expect(code, contains("@interface Foobar"));
    expect(code, matches("@property.*NSString.*field1"));
  });

  test('gen one class source', () {
    Root root = Root(apis: [], classes: [
      Class(
          name: 'Foobar', fields: [Field(name: 'field1', dataType: 'String')]),
    ]);
    StringBuffer sink = StringBuffer();
    generateObjcSource(ObjcOptions(header: "foo.h"), root, sink);
    String code = sink.toString();
    expect(code, contains("#import \"foo.h\""));
    expect(code, contains("@implementation Foobar"));
  });

  test('gen one api header', () {
    Root root = Root(apis: [
      Api(name: 'Api', location: ApiLocation.host, functions: [
        Func(name: 'doSomething', argType: 'Input', returnType: 'Output')
      ])
    ], classes: [
      Class(name: 'Input', fields: [Field(name: 'input', dataType: 'String')]),
      Class(name: 'Output', fields: [Field(name: 'output', dataType: 'String')])
    ]);
    StringBuffer sink = StringBuffer();
    generateObjcHeader(ObjcOptions(), root, sink);
    String code = sink.toString();
    expect(code, contains("@interface Input"));
    expect(code, contains("@interface Output"));
    expect(code, contains("@protocol Api"));
    expect(code, matches('Output.*doSomething.*Input'));
    expect(code, contains('ApiSetup('));
  });

  test('gen one api source', () {
    Root root = Root(apis: [
      Api(name: 'Api', location: ApiLocation.host, functions: [
        Func(name: 'doSomething', argType: 'Input', returnType: 'Output')
      ])
    ], classes: [
      Class(name: 'Input', fields: [Field(name: 'input', dataType: 'String')]),
      Class(name: 'Output', fields: [Field(name: 'output', dataType: 'String')])
    ]);
    StringBuffer sink = StringBuffer();
    generateObjcSource(ObjcOptions(header: "foo.h"), root, sink);
    String code = sink.toString();
    expect(code, contains('#import "foo.h"'));
    expect(code, contains("@implementation Input"));
    expect(code, contains("@implementation Output"));
    expect(code, contains('ApiSetup('));
  });

  test('all the simple datatypes header', () {
    Root root = Root(apis: [], classes: [
      Class(name: 'Foobar', fields: [
        Field(name: 'aBool', dataType: 'bool'),
        Field(name: 'aInt', dataType: 'int'),
        Field(name: 'aDouble', dataType: 'double'),
        Field(name: 'aString', dataType: 'String'),
        Field(name: 'aUint8List', dataType: 'Uint8List'),
        Field(name: 'aInt32List', dataType: 'Int32List'),
        Field(name: 'aInt64List', dataType: 'Int64List'),
        Field(name: 'aFloat64List', dataType: 'Float64List'),
      ]),
    ]);

    StringBuffer sink = StringBuffer();
    generateObjcHeader(ObjcOptions(header: "foo.h"), root, sink);
    String code = sink.toString();
    expect(code, contains("@interface Foobar"));
    expect(code, contains("@class FlutterStandardTypedData;"));
    expect(code, matches("@property.*strong.*NSNumber.*aBool"));
    expect(code, matches("@property.*strong.*NSNumber.*aInt"));
    expect(code, matches("@property.*strong.*NSNumber.*aDouble"));
    expect(code, matches("@property.*copy.*NSString.*aString"));
    expect(code,
        matches("@property.*strong.*FlutterStandardTypedData.*aUint8List"));
    expect(code,
        matches("@property.*strong.*FlutterStandardTypedData.*aInt32List"));
    expect(code,
        matches("@property.*strong.*FlutterStandardTypedData.*Int64List"));
    expect(code,
        matches("@property.*strong.*FlutterStandardTypedData.*Float64List"));
  });

  test('bool source', () {
    Root root = Root(apis: [], classes: [
      Class(name: 'Foobar', fields: [
        Field(name: 'aBool', dataType: 'bool'),
      ]),
    ]);

    StringBuffer sink = StringBuffer();
    generateObjcSource(ObjcOptions(header: "foo.h"), root, sink);
    String code = sink.toString();
    expect(code, contains("@implementation Foobar"));
    expect(code, contains("result.aBool = dict[@\"aBool\"];"));
  });

  test('nested class header', () {
    Root root = Root(apis: [], classes: [
      Class(name: 'Input', fields: [Field(name: 'input', dataType: 'String')]),
      Class(name: 'Nested', fields: [Field(name: 'nested', dataType: 'Input')])
    ]);
    StringBuffer sink = StringBuffer();
    generateObjcHeader(ObjcOptions(header: "foo.h"), root, sink);
    String code = sink.toString();
    expect(code, contains('@property(nonatomic, strong) Input * nested;'));
  });

  test('nested class source', () {
    Root root = Root(apis: [], classes: [
      Class(name: 'Input', fields: [Field(name: 'input', dataType: 'String')]),
      Class(name: 'Nested', fields: [Field(name: 'nested', dataType: 'Input')])
    ]);
    StringBuffer sink = StringBuffer();
    generateObjcSource(ObjcOptions(header: "foo.h"), root, sink);
    String code = sink.toString();
    expect(
        code, contains('result.nested = [Input fromMap:dict[@\"nested\"]];'));
    expect(code, contains('[self.nested toMap], @\"nested\"'));
  });

  test('prefix class header', () {
    Root root = Root(apis: [], classes: [
      Class(
          name: 'Foobar', fields: [Field(name: 'field1', dataType: 'String')]),
    ]);
    StringBuffer sink = StringBuffer();
    generateObjcHeader(ObjcOptions(prefix: 'ABC'), root, sink);
    String code = sink.toString();
    expect(code, contains("@interface ABCFoobar"));
  });

  test('prefix class source', () {
    Root root = Root(apis: [], classes: [
      Class(
          name: 'Foobar', fields: [Field(name: 'field1', dataType: 'String')]),
    ]);
    StringBuffer sink = StringBuffer();
    generateObjcSource(ObjcOptions(prefix: 'ABC'), root, sink);
    String code = sink.toString();
    expect(code, contains("@implementation ABCFoobar"));
  });

  test('prefix nested class header', () {
    Root root = Root(apis: [
      Api(name: 'Api', location: ApiLocation.host, functions: [
        Func(name: 'doSomething', argType: 'Input', returnType: 'Nested')
      ])
    ], classes: [
      Class(name: 'Input', fields: [Field(name: 'input', dataType: 'String')]),
      Class(name: 'Nested', fields: [Field(name: 'nested', dataType: 'Input')])
    ]);
    StringBuffer sink = StringBuffer();
    generateObjcHeader(ObjcOptions(prefix: 'ABC'), root, sink);
    String code = sink.toString();
    expect(code, matches("property.*ABCInput"));
    expect(code, matches("ABCNested.*doSomething.*ABCInput"));
    expect(code, contains("@protocol ABCApi"));
  });

  test('prefix nested class source', () {
    Root root = Root(apis: [
      Api(name: 'Api', location: ApiLocation.host, functions: [
        Func(name: 'doSomething', argType: 'Input', returnType: 'Nested')
      ])
    ], classes: [
      Class(name: 'Input', fields: [Field(name: 'input', dataType: 'String')]),
      Class(name: 'Nested', fields: [Field(name: 'nested', dataType: 'Input')])
    ]);
    StringBuffer sink = StringBuffer();
    generateObjcSource(ObjcOptions(prefix: 'ABC'), root, sink);
    String code = sink.toString();
    expect(code, contains("ABCInput fromMap"));
    expect(code, matches("ABCInput.*=.*ABCInput fromMap"));
    expect(code, contains("void ABCApiSetup("));
  });
}
