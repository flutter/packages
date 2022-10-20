// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// This file is used to mock the GIS library for integration tests under:
// example/integration_test

class PromptMomentNotification {
  constructor(momentType, reason) {
    this.momentType = momentType;
    this.reason = reason;
    this.getNotDisplayedReason = this._getReason;
    this.getSkippedReason = this._getReason;
    this.getDismissedReason = this._getReason;
  }
  getMomentType() { return this.momentType; }
  _getReason() { return this.reason; }
  isDismissedMoment() { return this.momentType === "dismissed" }
  isDisplayMoment() { return this.momentType === "display" }
  isSkippedMoment() { return this.momentType === "skipped" }
  isDisplayed() { return this.isDisplayMoment() && !this.reason; }
  isNotDisplayed() { return this.isDisplayMoment() && this.reason; }
}

const CREDENTIAL_RETURNED = new PromptMomentNotification("dismissed", "credential_returned");
const USER_CANCEL = new PromptMomentNotification("skipped", "user_cancel");

function callAsync(func, timeout = 100) {
  window.setTimeout(func, timeout)
}

class Id {
  initialize(config) {
    this.config = config;
  }
  prompt(momentListener) {
    callAsync(() => {
      if (this.mockCredentialResponse) {
        let callback = this.config.callback;
        if (callback) {
          callback(this.mockCredentialResponse);
        }
        if (momentListener) {
          momentListener(CREDENTIAL_RETURNED);
        }
      } else if (momentListener) {
        momentListener(USER_CANCEL);
      }
    });
  }
  setMockCredentialResponse(credential, select_by) {
    this.mockCredentialResponse = {
      credential: credential,
      select_by: select_by,
    };
  }
  disableAutoSelect() {}
  storeCredential() {}
  cancel() {}
  revoke(hint, callback) {
    this.mockCredentialResponse = null;
    if (!callback) {
      return;
    }
    callAsync(() => {
      callback({
        successful: true,
        error: 'Revoked ' + hint,
      });
    })
  }
}

class CodeClient {
  constructor(config) {
    this.config = config;
  }
  requestCode() {
    let callback = this.config.callback;
    if (!callback) {
      return;
    }
    callAsync(() => {
      callback(this.codeResponse);
    });
  }
  setMockCodeResponse(codeResponse) {
    this.codeResponse = codeResponse;
  }
}

class TokenClient {
  constructor(config) {
    this.config = config;
  }
  requestAccessToken(overridableConfig) {
    this.overridableConfig = overridableConfig;
    let callback = this.overridableConfig.callback || this.config.callback;
    if (!callback) {
      return;
    }
    callAsync(() => {
      callback(this.tokenResponse);
    });
  }
  setMockTokenResponse(tokenResponse) {
    this.tokenResponse = tokenResponse;
  }
}

class Oauth2 {
  initCodeClient(config) {
    return new CodeClient(config);
  }
  initTokenClient(config) {
    return new TokenClient(config);
  }
  hasGrantedAllScopes(tokenResponse, scope, ...scopes) {
    return tokenResponse != null;
  }
  hasGrantedAnyScopes(tokenResponse, scope, ...scopes) {
    return tokenResponse != null;
  }
  revoke(accessToken, done) {
    if (!done) {
      return;
    }
    callAsync(() => {
      done();
    })
  }
}

function mockGis() {
  let goog = {
    accounts: {
      id: new Id(),
      oauth2: new Oauth2(),
    }
  };
  globalThis['google'] = goog;
}

mockGis();
