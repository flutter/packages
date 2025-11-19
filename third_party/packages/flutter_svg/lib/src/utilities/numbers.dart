/// Parses a [rawDouble] `String` to a `double`.
///
/// The [rawDouble] might include a unit (`px`, `em` or `ex`)
/// which is stripped off when parsed to a `double`.
///
/// Passing `null` will return `null`.
double? parseDouble(String? rawDouble, {bool tryParse = false}) {
  assert(tryParse != null); // ignore: unnecessary_null_comparison
  if (rawDouble == null) {
    return null;
  }

  rawDouble = rawDouble
      .replaceFirst('rem', '')
      .replaceFirst('em', '')
      .replaceFirst('ex', '')
      .replaceFirst('px', '')
      .replaceFirst('pt', '')
      .trim();

  if (tryParse) {
    return double.tryParse(rawDouble);
  }
  return double.parse(rawDouble);
}
