// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import GoogleSignIn
import Testing

@testable import google_sign_in_ios

#if os(macOS)
  import FlutterMacOS
#else
  import Flutter
#endif

// Test implementation of ViewProvider.
class TestViewProvider: ViewProvider {
  #if os(macOS)
    // The view containing the Flutter content.
    var view: NSView?
  #else
    // The view controller containing the Flutter content.
    var viewController: UIViewController?
  #endif
}

// Test implementation of GIDSignInProtocol.
class TestSignIn: NSObject, GIDSignInProtocol {
  var configuration: GIDConfiguration?

  // To cause methods to throw an exception.
  var exception: NSException?

  // Results to use in completion callbacks.
  var user: (any GIDGoogleUserProtocol)?
  var error: Error?
  var signInResult: (any GIDSignInResultProtocol)?

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

  // URLs passed to handleURL:, and the value to return.
  var handledURLs: [URL] = []
  var handleURLResult = true

  func handle(_ url: URL) -> Bool {
    handledURLs.append(url)
    return handleURLResult
  }

  func restorePreviousSignIn(completion: (((any GIDGoogleUserProtocol)?, Error?) -> Void)?) {
    if let exception {
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
    if let exception {
      exception.raise()
    }
    completion?(error)
  }

  #if os(iOS) || targetEnvironment(macCatalyst)
    func signIn(
      withPresenting presentingViewController: UIViewController?,
      hint: String?,
      additionalScopes: [String]?,
      nonce: String?,
      completion: ((GIDSignInResultProtocol?, Error?) -> Void)?
    ) {
      if let exception {
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
      withPresenting presentingWindow: NSWindow?,
      hint: String?,
      additionalScopes: [String]?,
      nonce: String?,
      completion: (((any GIDSignInResultProtocol)?, Error?) -> Void)?
    ) {
      if let exception {
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

// Test implementation of GIDProfileDataProtocol.
class TestProfileData: GIDProfileDataProtocol {
  var email: String
  var name: String
  // A URL to return from imageURL(withDimension:).
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

// Test implementation of GIDTokenProtocol.
final class TestToken: GIDTokenProtocol {
  let tokenString: String
  let expirationDate: Date?

  init(_ token: String, expiration: Date? = nil) {
    tokenString = token
    expirationDate = expiration
  }
}

// Test implementation of GIDSignInResultProtocol.
class TestSignInResult: GIDSignInResultProtocol {
  var user: any GIDGoogleUserProtocol
  var serverAuthCode: String?

  init(user: any GIDGoogleUserProtocol, serverAuthCode: String? = nil) {
    self.user = user
    self.serverAuthCode = serverAuthCode
  }
}

// Test implementation of GIDGoogleUserProtocol.
class TestGoogleUser: GIDGoogleUserProtocol {
  var userID: String?
  var profile: (any GIDProfileDataProtocol)?
  var grantedScopes: [String]?
  var accessToken: any GIDTokenProtocol = TestToken("Access")
  var refreshToken: any GIDTokenProtocol = TestToken("Refresh")
  var idToken: (any GIDTokenProtocol)?

  // An exception to throw from methods.
  var exception: NSException?

  // The result to return from addScopes(_:presenting:completion:).
  var result: (any GIDSignInResultProtocol)?

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

  func refreshTokensIfNeeded(completion: @escaping ((any GIDGoogleUserProtocol)?, Error?) -> Void) {
    if let exception {
      exception.raise()
    }
    completion(self.error == nil ? self : nil, self.error)
  }

  #if os(iOS) || targetEnvironment(macCatalyst)
    func addScopes(
      _ scopes: [String],
      presenting presentingViewController: UIViewController?,
      completion: (((any GIDSignInResultProtocol)?, Error?) -> Void)?
    ) {
      self.requestedScopes = scopes
      self.presentingViewController = presentingViewController
      if let exception {
        exception.raise()
      }
      completion?(self.error == nil ? self.result : nil, self.error)
    }
  #elseif os(macOS)
    func addScopes(
      _ scopes: [String],
      presenting presentingWindow: NSWindow?,
      completion: (((any GIDSignInResultProtocol)?, Error?) -> Void)?
    ) {
      self.requestedScopes = scopes
      self.presentingWindow = presentingWindow
      if let exception {
        exception.raise()
      }
      completion?(self.error == nil ? self.result : nil, self.error)
    }
  #endif
}

struct GoogleSignInPluginTests {
  @Test func signOut() throws {
    let (plugin, fakeSignIn) = createTestPlugin()
    try plugin.signOut()
    #expect(fakeSignIn.signOutCalled == true)
  }

  @Test func disconnect() async {
    let (plugin, _) = createTestPlugin()
    await confirmation("expect result returns true") { confirmed in
      plugin.disconnect { result in
        switch result {
        case .success:
          break
        case .failure(let error):
          Issue.record("Unexpected error: \(error)")
        }
        confirmed()
      }
    }
  }

  @Suite("configure") struct ConfigureTests {
    @Test func configureFromAppInfoPlist() throws {
      let (plugin, fakeSignIn) = createTestPlugin()
      let params = PlatformConfigurationParams(
        clientId: nil,
        serverClientId: nil,
        hostedDomain: "example.com")

      try plugin.configure(params: params)
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
      ) throws
    {
      let (plugin, fakeSignIn) = createTestPlugin(
        googleServiceProperties: useGoogleServiceInfoPlist ? loadGoogleServiceInfo() : nil)
      let params = PlatformConfigurationParams(
        clientId: dynamicClientId,
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

      try plugin.configure(params: params)
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
        plugin.restorePreviousSignIn { result in
          switch result {
          case .success(let signInResult):
            #expect(signInResult.error == nil)
            #expect(signInResult.success != nil)
            #expect(signInResult.success?.user.displayName == name)
            #expect(signInResult.success?.user.email == email)
            #expect(signInResult.success?.user.userId == userID)
            #expect(signInResult.success?.user.photoUrl == imageURLString)
            #expect(signInResult.success?.accessToken == accessToken)
            #expect(signInResult.success?.serverAuthCode == nil)
          case .failure(let error):
            Issue.record("Unexpected error: \(error)")
          }
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
        plugin.restorePreviousSignIn { result in
          switch result {
          case .success(let signInResult):
            #expect(signInResult.success == nil)
            #expect(signInResult.error?.type == GoogleSignInErrorCode.noAuthInKeychain)
          case .failure(let error):
            Issue.record("Unexpected error: \(error)")
          }
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
        plugin.signIn(scopeHint: [], nonce: nil) { result in
          switch result {
          case .success(let signInResult):
            #expect(signInResult.success?.user.displayName == "mockDisplay")
            #expect(signInResult.success?.user.email == "mock@example.com")
            #expect(signInResult.success?.user.userId == "mockID")
            #expect(signInResult.success?.user.photoUrl == "https://example.com/profile.png")
            #expect(signInResult.success?.accessToken == accessToken)
            #expect(signInResult.success?.serverAuthCode == serverAuthCode)
          case .failure(let error):
            Issue.record("Unexpected error: \(error)")
          }
          confirmed()
        }
      }
    }

    @Test func signInWithScopeHint() async throws {
      let (plugin, fakeSignIn) = createTestPlugin()
      try plugin.configure(
        params: PlatformConfigurationParams(
          clientId: nil,
          serverClientId: nil,
          hostedDomain: nil))

      let fakeUser = TestGoogleUser("mockID")
      let fakeSignInResult = TestSignInResult(user: fakeUser)

      let requestedScopes = ["scope1", "scope2"]
      fakeSignIn.signInResult = fakeSignInResult

      await confirmation("completion called") { confirmed in
        plugin.signIn(scopeHint: requestedScopes, nonce: nil) { result in
          switch result {
          case .success(let signInResult):
            #expect(signInResult.error == nil)
            #expect(signInResult.success?.user.userId == "mockID")
          case .failure(let error):
            Issue.record("Unexpected error: \(error)")
          }
          confirmed()
        }
      }

      #expect(Set(fakeSignIn.additionalScopes ?? []) == Set(requestedScopes))
    }

    @Test func signInWithNonce() async throws {
      let (plugin, fakeSignIn) = createTestPlugin()
      try plugin.configure(
        params: PlatformConfigurationParams(
          clientId: nil,
          serverClientId: nil,
          hostedDomain: nil))

      let fakeUser = TestGoogleUser("mockID")
      let fakeSignInResult = TestSignInResult(user: fakeUser)

      let nonce = "A nonce"
      fakeSignIn.signInResult = fakeSignInResult

      await confirmation("completion called") { confirmed in
        plugin.signIn(scopeHint: [], nonce: nonce) { result in
          switch result {
          case .success(let signInResult):
            #expect(signInResult.error == nil)
            #expect(signInResult.success?.user.userId == "mockID")
          case .failure(let error):
            Issue.record("Unexpected error: \(error)")
          }
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
        plugin.signIn(scopeHint: [], nonce: nil) { result in
          switch result {
          case .success(let signInResult):
            #expect(signInResult.error == nil)
            #expect(signInResult.success?.user.userId == "mockID")
          case .failure(let error):
            Issue.record("Unexpected error: \(error)")
          }
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
        plugin.signIn(scopeHint: [], nonce: nil) { result in
          switch result {
          case .success(let signInResult):
            // Known errors from the SDK are returned as structured data, not
            // PigeonError.
            #expect(signInResult.success == nil)
            #expect(signInResult.error?.type == .canceled)
          case .failure(let error):
            Issue.record("Unexpected error: \(error)")
          }
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
        plugin.signIn(scopeHint: [], nonce: nil) { result in
          switch result {
          case .success:
            Issue.record("Expected a PigeonError for the runtime exception")
          case .failure(let error):
            // Unexpected errors, such as runtime exceptions, are returned as
            // PigeonError.
            guard let pigeonError = error as? PigeonError else {
              Issue.record("Expected PigeonError, got \(error)")
              break
            }
            #expect(pigeonError.code == "google_sign_in")
            #expect(pigeonError.message == "MockReason")
            #expect(pigeonError.details as? String == "MockName")
          }
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
        plugin.getRefreshedAuthorizationTokens(userId: fakeUser.userID!) { result in
          switch result {
          case .success(let signInResult):
            #expect(signInResult.error == nil)
            #expect(signInResult.success?.user.idToken == "mockIdToken")
            #expect(signInResult.success?.accessToken == "mockAccessToken")
          case .failure(let error):
            Issue.record("Unexpected error: \(error)")
          }
          confirmed()
        }
      }
    }

    @Test func refreshTokensUnkownUser() async {
      let (plugin, _) = createTestPlugin()
      await confirmation("completion called") { confirmed in
        plugin.getRefreshedAuthorizationTokens(userId: "unknownUser") { result in
          switch result {
          case .success(let signInResult):
            #expect(signInResult.success == nil)
            #expect(signInResult.error?.type == .userMismatch)
            #expect(signInResult.error?.message == "The user is no longer signed in.")
          case .failure(let error):
            Issue.record("Unexpected error: \(error)")
          }
          confirmed()
        }
      }
    }

    @Test(arguments: [
      (GIDSignInError.hasNoAuthInKeychain.rawValue, GoogleSignInErrorCode.noAuthInKeychain),
      (GIDSignInError.canceled.rawValue, GoogleSignInErrorCode.canceled),
    ]) func refreshTokensGIDSignInErrorDomainErrors(
      signInSDKErrorCode: Int,
      expectedPigeonErrorCode: GoogleSignInErrorCode
    ) async {
      let (plugin, _) = createTestPlugin()
      let fakeUser = addSignedInUser(to: plugin)

      let sdkError = NSError(
        domain: kGIDSignInErrorDomain, code: signInSDKErrorCode,
        userInfo: nil)
      fakeUser.error = sdkError

      await confirmation("completion called") { confirmed in
        plugin.getRefreshedAuthorizationTokens(userId: fakeUser.userID!) { result in
          switch result {
          case .success(let signInResult):
            #expect(signInResult.success == nil)
            #expect(signInResult.error?.type == expectedPigeonErrorCode)
          case .failure(let error):
            Issue.record("Unexpected error: \(error)")
          }
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
        plugin.getRefreshedAuthorizationTokens(userId: fakeUser.userID!) { result in
          switch result {
          case .success:
            Issue.record("Expected a PigeonError for a non-GID error domain")
          case .failure(let error):
            guard let pigeonError = error as? PigeonError else {
              Issue.record("Expected PigeonError, got \(error)")
              break
            }
            let expectedCode = "\(errorDomain): \(errorCode)"
            #expect(pigeonError.code == expectedCode)
          }
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
        plugin.addScopes(scopes: scopes, userId: fakeUser.userID!) { result in
          switch result {
          case .success(let signInResult):
            #expect(signInResult.success != nil)
          case .failure(let error):
            Issue.record("Unexpected error: \(error)")
          }
          confirmed()
        }
      }
      #expect(fakeUser.requestedScopes?.first == scopes.first)
    }

    @Test func addScopesErrorsIfNotSignedIn() async {
      let (plugin, _) = createTestPlugin()
      await confirmation("completion called") { confirmed in
        plugin.addScopes(scopes: ["mockScope1"], userId: "unknownUser") { result in
          switch result {
          case .success(let signInResult):
            #expect(signInResult.success == nil)
            #expect(signInResult.error?.type == .userMismatch)
          case .failure(let error):
            Issue.record("Unexpected error: \(error)")
          }
          confirmed()
        }
      }
    }

    @Test(arguments: [
      (GIDSignInError.scopesAlreadyGranted.rawValue, GoogleSignInErrorCode.scopesAlreadyGranted),
      (GIDSignInError.mismatchWithCurrentUser.rawValue, GoogleSignInErrorCode.userMismatch),
    ]) func addScopesGIDSignInErrorDomainErrors(
      signInSDKErrorCode: Int,
      expectedPigeonErrorCode: GoogleSignInErrorCode
    ) async {
      let (plugin, _) = createTestPlugin()
      let fakeUser = addSignedInUser(to: plugin)

      let sdkError = NSError(
        domain: kGIDSignInErrorDomain, code: signInSDKErrorCode,
        userInfo: nil)
      fakeUser.error = sdkError

      await confirmation("completion called") { confirmed in
        plugin.addScopes(scopes: ["mockScope1"], userId: fakeUser.userID!) { result in
          switch result {
          case .success(let signInResult):
            #expect(signInResult.success == nil)
            #expect(signInResult.error?.type == expectedPigeonErrorCode)
          case .failure(let error):
            Issue.record("Unexpected error: \(error)")
          }
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
        plugin.addScopes(scopes: ["mockScope1"], userId: fakeUser.userID!) { result in
          switch result {
          case .success:
            Issue.record("Expected a PigeonError for an unknown error domain")
          case .failure(let error):
            guard let pigeonError = error as? PigeonError else {
              Issue.record("Expected PigeonError, got \(error)")
              break
            }
            #expect(pigeonError.code == "BogusDomain: 42")
          }
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
        plugin.addScopes(scopes: [], userId: fakeUser.userID!) { result in
          switch result {
          case .success:
            Issue.record("Expected a PigeonError for the runtime exception")
          case .failure(let error):
            guard let pigeonError = error as? PigeonError else {
              Issue.record("Expected PigeonError, got \(error)")
              break
            }
            #expect(pigeonError.code == "request_scopes")
            #expect(pigeonError.message == "MockReason")
            #expect(pigeonError.details as? String == "MockName")
          }
          confirmed()
        }
      }
    }
  }

  @Suite("urlHandling")
  @MainActor
  struct URLHandlingTests {
    #if os(iOS) || targetEnvironment(macCatalyst)
      @Test func applicationOpenURL() {
        let (plugin, fakeSignIn) = createTestPlugin()
        let url = URL(string: "com.googleusercontent.apps.test:/oauthredirect")!
        fakeSignIn.handleURLResult = true

        let handled = plugin.application(UIApplication.shared, open: url, options: [:])

        #expect(handled == true)
        #expect(fakeSignIn.handledURLs == [url])
      }

      @Test func applicationOpenURLReturnsHandleResult() {
        let (plugin, fakeSignIn) = createTestPlugin()
        let url = URL(string: "com.googleusercontent.apps.test:/oauthredirect")!
        fakeSignIn.handleURLResult = false

        let handled = plugin.application(UIApplication.shared, open: url, options: [:])

        #expect(handled == false)
        #expect(fakeSignIn.handledURLs == [url])
      }

      @Test func handleURLs() {
        let (plugin, fakeSignIn) = createTestPlugin()
        let firstURL = URL(string: "com.googleusercontent.apps.test:/oauthredirect")!
        let secondURL = URL(string: "com.googleusercontent.apps.test:/another")!

        let handled = plugin.handleURLs([firstURL, secondURL])

        #expect(handled == true)
        #expect(fakeSignIn.handledURLs == [firstURL, secondURL])
      }

      @Test func handleURLsReturnsHandleResult() {
        let (plugin, fakeSignIn) = createTestPlugin()
        let url = URL(string: "com.googleusercontent.apps.test:/oauthredirect")!
        fakeSignIn.handleURLResult = false

        let handled = plugin.handleURLs([url])

        #expect(handled == false)
        #expect(fakeSignIn.handledURLs == [url])
      }
    #endif
  }

  @Suite("errorMapping") struct ErrorMappingTests {
    @Test(arguments: [
      (GIDSignInError.keychain.rawValue, GoogleSignInErrorCode.keychainError),
      (GIDSignInError.EMM.rawValue, GoogleSignInErrorCode.eemError),
      (GIDSignInError.unknown.rawValue, GoogleSignInErrorCode.unknown),
      // Unrecognized SDK codes fall through to the default → unknown.
      (12_345, GoogleSignInErrorCode.unknown),
    ]) func mapsRemainingGIDSignInErrorCodes(
      signInSDKErrorCode: Int,
      expectedPigeonErrorCode: GoogleSignInErrorCode
    ) async {
      let (plugin, fakeSignIn) = createTestPlugin()
      fakeSignIn.error = NSError(
        domain: kGIDSignInErrorDomain, code: signInSDKErrorCode, userInfo: nil)

      await confirmation("completion called") { confirmed in
        plugin.signIn(scopeHint: [], nonce: nil) { result in
          switch result {
          case .success(let signInResult):
            #expect(signInResult.success == nil)
            #expect(signInResult.error?.type == expectedPigeonErrorCode)
          case .failure(let error):
            Issue.record("Unexpected error: \(error)")
          }
          confirmed()
        }
      }
    }

    @Test func sanitizesComplexUserInfoInFlutterError() async {
      let (plugin, _) = createTestPlugin()
      let fakeUser = addSignedInUser(to: plugin)
      let nested = NSError(domain: "NestedDomain", code: 99, userInfo: ["nestedKey": "nestedValue"])
      let userInfo: [String: Any] = [
        "string": "ok",
        "number": NSNumber(value: 42),
        "url": URL(string: "https://example.com/path")!,
        "array": ["a", NSNumber(value: 1)],
        "dict": ["inner": "value"],
        NSUnderlyingErrorKey: nested,
        "unsupported": Date(timeIntervalSince1970: 0),
      ]
      fakeUser.error = NSError(domain: "BogusDomain", code: 7, userInfo: userInfo)

      await confirmation("completion called") { confirmed in
        plugin.getRefreshedAuthorizationTokens(userId: fakeUser.userID!) { result in
          switch result {
          case .success:
            Issue.record("Expected a PigeonError for a non-GID error domain")
          case .failure(let error):
            guard let pigeonError = error as? PigeonError else {
              Issue.record("Expected PigeonError, got \(error)")
              break
            }
            #expect(pigeonError.code == "BogusDomain: 7")
            let details = pigeonError.details as? [String: Any]
            #expect(details?["string"] as? String == "ok")
            #expect(details?["number"] as? NSNumber == NSNumber(value: 42))
            #expect(details?["url"] as? String == "https://example.com/path")
            #expect((details?["array"] as? [Any])?.count == 2)
            #expect((details?["dict"] as? [String: Any])?["inner"] as? String == "value")
            let nestedDetails = details?[NSUnderlyingErrorKey] as? [String: Any]
            #expect(nestedDetails?["domain"] as? String == "NestedDomain")
            #expect(nestedDetails?["code"] as? String == "99")
            let unsupported = details?["unsupported"] as? String
            #expect(unsupported?.contains("Unsupported type:") == true)
          }
          confirmed()
        }
      }
    }
  }

  @Suite("disconnect") struct DisconnectTests {
    @Test func disconnectReturnsFlutterErrorOnFailure() async {
      let (plugin, fakeSignIn) = createTestPlugin()
      fakeSignIn.error = NSError(
        domain: "DisconnectDomain", code: 3, userInfo: ["reason": "failed"])

      await confirmation("completion called") { confirmed in
        plugin.disconnect { result in
          switch result {
          case .success:
            Issue.record("Expected a PigeonError for a failed disconnect")
          case .failure(let error):
            guard let pigeonError = error as? PigeonError else {
              Issue.record("Expected PigeonError, got \(error)")
              break
            }
            #expect(pigeonError.code == "DisconnectDomain: 3")
            #expect((pigeonError.details as? [String: Any])?["reason"] as? String == "failed")
          }
          confirmed()
        }
      }
    }
  }

  @Suite("userData") struct UserDataTests {
    @Test func signInWithoutProfileImageOmitsPhotoUrl() async {
      let (plugin, fakeSignIn) = createTestPlugin()
      let fakeUser = TestGoogleUser("mockID")
      fakeUser.profile = TestProfileData(name: "Name", email: "user@example.com", imageURL: nil)
      fakeSignIn.signInResult = TestSignInResult(user: fakeUser)

      await confirmation("completion called") { confirmed in
        plugin.signIn(scopeHint: [], nonce: nil) { result in
          switch result {
          case .success(let signInResult):
            #expect(signInResult.success?.user.photoUrl == nil)
            #expect(signInResult.success?.user.displayName == "Name")
          case .failure(let error):
            Issue.record("Unexpected error: \(error)")
          }
          confirmed()
        }
      }
    }
  }

  @Suite("wrappers") struct WrapperTests {
    @Test func signInCompletesWithErrorWhenPresenterIsNil() async {
      let wrapper = GIDSignInWrapper()
      await confirmation("completion called") { confirmed in
        wrapper.signIn(
          withPresenting: nil, hint: nil, additionalScopes: nil, nonce: nil
        ) { result, error in
          #expect(result == nil)
          let nsError = error as NSError?
          #expect(nsError?.domain == "google_sign_in")
          #expect(
            nsError?.localizedDescription
              == "No host view available to present Google Sign-In.")
          confirmed()
        }
      }
    }

    @Test func pluginSignInWithoutPresenterReturnsFlutterError() async {
      let plugin = GoogleSignInPlugin(
        signIn: GIDSignInWrapper(), viewProvider: TestViewProvider())
      await confirmation("completion called") { confirmed in
        plugin.signIn(scopeHint: [], nonce: nil) { result in
          switch result {
          case .success:
            Issue.record("Expected a PigeonError when no presenter is available")
          case .failure(let error):
            guard let pigeonError = error as? PigeonError else {
              Issue.record("Expected PigeonError, got \(error)")
              break
            }
            #expect(pigeonError.code == "google_sign_in: 0")
            #expect(pigeonError.message == "No host view available to present Google Sign-In.")
          }
          confirmed()
        }
      }
    }
  }

  #if os(iOS) || targetEnvironment(macCatalyst)
    @Suite("topViewController")
    @MainActor
    struct TopViewControllerTests {
      @Test func usesNavigationControllerVisibleController() async {
        let root = UIViewController()
        let nav = UINavigationController(rootViewController: root)
        let top = UIViewController()
        nav.pushViewController(top, animated: false)

        let viewProvider = TestViewProvider()
        viewProvider.viewController = nav
        let (plugin, fakeSignIn) = createTestPlugin(viewProvider: viewProvider)
        fakeSignIn.signInResult = TestSignInResult(user: TestGoogleUser("id"))

        await confirmation("completion called") { confirmed in
          plugin.signIn(scopeHint: [], nonce: nil) { _ in confirmed() }
        }
        #expect(fakeSignIn.presentingViewController === top)
      }

      @Test func usesTabBarControllerSelectedController() async {
        let selected = UIViewController()
        let other = UIViewController()
        let tab = UITabBarController()
        tab.viewControllers = [selected, other]
        tab.selectedViewController = selected

        let viewProvider = TestViewProvider()
        viewProvider.viewController = tab
        let (plugin, fakeSignIn) = createTestPlugin(viewProvider: viewProvider)
        fakeSignIn.signInResult = TestSignInResult(user: TestGoogleUser("id"))

        await confirmation("completion called") { confirmed in
          plugin.signIn(scopeHint: [], nonce: nil) { _ in confirmed() }
        }
        #expect(fakeSignIn.presentingViewController === selected)
      }

      @Test func usesPresentedViewController() async {
        let presented = UIViewController()
        let host = StubHostingViewController(presented: presented)

        let viewProvider = TestViewProvider()
        viewProvider.viewController = host
        let (plugin, fakeSignIn) = createTestPlugin(viewProvider: viewProvider)
        fakeSignIn.signInResult = TestSignInResult(user: TestGoogleUser("id"))

        await confirmation("completion called") { confirmed in
          plugin.signIn(scopeHint: [], nonce: nil) { _ in confirmed() }
        }
        #expect(fakeSignIn.presentingViewController === presented)
      }
    }
  #endif
}

#if os(iOS) || targetEnvironment(macCatalyst)
  /// Stand-in for UIOpenURLContext that only needs to respond to `URL`.
  final class FakeOpenURLContext: NSObject {
    @objc(URL) var openURL: URL

    init(url: URL) {
      self.openURL = url
      super.init()
    }
  }

  /// Lets tests stub `presentedViewController` without a real window presentation.
  @MainActor
  final class StubHostingViewController: UIViewController {
    private let stubPresented: UIViewController?

    init(presented: UIViewController?) {
      self.stubPresented = presented
      super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
    }

    override var presentedViewController: UIViewController? {
      stubPresented
    }
  }
#endif

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
) -> (GoogleSignInPlugin, TestSignIn) {
  let fakeSignIn = TestSignIn()
  return (
    GoogleSignInPlugin(
      signIn: fakeSignIn, viewProvider: viewProvider,
      googleServiceProperties: googleServiceProperties), fakeSignIn
  )
}

func addSignedInUser(to plugin: GoogleSignInPlugin) -> TestGoogleUser {
  let identifier = "fakeID"
  let user = TestGoogleUser(identifier)
  plugin.usersByIdentifier[identifier] = user
  return user
}
