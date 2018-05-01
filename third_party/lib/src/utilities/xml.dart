import 'package:xml/xml.dart';

/// Gets the attribute, trims it, and returns the attribute or default if the attribute
/// is null or ''.
String getAttribute(XmlElement el, String name, [String def = '', String namespace]) {
  final String raw = el.getAttribute(name, namespace: namespace)?.trim();
  return raw == '' || raw == null ? def : raw;
}