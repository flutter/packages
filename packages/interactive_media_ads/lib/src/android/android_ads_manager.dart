import '../../interactive_media_ads.dart';
import '../platform_interface/platform_ads_manager.dart';
import '../platform_interface/platform_ads_manager_delegate.dart';
import 'interactive_media_ads.g.dart' as interactive_media_ads;

class AndroidAdsManager extends PlatformAdsManager {
  AndroidAdsManager(this.manager);

  final interactive_media_ads.AdsManager manager;

  PlatformAdsManagerDelegate? managerDelegate;

  @override
  Future<void> destroy() {
    return manager.destroy();
  }

  @override
  Future<void> init(AdsManagerInitParams params) {
    return manager.init();
  }

  @override
  Future<void> setAdsManagerDelegate(
    PlatformAdsManagerDelegate delegate,
  ) async {
    managerDelegate = delegate;
    _addListeners(WeakReference<AndroidAdsManager>(this));
  }

  @override
  Future<void> start(AdsManagerStartParams params) {
    return manager.start();
  }

  static void _addListeners(WeakReference<AndroidAdsManager> weakThis) {
    weakThis.target?.manager.addAdEventListener(
      interactive_media_ads.AdEventListener(
        onAdEvent: (_, interactive_media_ads.AdEvent event) {
          late final AdEventType eventType;

          switch (event.type) {
            case interactive_media_ads.AdEventType.allAdsCompleted:
              eventType = AdEventType.allAdsCompleted;
            case interactive_media_ads.AdEventType.completed:
              eventType = AdEventType.complete;
            case interactive_media_ads.AdEventType.contentPauseRequested:
              eventType = AdEventType.contentPauseRequested;
            case interactive_media_ads.AdEventType.contentResumeRequested:
              eventType = AdEventType.contentResumeRequested;
            case interactive_media_ads.AdEventType.loaded:
              eventType = AdEventType.loaded;
            case interactive_media_ads.AdEventType.unknown:
            case interactive_media_ads.AdEventType.adBreakReady:
            case interactive_media_ads.AdEventType.adBreakEnded:
            case interactive_media_ads.AdEventType.adBreakFetchError:
            case interactive_media_ads.AdEventType.adBreakStarted:
            case interactive_media_ads.AdEventType.adBuffering:
            case interactive_media_ads.AdEventType.adPeriodEnded:
            case interactive_media_ads.AdEventType.adPeriodStarted:
            case interactive_media_ads.AdEventType.adProgress:
            case interactive_media_ads.AdEventType.clicked:
            case interactive_media_ads.AdEventType.cuepointsChanged:
            case interactive_media_ads.AdEventType.firstQuartile:
            case interactive_media_ads.AdEventType.iconFallbackImageClosed:
            case interactive_media_ads.AdEventType.iconTapped:
            case interactive_media_ads.AdEventType.log:
            case interactive_media_ads.AdEventType.midpoint:
            case interactive_media_ads.AdEventType.paused:
            case interactive_media_ads.AdEventType.resumed:
            case interactive_media_ads.AdEventType.skippableStateChanged:
            case interactive_media_ads.AdEventType.skipped:
            case interactive_media_ads.AdEventType.started:
            case interactive_media_ads.AdEventType.tapped:
            case interactive_media_ads.AdEventType.thirdQuartile:
              return;
          }
          weakThis.target?.managerDelegate?.params.onAdEvent
              ?.call(AdEvent(type: eventType));
        },
      ),
    );
    weakThis.target?.manager.addAdErrorListener(
      interactive_media_ads.AdErrorListener(
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

          weakThis.target?.managerDelegate?.params.onAdErrorEvent?.call(
            AdErrorEvent(
              error: AdError(
                type: errorType,
                code: errorCode,
                message: event.error.message,
              ),
            ),
          );
        },
      ),
    );
  }
}

final class AndroidAdsManagerDelegate extends PlatformAdsManagerDelegate {
  AndroidAdsManagerDelegate(super.params) : super.implementation();
}
