package dev.flutter.packages.interactive_media_ads

import com.google.ads.interactivemedia.v3.api.AdError

class AdErrorProxyApi(pigeonRegistrar: PigeonProxyApiRegistrar) :
    PigeonApiAdError(pigeonRegistrar) {
  override fun errorCode(pigeon_instance: AdError): AdErrorCode {
    return when (pigeon_instance.errorCode) {
      AdError.AdErrorCode.ADS_PLAYER_NOT_PROVIDED -> AdErrorCode.ADS_PLAYER_WAS_NOT_PROVIDED
      else -> AdErrorCode.UNKNOWN_ERROR
    }
  }

  override fun errorCodeNumber(pigeon_instance: AdError): Long {
    return pigeon_instance.errorCodeNumber.toLong()
  }

  override fun errorType(pigeon_instance: AdError): AdErrorType {
    return when (pigeon_instance.errorType) {
      AdError.AdErrorType.LOAD -> AdErrorType.LOAD
      AdError.AdErrorType.PLAY -> AdErrorType.PLAY
      else -> AdErrorType.UNKNOWN
    }
  }

  override fun message(pigeon_instance: AdError): String {
    return pigeon_instance.message
  }
}
