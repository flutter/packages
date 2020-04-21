// Copyright 2020 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'ast.dart';
import 'generator_tools.dart';

void _writeHostApi(Indent indent, Api api) {
  assert(api.location == ApiLocation.host);
  indent.write('class ${api.name} ');
  indent.scoped('{', '}', () {
    for (Method func in api.methods) {
      String argSignature = '';
      String sendArgument = 'null';
      String requestMapDeclaration;
      if (func.argType != 'void') {
        argSignature = '${func.argType} arg';
        sendArgument = 'requestMap';
        requestMapDeclaration =
            'final Map<dynamic, dynamic> requestMap = arg._toMap();';
      }
      indent.write(
          'Future<${func.returnType}> ${func.name}($argSignature) async ');
      indent.scoped('{', '}', () {
        if (requestMapDeclaration != null) {
          indent.writeln(requestMapDeclaration);
        }
        final String channelName = makeChannelName(api, func);
        indent.writeln('const BasicMessageChannel<dynamic> channel =');
        indent.inc();
        indent.inc();
        indent.writeln(
            'BasicMessageChannel<dynamic>(\'$channelName\', StandardMessageCodec());');
        indent.dec();
        indent.dec();
        indent.writeln('');
        final String returnStatement = func.returnType == 'void'
            ? '// noop'
            : 'return ${func.returnType}._fromMap(replyMap[\'${Keys.result}\']);';
        indent.format(
            '''final Map<dynamic, dynamic> replyMap = await channel.send($sendArgument);
if (replyMap == null) {
\tthrow PlatformException(
\t\tcode: 'channel-error',
\t\tmessage: 'Unable to establish connection on channel.',
\t\tdetails: null);
} else if (replyMap['error'] != null) {
\tfinal Map<dynamic, dynamic> error = replyMap['${Keys.error}'];
\tthrow PlatformException(
\t\t\tcode: error['${Keys.errorCode}'],
\t\t\tmessage: error['${Keys.errorMessage}'],
\t\t\tdetails: error['${Keys.errorDetails}']);
} else {
\t$returnStatement
}
''');
      });
    }
  });
  indent.writeln('');
}

void _writeFlutterApi(Indent indent, Api api) {
  assert(api.location == ApiLocation.flutter);
  indent.write('abstract class ${api.name} ');
  indent.scoped('{', '}', () {
    for (Method func in api.methods) {
      final String argSignature =
          func.argType == 'void' ? '' : '${func.argType} arg';
      indent.writeln('${func.returnType} ${func.name}($argSignature);');
    }
  });
  indent.addln('');
  indent.write('void ${api.name}Setup(${api.name} api) ');
  indent.scoped('{', '}', () {
    for (Method func in api.methods) {
      indent.write('');
      indent.scoped('{', '}', () {
        indent.writeln('const BasicMessageChannel<dynamic> channel =');
        indent.inc();
        indent.inc();
        indent.writeln(
            'BasicMessageChannel<dynamic>(\'${makeChannelName(api, func)}\', StandardMessageCodec());');
        indent.dec();
        indent.dec();
        indent.write('channel.setMessageHandler((dynamic message) async ');
        indent.scoped('{', '});', () {
          final String argType = func.argType;
          final String returnType = func.returnType;
          indent.writeln(
              'final Map<dynamic, dynamic> mapMessage = message as Map<dynamic, dynamic>;');
          String call;
          if (argType == 'void') {
            call = 'api.${func.name}()';
          } else {
            indent.writeln(
                'final $argType input = $argType._fromMap(mapMessage);');
            call = 'api.${func.name}(input)';
          }
          if (returnType == 'void') {
            indent.writeln('$call;');
          } else {
            indent.writeln('final $returnType output = $call;');
            indent.writeln('return output._toMap();');
          }
        });
      });
    }
  });
}

/// Generates Dart source code for the given AST represented by [root],
/// outputting the code to [sink].
void generateDart(Root root, StringSink sink) {
  final List<String> customClassNames =
      root.classes.map((Class x) => x.name).toList();
  final Indent indent = Indent(sink);
  indent.writeln('// $generatedCodeWarning');
  indent.writeln('// $seeAlsoWarning');
  indent.writeln(
      '// ignore_for_file: public_member_api_docs, non_constant_identifier_names, avoid_as, unused_import');
  indent.writeln('import \'dart:async\';');
  indent.writeln('import \'package:flutter/services.dart\';');
  indent.writeln('');

  for (Class klass in root.classes) {
    sink.write('class ${klass.name} ');
    indent.scoped('{', '}', () {
      for (Field field in klass.fields) {
        indent.writeln('${field.dataType} ${field.name};');
      }
      indent.writeln('// ignore: unused_element');
      indent.write('Map<dynamic, dynamic> _toMap() ');
      indent.scoped('{', '}', () {
        indent.writeln(
            'final Map<dynamic, dynamic> pigeonMap = <dynamic, dynamic>{};');
        for (Field field in klass.fields) {
          indent.write('pigeonMap[\'${field.name}\'] = ');
          if (customClassNames.contains(field.dataType)) {
            indent.addln('${field.name}._toMap();');
          } else {
            indent.addln('${field.name};');
          }
        }
        indent.writeln('return pigeonMap;');
      });
      indent.writeln('// ignore: unused_element');
      indent.write(
          'static ${klass.name} _fromMap(Map<dynamic, dynamic> pigeonMap) ');
      indent.scoped('{', '}', () {
        indent.writeln('final ${klass.name} result = ${klass.name}();');
        for (Field field in klass.fields) {
          indent.write('result.${field.name} = ');
          if (customClassNames.contains(field.dataType)) {
            indent.addln(
                '${field.dataType}._fromMap(pigeonMap[\'${field.name}\']);');
          } else {
            indent.addln('pigeonMap[\'${field.name}\'];');
          }
        }
        indent.writeln('return result;');
      });
    });
    indent.writeln('');
  }
  for (Api api in root.apis) {
    if (api.location == ApiLocation.host) {
      _writeHostApi(indent, api);
    } else if (api.location == ApiLocation.flutter) {
      _writeFlutterApi(indent, api);
    }
  }
}
