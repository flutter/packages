//
//  Utils.swift
//  RunnerTests
//
//  Created by Ailton Vieira on 01/03/22.
//  Copyright © 2022 The Flutter Authors. All rights reserved.
//

import Foundation

func equals(_ x: Any?, _ y: Any?) -> Bool {
    guard let x = x as? AnyHashable,
          let y = y as? AnyHashable else {
              if x == nil, y == nil {
                  return true
              } else {
                  return false
              }
          }
    return x == y
}

func equalsList(_ x: [Any?]?, _ y: [Any?]?) -> Bool {
    guard x?.count == y?.count else { return false }
    guard let x = x, let y = y else {
        if x == nil, y == nil {
            return true
        } else {
            return false
        }
    }
    
    for i in 0..<(x.count) {
        if equals(x[i], y[i]) == false {
            return false
        }
    }
    
    return true
}
    
func equalsDictionary(_ x: [AnyHashable: Any?]?, _ y: [AnyHashable: Any?]?) -> Bool {
    guard x?.count == y?.count else { return false }
    guard let x = x, let y = y else {
        if x == nil, y == nil {
            return true
        } else {
            return false
        }
    }
    
    for (key, valueX) in x {
        if let valueY = y[key] {
            if equals(valueX, valueY) == false {
                return false
            }
        } else {
            return false
        }
    }
    
    return true
}
