library mustache_test;

import 'package:unittest/unittest.dart';
import 'package:mustache/mustache.dart';

main() {
	test('1', () {
		var output = render(
			'{{#section}}_{{var}}_{{/section}}',
			{"section": {"var": "bob"}}
		);
		expect(output, equals('_bob_'));
	});
}
