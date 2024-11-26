//
//  AuthenticationChallengeResponse.swift
//  webview_flutter_wkwebview
//
//  Created by Maurice Parrish on 11/16/24.
//

import Foundation

class AuthenticationChallengeResponse {
  let disposition: URLSession.AuthChallengeDisposition
  let credential: URLCredential?

  init(disposition: URLSession.AuthChallengeDisposition, credential: URLCredential?) {
    self.disposition = disposition
    self.credential = credential
  }
}
