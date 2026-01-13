// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import GoogleSignIn
import Testing
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

struct FLTGoogleSignInPluginTest {
  // A fake that replaces the real global GoogleSignIn instance for tests.
  var fakeSignIn = TestSignIn()

  @Test func signOut() {
    let plugin = createTestPlugin()
    var error: FlutterError?
    plugin.signOutWithError(&error)
    #expect(fakeSignIn.signOutCalled == true)
    #expect(error == nil)
  }

  @Test func disconnect() async {
    let plugin = createTestPlugin()
    await confirmation("expect result returns true") { confirmed in
      plugin.disconnect { error in
        #expect(error == nil)
        confirmed()
      }
    }
  }

  // MARK: - Configure

  @Test func initNoClientIdNoError() {
    // Init plugin without GoogleService-Info.plist.
    let plugin = createTestPlugin(googleServiceProperties: nil)

    // init call does not provide a clientId.
    let params = FSIPlatformConfigurationParams.make(
      withClientId: nil,
      serverClientId: nil,
      hostedDomain: nil)

    var error: FlutterError?
    plugin.configure(withParameters: params, error: &error)
    #expect(error == nil)
  }

  @Test func initGoogleServiceInfoPlist() {
    let plugin = createTestPlugin(googleServiceProperties: loadGoogleServiceInfo())
    let params = FSIPlatformConfigurationParams.make(
      withClientId: nil,
      serverClientId: nil,
      hostedDomain: "example.com")

    var error: FlutterError?
    plugin.configure(withParameters: params, error: &error)
    #expect(error == nil)
    #expect(fakeSignIn.configuration?.hostedDomain == "example.com")
    // Set in example app GoogleService-Info.plist.
    #expect(
      fakeSignIn.configuration?.clientID
        == "479882132969-9i9aqik3jfjd7qhci1nqf0bm2g71rm1u.apps.googleusercontent.com")
    #expect(fakeSignIn.configuration?.serverClientID == "YOUR_SERVER_CLIENT_ID")
  }

  @Test func initDynamicClientIdNullDomain() {
    // Init plugin without GoogleService-Info.plist.
    let plugin = createTestPlugin(googleServiceProperties: nil)

    let params = FSIPlatformConfigurationParams.make(
      withClientId: "mockClientId",
      serverClientId: nil,
      hostedDomain: nil)

    var error: FlutterError?
    plugin.configure(withParameters: params, error: &error)
    #expect(error == nil)
    #expect(fakeSignIn.configuration?.hostedDomain == nil)
    #expect(fakeSignIn.configuration?.clientID == "mockClientId")
    #expect(fakeSignIn.configuration?.serverClientID == nil)
  }

  @Test func initDynamicServerClientIdNullDomain() {
    // Init plugin without GoogleService-Info.plist.
    let plugin = createTestPlugin(googleServiceProperties: loadGoogleServiceInfo())
    let params = FSIPlatformConfigurationParams.make(
      withClientId: nil,
      serverClientId: "mockServerClientId",
      hostedDomain: nil)

    var error: FlutterError?
    plugin.configure(withParameters: params, error: &error)
    #expect(error == nil)
    #expect(fakeSignIn.configuration?.hostedDomain == nil)
    // Set in example app GoogleService-Info.plist.
    #expect(
      fakeSignIn.configuration?.clientID
        == "479882132969-9i9aqik3jfjd7qhci1nqf0bm2g71rm1u.apps.googleusercontent.com")
    // Overridden by params.
    #expect(fakeSignIn.configuration?.serverClientID == "mockServerClientId")
  }

  @Test func initInfoPlist() {
    let plugin = createTestPlugin()
    let params = FSIPlatformConfigurationParams.make(
      withClientId: nil,
      serverClientId: nil,
      hostedDomain: "example.com")

    var error: FlutterError?
    plugin.configure(withParameters: params, error: &error)
    #expect(error == nil)
    // No configuration should be set, allowing the SDK to use its default behavior
    // (which is to load configuration information from Info.plist).
    #expect(fakeSignIn.configuration == nil)
  }

  // MARK: - restorePreviousSignIn

  @Test func signInSilently() async {
    let plugin = createTestPlugin()
    let fakeUser = TestGoogleUser("mockID")
    let fakeUserProfile = TestProfileData(
      name: "mockDisplay", email: "mock@example.com",
      imageURL: URL(string: "https://example.com/profile.png"))
    fakeUser.profile = fakeUserProfile
    fakeSignIn.user = fakeUser

    await confirmation("completion called") { confirmed in
      plugin.restorePreviousSignIn { result, error in
        #expect(error == nil)
        #expect(result?.error == nil)
        #expect(result?.success != nil)
        #expect(result?.success?.user.displayName == fakeUserProfile.name)
        #expect(result?.success?.user.email == fakeUserProfile.email)
        #expect(result?.success?.user.userId == fakeUser.userID)
        #expect(result?.success?.user.photoUrl == fakeUserProfile.imageURL?.absoluteString)
        #expect(result?.success?.accessToken == fakeUser.accessToken.tokenString)
        #expect(result?.success?.serverAuthCode == nil)
        confirmed()
      }
    }
  }

  @Test func restorePreviousSignInWithError() async {
    let plugin = createTestPlugin()
    let sdkError = NSError(
      domain: kGIDSignInErrorDomain, code: GIDSignInError.hasNoAuthInKeychain.rawValue,
      userInfo: nil)
    fakeSignIn.error = sdkError

    await confirmation("completion called") { confirmed in
      plugin.restorePreviousSignIn { result, error in
        #expect(error == nil)
        #expect(result?.success == nil)
        #expect(result?.error?.type == FSIGoogleSignInErrorCode.noAuthInKeychain)
        confirmed()
      }
    }
  }

  // MARK: - signIn

  @Test func signIn() async {
    let plugin = createTestPlugin()
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

    await confirmation("completion called") { confirmed in
      plugin.signIn(withScopeHint: [], nonce: nil) { result, error in
        #expect(error == nil)
        #expect(result?.success?.user.displayName == "mockDisplay")
        #expect(result?.success?.user.email == "mock@example.com")
        #expect(result?.success?.user.userId == "mockID")
        #expect(result?.success?.user.photoUrl == "https://example.com/profile.png")
        #expect(result?.success?.accessToken == accessToken)
        #expect(result?.success?.serverAuthCode == serverAuthCode)
        confirmed()
      }
    }
  }

  @Test func signInWithScopeHint() async {
    let plugin = createTestPlugin()
    var initializationError: FlutterError?
    plugin.configure(
      withParameters: FSIPlatformConfigurationParams.make(
        withClientId: nil,
        serverClientId: nil,
        hostedDomain: nil),
      error: &initializationError)
    #expect(initializationError == nil)

    let fakeUser = TestGoogleUser("mockID")
    let fakeSignInResult = TestSignInResult(user: fakeUser)

    let requestedScopes = ["scope1", "scope2"]
    fakeSignIn.signInResult = fakeSignInResult

    await confirmation("completion called") { confirmed in
      plugin.signIn(withScopeHint: requestedScopes, nonce: nil) { result, error in
        #expect(error == nil)
        #expect(result?.error == nil)
        #expect(result?.success?.user.userId == "mockID")
        confirmed()
      }
    }

    #expect(Set(fakeSignIn.additionalScopes ?? []) == Set(requestedScopes))
  }

  @Test func signInWithNonce() async {
    let plugin = createTestPlugin()
    var initializationError: FlutterError?
    plugin.configure(
      withParameters: FSIPlatformConfigurationParams.make(
        withClientId: nil,
        serverClientId: nil,
        hostedDomain: nil),
      error: &initializationError)
    #expect(initializationError == nil)

    let fakeUser = TestGoogleUser("mockID")
    let fakeSignInResult = TestSignInResult(user: fakeUser)

    let nonce = "A nonce"
    fakeSignIn.signInResult = fakeSignInResult

    await confirmation("completion called") { confirmed in
      plugin.signIn(withScopeHint: [], nonce: nonce) { result, error in
        #expect(error == nil)
        #expect(result?.error == nil)
        #expect(result?.success?.user.userId == "mockID")
        confirmed()
      }
    }

    #expect(fakeSignIn.nonce == nonce)
  }

  @Test func signInAlreadyGranted() async {
    let plugin = createTestPlugin()
    let fakeUser = TestGoogleUser("mockID")
    let fakeSignInResult = TestSignInResult(user: fakeUser)

    fakeSignIn.signInResult = fakeSignInResult

    let sdkError = NSError(
      domain: kGIDSignInErrorDomain, code: GIDSignInError.scopesAlreadyGranted.rawValue,
      userInfo: nil)
    fakeSignIn.error = sdkError

    await confirmation("completion called") { confirmed in
      plugin.signIn(withScopeHint: [], nonce: nil) { result, error in
        #expect(error == nil)
        #expect(result?.error == nil)
        #expect(result?.success?.user.userId == "mockID")
        confirmed()
      }
    }
  }

  @Test func signInError() async {
    let plugin = createTestPlugin()
    let sdkError = NSError(
      domain: kGIDSignInErrorDomain, code: GIDSignInError.canceled.rawValue, userInfo: nil)
    fakeSignIn.error = sdkError

    await confirmation("completion called") { confirmed in
      plugin.signIn(withScopeHint: [], nonce: nil) { result, error in
        // Known errors from the SDK are returned as structured data, not
        // FlutterError.
        #expect(error == nil)
        #expect(result?.success == nil)
        #expect(result?.error?.type == .canceled)
        confirmed()
      }
    }
  }

  @Test func signInExceptionReturnsError() async {
    let plugin = createTestPlugin()
    fakeSignIn.exception = NSException(
      name: NSExceptionName(rawValue: "MockName"),
      reason: "MockReason",
      userInfo: nil)

    await confirmation("completion called") { confirmed in
      plugin.signIn(withScopeHint: [], nonce: nil) { result, error in
        // Unexpected errors, such as runtime exceptions, are returned as
        // FlutterError.
        #expect(result == nil)
        #expect(error?.code == "google_sign_in")
        #expect(error?.message == "MockReason")
        #expect(error?.details as! String == "MockName")
        confirmed()
      }
    }
  }

  // MARK: - refreshedAuthorizationTokens

  @Test func refreshTokens() async {
    let plugin = createTestPlugin()
    let fakeUser = addSignedInUser(to: plugin)
    // TestGoogleUser passes itself as the result's user property, so set the
    // fake result data on this object.
    fakeUser.idToken = TestToken("mockIdToken")
    fakeUser.accessToken = TestToken("mockAccessToken")

    await confirmation("completion called") { confirmed in
      plugin.refreshedAuthorizationTokens(forUser: fakeUser.userID!) { result, error in
        #expect(error == nil)
        #expect(result?.error == nil)
        #expect(result?.success?.user.idToken == "mockIdToken")
        #expect(result?.success?.accessToken == "mockAccessToken")
        confirmed()
      }
    }
  }

  @Test func refreshTokensUnkownUser() async {
    let plugin = createTestPlugin()
    await confirmation("completion called") { confirmed in
      plugin.refreshedAuthorizationTokens(forUser: "unknownUser") { result, error in
        #expect(error == nil)
        #expect(result?.success == nil)
        #expect(result?.error?.type == .userMismatch)
        #expect(result?.error?.message == "The user is no longer signed in.")
        confirmed()
      }
    }
  }

  @Test func refreshTokensNoAuthKeychainError() async {
    let plugin = createTestPlugin()
    let fakeUser = addSignedInUser(to: plugin)

    let sdkError = NSError(
      domain: kGIDSignInErrorDomain, code: GIDSignInError.hasNoAuthInKeychain.rawValue,
      userInfo: nil)
    fakeUser.error = sdkError

    await confirmation("completion called") { confirmed in
      plugin.refreshedAuthorizationTokens(forUser: fakeUser.userID!) { result, error in
        #expect(error == nil)
        #expect(result?.success == nil)
        #expect(result?.error?.type == .noAuthInKeychain)
        confirmed()
      }
    }
  }

  @Test func refreshTokensCancelledError() async {
    let plugin = createTestPlugin()
    let fakeUser = addSignedInUser(to: plugin)

    let sdkError = NSError(
      domain: kGIDSignInErrorDomain, code: GIDSignInError.canceled.rawValue, userInfo: nil)
    fakeUser.error = sdkError

    await confirmation("completion called") { confirmed in
      plugin.refreshedAuthorizationTokens(forUser: fakeUser.userID!) { result, error in
        #expect(error == nil)
        #expect(result?.success == nil)
        #expect(result?.error?.type == .canceled)
        confirmed()
      }
    }
  }

  @Test func refreshTokensURLError() async {
    let plugin = createTestPlugin()
    let fakeUser = addSignedInUser(to: plugin)

    let sdkError = NSError(domain: NSURLErrorDomain, code: NSURLErrorTimedOut, userInfo: nil)
    fakeUser.error = sdkError

    await confirmation("completion called") { confirmed in
      plugin.refreshedAuthorizationTokens(forUser: fakeUser.userID!) { result, error in
        #expect(result?.error == nil)
        #expect(result?.success == nil)
        let expectedCode = "\(NSURLErrorDomain): \(NSURLErrorTimedOut)"
        #expect(error?.code == expectedCode)
        confirmed()
      }
    }
  }

  @Test func refreshTokensUnknownError() async {
    let plugin = createTestPlugin()
    let fakeUser = addSignedInUser(to: plugin)

    let sdkError = NSError(domain: "BogusDomain", code: 42, userInfo: nil)
    fakeUser.error = sdkError

    await confirmation("completion called") { confirmed in
      plugin.refreshedAuthorizationTokens(forUser: fakeUser.userID!) { result, error in
        #expect(result?.success == nil)
        #expect(error?.code == "BogusDomain: 42")
        confirmed()
      }
    }
  }

  // MARK: - addScopes

  @Test func requestScopesPassesScopes() async {
    let plugin = createTestPlugin()
    let fakeUser = addSignedInUser(to: plugin)
    // Create a different instance to return in the result, to avoid a retain cycle.
    let fakeResultUser = TestGoogleUser(fakeUser.userID!)
    let fakeSignInResult = TestSignInResult(user: fakeResultUser)
    fakeUser.result = fakeSignInResult

    let scopes = ["mockScope1"]

    await confirmation("completion called") { confirmed in
      plugin.addScopes(scopes, forUser: fakeUser.userID!) { result, error in
        #expect(error == nil)
        #expect(result?.success != nil)
        confirmed()
      }
    }
    #expect(fakeUser.requestedScopes?.first == scopes.first)
  }

  @Test func requestScopesResultErrorIfNotSignedIn() async {
    let plugin = createTestPlugin()
    await confirmation("completion called") { confirmed in
      plugin.addScopes(["mockScope1"], forUser: "unknownUser") { result, error in
        #expect(error == nil)
        #expect(result?.success == nil)
        #expect(result?.error?.type == .userMismatch)
        confirmed()
      }
    }
  }

  @Test func requestScopesIfNoMissingScope() async {
    let plugin = createTestPlugin()
    let fakeUser = addSignedInUser(to: plugin)

    let sdkError = NSError(
      domain: kGIDSignInErrorDomain, code: GIDSignInError.scopesAlreadyGranted.rawValue,
      userInfo: nil)
    fakeUser.error = sdkError

    await confirmation("completion called") { confirmed in
      plugin.addScopes(["mockScope1"], forUser: fakeUser.userID!) { result, error in
        #expect(error == nil)
        #expect(result?.success == nil)
        #expect(result?.error?.type == .scopesAlreadyGranted)
        confirmed()
      }
    }
  }

  @Test func requestScopesResultErrorIfMismatchingUser() async {
    let plugin = createTestPlugin()
    let fakeUser = addSignedInUser(to: plugin)

    let sdkError = NSError(
      domain: kGIDSignInErrorDomain, code: GIDSignInError.mismatchWithCurrentUser.rawValue,
      userInfo: nil)
    fakeUser.error = sdkError

    await confirmation("completion called") { confirmed in
      plugin.addScopes(["mockScope1"], forUser: fakeUser.userID!) { result, error in
        #expect(error == nil)
        #expect(result?.success == nil)
        #expect(result?.error?.type == .userMismatch)
        confirmed()
      }
    }
  }

  @Test func requestScopesWithUnknownError() async {
    let plugin = createTestPlugin()
    let fakeUser = addSignedInUser(to: plugin)

    let sdkError = NSError(domain: "BogusDomain", code: 42, userInfo: nil)
    fakeUser.error = sdkError

    await confirmation("completion called") { confirmed in
      plugin.addScopes(["mockScope1"], forUser: fakeUser.userID!) { result, error in
        #expect(result == nil)
        #expect(error?.code == "BogusDomain: 42")
        confirmed()
      }
    }
  }

  @Test func requestScopesException() async {
    let plugin = createTestPlugin()
    let fakeUser = addSignedInUser(to: plugin)

    fakeUser.exception = NSException(
      name: NSExceptionName(rawValue: "MockName"),
      reason: "MockReason",
      userInfo: nil)

    await confirmation("completion called") { confirmed in
      plugin.addScopes([], forUser: fakeUser.userID!) { result, error in
        #expect(result == nil)
        #expect(error?.code == "request_scopes")
        #expect(error?.message == "MockReason")
        #expect(error?.details as! String == "MockName")
        confirmed()
      }
    }
  }

  // MARK: - Utils

  func loadGoogleServiceInfo() -> [String: Any]? {
    if let plistPath = Bundle(for: type(of: fakeSignIn)).path(
      forResource: "GoogleService-Info", ofType: "plist")
    {
      return NSDictionary(contentsOfFile: plistPath) as? [String: Any]
    }
    return nil
  }

  func createTestPlugin(
    viewProvider: TestViewProvider = TestViewProvider(),
    googleServiceProperties: [String: Any]? = nil
  ) -> FLTGoogleSignInPlugin {
    return FLTGoogleSignInPlugin(
      signIn: fakeSignIn, viewProvider: viewProvider,
      googleServiceProperties: googleServiceProperties)
  }

  func addSignedInUser(to plugin: FLTGoogleSignInPlugin) -> TestGoogleUser {
    let identifier = "fakeID"
    let user = TestGoogleUser(identifier)
    plugin.usersByIdentifier[identifier] = user
    return user
  }
}
