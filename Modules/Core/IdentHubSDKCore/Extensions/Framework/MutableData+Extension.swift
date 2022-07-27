//
//  MutableData+Extension.swift
//  IdentHubSDKCore
//

import Foundation

public extension NSMutableData {
  func appendString(_ string: String) {
    if let data = string.data(using: .utf8) {
      self.append(data)
    }
  }
}
