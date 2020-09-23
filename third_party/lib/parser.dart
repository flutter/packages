import 'package:xml/xml_events.dart' as xml show parseEvents;

import 'src/svg/parser_state.dart';
import 'src/vector_drawable.dart';

/// Parses SVG data into a [DrawableRoot].
class SvgParser {
  /// Parses SVG from a string to a [DrawableRoot].
  ///
  /// The [key] parameter is used for debugging purposes.
  Future<DrawableRoot> parse(String str, {String key}) async {
    return await SvgParserState(xml.parseEvents(str), key).parse();
  }
}
