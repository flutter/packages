import 'feature_test.dart' as test;
import 'mustache_specs.dart' as specs;
import 'parser_test.dart' as parser;

const List<String> UNSUPPORTED_SPECS = [
  '~dynamic-names',
  '~inheritance',
];

void main() {
  specs.main(UNSUPPORTED_SPECS);
  test.main();
  parser.main();
}
