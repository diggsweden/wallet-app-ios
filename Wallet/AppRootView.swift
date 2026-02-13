// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import AuthenticationServices
import SwiftData
import SwiftUI

struct AppRootView: View {
  private let gatewayAPIClient: GatewayAPI
  @State private var userViewModel: UserViewModel
  @State private var router = Router()
  @Environment(\.theme) private var theme

  init(userStore: UserStore, gatewayAPIClient: GatewayAPI) {
    _userViewModel = State(wrappedValue: .init(userStore: userStore))
    self.gatewayAPIClient = gatewayAPIClient
  }

  var body: some View {
    NavigationStack(path: $router.navigationPath) {
      rootView
        .padding(.horizontal, theme.horizontalPadding)
        .containerRelativeFrame([.horizontal, .vertical])
        .background(theme.colors.background)
        .navigationDestination(for: Route.self) { route in
          destination(for: route)
            .padding(.horizontal, theme.horizontalPadding)
            .containerRelativeFrame([.horizontal, .vertical])
            .background(theme.colors.background)
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
            gatewayAPIClient: gatewayAPIClient,
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
    switch userViewModel.user {
      case .ready(let user):
        destination(for: route, userSnapshot: user)

      default:
        ProgressView()
    }
  }

  @ViewBuilder
  private func destination(for route: Route, userSnapshot: UserSnapshot) -> some View {
    switch route {
      case .presentation(let data):
        PresentationView(
          vpTokenData: data,
          credential: userSnapshot.credential
        )

      case .issuance(let url):
        IssuanceViewWrapper(
          credentialOfferUri: url,
          gatewayAPIClient: gatewayAPIClient
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
