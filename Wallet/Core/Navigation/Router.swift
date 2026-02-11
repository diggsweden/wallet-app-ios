// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import Foundation
import SwiftUI

@Observable
class Router {
  var navigationPath = NavigationPath()

  func go(to route: Route) {
    navigationPath.append(route)
  }

  func pop() {
    navigationPath.removeLast()
  }
}
