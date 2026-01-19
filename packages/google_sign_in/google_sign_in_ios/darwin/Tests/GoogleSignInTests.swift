// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import GoogleSignIn
import Testing

@testable import google_sign_in_ios

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
  var user: (any FSIGIDGoogleUser)?
  var error: Error?
  var signInResult: (any FSIGIDSignInResult)?

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

  func restorePreviousSignIn(completion: (((any FSIGIDGoogleUser)?, Error?) -> Void)?) {
    if let exception = exception {
      exception.raise()
    }
    if let user {
      completion?(user, nil)
    } else {
      completion?(nil, error)
    }
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
      if let signInResult {
        completion?(signInResult, nil)
      } else {
        completion?(nil, error)
      }
    }
  #else
    func signIn(
      withPresenting presentingWindow: NSWindow,
      hint: String?,
      additionalScopes: [String]?,
      nonce: String?,
      completion: (((any FSIGIDSignInResult)?, Error?) -> Void)?
    ) {
      if let exception = exception {
        exception.raise()
      }
      self.presentingWindow = presentingWindow
      self.hint = hint
      self.additionalScopes = additionalScopes
      self.nonce = nonce
      if let signInResult {
        completion?(signInResult, nil)
      } else {
        completion?(nil, error)
      }
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
final class TestToken: NSObject, FSIGIDToken {
  let tokenString: String
  let expirationDate: Date?

  init(_ token: String, expiration: Date? = nil) {
    tokenString = token
    expirationDate = expiration
  }
}

// Test implementation of FSIGIDSignInResult.
class TestSignInResult: NSObject, FSIGIDSignInResult {
  var user: any FSIGIDGoogleUser
  var serverAuthCode: String?

  init(user: any FSIGIDGoogleUser, serverAuthCode: String? = nil) {
    self.user = user
    self.serverAuthCode = serverAuthCode
  }
}

// Test implementation of FSIGIDGoogleUser.
class TestGoogleUser: NSObject, FSIGIDGoogleUser {
  var userID: String?
  var profile: (any FSIGIDProfileData)?
  var grantedScopes: [String]?
  var accessToken: any FSIGIDToken = TestToken("Access")
  var refreshToken: any FSIGIDToken = TestToken("Refresh")
  var idToken: (any FSIGIDToken)?

  // An exception to throw from methods.
  var exception: NSException?

  // The result to return from addScopes:presentingViewController:completion:.
  var result: (any FSIGIDSignInResult)?

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

  func refreshTokensIfNeeded(completion: @escaping ((any FSIGIDGoogleUser)?, Error?) -> Void) {
    if let exception = exception {
      exception.raise()
    }
    completion(self.error == nil ? self : nil, self.error)
  }

  #if os(iOS) || targetEnvironment(macCatalyst)
    func addScopes(
      _ scopes: [String],
      presenting presentingViewController: UIViewController,
      completion: (((any FSIGIDSignInResult)?, Error?) -> Void)?
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
      completion: (((any FSIGIDSignInResult)?, Error?) -> Void)?
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

struct GoogleSignInPluginTests {
  @Test func signOut() {
    let (plugin, fakeSignIn) = createTestPlugin()
    var error: FlutterError?
    plugin.signOutWithError(&error)
    #expect(fakeSignIn.signOutCalled == true)
    #expect(error == nil)
  }

  @Test func disconnect() async {
    let (plugin, _) = createTestPlugin()
    await confirmation("expect result returns true") { confirmed in
      plugin.disconnect { error in
        #expect(error == nil)
        confirmed()
      }
    }
  }

  @Suite("configure") struct ConfigureTests {
    @Test func configureFromAppInfoPlist() {
      let (plugin, fakeSignIn) = createTestPlugin()
      let params = FSIPlatformConfigurationParams.make(
        withClientId: nil,
        serverClientId: nil,
        hostedDomain: "example.com")

      var error: FlutterError?
      plugin.configure(withParameters: params, error: &error)
      #expect(error == nil)
      // No configuration should be set, allowing the SDK to use its default behavior
      // (which is to load configuration information from the app's Info.plist).
      #expect(fakeSignIn.configuration == nil)
    }

    @Test(
      arguments: [
        // Use GoogleService-Info.plist, but add a domain.
        (nil, nil, "example.com", true),
        // Use GoogleService-Info.plist, but override the server client ID.
        (nil, "overridingServerClientId", nil, true),
        // No plist, providing only some values.
        ("runtimeClientId", nil, nil, false),
        ("runtimeClientId", "runtimeSeverClientId", nil, false),
      ] as [(String?, String?, String?, Bool)]) func configureFromExplicitValues(
        dynamicClientId: String?,
        dynamicServerClientId: String?,
        dynamicHostedDomain: String?,
        useGoogleServiceInfoPlist: Bool
      )
    {
      let (plugin, fakeSignIn) = createTestPlugin(
        googleServiceProperties: useGoogleServiceInfoPlist ? loadGoogleServiceInfo() : nil)
      let params = FSIPlatformConfigurationParams.make(
        withClientId: dynamicClientId,
        serverClientId: dynamicServerClientId,
        hostedDomain: dynamicHostedDomain)

      // Default configuration values are nil, or the values from GoogleService-Info.plist if
      // that's being used.
      var expectedClientId: String? =
        useGoogleServiceInfoPlist
        ? "479882132969-9i9aqik3jfjd7qhci1nqf0bm2g71rm1u.apps.googleusercontent.com" : nil
      var expectedServerClientId: String? =
        useGoogleServiceInfoPlist ? "YOUR_SERVER_CLIENT_ID" : nil
      var expectedDomain: String? = nil
      // Any value passed in at runtime should override the default.
      if let dynamicClientId {
        expectedClientId = dynamicClientId
      }
      if let dynamicServerClientId {
        expectedServerClientId = dynamicServerClientId
      }
      if let dynamicHostedDomain {
        expectedDomain = dynamicHostedDomain
      }

      var error: FlutterError?
      plugin.configure(withParameters: params, error: &error)
      #expect(error == nil)
      #expect(
        fakeSignIn.configuration?.clientID
          == expectedClientId)
      #expect(fakeSignIn.configuration?.serverClientID == expectedServerClientId)
      #expect(fakeSignIn.configuration?.hostedDomain == expectedDomain)
    }
  }

  @Suite("restorePreviousSignIn") struct RestorePreviousSignInTests {
    @Test func restorePreviousSignInSuccess() async {
      let (plugin, fakeSignIn) = createTestPlugin()
      let userID = "mockID"
      let fakeUser = TestGoogleUser(userID)
      let accessToken = fakeUser.accessToken.tokenString
      let name = "mockDislayName"
      let email = "mock@example.com"
      let imageURLString = "https://example.com/profile.png"
      fakeUser.profile = TestProfileData(
        name: name, email: email,
        imageURL: URL(string: imageURLString))
      fakeSignIn.user = fakeUser

      await confirmation("completion called") { confirmed in
        plugin.restorePreviousSignIn { result, error in
          #expect(error == nil)
          #expect(result?.error == nil)
          #expect(result?.success != nil)
          #expect(result?.success?.user.displayName == name)
          #expect(result?.success?.user.email == email)
          #expect(result?.success?.user.userId == userID)
          #expect(result?.success?.user.photoUrl == imageURLString)
          #expect(result?.success?.accessToken == accessToken)
          #expect(result?.success?.serverAuthCode == nil)
          confirmed()
        }
      }
    }

    @Test func restorePreviousSignInError() async {
      let (plugin, fakeSignIn) = createTestPlugin()
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
  }

  @Suite("signIn") struct SignInTests {
    @Test func signInWithoutParameters() async {
      let (plugin, fakeSignIn) = createTestPlugin()
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
      let (plugin, fakeSignIn) = createTestPlugin()
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
      let (plugin, fakeSignIn) = createTestPlugin()
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
      let (plugin, fakeSignIn) = createTestPlugin()
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

    @Test func signInCanceled() async {
      let (plugin, fakeSignIn) = createTestPlugin()
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
      let (plugin, fakeSignIn) = createTestPlugin()
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
          #expect(error?.details as? String == "MockName")
          confirmed()
        }
      }
    }
  }

  @Suite("refreshedAuthorizationTokens") struct RefreshTests {
    @Test func refreshTokensSuccess() async {
      let (plugin, _) = createTestPlugin()
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
      let (plugin, _) = createTestPlugin()
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

    @Test(arguments: [
      (GIDSignInError.hasNoAuthInKeychain.rawValue, FSIGoogleSignInErrorCode.noAuthInKeychain),
      (GIDSignInError.canceled.rawValue, .canceled),
    ]) func refreshTokensGIDSignInErrorDomainErrors(
      signInSDKErrorCode: Int,
      expectedPigeonErrorCode: FSIGoogleSignInErrorCode
    ) async {
      let (plugin, _) = createTestPlugin()
      let fakeUser = addSignedInUser(to: plugin)

      let sdkError = NSError(
        domain: kGIDSignInErrorDomain, code: signInSDKErrorCode,
        userInfo: nil)
      fakeUser.error = sdkError

      await confirmation("completion called") { confirmed in
        plugin.refreshedAuthorizationTokens(forUser: fakeUser.userID!) { result, error in
          #expect(error == nil)
          #expect(result?.success == nil)
          #expect(result?.error?.type == expectedPigeonErrorCode)
          confirmed()
        }
      }
    }

    @Test(arguments: [
      (NSURLErrorDomain, NSURLErrorTimedOut),
      ("BogusDomain", 42),
    ]) func refreshTokensOtherDomainErrors(
      errorDomain: String,
      errorCode: Int
    ) async {
      let (plugin, _) = createTestPlugin()
      let fakeUser = addSignedInUser(to: plugin)

      let sdkError = NSError(domain: errorDomain, code: errorCode, userInfo: nil)
      fakeUser.error = sdkError

      await confirmation("completion called") { confirmed in
        plugin.refreshedAuthorizationTokens(forUser: fakeUser.userID!) { result, error in
          #expect(result?.error == nil)
          #expect(result?.success == nil)
          let expectedCode = "\(errorDomain): \(errorCode)"
          #expect(error?.code == expectedCode)
          confirmed()
        }
      }
    }
  }

  @Suite("addScopes") struct AddScopesTests {
    @Test func addScopesPassesScopes() async {
      let (plugin, _) = createTestPlugin()
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

    @Test func addScopesErrorsIfNotSignedIn() async {
      let (plugin, _) = createTestPlugin()
      await confirmation("completion called") { confirmed in
        plugin.addScopes(["mockScope1"], forUser: "unknownUser") { result, error in
          #expect(error == nil)
          #expect(result?.success == nil)
          #expect(result?.error?.type == .userMismatch)
          confirmed()
        }
      }
    }

    @Test(arguments: [
      (GIDSignInError.scopesAlreadyGranted.rawValue, FSIGoogleSignInErrorCode.scopesAlreadyGranted),
      (GIDSignInError.mismatchWithCurrentUser.rawValue, FSIGoogleSignInErrorCode.userMismatch),
    ]) func addScopesGIDSignInErrorDomainErrors(
      signInSDKErrorCode: Int,
      expectedPigeonErrorCode: FSIGoogleSignInErrorCode
    ) async {
      let (plugin, _) = createTestPlugin()
      let fakeUser = addSignedInUser(to: plugin)

      let sdkError = NSError(
        domain: kGIDSignInErrorDomain, code: signInSDKErrorCode,
        userInfo: nil)
      fakeUser.error = sdkError

      await confirmation("completion called") { confirmed in
        plugin.addScopes(["mockScope1"], forUser: fakeUser.userID!) { result, error in
          #expect(error == nil)
          #expect(result?.success == nil)
          #expect(result?.error?.type == expectedPigeonErrorCode)
          confirmed()
        }
      }
    }

    @Test func addScopesUnknownError() async {
      let (plugin, _) = createTestPlugin()
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

    @Test func addScopesException() async {
      let (plugin, _) = createTestPlugin()
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
          #expect(error?.details as? String == "MockName")
          confirmed()
        }
      }
    }
  }
}

func loadGoogleServiceInfo() -> [String: Any]? {
  if let plistPath = Bundle(for: TestSignIn.self).path(
    forResource: "GoogleService-Info", ofType: "plist")
  {
    return NSDictionary(contentsOfFile: plistPath) as? [String: Any]
  }
  return nil
}

func createTestPlugin(
  viewProvider: TestViewProvider = TestViewProvider(),
  googleServiceProperties: [String: Any]? = nil
) -> (FLTGoogleSignInPlugin, TestSignIn) {
  let fakeSignIn = TestSignIn()
  return (
    FLTGoogleSignInPlugin(
      signIn: fakeSignIn, viewProvider: viewProvider,
      googleServiceProperties: googleServiceProperties), fakeSignIn
  )
}

func addSignedInUser(to plugin: FLTGoogleSignInPlugin) -> TestGoogleUser {
  let identifier = "fakeID"
  let user = TestGoogleUser(identifier)
  plugin.usersByIdentifier[identifier] = user
  return user
}
