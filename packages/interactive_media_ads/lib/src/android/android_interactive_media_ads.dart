import '../platform_interface/interactive_media_ads_platform.dart';
import '../platform_interface/platform_ad_display_container.dart';
import '../platform_interface/platform_ads_loader.dart';
import '../platform_interface/platform_ads_manager_delegate.dart';
import 'android_ad_display_container.dart';
import 'android_ads_loader.dart';
import 'android_ads_manager.dart';

final class AndroidInteractiveMediaAds extends InteractiveMediaAdsPlatform {
  @override
  PlatformAdDisplayContainer createPlatformAdDisplayContainer(
    PlatformAdDisplayContainerCreationParams params,
  ) {
    return AndroidAdDisplayContainer(params);
  }

  @override
  PlatformAdsLoader createPlatformAdsLoader(
    PlatformAdsLoaderCreationParams params,
  ) {
    return AndroidAdsLoader(params);
  }

  @override
  PlatformAdsManagerDelegate createPlatformAdsManagerDelegate(
    PlatformAdsManagerDelegateCreationParams params,
  ) {
    return AndroidAdsManagerDelegate(params);
  }
}
