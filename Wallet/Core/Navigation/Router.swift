// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import Foundation
import SwiftUI

@Observable
class Router {
  var navigationPath = NavigationPath()
  var presentedSheet: Sheet?
  var presentedFullScreenCover: FullScreenCover?

  func go(to route: Route) {
    navigationPath.append(route)
  }

  func open(_ deeplink: Deeplink) {
    switch deeplink {
      case .issuance(let url):
        go(to: .issuance(url: url))

      case .presentation(let url):
        presentedSheet = .presentation(url: url)
    }
  }

  func pop() {
    navigationPath.removeLast()
  }

  func popToRoot() {
    navigationPath.removeLast(navigationPath.count)
  }

  func reset() {
    navigationPath = NavigationPath()
    presentedSheet = nil
    presentedFullScreenCover = nil
  }

  func dismiss() {
    presentedSheet = nil
    presentedFullScreenCover = nil
  }
}

extension Router {
  enum Sheet: Identifiable {
    case settings
    case presentation(url: URL)

    var id: String {
      switch self {
        case .settings:
          "settings"

        case .presentation(let url):
          "presentation-\(url.absoluteString)"
      }
    }
  }

  enum FullScreenCover: String, Identifiable {
    case camera

    var id: Self { self }
  }
}
