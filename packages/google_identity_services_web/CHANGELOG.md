## 0.3.0

* Updates minimum supported SDK version to Flutter 3.10/Dart 3.0.
* Migrated from to `package:web` so this package can compile to WASM.
* **Breaking API changes** and fixes to align with the GIS SDK:
  * **Removed the need to explicitly `allowInterop` in all callbacks.**
  * `id`:
    * **Changed type:**
      * `IdConfiguration.intermediate_iframe_close_callback` to
      `VoidFn?`.
    * Added: `fedcm` to `CredentialSelectBy` enum.
    * Fixed typo in `storeCredential` `callback` positional parameter name.
  * `oauth2`:
    * **Removed:**
      * `CodeClientConfig.auto_select`, `hint` (now `login_hint`), and `hosted_domain` (now `hd`).
      * `TokenClientConfig.hint` (now `login_hint`) and `hosted_domain` (now `hd`).
      * `OverridableTokenClientConfig.hint` (now `login_hint`).
    * **Changed types:**
      * `CodeClientConfig.redirect_uri` to `Uri?`.
      * `scope` in `CodeClientConfig` and `CodeResponse` to `List<String>`.
      * `CodeResponse.code` and `state` to `String?` (now nullable).
      * `scope` in `TokenClientConfig`, `OverridableTokenClientConfig`, and `TokenResponse` to `List<String>`.
      * Made the following `TokenResponse` getters nullable: `access_token`,
        `expires_in`, `hd`, `prompt`, `token_type`, and `state`.
      * The `error_callback` functions now receive a `GoogleIdentityServicesError` parameter, instead of `Object`.
    * Added:
      * `include_granted_scopes` and `enable_granular_consent` to `CodeClientConfig`.
      * `include_granted_scopes` and `enable_granular_consent` to `TokenClientConfig`.
      * `enable_granular_consent` to `OverridableTokenClientConfig`.
      * `message` to `GoogleIdentityServicesError`.
    * Fixed:
      * Assert that `CodeClientConfig.scope` is not empty when creating an instance.
      * `TokenClientConfig.scope` is no longer `required`.
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
