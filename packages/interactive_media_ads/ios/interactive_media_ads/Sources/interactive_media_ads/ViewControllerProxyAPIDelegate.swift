//
//  ViewControllerProxyAPIDelegate.swift
//  interactive_media_ads
//
//  Created by Maurice Parrish on 6/21/24.
//

import Foundation

class ViewControllerProxyAPIDelegate: PigeonDelegateUIViewController {
  func pigeonDefaultConstructor(pigeonApi: PigeonApiUIViewController) throws -> UIViewController {
    return UIViewController()
  }
  
  func view(pigeonApi: PigeonApiUIViewController, pigeonInstance: UIViewController) throws -> UIView {
    return pigeonInstance.view
  }
}
