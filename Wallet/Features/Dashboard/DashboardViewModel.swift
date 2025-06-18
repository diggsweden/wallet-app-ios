import Foundation
import SwiftUI

@MainActor
class DashboardViewModel: ObservableObject {
  @Published var navigationPath = NavigationPath()
  @Published var showDashboard = true

  func handleDeepLink(url: URL) {
    guard url.scheme == "openid-credential-offer" else { return }

    let components = URLComponents(url: url, resolvingAgainstBaseURL: false)

    if url.host == "credential_offer",
      let credentialOfferUri = components?.queryItems?
        .first(where: {
          $0.name == "credential_offer_uri"
        })?
        .value
    {
      showDashboard = false
      navigationPath.append(credentialOfferUri)
    }
  }
}
