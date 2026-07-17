import Flutter
import GoogleMaps
import Testing

@testable import google_maps_flutter_ios

class StubTileReceiver: NSObject, GMSTileReceiver {
  func receiveTileWith(x: UInt, y: UInt, zoom: UInt, image: UIImage?) {
    // No-op.
  }
}

// A tile provider that expects a single call to
// tileWithOverlayIdentifier:location:zoom:completion: on the main thread,
// and then confirms it.
class TestTileProvider: NSObject, FGMTileProviderDelegate {
  var onTileCalled: () -> Void

  init(onTileCalled: @escaping () -> Void) {
    self.onTileCalled = onTileCalled
    super.init()
  }

  func tile(
    withOverlayIdentifier tileOverlayId: String,
    location: FGMPlatformPoint,
    zoom: Int,
    completion: @escaping (FGMPlatformTile?, FlutterError?) -> Void
  ) {
    #expect(Thread.isMainThread)
    onTileCalled()
  }
}

@MainActor struct TileProviderControllerTests {

  @Test func callChannelOnPlatformThread() async {
    var continuationToResume: CheckedContinuation<Void, Never>?

    let tileProvider = TestTileProvider {
      continuationToResume?.resume()
    }
    let controller = FGMTileProviderController(
      tileOverlayIdentifier: "foo",
      tileProvider: tileProvider
    )
    #expect(controller != nil)

    await withCheckedContinuation { continuation in
      continuationToResume = continuation
      controller.requestTileFor(x: 0, y: 0, zoom: 0, receiver: StubTileReceiver())
    }
  }
}
