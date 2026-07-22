// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import AuthenticationServices
import SDWebImageWebPCoder
import SwiftAccessMechanism
import SwiftData
import SwiftUI
import User
import WalletGateway

struct AppRootView: View {
  private let gatewayApiClient: GatewayApiClient
  @State private var userSessionViewModel: UserSessionViewModel
  @State private var router = Router()
  @State private var isLogoutErrorAlertPresented = false
  @State private var isFirstError: Bool = true

  init(userStore: UserStore, gatewayApiClient: GatewayApiClient) {
    _userSessionViewModel = State(wrappedValue: .init(userStore: userStore))
    self.gatewayApiClient = gatewayApiClient
    SDImageCodersManager.shared.addCoder(SDImageAWebPCoder.shared)
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
      await userSessionViewModel.initUser()
    }
    .alert("Kunde inte logga ut", isPresented: $isLogoutErrorAlertPresented) {
      Button("Försök igen") { signOutFromErrorState() }
      Button("Avbryt", role: .cancel) {}
    }
  }
}

// MARK: - Child views
private extension AppRootView {
  @ViewBuilder
  var rootView: some View {
    ZStack {
      switch userSessionViewModel.user {
        case .ready(let user):
          userStateReadyView(user)
            .transition(.blurReplace)

        case .loading:
          ProgressView()
            .transition(.blurReplace)

        case let .error(caught):
          errorView(caught: caught)
            .transition(.blurReplace)
      }
    }
    .animation(.default, value: userSessionViewModel.user)
  }

  func errorView(caught: CaughtError) -> some View {
    ErrorView(
      model: .init(
        caughtError: caught,
        primaryButton: .init(
          label: "Försök igen",
          accessibilityHint: "Använd knappen för att försöka igen",
          asyncAction: userSessionViewModel.retryInitUser,
        ),
        secondaryButton: .init(
          label: "Logga ut",
          accessibilityHint: "Använd knappen för att logga ut",
          action: {
            Task { @MainActor in
              signOutFromErrorState()
            }
          },
        ),
      )
    )
  }

  @ViewBuilder
  func userStateReadyView(_ user: UserSnapshot) -> some View {
    if !userSessionViewModel.isEnrolled {
      OnboardingRootView(
        gatewayApiClient: gatewayApiClient,
        userSnapshot: user,
        actions: OnboardingActions(
          signIn: userSessionViewModel.signIn,
          savePidCredential: userSessionViewModel.savePid,
          resetSession: userSessionViewModel.signOut,
          saveHsmServerParameters: userSessionViewModel.saveHsmServerParameters,
        ),
      )
    } else {
      DashboardView(
        pid: user.pid,
        credentials: user.credentials,
      )
    }
  }
}

// MARK: - Actions
private extension AppRootView {
  func signOutFromErrorState() {
    Task {
      do {
        try await userSessionViewModel.signOut()
      } catch {
        isLogoutErrorAlertPresented = true
      }
    }
  }
}

// MARK: - Deeplink
private extension AppRootView {
  @ViewBuilder
  func destination(for route: Route) -> some View {
    switch route {
      case .presentation(let url):
        PresentationView(
          url: url,
          credential: userSessionViewModel.userSnapshot?.pid,
          gatewayApiClient: gatewayApiClient,
          hsmServerParameters: userSessionViewModel.userSnapshot?.hsmServerParameters,
        )

      case .issuance(let url):
        IssuanceViewWrapper(
          credentialOfferUri: url,
          gatewayApiClient: gatewayApiClient,
          hsmServerParameters: userSessionViewModel.userSnapshot?.hsmServerParameters,
        ) { credential in
          try await userSessionViewModel.saveCredential(credential)
          router.pop()
        }

      case .credentialDetails(let credential):
        CredentialDetailsView(credential: credential)

      case .settings:
        SettingsView(onLogout: userSessionViewModel.signOut)
    }
  }

  func handleOpenURL(_ url: URL) {
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
