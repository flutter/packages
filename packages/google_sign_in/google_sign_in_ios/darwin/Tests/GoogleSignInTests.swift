// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import GoogleSignIn
import XCTest
import google_sign_in_ios

#if os(OSX)
  import FlutterMacOS
#else
  import Flutter
#endif

// Test implementation of FSIViewProvider.
class TestViewProvider: NSObject, FSIViewProvider {
  #if os(OSX)
    // The view containing the Flutter content.
    var view: NSView?
  #else
    // The view controller containing the Flutter content.
    var viewController: UIViewController?
  #endif
}

// Test implementation of FSIGIDSignIn.
class TestSignIn: NSObject, FSIGIDSignIn {
  var configuration: GIDConfiguration?

  // To cause methods to throw an exception.
  var exception: NSException?

  // Results to use in completion callbacks.
  var user: FSIGIDGoogleUser?
  var error: Error?
  var signInResult: FSIGIDSignInResult?

  // Passed parameters.
  var hint: String?
  var additionalScopes: [String]?
  var nonce: String?
  #if os(iOS) || targetEnvironment(macCatalyst)
    var presentingViewController: UIViewController?
  #else
    var presentingWindow: NSWindow?
  #endif

  // Whether signOut was called.
  var signOutCalled = false

  func handle(_ url: URL) -> Bool {
    return true
  }

  func restorePreviousSignIn(completion: ((FSIGIDGoogleUser?, Error?) -> Void)?) {
    if let exception = exception {
      exception.raise()
    }
    completion?(user, user != nil ? nil : error)
  }

  func signOut() {
    signOutCalled = true
  }

  func disconnect(completion: ((Error?) -> Void)?) {
    if let exception = exception {
      exception.raise()
    }
    completion?(error)
  }

  #if os(iOS) || targetEnvironment(macCatalyst)
    func signIn(
      withPresenting presentingViewController: UIViewController,
      hint: String?,
      additionalScopes: [String]?,
      nonce: String?,
      completion: ((FSIGIDSignInResult?, Error?) -> Void)?
    ) {
      if let exception = exception {
        exception.raise()
      }
      self.presentingViewController = presentingViewController
      self.hint = hint
      self.additionalScopes = additionalScopes
      self.nonce = nonce
      completion?(signInResult, signInResult != nil ? nil : error)
    }
  #else
    func signIn(
      withPresenting presentingWindow: NSWindow,
      hint: String?,
      additionalScopes: [String]?,
      nonce: String?,
      completion: ((FSIGIDSignInResult?, Error?) -> Void)?
    ) {
      if let exception = exception {
        exception.raise()
      }
      self.presentingWindow = presentingWindow
      self.hint = hint
      self.additionalScopes = additionalScopes
      self.nonce = nonce
      completion?(signInResult, signInResult != nil ? nil : error)
    }
  #endif
}

// Test implementation of FSIGIDProfileData.
class TestProfileData: NSObject, FSIGIDProfileData {
  var email: String
  var name: String
  // A URL to return from imageURLWithDimension:.
  var imageURL: URL?

  init(name: String, email: String, imageURL: URL?) {
    self.name = name
    self.email = email
    self.imageURL = imageURL
  }

  var hasImage: Bool {
    return imageURL != nil
  }

  func imageURL(withDimension dimension: UInt) -> URL? {
    return imageURL
  }
}

// Test implementation of FSIGIDToken.
class TestToken: NSObject, FSIGIDToken {
  var tokenString: String
  var expirationDate: Date?

  init(_ token: String) {
    tokenString = token
  }
}

// Test implementation of FSIGIDSignInResult.
class TestSignInResult: NSObject, FSIGIDSignInResult {
  var user: FSIGIDGoogleUser
  var serverAuthCode: String?

  init(user: FSIGIDGoogleUser, serverAuthCode: String? = nil) {
    self.user = user
    self.serverAuthCode = serverAuthCode
  }
}

// Test implementation of FSIGIDGoogleUser.
class TestGoogleUser: NSObject, FSIGIDGoogleUser {
  var userID: String?
  var profile: FSIGIDProfileData?
  var grantedScopes: [String]?
  var accessToken: FSIGIDToken = TestToken("Acces")
  var refreshToken: FSIGIDToken = TestToken("Refresh")
  var idToken: FSIGIDToken?

  // An exception to throw from methods.
  var exception: NSException?

  // The result to return from addScopes:presentingViewController:completion:.
  var result: FSIGIDSignInResult?

  // The error to return from methods.
  var error: Error?

  // Values passed as parameters.
  var requestedScopes: [String]?
  #if os(iOS) || targetEnvironment(macCatalyst)
    var presentingViewController: UIViewController?
  #else
    var presentingWindow: NSWindow?
  #endif

  init(_ userIdentifier: String) {
    userID = userIdentifier
  }

  func refreshTokensIfNeeded(completion: @escaping (FSIGIDGoogleUser?, Error?) -> Void) {
    if let exception = exception {
      exception.raise()
    }
    completion(self.error == nil ? self : nil, self.error)
  }

  #if os(iOS) || targetEnvironment(macCatalyst)
    func addScopes(
      _ scopes: [String],
      presenting presentingViewController: UIViewController,
      completion: ((FSIGIDSignInResult?, Error?) -> Void)?
    ) {
      self.requestedScopes = scopes
      self.presentingViewController = presentingViewController
      if let exception = exception {
        exception.raise()
      }
      completion?(self.error == nil ? self.result : nil, self.error)
    }
  #elseif os(OSX)
    func addScopes(
      _ scopes: [String],
      presenting presentingWindow: NSWindow,
      completion: ((FSIGIDSignInResult?, Error?) -> Void)?
    ) {
      self.requestedScopes = scopes
      self.presentingWindow = presentingWindow
      if let exception = exception {
        exception.raise()
      }
      completion?(self.error == nil ? self.result : nil, self.error)
    }
  #endif
}

class FLTGoogleSignInPluginTest: XCTestCase {

  var viewProvider: TestViewProvider!
  var plugin: FLTGoogleSignInPlugin!
  var fakeSignIn: TestSignIn!
  var googleServiceInfo: [String: Any]?

  override func setUp() {
    super.setUp()
    viewProvider = TestViewProvider()
    fakeSignIn = TestSignIn()
    plugin = FLTGoogleSignInPlugin(signIn: fakeSignIn, viewProvider: viewProvider)

    if let plistPath = Bundle(for: type(of: self)).path(
      forResource: "GoogleService-Info", ofType: "plist")
    {
      googleServiceInfo = NSDictionary(contentsOfFile: plistPath) as? [String: Any]
    }
  }

  func testSignOut() {
    var error: FlutterError?
    plugin.signOutWithError(&error)
    XCTAssertTrue(fakeSignIn.signOutCalled)
    XCTAssertNil(error)
  }

  func testDisconnect() async {
    let expectation = self.expectation(description: "expect result returns true")
    plugin.disconnect { error in
      XCTAssertNil(error)
      expectation.fulfill()
    }
    await fulfillment(of: [expectation], timeout: 5.0)
  }

  // MARK: - Configure

  func testInitNoClientIdNoError() {
    // Init plugin without GoogleService-Info.plist.
    plugin = FLTGoogleSignInPlugin(
      signIn: fakeSignIn, viewProvider: viewProvider, googleServiceProperties: nil)

    // init call does not provide a clientId.
    let params = FSIPlatformConfigurationParams.make(
      withClientId: nil,
      serverClientId: nil,
      hostedDomain: nil)

    var error: FlutterError?
    plugin.configure(withParameters: params, error: &error)
    XCTAssertNil(error)
  }

  func testInitGoogleServiceInfoPlist() {
    plugin = FLTGoogleSignInPlugin(
      signIn: fakeSignIn, viewProvider: viewProvider, googleServiceProperties: googleServiceInfo)
    let params = FSIPlatformConfigurationParams.make(
      withClientId: nil,
      serverClientId: nil,
      hostedDomain: "example.com")

    var error: FlutterError?
    plugin.configure(withParameters: params, error: &error)
    XCTAssertNil(error)
    XCTAssertEqual(fakeSignIn.configuration?.hostedDomain, "example.com")
    // Set in example app GoogleService-Info.plist.
    XCTAssertEqual(
      fakeSignIn.configuration?.clientID,
      "479882132969-9i9aqik3jfjd7qhci1nqf0bm2g71rm1u.apps.googleusercontent.com")
    XCTAssertEqual(fakeSignIn.configuration?.serverClientID, "YOUR_SERVER_CLIENT_ID")
  }

  func testInitDynamicClientIdNullDomain() {
    // Init plugin without GoogleService-Info.plist.
    plugin = FLTGoogleSignInPlugin(
      signIn: fakeSignIn, viewProvider: viewProvider, googleServiceProperties: nil)

    let params = FSIPlatformConfigurationParams.make(
      withClientId: "mockClientId",
      serverClientId: nil,
      hostedDomain: nil)

    var error: FlutterError?
    plugin.configure(withParameters: params, error: &error)
    XCTAssertNil(error)
    XCTAssertNil(fakeSignIn.configuration?.hostedDomain)
    XCTAssertEqual(fakeSignIn.configuration?.clientID, "mockClientId")
    XCTAssertNil(fakeSignIn.configuration?.serverClientID)
  }

  func testInitDynamicServerClientIdNullDomain() {
    // Init plugin without GoogleService-Info.plist.
    plugin = FLTGoogleSignInPlugin(
      signIn: fakeSignIn, viewProvider: viewProvider, googleServiceProperties: googleServiceInfo)
    let params = FSIPlatformConfigurationParams.make(
      withClientId: nil,
      serverClientId: "mockServerClientId",
      hostedDomain: nil)

    var error: FlutterError?
    plugin.configure(withParameters: params, error: &error)
    XCTAssertNil(error)
    XCTAssertNil(fakeSignIn.configuration?.hostedDomain)
    // Set in example app GoogleService-Info.plist.
    XCTAssertEqual(
      fakeSignIn.configuration?.clientID,
      "479882132969-9i9aqik3jfjd7qhci1nqf0bm2g71rm1u.apps.googleusercontent.com")
    // Overridden by params.
    XCTAssertEqual(fakeSignIn.configuration?.serverClientID, "mockServerClientId")
  }

  func testInitInfoPlist() {
    let params = FSIPlatformConfigurationParams.make(
      withClientId: nil,
      serverClientId: nil,
      hostedDomain: "example.com")

    var error: FlutterError?
    plugin.configure(withParameters: params, error: &error)
    XCTAssertNil(error)
    // No configuration should be set, allowing the SDK to use its default behavior
    // (which is to load configuration information from Info.plist).
    XCTAssertNil(fakeSignIn.configuration)
  }

  // MARK: - restorePreviousSignIn

  func testSignInSilently() async {
    let fakeUser = TestGoogleUser("mockID")
      let fakeUserProfile = TestProfileData(
        name: "mockDisplay", email: "mock@example.com",
        imageURL: URL(string: "https://example.com/profile.png"))
      fakeUser.profile = fakeUserProfile
    fakeSignIn.user = fakeUser

    let expectation = self.expectation(description: "completion called")
    plugin.restorePreviousSignIn { result, error in
      XCTAssertNil(error)
      XCTAssertNil(result?.error)
      XCTAssertNotNil(result?.success)
      let user = result?.success?.user
        XCTAssertEqual(user?.displayName, fakeUserProfile.name)
        XCTAssertEqual(user?.email, fakeUserProfile.email)
        XCTAssertEqual(user?.userId, fakeUser.userID)
        XCTAssertEqual(user?.photoUrl, fakeUserProfile.imageURL?.absoluteString)
        XCTAssertEqual(result?.success?.accessToken, fakeUser.accessToken.tokenString)
        XCTAssertNil(result?.success?.serverAuthCode)
      expectation.fulfill()
    }
      await fulfillment(of: [expectation], timeout: 5.0)
  }

  func testRestorePreviousSignInWithError() async {
    let sdkError = NSError(
      domain: kGIDSignInErrorDomain, code: GIDSignInError.hasNoAuthInKeychain.rawValue,
      userInfo: nil)
    fakeSignIn.error = sdkError

    let expectation = self.expectation(description: "completion called")
    plugin.restorePreviousSignIn { result, error in
      XCTAssertNil(error)
      XCTAssertNil(result?.success)
      XCTAssertEqual(result?.error?.type, FSIGoogleSignInErrorCode.noAuthInKeychain)
      expectation.fulfill()
    }
      await fulfillment(of: [expectation], timeout: 5.0)
  }

  // MARK: - signIn

  func testSignIn() async {
    plugin = FLTGoogleSignInPlugin(
      signIn: fakeSignIn, viewProvider: viewProvider, googleServiceProperties: googleServiceInfo)
    let fakeUser = TestGoogleUser("mockID")
    let fakeUserProfile = TestProfileData(
      name: "mockDisplay", email: "mock@example.com",
      imageURL: URL(string: "https://example.com/profile.png"))

    let accessToken = "mockAccessToken"
    let serverAuthCode = "mockAuthCode"
    fakeUser.profile = fakeUserProfile
    fakeUser.accessToken = TestToken(accessToken)

    let fakeSignInResult = TestSignInResult(user: fakeUser, serverAuthCode: serverAuthCode)

    fakeSignIn.signInResult = fakeSignInResult

    let expectation = self.expectation(description: "completion called")
    plugin.signIn(withScopeHint: [], nonce: nil) { result, error in
      XCTAssertNil(error)
      let user = result?.success?.user
      XCTAssertEqual(user?.displayName, "mockDisplay")
      XCTAssertEqual(user?.email, "mock@example.com")
      XCTAssertEqual(user?.userId, "mockID")
      XCTAssertEqual(user?.photoUrl, "https://example.com/profile.png")
      XCTAssertEqual(result?.success?.accessToken, accessToken)
      XCTAssertEqual(result?.success?.serverAuthCode, serverAuthCode)
      expectation.fulfill()
    }
      await fulfillment(of: [expectation], timeout: 5.0)
  }

  func testSignInWithScopeHint() async {
    var initializationError: FlutterError?
    plugin.configure(
      withParameters: FSIPlatformConfigurationParams.make(
        withClientId: nil,
        serverClientId: nil,
        hostedDomain: nil),
      error: &initializationError)
    XCTAssertNil(initializationError)

    let fakeUser = TestGoogleUser("mockID")
    let fakeSignInResult = TestSignInResult(user: fakeUser)

    let requestedScopes = ["scope1", "scope2"]
    fakeSignIn.signInResult = fakeSignInResult

    let expectation = self.expectation(description: "completion called")
    plugin.signIn(withScopeHint: requestedScopes, nonce: nil) { result, error in
      XCTAssertNil(error)
      XCTAssertNil(result?.error)
      XCTAssertEqual(result?.success?.user.userId, "mockID")
      expectation.fulfill()
    }
      await fulfillment(of: [expectation], timeout: 5.0)

    XCTAssertEqual(Set(fakeSignIn.additionalScopes ?? []), Set(requestedScopes))
  }

  func testSignInWithNonce() async {
    var initializationError: FlutterError?
    plugin.configure(
      withParameters: FSIPlatformConfigurationParams.make(
        withClientId: nil,
        serverClientId: nil,
        hostedDomain: nil),
      error: &initializationError)
    XCTAssertNil(initializationError)

    let fakeUser = TestGoogleUser("mockID")
    let fakeSignInResult = TestSignInResult(user: fakeUser)

    let nonce = "A nonce"
    fakeSignIn.signInResult = fakeSignInResult

    let expectation = self.expectation(description: "completion called")
    plugin.signIn(withScopeHint: [], nonce: nonce) { result, error in
      XCTAssertNil(error)
      XCTAssertNil(result?.error)
      XCTAssertEqual(result?.success?.user.userId, "mockID")
      expectation.fulfill()
    }
      await fulfillment(of: [expectation], timeout: 5.0)

    XCTAssertEqual(fakeSignIn.nonce, nonce)
  }

  func testSignInAlreadyGranted() async {
    let fakeUser = TestGoogleUser("mockID")
    let fakeSignInResult = TestSignInResult(user: fakeUser)

    fakeSignIn.signInResult = fakeSignInResult

    let sdkError = NSError(
      domain: kGIDSignInErrorDomain, code: GIDSignInError.scopesAlreadyGranted.rawValue,
      userInfo: nil)
    fakeSignIn.error = sdkError

    let expectation = self.expectation(description: "completion called")
    plugin.signIn(withScopeHint: [], nonce: nil) { result, error in
      XCTAssertNil(error)
      XCTAssertNil(result?.error)
      XCTAssertEqual(result?.success?.user.userId, "mockID")
      expectation.fulfill()
    }
      await fulfillment(of: [expectation], timeout: 5.0)
  }

  func testSignInError() async {
    let sdkError = NSError(
      domain: kGIDSignInErrorDomain, code: GIDSignInError.canceled.rawValue, userInfo: nil)
    fakeSignIn.error = sdkError

    let expectation = self.expectation(description: "completion called")
    plugin.signIn(withScopeHint: [], nonce: nil) { result, error in
      // Known errors from the SDK are returned as structured data, not
      // FlutterError.
      XCTAssertNil(error)
      XCTAssertNil(result?.success)
      XCTAssertEqual(result?.error?.type, FSIGoogleSignInErrorCode.canceled)
      expectation.fulfill()
    }
      await fulfillment(of: [expectation], timeout: 5.0)
  }

  func testSignInExceptionReturnsError() async {
    fakeSignIn.exception = NSException(
      name: NSExceptionName(rawValue: "MockName"),
      reason: "MockReason",
      userInfo: nil)

    let expectation = self.expectation(description: "completion called")
    plugin.signIn(withScopeHint: [], nonce: nil) { result, error in
      // Unexpected errors, such as runtime exceptions, are returned as
      // FlutterError.
      XCTAssertNil(result)
      XCTAssertEqual(error?.code, "google_sign_in")
      XCTAssertEqual(error?.message, "MockReason")
      XCTAssertEqual(error?.details as! String, "MockName")
      expectation.fulfill()
    }
      await fulfillment(of: [expectation], timeout: 5.0)
  }

  // MARK: - refreshedAuthorizationTokens

  func testRefreshTokens() async {
    let fakeUser = addSignedInUser()
    // TestGoogleUser passes itself as the result's user property, so set the
    // fake result data on this object.
    fakeUser.idToken = TestToken("mockIdToken")
    fakeUser.accessToken = TestToken("mockAccessToken")

    let expectation = self.expectation(description: "completion called")
    plugin.refreshedAuthorizationTokens(forUser: fakeUser.userID!) { result, error in
      XCTAssertNil(error)
      XCTAssertNil(result?.error)
      XCTAssertEqual(result?.success?.user.idToken, "mockIdToken")
      XCTAssertEqual(result?.success?.accessToken, "mockAccessToken")
      expectation.fulfill()
    }
      await fulfillment(of: [expectation], timeout: 5.0)
  }

  func testRefreshTokensUnkownUser() async {
    let expectation = self.expectation(description: "completion called")
    plugin.refreshedAuthorizationTokens(forUser: "unknownUser") { result, error in
      XCTAssertNil(error)
      XCTAssertNil(result?.success)
      XCTAssertEqual(result?.error?.type, FSIGoogleSignInErrorCode.userMismatch)
      XCTAssertEqual(result?.error?.message, "The user is no longer signed in.")
      expectation.fulfill()
    }
      await fulfillment(of: [expectation], timeout: 5.0)
  }

  func testRefreshTokensNoAuthKeychainError() async {
    let fakeUser = addSignedInUser()

    let sdkError = NSError(
      domain: kGIDSignInErrorDomain, code: GIDSignInError.hasNoAuthInKeychain.rawValue,
      userInfo: nil)
    fakeUser.error = sdkError

    let expectation = self.expectation(description: "completion called")
    plugin.refreshedAuthorizationTokens(forUser: fakeUser.userID!) { result, error in
      XCTAssertNil(error)
      XCTAssertNil(result?.success)
      XCTAssertEqual(result?.error?.type, FSIGoogleSignInErrorCode.noAuthInKeychain)
      expectation.fulfill()
    }
      await fulfillment(of: [expectation], timeout: 5.0)
  }

  func testRefreshTokensCancelledError() async {
    let fakeUser = addSignedInUser()

    let sdkError = NSError(
      domain: kGIDSignInErrorDomain, code: GIDSignInError.canceled.rawValue, userInfo: nil)
    fakeUser.error = sdkError

    let expectation = self.expectation(description: "completion called")
    plugin.refreshedAuthorizationTokens(forUser: fakeUser.userID!) { result, error in
      XCTAssertNil(error)
      XCTAssertNil(result?.success)
      XCTAssertEqual(result?.error?.type, FSIGoogleSignInErrorCode.canceled)
      expectation.fulfill()
    }
      await fulfillment(of: [expectation], timeout: 5.0)
  }

  func testRefreshTokensURLError() async {
    let fakeUser = addSignedInUser()

    let sdkError = NSError(domain: NSURLErrorDomain, code: NSURLErrorTimedOut, userInfo: nil)
    fakeUser.error = sdkError

    let expectation = self.expectation(description: "completion called")
    plugin.refreshedAuthorizationTokens(forUser: fakeUser.userID!) { result, error in
      XCTAssertNil(result?.error)
      XCTAssertNil(result?.success)
      let expectedCode = "\(NSURLErrorDomain): \(NSURLErrorTimedOut)"
      XCTAssertEqual(error?.code, expectedCode)
      expectation.fulfill()
    }
      await fulfillment(of: [expectation], timeout: 5.0)
  }

  func testRefreshTokensUnknownError() async {
    let fakeUser = addSignedInUser()

    let sdkError = NSError(domain: "BogusDomain", code: 42, userInfo: nil)
    fakeUser.error = sdkError

    let expectation = self.expectation(description: "completion called")
    plugin.refreshedAuthorizationTokens(forUser: fakeUser.userID!) { result, error in
      XCTAssertNil(result?.success)
      XCTAssertEqual(error?.code, "BogusDomain: 42")
      expectation.fulfill()
    }
      await fulfillment(of: [expectation], timeout: 5.0)
  }

  // MARK: - addScopes

  func testRequestScopesPassesScopes() async {
    let fakeUser = addSignedInUser()
    // Create a different instance to return in the result, to avoid a retain cycle.
    let fakeResultUser = TestGoogleUser(fakeUser.userID!)
    let fakeSignInResult = TestSignInResult(user: fakeResultUser)
    fakeUser.result = fakeSignInResult

    let scopes = ["mockScope1"]

    let expectation = self.expectation(description: "completion called")
    plugin.addScopes(scopes, forUser: fakeUser.userID!) { result, error in
      XCTAssertNil(error)
      XCTAssertNotNil(result?.success)
      expectation.fulfill()
    }
      await fulfillment(of: [expectation], timeout: 5.0)
    XCTAssertEqual(fakeUser.requestedScopes?.first, scopes.first)
  }

  func testRequestScopesResultErrorIfNotSignedIn() async {
    let expectation = self.expectation(description: "completion called")
    plugin.addScopes(["mockScope1"], forUser: "unknownUser") { result, error in
      XCTAssertNil(error)
      XCTAssertNil(result?.success)
      XCTAssertEqual(result?.error?.type, FSIGoogleSignInErrorCode.userMismatch)
      expectation.fulfill()
    }
      await fulfillment(of: [expectation], timeout: 5.0)
  }

  func testRequestScopesIfNoMissingScope() async {
    let fakeUser = addSignedInUser()

    let sdkError = NSError(
      domain: kGIDSignInErrorDomain, code: GIDSignInError.scopesAlreadyGranted.rawValue,
      userInfo: nil)
    fakeUser.error = sdkError

    let expectation = self.expectation(description: "completion called")
    plugin.addScopes(["mockScope1"], forUser: fakeUser.userID!) { result, error in
      XCTAssertNil(error)
      XCTAssertNil(result?.success)
      XCTAssertEqual(result?.error?.type, FSIGoogleSignInErrorCode.scopesAlreadyGranted)
      expectation.fulfill()
    }
      await fulfillment(of: [expectation], timeout: 5.0)
  }

  func testRequestScopesResultErrorIfMismatchingUser() async {
    let fakeUser = addSignedInUser()

    let sdkError = NSError(
      domain: kGIDSignInErrorDomain, code: GIDSignInError.mismatchWithCurrentUser.rawValue,
      userInfo: nil)
    fakeUser.error = sdkError

    let expectation = self.expectation(description: "completion called")
    plugin.addScopes(["mockScope1"], forUser: fakeUser.userID!) { result, error in
      XCTAssertNil(error)
      XCTAssertNil(result?.success)
      XCTAssertEqual(result?.error?.type, FSIGoogleSignInErrorCode.userMismatch)
      expectation.fulfill()
    }
      await fulfillment(of: [expectation], timeout: 5.0)
  }

  func testRequestScopesWithUnknownError() async {
    let fakeUser = addSignedInUser()

    let sdkError = NSError(domain: "BogusDomain", code: 42, userInfo: nil)
    fakeUser.error = sdkError

    let expectation = self.expectation(description: "completion called")
    plugin.addScopes(["mockScope1"], forUser: fakeUser.userID!) { result, error in
      XCTAssertNil(result)
      XCTAssertEqual(error?.code, "BogusDomain: 42")
      expectation.fulfill()
    }
      await fulfillment(of: [expectation], timeout: 5.0)
  }

  func testRequestScopesException() async {
    let fakeUser = addSignedInUser()

    fakeUser.exception = NSException(
      name: NSExceptionName(rawValue: "MockName"),
      reason: "MockReason",
      userInfo: nil)

    let expectation = self.expectation(description: "completion called")
    plugin.addScopes([], forUser: fakeUser.userID!) { result, error in
      XCTAssertNil(result)
      XCTAssertEqual(error?.code, "request_scopes")
      XCTAssertEqual(error?.message, "MockReason")
      XCTAssertEqual(error?.details as! String, "MockName")
      expectation.fulfill()
    }
      await fulfillment(of: [expectation], timeout: 5.0)
  }

  // MARK: - Utils

  func addSignedInUser() -> TestGoogleUser {
    let identifier = "fakeID"
    let user = TestGoogleUser(identifier)
    plugin.usersByIdentifier[identifier] = user
    return user
  }
}
