import 'package:flutter/foundation.dart';

/// Defines the parameters of a SSL certificate
@immutable
class SslCertificate {
  /// Creates a [SslCertificate].
  const SslCertificate({
    required this.issuedBy,
    required this.issuedTo,
    required this.validNotAfterDate,
    required this.validNotBeforeDate,
    required this.x509CertificateDer,
  });

  /// The identity that the certificate is issued by
  final String? issuedBy;

  /// The identity that the certificate is issued to
  final String? issuedTo;

  /// The date that must not be passed for the certificate to be valid
  final DateTime? validNotAfterDate;

  /// The date that must be passed for the certificate to be valid
  final DateTime? validNotBeforeDate;

  /// The original x509 certificate DER
  final Uint8List? x509CertificateDer;

  /// Creates a copy of the SSL certificate
  SslCertificate copy() {
    return SslCertificate(
      issuedBy: issuedBy,
      issuedTo: issuedTo,
      validNotAfterDate: validNotAfterDate,
      validNotBeforeDate: validNotBeforeDate,
      x509CertificateDer: x509CertificateDer == null
          ? null
          : Uint8List.fromList(x509CertificateDer!),
    );
  }
}
