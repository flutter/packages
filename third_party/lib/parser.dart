import 'dart:async';

import 'package:xml/xml.dart' show XmlPushReader;

import 'src/svg/parser_state.dart';
import 'src/vector_drawable.dart';

class SvgParser {
  Future<DrawableRoot> parse(String str, {String key}) async {
    return await SvgParserState(XmlPushReader(str), key).parse();
  }
}
