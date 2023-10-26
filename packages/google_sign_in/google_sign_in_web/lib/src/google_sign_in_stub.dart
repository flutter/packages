/// Provides web platform access to web-specific Google Sign-In functionality.
abstract class GoogleSignInPlugin {
  /// Passes auth code request to google_sign_in_web plugin on web, throws on other platforms.
  Future<String?> requestServerAuthCode() =>
      throw UnsupportedError('Function not implemented on this platform.');
}
