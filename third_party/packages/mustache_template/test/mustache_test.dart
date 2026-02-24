import 'mustache_specs.dart' as specs;

/// Optional specifications that are not currently supported
/// by this library, in the format of the keys in the SPECS map in specs/specs.dart
const List<String> UNSUPPORTED_SPECS = ['inheritance', 'dynamic_names'];

void main() {
  specs.defineTests(UNSUPPORTED_SPECS);
}
