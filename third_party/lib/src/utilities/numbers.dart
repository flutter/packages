/// Parses a `String` to a `double`.
///
/// Passing `null` will return `null`.
///
/// Will strip off a `px` prefix.
double parseDouble(String maybeDouble) {
  if (maybeDouble == null) {
    return null;
  }
  maybeDouble = maybeDouble.trim().replaceFirst('px', '').trim();
  return double.parse(maybeDouble);
}
