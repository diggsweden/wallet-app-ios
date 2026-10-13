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

  func pop() {
    navigationPath.removeLast()
  }

  func popToRoot() {
    navigationPath.removeLast(navigationPath.count)
  }

  func reset() {
    navigationPath = NavigationPath()
    presentedSheet = nil
  }
}

extension Router {
  enum Sheet: String, Identifiable {
    case settings

    var id: Self { self }
  }

  enum FullScreenCover: String, Identifiable {
    case camera

    var id: Self { self }
  }
}
