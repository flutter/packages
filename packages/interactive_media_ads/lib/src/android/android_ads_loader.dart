import '../../interactive_media_ads.dart';
import '../platform_interface/platform_ads_loader.dart';
import 'android_ad_display_container.dart';
import 'android_ads_manager.dart';
import 'interactive_media_ads.g.dart' as interactive_media_ads;

final class AndroidAdsLoader extends PlatformAdsLoader {
  AndroidAdsLoader(
    PlatformAdsLoaderCreationParams params,
  )   : assert(params.container is AndroidAdDisplayContainer),
        super.implementation(params) {
    adsLoaderFuture = _createAdsLoader();
  }

  late Future<interactive_media_ads.AdsLoader> adsLoaderFuture;

  final interactive_media_ads.ImaSdkFactory sdkFactory =
      interactive_media_ads.ImaSdkFactory.instance;

  Future<interactive_media_ads.AdsLoader> _createAdsLoader() async {
    final interactive_media_ads.ImaSdkSettings settings =
        await sdkFactory.createImaSdkSettings();

    final interactive_media_ads.AdsLoader adsLoader =
        await interactive_media_ads.ImaSdkFactory.instance.createAdsLoader(
      settings,
      (params.container as AndroidAdDisplayContainer).adDisplayContainer,
    );

    _addListeners(
      WeakReference<AndroidAdsLoader>(this),
      adsLoader,
    );

    return adsLoader;
  }

  static void _addListeners(
    WeakReference<AndroidAdsLoader> weakThis,
    interactive_media_ads.AdsLoader adsLoader,
  ) {
    adsLoader.addAdsLoadedListener(interactive_media_ads.AdsLoadedListener(
      onAdsManagerLoaded: (
        _,
        interactive_media_ads.AdsManagerLoadedEvent event,
      ) {
        weakThis.target?.params.onAdsLoaded(
          PlatformOnAdsLoadedData(manager: AndroidAdsManager(event.manager)),
        );
      },
    ));
    adsLoader.addAdErrorListener(interactive_media_ads.AdErrorListener(
      onAdError: (_, interactive_media_ads.AdErrorEvent event) {
        final AdErrorType errorType = switch (event.error.errorType) {
          interactive_media_ads.AdErrorType.load => AdErrorType.loading,
          interactive_media_ads.AdErrorType.play => AdErrorType.playing,
          interactive_media_ads.AdErrorType.unknown => AdErrorType.unknown,
        };

        final AdErrorCode errorCode = switch (event.error.errorCode) {
          interactive_media_ads.AdErrorCode.adsPlayerWasNotProvided =>
            AdErrorCode.adsPlayerNotProvided,
          interactive_media_ads.AdErrorCode.unknownError =>
            AdErrorCode.unknownError,
        };

        weakThis.target?.params.onAdsLoadError(
          AdsLoadErrorData(
            error: AdError(
              type: errorType,
              code: errorCode,
              message: event.error.message,
            ),
          ),
        );
      },
    ));
  }

  @override
  Future<void> contentComplete() async {}

  @override
  Future<void> requestAds(AdsRequest request) async {
    final interactive_media_ads.AdsLoader adsLoader = await adsLoaderFuture;

    final interactive_media_ads.AdsRequest request =
        await sdkFactory.createAdsRequest();

    await adsLoader.requestAds(request);
  }
}
