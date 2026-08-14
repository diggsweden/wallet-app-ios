// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import Foundation

extension Bundle {
  var appVersion: String {
    guard let version = infoDictionary?["CFBundleShortVersionString"] as? String else {
      return ""
    }

    return version
  }

  var buildNumber: String {
    guard let buildNumber = infoDictionary?["CFBundleVersion"] as? String else {
      return ""
    }

    return buildNumber
  }

  var fullVersion: String {
    "\(appVersion) (\(buildNumber))"
  }

  var variantLabel: String? {
    #if LOCALHOST
      return "local"
    #elseif DEBUG
      return "demo"
    #else
      return nil
    #endif
  }

  var displayVersion: String {
    guard let variantLabel else {
      return fullVersion
    }

    return "\(fullVersion) (\(variantLabel))"
  }
}
