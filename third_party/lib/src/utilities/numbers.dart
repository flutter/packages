/// Parses a `String` to a `double`.
///
/// Passing `null` will return `null`.
///
/// Will strip off a `px` prefix.
double? parseDouble(String? maybeDouble, {bool tryParse = false}) {
  assert(tryParse != null); // ignore: unnecessary_null_comparison
  if (maybeDouble == null) {
    return null;
  }
  maybeDouble = maybeDouble.trim().replaceFirst('px', '').trim();
  if (tryParse) {
    return double.tryParse(maybeDouble);
  }
  return double.parse(maybeDouble);
}
