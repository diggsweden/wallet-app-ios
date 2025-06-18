//
//  StringExtensions.swift
//  wallet
//
//  Created by Asser Hakala on 2025-06-16.
//
import Foundation

extension String {
  func addBase64Padding() -> String {
    let remainder = self.count % 4
    if remainder > 0 {
      return self + String(repeating: "=", count: 4 - remainder)
    }
    return self
  }

  func decodeFromBase64() -> String? {
    guard let decodedData = Data(base64Encoded: self.addBase64Padding()) else {
      return nil
    }

    return String(data: decodedData, encoding: .utf8)
  }
}
