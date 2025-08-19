/// Simple data object containing universal ad ID information.
base class PlatformUniversalAdId {
  PlatformUniversalAdId({required this.adIDValue, required this.adIDRegistry});

  /// The universal ad ID value.
  ///
  /// This will be “unknown” if it isn’t defined by the ad.
  final String adIDValue;

  /// The universal ad ID registry with which the value is registered.
  ///
  /// This will be “unknown” if it isn’t defined by the ad.
  final String adIDRegistry;
}
