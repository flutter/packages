//
//  AuthenticationChallengeResponse.swift
//  webview_flutter_wkwebview
//
//  Created by Maurice Parrish on 11/16/24.
//

import Foundation

class AuthenticationChallengeResponse {
  let disposition: UrlSessionAuthChallengeDisposition
  let credential: URLCredential

  init(disposition: UrlSessionAuthChallengeDisposition, credential: URLCredential) {
    self.disposition = disposition
    self.credential = credential
  }
}
