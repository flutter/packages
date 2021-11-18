/// Parses a [rawDouble] `String` to a `double`.
///
/// The [rawDouble] might include a unit (`px` or `em`)
/// which is stripped off when parsed to a `double`.
///
/// Passing `null` will return `null`.
double? parseDouble(String? rawDouble, {bool tryParse = false}) {
  assert(tryParse != null); // ignore: unnecessary_null_comparison
  if (rawDouble == null) {
    return null;
  }

  rawDouble = rawDouble.replaceFirst('em', '').replaceFirst('px', '').trim();

  if (tryParse) {
    return double.tryParse(rawDouble);
  }
  return double.parse(rawDouble);
}

/// Parses a [rawDouble] `String` to a `double`
/// taking into account absolute and relative units
/// (`px` or `em`).
///
/// Passing an `em` value will calculate the result
/// relative to the provided [fontSize]:
/// 1 em = 1 * [fontSize].
///
/// The [rawDouble] might include a unit which is
/// stripped off when parsed to a `double`.
///
/// Passing `null` will return `null`.
double? parseDoubleWithUnits(
  String? rawDouble, {
  required double fontSize,
  bool tryParse = false,
}) {
  double unit = 1.0;

  // 1 em unit is equal to the current font size.
  if (rawDouble?.contains('em') ?? false) {
    unit = fontSize;
  }

  final double? value = parseDouble(
    rawDouble,
    tryParse: tryParse,
  );

  return value != null ? value * unit : null;
}
