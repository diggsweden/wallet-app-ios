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
