import 'package:xml/xml_events.dart';

/// The namespace for xlink from the SVG 1.1 spec.
const String kXlinkNamespace = 'http://www.w3.org/1999/xlink';

/// Get the `xlink:href` or `href` attribute, preferring `xlink`.
///
/// SVG 1.1 specifies that these attributes should be in the xlink namespace.
/// SVG 2 deprecates that namespace.
String? getHrefAttribute(List<XmlEventAttribute>? attributes) => getAttribute(
      attributes,
      'href',
      namespace: kXlinkNamespace,
      def: getAttribute(attributes, 'href'),
    );

/// Gets the attribute, trims it, and returns the attribute or default if the attribute
/// is null or ''.
///
/// Will look to the style first if it can.
String? getAttribute(
  List<XmlEventAttribute>? el,
  String name, {
  String? def = '',
  String? namespace,
  bool checkStyle = true,
}) {
  String raw = '';
  if (checkStyle) {
    final String? style = _getAttribute(el!, 'style').trim();
    if (style != '' && style != null) {
      // Probably possible to slightly optimize this (e.g. use indexOf instead of split),
      // but handling potential whitespace will get complicated and this just works.
      // I also don't feel like writing benchmarks for what is likely a micro-optimization.
      final List<String> styles = style.split(';');
      raw = styles.firstWhere(
          (String str) => str.trimLeft().startsWith(name + ':'),
          orElse: () => '');

      if (raw != '') {
        raw = raw.substring(raw.indexOf(':') + 1).trim();
      }
    }

    if (raw == '') {
      raw = _getAttribute(el, name, namespace: namespace).trim();
    }
  } else {
    raw = _getAttribute(el!, name, namespace: namespace).trim();
  }

  return raw == '' ? def : raw;
}

String _getAttribute(
  List<XmlEventAttribute> list,
  String localName, {
  String def = '',
  String? namespace,
}) {
  for (XmlEventAttribute attr in list) {
    if (attr.name.replaceFirst('${attr.namespacePrefix}:', '') == localName) {
      return attr.value;
    }
  }
  return def;
}
