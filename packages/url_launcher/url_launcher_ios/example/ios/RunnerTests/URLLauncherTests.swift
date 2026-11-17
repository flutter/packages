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
  func canLaunch(url: String, expected: LaunchResult) throws {
    let result = try createPlugin().canLaunchUrl(url: url)
    #expect(result == expected)
  }

  @Test func canLaunchFailureWithInvalidURL() throws {
    let result = try createPlugin().canLaunchUrl(url: "urls can't have spaces")
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
  func launch(url: String, expected: LaunchResult) async throws {
    let result = try await createPlugin().launchUrl(url: url, universalLinksOnly: false)
    #expect(result == expected)
  }

  @Test func launchFailureWithInvalidURL() async throws {
    let result = try await createPlugin().launchUrl(
      url: "urls can't have spaces", universalLinksOnly: false)
    if urlParsingIsStrict() {
      #expect(result == .invalidUrl)
    } else {
      #expect(result == .failure)
    }
  }

  @Test func launchWithoutUniversalLinks() async throws {
    let launcher = FakeLauncher()
    let plugin = createPlugin(launcher: launcher)

    let result = try await plugin.launchUrl(url: "good://url", universalLinksOnly: false)
    #expect(result == .success)
    let passedOptions = try #require(launcher.passedOptions)
    #expect(passedOptions[.universalLinksOnly] as? Bool == false)
  }

  @Test func launchWithUniversalLinks() async throws {
    let launcher = FakeLauncher()
    let plugin = createPlugin(launcher: launcher)

    let result = try await plugin.launchUrl(url: "good://url", universalLinksOnly: true)
    #expect(result == .success)
    let passedOptions = try #require(launcher.passedOptions)
    #expect(passedOptions[.universalLinksOnly] as? Bool == true)
  }

  @Test func launchSafariViewControllerWithClose() async throws {
    let launcher = FakeLauncher()
    let viewPresenter = TestViewPresenter()
    let plugin = createPlugin(launcher: launcher, viewPresenter: viewPresenter)

    let resultTask = Task {
      try await plugin.openUrlInSafariViewController(url: "https://flutter.dev")
    }
    while viewPresenter.presentedController == nil {
      await Task.yield()
    }
    try plugin.closeSafariViewController()
    let result = try await resultTask.value
    #expect(result == .dismissed)
    #expect(viewPresenter.presentedController != nil)
  }

  @Test func launchSafariViewControllerFailureWithNoViewPresenter() async throws {
    let result = try await createPlugin(viewPresenter: nil).openUrlInSafariViewController(
      url: "https://flutter.dev")
    #expect(result == .noUI)
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
