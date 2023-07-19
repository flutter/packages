//// Copyright 2013 The Flutter Authors. All rights reserved.
//// Use of this source code is governed by a BSD-style license that can be
//// found in the LICENSE file.
//
//import Foundation
//@testable import local_auth_ios
//import LocalAuthentication
//import XCTest
//
//class StubAuthContextFactory: NSObject, AuthContextFactory {
//    var contexts: [LAContext]
//
//    init(contexts: [LAContext]) {
//        self.contexts = contexts
//    }
//
//    func createAuthContext() -> LAContext {
//        precondition(!contexts.isEmpty, "Insufficient test contexts provided")
//        let context = contexts.removeFirst()
//        return context
//    }
//}
//
//class LocalAuthPluginTests: XCTestCase {
//    private let kTimeout: TimeInterval = 30.0
//
//    func testSuccessfullAuthWithBiometrics() {
//        let mockAuthContext = LAContext()
//        let plugin = LocalAuthPlugin()
//
//        let policy = LAPolicy.deviceOwnerAuthenticationWithBiometrics
//        let strings = createAuthStrings()
//        XCTAssertTrue(mockAuthContext.canEvaluatePolicy(policy, error: nil))
//
//        let backgroundThreadReplyCaller: @convention(block) (NSInvocation) -> Void = { invocation in
//            var reply: ((Bool, Error?) -> Void)?
//            invocation.getArgument(&reply, at: 4)
//
//            DispatchQueue.global(qos: .background).async {
//                reply?(true, nil)
//            }
//        }
//        OCMStub(mockAuthContext.evaluatePolicy(policy, localizedReason: strings.reason, reply: any())).do(backgroundThreadReplyCaller)
//
//        let expectation = self.expectation(description: "Result is called")
//        plugin.authenticate(withOptions: AuthOptions.make(withBiometricOnly: true, sticky: false, useErrorDialogs: false), strings: strings) { resultDetails, error in
//            XCTAssertTrue(Thread.isMainThread)
//            XCTAssertEqual(resultDetails?.result, AuthResult.success)
//            XCTAssertNil(error)
//            expectation.fulfill()
//        }
//
//        waitForExpectations(timeout: kTimeout, handler: nil)
//    }
//}
