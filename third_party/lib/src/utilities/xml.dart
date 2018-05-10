import 'package:xml/xml.dart';

/// Gets the attribute, trims it, and returns the attribute or default if the attribute
/// is null or ''.
///
/// Will look to the style first if it can.
String getAttribute(XmlElement el, String name,
    {String def = '', String namespace, bool checkStyle = true}) {
  String raw = '';
  if (checkStyle) {
    final String style = el.getAttribute('style')?.trim();
    if (style != '' && style != null) {
      final List<String> styles = style.split(';');
      raw = styles.firstWhere((str) => str.trimLeft().startsWith(name + ':'),
          orElse: () => '');

      if (raw != '') {
        raw = raw.substring(raw.indexOf(':') + 1)?.trim();
      }
    }

    if (raw == '' || raw == null) {
      raw = el.getAttribute(name, namespace: namespace)?.trim();
    }
  } else {
    raw = el.getAttribute(name, namespace: namespace)?.trim();
  }

  return raw == '' || raw == null ? def : raw;
}
