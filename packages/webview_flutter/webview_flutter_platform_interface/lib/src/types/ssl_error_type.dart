/// Defines the types of SSL errors
enum SslErrorType {
  /// The date of the certificate is invalid
  dateInvalid,

  /// The certificate has expired
  expired,

  /// Hostname mismatch
  idMismatch,

  /// The certificate is not yet valid
  notYetValid,

  /// The certificate authority is not trusted
  untrusted,

  /// The user did not specify a trust setting
  unspecified,

  /// The user specified that the certificate should not be trusted
  deny,

  /// Trust is denied, but recovery may be possible
  recoverableTrustFailure,

  /// Trust is denied and no simple fix is available
  fatalTrustFailure,

  /// Other error has occurred
  otherError,

  /// An indication of an invalid setting or result
  invalid,
}
