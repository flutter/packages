// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Flutter
import GoogleMaps
import Testing

@testable import google_maps_flutter_ios_sdk10

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

    await withCheckedContinuation { continuation in
      continuationToResume = continuation
      controller.requestTileFor(x: 0, y: 0, zoom: 0, receiver: StubTileReceiver())
    }
  }
}
