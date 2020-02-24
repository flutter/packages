// Copyright 2020 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'ast.dart';
import 'generator_tools.dart';

const Map<String, String> _javaTypeForDartTypeMap = <String, String>{
  'bool': 'Boolean',
  'int': 'Long',
  'String': 'String',
  'double': 'Double',
  'Uint8List': 'byte[]',
  'Int32List': 'int[]',
  'Int64List': 'long[]',
  'Float64List': 'double[]',
};

/// Options that control how Java code will be generated.
class JavaOptions {
  /// The name of the class that will house all the generated classes.
  String className;

  /// The package where the generated class will live.
  String package;
}

void _writeHostApi(Indent indent, Api api) {
  assert(api.location == ApiLocation.host);
  indent.writeln(
      '/** Generated interface from Pigeon that represents a handler of messages from Flutter.*/');
  indent.write('public interface ${api.name} ');
  indent.scoped('{', '}', () {
    for (Method method in api.methods) {
      indent.writeln(
          '${method.returnType} ${method.name}(${method.argType} arg);');
    }
    indent.addln('');
    indent.writeln(
        '/** Sets up an instance of `${api.name}` to handle messages through the `binaryMessenger` */');
    indent.write(
        'public static void setup(BinaryMessenger binaryMessenger, ${api.name} api) ');
    indent.scoped('{', '}', () {
      for (Method method in api.methods) {
        final String channelName = makeChannelName(api, method);
        indent.write('');
        indent.scoped('{', '}', () {
          indent.writeln('BasicMessageChannel<Object> channel =');
          indent.inc();
          indent.inc();
          indent.writeln(
              'new BasicMessageChannel<Object>(binaryMessenger, "$channelName", new StandardMessageCodec());');
          indent.dec();
          indent.dec();
          indent.write(
              'channel.setMessageHandler(new BasicMessageChannel.MessageHandler<Object>() ');
          indent.scoped('{', '});', () {
            indent.write(
                'public void onMessage(Object message, BasicMessageChannel.Reply<Object> reply) ');
            indent.scoped('{', '}', () {
              final String argType = method.argType;
              final String returnType = method.returnType;
              indent.writeln(
                  '$argType input = $argType.fromMap((HashMap)message);');
              indent.writeln('$returnType output = api.${method.name}(input);');
              indent.writeln('reply.reply(output.toMap());');
            });
          });
        });
      }
    });
  });
}

void _writeFlutterApi(Indent indent, Api api) {
  assert(api.location == ApiLocation.flutter);
  indent.writeln(
      '/** Generated class from Pigeon that represents Flutter messages that can be called from Java.*/');
  indent.write('public static class ${api.name} ');
  indent.scoped('{', '}', () {
    indent.writeln('private BinaryMessenger binaryMessenger;');
    indent.write('public ${api.name}(BinaryMessenger argBinaryMessenger)');
    indent.scoped('{', '}', () {
      indent.writeln('this.binaryMessenger = argBinaryMessenger;');
    });
    indent.write('public interface Reply<T> ');
    indent.scoped('{', '}', () {
      indent.writeln('void reply(T reply);');
    });
    for (Method func in api.methods) {
      final String channelName = makeChannelName(api, func);
      indent.write(
          'public void ${func.name}(${func.argType} argInput, Reply<${func.returnType}> callback) ');
      indent.scoped('{', '}', () {
        indent.writeln('BasicMessageChannel<Object> channel =');
        indent.inc();
        indent.inc();
        indent.writeln(
            'new BasicMessageChannel<Object>(binaryMessenger, "$channelName", new StandardMessageCodec());');
        indent.dec();
        indent.dec();
        indent.writeln('HashMap inputMap = argInput.toMap();');
        indent.write(
            'channel.send(inputMap, new BasicMessageChannel.Reply<Object>() ');
        indent.scoped('{', '});', () {
          indent.write('public void reply(Object channelReply) ');
          indent.scoped('{', '}', () {
            indent.writeln('HashMap outputMap = (HashMap)channelReply;');
            indent.writeln(
                '${func.returnType} output = ${func.returnType}.fromMap(outputMap);');
            indent.writeln('callback.reply(output);');
          });
        });
      });
    }
  });
}

String _makeGetter(Field field) {
  final String uppercased =
      field.name.substring(0, 1).toUpperCase() + field.name.substring(1);
  return 'get$uppercased';
}

String _makeSetter(Field field) {
  final String uppercased =
      field.name.substring(0, 1).toUpperCase() + field.name.substring(1);
  return 'set$uppercased';
}

String _javaTypeForDartType(String datatype) {
  return _javaTypeForDartTypeMap[datatype];
}

/// Generates the ".java" file for the AST represented by [root] to [sink] with the
/// provided [options].
void generateJava(JavaOptions options, Root root, StringSink sink) {
  final Indent indent = Indent(sink);
  indent.writeln('// $generatedCodeWarning');
  indent.writeln('// $seeAlsoWarning');
  indent.addln('');
  if (options.package != null) {
    indent.writeln('package ${options.package};');
  }
  indent.addln('');

  indent.writeln('import java.util.HashMap;');
  indent.addln('');
  indent.writeln('import io.flutter.plugin.common.BasicMessageChannel;');
  indent.writeln('import io.flutter.plugin.common.BinaryMessenger;');
  indent.writeln('import io.flutter.plugin.common.StandardMessageCodec;');

  indent.addln('');
  assert(options.className != null);
  indent.writeln('/** Generated class from Pigeon. */');
  indent.write('public class ${options.className} ');
  indent.scoped('{', '}', () {
    for (Class klass in root.classes) {
      indent.addln('');
      indent.writeln(
          '/** Generated class from Pigeon that represents data sent in messages. */');
      indent.write('public static class ${klass.name} ');
      indent.scoped('{', '}', () {
        for (Field field in klass.fields) {
          final HostDatatype hostDatatype = getHostDatatype(
              field, root.classes, _javaTypeForDartType, (String x) => x);
          indent.writeln('private ${hostDatatype.datatype} ${field.name};');
          indent.writeln(
              'public ${hostDatatype.datatype} ${_makeGetter(field)}() { return ${field.name}; }');
          indent.writeln(
              'public void ${_makeSetter(field)}(${hostDatatype.datatype} setterArg) { this.${field.name} = setterArg; }');
          indent.addln('');
        }
        indent.write('HashMap toMap() ');
        indent.scoped('{', '}', () {
          indent.writeln(
              'HashMap<String, Object> toMapResult = new HashMap<String, Object>();');
          for (Field field in klass.fields) {
            indent.writeln('toMapResult.put("${field.name}", ${field.name});');
          }
          indent.writeln('return toMapResult;');
        });
        indent.write('static ${klass.name} fromMap(HashMap map) ');
        indent.scoped('{', '}', () {
          indent.writeln('${klass.name} fromMapResult = new ${klass.name}();');
          for (Field field in klass.fields) {
            indent.writeln(
                'fromMapResult.${field.name} = (${field.dataType})map.get("${field.name}");');
          }
          indent.writeln('return fromMapResult;');
        });
      });
    }

    for (Api api in root.apis) {
      indent.addln('');
      if (api.location == ApiLocation.host) {
        _writeHostApi(indent, api);
      } else if (api.location == ApiLocation.flutter) {
        _writeFlutterApi(indent, api);
      }
    }
  });
}
