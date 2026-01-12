# Migrating from `google_sign_in` 6.x to 7.x

The API of `google_sign_in` 6.x and earlier was designed for the Google Sign-In
SDK, which has been deprecated on both Android and Web, and replaced with new
SDKs that have significantly different structures. As a result, the
`google_sign_in` API surface has changed significantly. Notable differences
include:
* `GoogleSignIn` is now a singleton, which is obtained via
  `GoogleSignIn.instance`. In practice, creating multiple `GoogleSignIn`
  instances in 6.x would not work correctly, so this just enforces an existing
  restriction.
* There is now an explicit `initialize` step that must be called exactly once,
  before any other methods. On some platforms the future will complete almost
  immediately, but on others (for example, web) it may take some time.
* The plugin no longer tracks a single "current" signed in user. Instead,
  applications that assume a single signed in user should track this at the
  application level using the `authenticationEvents` stream.
* Authentication (signing in) and authorization (allowing access to user data
  in the form of scopes) are now separate steps. Recommended practice is to
  authenticate as soon as it makes sense for a user to potentially be signed in,
  but to delay authorization until the point where the data will actually be
  used.
  * In applications where these steps should happen at the same time, you can
    pass a `scopeHint` during the authentication step. On platforms that support
    it this allows for a combined authentication and authorization UI flow.
    Not all platforms allow combining these flows, so your application should be
    prepared to trigger a separate authorization prompt if necessary.
  * Authorization is further separated into client and server authorization.
    Applications that need a `serverAuthCode` must now call a separate method,
    `authorizeServer`, to obtain that code.
  * Client authorization is handled via two new methods:
    * `authorizationForScopes`, which returns an access token if the requested
      scopes are already authorized, or null if not, and
    * `authorizeScopes`, which requests that the user authorize the scopes, and
      is expected to show UI.

    Clients should generally attempt to get tokens via `authorizationForScopes`,
    and if they are unable to do so, show some UI to request authoriaztion that
    calls `authorizeScopes`. This is similar to the previously web-only flow
    of calling `canAccessScopes` and then calling `addScopes` if necessary.
* `signInSilently` has been replaced with `attemptLightweightAuthentication`.
  The intended usage is essentially the same, but the change reflects that it
  is no longer guaranteed to be silent. For example, as of the publishing of
  7.0, on web this may show a floating sign-in card, and on Android it may show
  an account selection sheet.
  * This new method is no longer guaranteed to return a future. This allows
    clients to distinguish, at runtime:
      * platforms where a definitive "signed in" or "not signed in" response
        can be returned quickly, and thus `await`-ing completion is reasonable,
        in which case a `Future` is returned, and
      * platforms (such as web) where it could take an arbitrary amount of time,
        in which case no `Future` is returned, and clients should assume a
        non-signed-in state until/unless a sign-in event is eventually posted to
        the `authenticationEvents` stream.
* `authenticate` replaces the authentication portion of `signIn` on platforms
  that support it (see below).
* The new `supportsAuthenticate` method allows clients to determine at runtime
  whether the `authenticate` method is supported, as some platforms do not allow
  custom UI to trigger explicit authentication. These platforms instead provide
  some other platform-specific way of triggering authentication. As of
  publishing, the only platform that does not support `authenticate` is web,
  where `google_sign_in_web`'s `renderButton` is used to create a sign-in
  button.
* `clearAuthCache` has been replaced by `clearAuthorizationToken`.
* Outcomes other than successful authentication or authorization will throw
  `GoogleSignInException`s in most cases, allowing a clear way to distinguish
  different sign in failure outcomes. This includes the user canceling
  sign-in, which will throw an exception with a `code` of
  `GoogleSignInExceptionCode.canceled`.
    * Similarly, the `authenticationEvents` will receive exceptions as
      stream errors, unlike the event stream from version 6.x.
