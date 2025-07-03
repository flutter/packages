## NEXT

* Updates minimum supported SDK version to Flutter 3.27/Dart 3.6.

## 0.3.3+1

* Handles potential exceptions gracefully while fetching `Moment*Reason` for invalid value.

## 0.3.3

* Moves all the JavaScript types to extend `JSObject`.

## 0.3.2

* Adds the `nonce` parameter to `loadWebSdk`.

## 0.3.1+5

* Updates minimum supported SDK version to Flutter 3.22/Dart 3.4.
* Cleans up documentation of callbacks in `CodeClientConfig`,
  `TokenClientConfig`, `onGoogleLibraryLoad`, and `revoke` to indicate they only
  accept Dart functions and not JS functions.

## 0.3.1+4

* Restores support for Dart `^3.3.0`.

## 0.3.1+3

* Updates `README.md` to reflect modern `index.html` script tag placement.

## 0.3.1+2

* Adds support for `web: ^1.0.0`.
* Updates SDK version to Dart `^3.4.0`. Flutter `^3.22.0`.

## 0.3.1+1

* Uses `TrustedTypes` from `web: ^0.5.1`.

## 0.3.1

* Updates web code to package `web: ^0.5.0`.
* Updates SDK version to Dart `^3.3.0`. Flutter `^3.19.0`.

## 0.3.0+2

* Adds `fedcm_auto` to `CredentialSelectBy` enum.
* Adds `unknown_reason` to all `Moment*Reason` enums.

## 0.3.0+1

* Corrects 0.3.0 changelog entry about the minimum Flutter/Dart dependencies.

## 0.3.0

* Updates minimum supported SDK version to Flutter 3.16/Dart 3.2.
* Migrates from `package:js`/`dart:html` to `package:web` so this package can
  compile to WASM.
* Performs the following **breaking API changes (in bold)** and other fixes to
  align with the published GIS SDK:
  * **Removes the need to explicitly `allowInterop` in all callbacks.**
  * `id`:
    * **Changes type:**
      * `IdConfiguration.intermediate_iframe_close_callback` to
      `VoidFn?`.
    * Adds: `fedcm` to `CredentialSelectBy` enum.
    * Fixes typo in `storeCredential` `callback` positional parameter name.
  * `oauth2`:
    * **Removes:**
      * `CodeClientConfig.auto_select`, `hint` (now `login_hint`), and `hosted_domain` (now `hd`).
      * `TokenClientConfig.hint` (now `login_hint`) and `hosted_domain` (now `hd`).
      * `OverridableTokenClientConfig.hint` (now `login_hint`).
    * **Changes types:**
      * `CodeClientConfig.redirect_uri` to `Uri?`.
      * `scope` in `CodeClientConfig` and `CodeResponse` to `List<String>`.
      * `CodeResponse.code` and `state` to `String?` (now nullable).
      * `scope` in `TokenClientConfig`, `OverridableTokenClientConfig`, and `TokenResponse` to `List<String>`.
      * The following `TokenResponse` getters are now nullable: `access_token`,
        `expires_in`, `hd`, `prompt`, `token_type`, and `state`.
      * The `error_callback` functions now receive a `GoogleIdentityServicesError` parameter, instead of `Object`.
    * Adds:
      * `include_granted_scopes` and `enable_granular_consent` to `CodeClientConfig`.
      * `include_granted_scopes` and `enable_granular_consent` to `TokenClientConfig`.
      * `enable_granular_consent` to `OverridableTokenClientConfig`.
      * `message` to `GoogleIdentityServicesError`.
    * Fixes:
      * Assert that `scope` is not empty when used to create `CodeClientConfig`,
        `TokenClientConfig`, and `OverridableTokenClientConfig` instances.
      * Deprecated `enable_serial_consent`.

## 0.2.2

* Adds the following new fields to `IdConfiguration`:
  * `login_hint`, `hd` as auto-select hints for users with multiple accounts/domains.
  * `use_fedcm_for_prompt` so FedCM can be enabled.

## 0.2.1+1

* Adds pub topics to package metadata.
* Updates minimum supported SDK version to Flutter 3.7/Dart 2.19.

## 0.2.1

* Relaxes the `renderButton` API so any JS-Interop Object can be its `target`.
* Exposes the `Button*` configuration enums, so the rendered button can be configured.

## 0.2.0

* Adds `renderButton` API to `id.dart`.
* **Breaking Change:** Makes JS-interop API more `dart2wasm`-friendly.
  * Removes external getters for function types
  * Introduces an external getter for the whole libraries instead.
  * Updates `README.md` with the new way of `import`ing the desired libraries.

## 0.1.1

* Add optional `scope` to `OverridableTokenClientConfig` object.
* Mark some callbacks as optional properly.

## 0.1.0

* Initial release.
