// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Flutter
import Testing

@testable import url_launcher_ios

// Tests whether NSURL parsing is strict. When linking against the iOS 17 SDK or later,
// NSURL uses a more lenient parser which will not return nil.
private func urlParsingIsStrict() -> Bool {
  return URL(string: "b a d U R L") == nil
}

final class TestViewPresenter: ViewPresenter {
  public var presentedController: UIViewController?

  func present(
    _ viewControllerToPresent: UIViewController, animated: Bool, completion: (() -> Void)? = nil
  ) {
    presentedController = viewControllerToPresent
  }
}

final class StubViewPresenterProvider: ViewPresenterProvider {
  var viewPresenter: ViewPresenter?

  init(viewPresenter: ViewPresenter?) {
    self.viewPresenter = viewPresenter
  }
}

@MainActor
struct URLLauncherTests {

  private func createPlugin(
    launcher: FakeLauncher = FakeLauncher(), viewPresenter: ViewPresenter? = TestViewPresenter()
  ) -> URLLauncherPlugin {
    return URLLauncherPlugin(
      launcher: launcher,
      viewPresenterProvider: StubViewPresenterProvider(viewPresenter: viewPresenter))
  }

  @Test(arguments: [
    ("good://url", LaunchResult.success),
    ("bad://url", .failure),
  ])
  func canLaunch(url: String, expected: LaunchResult) {
    let result = createPlugin().canLaunchUrl(url: url)
    #expect(result == expected)
  }

  @Test func canLaunchFailureWithInvalidURL() {
    let result = createPlugin().canLaunchUrl(url: "urls can't have spaces")
    if urlParsingIsStrict() {
      #expect(result == .invalidUrl)
    } else {
      #expect(result == .failure)
    }
  }

  @Test(arguments: [
    ("good://url", LaunchResult.success),
    ("bad://url", .failure),
  ])
  func launch(url: String, expected: LaunchResult) async {
    await confirmation("completion called") { confirmed in
      createPlugin().launchUrl(url: url, universalLinksOnly: false) { result in
        switch result {
        case .success(let details):
          #expect(details == expected)
        case .failure(let error):
          Issue.record("Unexpected error: \(error)")
        }
        confirmed()
      }
    }
  }

  @Test func launchFailureWithInvalidURL() async {
    await confirmation("completion called") { confirmed in
      createPlugin().launchUrl(url: "urls can't have spaces", universalLinksOnly: false) { result in
        switch result {
        case .success(let details):
          if urlParsingIsStrict() {
            #expect(details == .invalidUrl)
          } else {
            #expect(details == .failure)
          }
        case .failure(let error):
          Issue.record("Unexpected error: \(error)")
        }
        confirmed()
      }
    }
  }

  @Test func launchWithoutUniversalLinks() async throws {
    let launcher = FakeLauncher()
    let plugin = createPlugin(launcher: launcher)

    await confirmation("completion called") { confirmed in
      plugin.launchUrl(url: "good://url", universalLinksOnly: false) { result in
        switch result {
        case .success(let details):
          #expect(details == .success)
        case .failure(let error):
          Issue.record("Unexpected error: \(error)")
        }
        confirmed()
      }
    }
    let passedOptions = try #require(launcher.passedOptions)
    #expect(passedOptions[.universalLinksOnly] as? Bool == false)
  }

  @Test func launchWithUniversalLinks() async throws {
    let launcher = FakeLauncher()
    let plugin = createPlugin(launcher: launcher)

    await confirmation("completion called") { confirmed in
      plugin.launchUrl(url: "good://url", universalLinksOnly: true) { result in
        switch result {
        case .success(let details):
          #expect(details == .success)
        case .failure(let error):
          Issue.record("Unexpected error: \(error)")
        }
        confirmed()
      }
    }
    let passedOptions = try #require(launcher.passedOptions)
    #expect(passedOptions[.universalLinksOnly] as? Bool == true)
  }

  @Test func launchSafariViewControllerWithClose() async {
    let launcher = FakeLauncher()
    let viewPresenter = TestViewPresenter()
    let plugin = createPlugin(launcher: launcher, viewPresenter: viewPresenter)

    await confirmation("completion called") { confirmed in
      plugin.openUrlInSafariViewController(url: "https://flutter.dev") { result in
        switch result {
        case .success(let details):
          #expect(details == .dismissed)
        case .failure(let error):
          Issue.record("Unexpected error: \(error)")
        }
        confirmed()
      }
      plugin.closeSafariViewController()
    }
    #expect(viewPresenter.presentedController != nil)
  }

  @Test func launchSafariViewControllerFailureWithNoViewPresenter() async {
    await confirmation("completion called") { confirmed in
      createPlugin(viewPresenter: nil).openUrlInSafariViewController(url: "https://flutter.dev") {
        result in
        switch result {
        case .success(let details):
          #expect(details == .noUI)
        case .failure(let error):
          Issue.record("Unexpected error: \(error)")
        }
        confirmed()
      }
    }
  }

}

final private class FakeLauncher: NSObject, Launcher {
  var passedOptions: [UIApplication.OpenExternalURLOptionsKey: Any]?

  func canOpenURL(_ url: URL) -> Bool {
    url.scheme == "good"
  }

  func open(
    _ url: URL,
    options: [UIApplication.OpenExternalURLOptionsKey: Any],
    completionHandler completion: ((Bool) -> Void)?
  ) {
    self.passedOptions = options
    completion?(url.scheme == "good")
  }
}
