const int _0 = 48; // ASCII '0'
const int _9 = 57; // ASCII '9'
const int _period = 46; // ASCII '.'
const int _minus = 45;

/// Parses a `String` to a `double`.
///
/// Passing `null` will return `null`.
///
/// Will only take the initial numeric value.
double parseDouble(String maybeDouble) {
  if (maybeDouble == null) {
    return null;
  }
  maybeDouble = maybeDouble.trim();
  for (int i = 0; i < maybeDouble.length; i++) {
    final int codeUnit = maybeDouble.codeUnitAt(i);
    if ((codeUnit < _0 || codeUnit > _9) && codeUnit != _period && codeUnit != _minus) {
      return double.parse(maybeDouble.substring(0, i));
    }
  }
  return double.parse(maybeDouble);
}
