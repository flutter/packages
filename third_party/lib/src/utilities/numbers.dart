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
      .replaceFirst('em', '')
      .replaceFirst('ex', '')
      .replaceFirst('px', '')
      .trim();

  if (tryParse) {
    return double.tryParse(rawDouble);
  }
  return double.parse(rawDouble);
}

/// Parses a [rawDouble] `String` to a `double`
/// taking into account absolute and relative units
/// (`px`, `em` or `ex`).
///
/// Passing an `em` value will calculate the result
/// relative to the provided [fontSize]:
/// 1 em = 1 * [fontSize].
///
/// Passing an `ex` value will calculate the result
/// relative to the provided [xHeight]:
/// 1 ex = 1 * [xHeight].
///
/// The [rawDouble] might include a unit which is
/// stripped off when parsed to a `double`.
///
/// Passing `null` will return `null`.
double? parseDoubleWithUnits(
  String? rawDouble, {
  required double fontSize,
  required double xHeight,
  bool tryParse = false,
}) {
  double unit = 1.0;

  // 1 em unit is equal to the current font size.
  if (rawDouble?.contains('em') ?? false) {
    unit = fontSize;
  }
  // 1 ex unit is equal to the current x-height.
  else if (rawDouble?.contains('ex') ?? false) {
    unit = xHeight;
  }

  final double? value = parseDouble(
    rawDouble,
    tryParse: tryParse,
  );

  return value != null ? value * unit : null;
}
