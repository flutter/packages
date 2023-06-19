enum AspectRatioPreset {
  /// 4:3
  /// Only supported in photo capture mode.
  standard,

  /// 16:9
  widescreen,
}

/// Returns the aspect ratio preset as a String.
///
String serializeAspectRatioPreset(AspectRatioPreset aspectRatioPreset) {
  switch (aspectRatioPreset) {
    case AspectRatioPreset.standard:
      return 'standard';
    case AspectRatioPreset.widescreen:
      return 'widescreen';
  }
}

/// Returns the aspect ratio preset for a given String.
///
AspectRatioPreset deserializeAspectRatioPreset(String str) {
  switch (str) {
    case 'standard':
      return AspectRatioPreset.standard;
    case 'widescreen':
      return AspectRatioPreset.widescreen;
    default:
      throw ArgumentError('"$str" is not a valid AspectRatioPreset value');
  }
}
