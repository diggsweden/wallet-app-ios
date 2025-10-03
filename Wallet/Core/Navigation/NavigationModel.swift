import Foundation
import SwiftUI

@MainActor
@Observable
class NavigationModel {
  var navigationPath = NavigationPath()

  func go(to route: Route) {
    navigationPath.append(route)
  }

  func pop() {
    navigationPath.removeLast()
  }
}
