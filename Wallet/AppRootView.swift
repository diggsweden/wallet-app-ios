// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import AuthenticationServices
import SwiftAccessMechanism
import SwiftData
import SwiftUI
import WalletGateway

struct AppRootView: View {
  private let gatewayApiClient: GatewayApiClient
  @State private var userViewModel: UserViewModel
  @State private var router = Router()

  init(userStore: UserStore, gatewayApiClient: GatewayApiClient) {
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
            savePidCredential: userViewModel.savePid,
            signIn: userViewModel.signIn,
            onReset: userViewModel.signOut,
          )
        } else {
          DashboardView(
            pid: user.pid,
            credentials: user.credentials,
            vm: RegisterPinViewModel(transport: gatewayApiClient)
          )
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
          credential: userViewModel.userSnapshot?.pid
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
