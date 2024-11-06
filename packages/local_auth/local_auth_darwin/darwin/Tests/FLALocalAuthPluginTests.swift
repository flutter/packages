// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import LocalAuthentication
import XCTest

@testable import local_auth_darwin

// Set a long timeout to avoid flake due to slow CI.
private let timeout: TimeInterval = 30.0

/// A context factory that returns preset contexts.
class MockAuthContext: AuthContextProtocol {
    var biometryType: LABiometryType

    var canEvaluatePolicyReturnValue: Bool = true
    var evaluatePolicyResult: (Bool, NSError?) = (true, nil)
    var localizedFallbackTitle: String?

    func canEvaluatePolicy(_ policy: LAPolicy, error: NSErrorPointer) -> Bool {
        return canEvaluatePolicyReturnValue
    }

    func evaluatePolicy(
        _ policy: LAPolicy, localizedReason: String, reply: @escaping (Bool, (any Error)?) -> Void
    ) {
        reply(evaluatePolicyResult.0, evaluatePolicyResult.1)
    }

    init(biometryType: LABiometryType = .none) {
            self.biometryType = biometryType
        }
}

class MockAlertController: AlertControllerProtocol {
    var showAlertCalled = false
    var showAlertCompletionResult: Bool = false

    func showAlert(
        message: String,
        dismissTitle dismissButtonTitle: String,
        openSettingsTitle openSettingsButtonTitle: String?,
        completion: @escaping (Bool) -> Void
    ) {
        showAlertCalled = true
        completion(showAlertCompletionResult)
    }
}

class LocalAuthPluginTests: XCTestCase {
    var plugin: LocalAuthPlugin!
    var mockAuthContext: MockAuthContext!
    var mockAlertController: MockAlertController!

    override func setUp() {
        super.setUp()
        mockAuthContext = MockAuthContext()
        mockAlertController = MockAlertController()
        plugin = LocalAuthPlugin(authContext: mockAuthContext, alertController: mockAlertController)
    }

    func testAuthenticationSuccess() {
        mockAuthContext.evaluatePolicyResult = (true, nil)

        let expectation = self.expectation(description: "Authentication completion")
        let authStrings = AuthStrings(
            reason: "Test Reason",
            lockOut: "Locked out",
            goToSettingsButton: "Go to Settings",
            goToSettingsDescription: "Go to settings to enable biometrics",
            cancelButton: "Cancel"
        )

        plugin.authenticate(
            options: AuthOptions(biometricOnly: true, sticky: false, useErrorDialogs: true),
            strings: authStrings
        ) { result in
            if case .success(let details) = result {
                XCTAssertEqual(details.result, .success)
            } else {
                XCTFail("Expected success result")
            }
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1)
    }
}
