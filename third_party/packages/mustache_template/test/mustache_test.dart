import 'mustache_specs.dart' as specs;

const List<String> UNSUPPORTED_SPECS = [
  '~dynamic-names',
  '~inheritance',
];

void main() {
  specs.defineTests(UNSUPPORTED_SPECS);
}
