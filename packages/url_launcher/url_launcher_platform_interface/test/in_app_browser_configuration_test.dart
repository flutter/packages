import 'package:flutter_test/flutter_test.dart';
import 'package:url_launcher_platform_interface/url_launcher_platform_interface.dart';

void main() {
  test('InAppBrowserConfiguration defaults to showTitle false', () {
    expect(const InAppBrowserConfiguration().showTitle, false);
  });

  test('InAppBrowserConfiguration showTitle can be set to true', () {
    expect(const InAppBrowserConfiguration(showTitle: true).showTitle, true);
  });
}
