// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import AuthenticationServices
import SwiftData
import SwiftUI

struct AppRootView: View {
  private let gatewayApiClient: GatewayApi
  @State private var userViewModel: UserViewModel
  @State private var router = Router()

  init(userStore: UserStore, gatewayApiClient: GatewayApi) {
    _userViewModel = State(wrappedValue: .init(userStore: userStore))
    self.gatewayApiClient = gatewayApiClient
  }

  var body: some View {
    NavigationStack(path: $router.navigationPath) {
      rootView
        .defaultScreenStyle
        .navigationDestination(for: Route.self) { route in
          destination(for: route)
            .defaultScreenStyle
        }
    }
    .environment(router)
    .onOpenURL(perform: handleOpenURL)
    .task {
      await userViewModel.initUser()
    }
  }

  @ViewBuilder
  private var rootView: some View {
    switch userViewModel.user {
      case .ready(let user):
        if !userViewModel.isEnrolled {
          OnboardingRootView(
            gatewayApiClient: gatewayApiClient,
            userSnapshot: user,
            saveCredential: userViewModel.saveCredential,
            signIn: userViewModel.signIn,
            onReset: userViewModel.signOut,
          )
        } else {
          DashboardView(credential: user.credential)
        }

      case .loading, .error:
        ProgressView()
    }
  }

  @ViewBuilder
  private func destination(for route: Route) -> some View {
    switch route {
      case .presentation(let url):
        PresentationView(
          url: url,
          credential: userViewModel.userSnapshot?.credential
        )

      case .issuance(let url):
        IssuanceViewWrapper(
          credentialOfferUri: url,
          gatewayApiClient: gatewayApiClient
        ) { credential in
          await userViewModel.saveCredential(credential)
          router.pop()
        }

      case .credentialDetails(let credential):
        CredentialDetailsView(credential: credential)

      case .settings:
        SettingsView(onLogout: userViewModel.signOut)
    }
  }

  private func handleOpenURL(_ url: URL) {
    Task {
      do {
        let deeplink = try Deeplink(from: url)
        let route = try await deeplink.router.route(from: url)
        router.go(to: route)
      } catch {
        print("Failed to deeplink: \(error)")
      }
    }
  }
}
