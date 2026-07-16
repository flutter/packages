// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import XCTest
import GoogleMaps
import Flutter
@testable import google_maps_flutter_ios

class StubTileReceiver: NSObject, GMSTileReceiver {
  func receiveTileWith(x: UInt, y: UInt, zoom: UInt, image: UIImage?) {
    // No-op.
  }
}

// A tile provider that expects a single call to
// tileWithOverlayIdentifier:location:zoom:completion: on the main thread,
// and then fulfills the expectation.
class TestTileProvider: NSObject, FGMTileProviderDelegate {
  var expectation: XCTestExpectation

  init(expectation: XCTestExpectation) {
    self.expectation = expectation
    super.init()
  }

  func tile(
    withOverlayIdentifier tileOverlayId: String,
    location: FGMPlatformPoint,
    zoom: Int,
    completion: @escaping (FGMPlatformTile?, FlutterError?) -> Void
  ) {
    XCTAssertTrue(Thread.isMainThread)
    expectation.fulfill()
  }
}

class TileProviderControllerTests: XCTestCase {

  func testCallChannelOnPlatformThread() {
    let expectation = self.expectation(description: "invokeMethod")
    let tileProvider = TestTileProvider(expectation: expectation)
    let controller = FGMTileProviderController(
      tileOverlayIdentifier: "foo",
      tileProvider: tileProvider
    )
    XCTAssertNotNil(controller)
    controller.requestTileFor(x: 0, y: 0, zoom: 0, receiver: StubTileReceiver())
    wait(for: [expectation], timeout: 10.0)
  }
}
