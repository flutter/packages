/// Simple credentials wrapper for authorization requests
class WebViewAuthInfo {
  /// Creates a new AuthInfo
  const WebViewAuthInfo({
     required this.username,
     required this.password,
  });
  /// authentication username
  final String username;

  /// authentication password
  final String password;
}
