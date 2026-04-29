import 'package:http/http.dart' as http;

/// A collection of properties used to specify custom behavior of the
/// GoogleFonts library.
class GoogleFontsConfig {
  /// Whether or not the GoogleFonts library can make requests to
  /// [fonts.google.com](https://fonts.google.com/) to retrieve font files.
  bool allowRuntimeFetching = true;

  /// The HTTP client used to fetch fonts.
  ///
  /// If this is null, a shared default [http.Client] will be used.
  ///
  /// If you supply a client, you are responsible for closing it.
  http.Client? httpClient;
}
