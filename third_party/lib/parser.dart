import 'package:xml/xml_events.dart' as xml show parseEvents;

import 'src/svg/parser_state.dart';
import 'src/vector_drawable.dart';

/// Parses SVG data into a [DrawableRoot].
class SvgParser {
  /// Parses SVG from a string to a [DrawableRoot].
  ///
  /// The [key] parameter is used for debugging purposes.
  ///
  /// By default SVG parsing will only log warnings when detecting unsupported
  /// elements in an SVG.
  /// If [warningsAsErrors] is true the function will throw with an error
  /// instead.
  /// You might want to set this to true for test and to false at runtime.
  /// Defaults to false.
  Future<DrawableRoot> parse(
    String str, {
    String? key,
    bool warningsAsErrors = false,
  }) async {
    final SvgParserState state =
        SvgParserState(xml.parseEvents(str), key, warningsAsErrors);
    return await state.parse();
  }
}
