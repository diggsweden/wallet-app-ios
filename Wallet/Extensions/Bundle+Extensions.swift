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
}
