// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import SwiftAccessMechanism
import SwiftUI
import User
import WalletGatewayInterface

struct AppRootView: View {
  private let gatewayApiClient: any GatewayApi & HSMTransport
  @State private var userViewModel: UserViewModel
  @State private var router = Router()

  init(appDependencies: AppDependencies) {
    _userViewModel = State(wrappedValue: appDependencies.userViewModel)
    self.gatewayApiClient = appDependencies.gatewayApiClient
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
    .sheet(item: $router.presentedSheet) { sheet in
      switch sheet {
        case .settings:
          SettingsView(
            showsLogout: userViewModel.isOnboardingCompleted,
            onLogout: userViewModel.signOut,
          )
      }
    }
    .environment(router)
    .onOpenURL(perform: handleOpenURL)
  }
}

// MARK: - Child views
private extension AppRootView {
  @ViewBuilder
  var rootView: some View {
    let user = userViewModel.user
    if !userViewModel.isOnboardingCompleted {
      OnboardingRootView(
        gatewayApiClient: gatewayApiClient,
        userSnapshot: user,
        actions: OnboardingActions(
          signIn: userViewModel.signIn,
          saveCredential: userViewModel.saveCredential,
          resetSession: userViewModel.signOut,
          saveHsmServerParameters: userViewModel.saveHsmServerParameters,
          saveBackendGeneration: userViewModel.saveBackendGeneration,
          onComplete: userViewModel.completeOnboarding,
        ),
      )
    } else {
      DashboardView(
        pid: user.credentials.first,
        credentials: Array(user.credentials.dropFirst()),
      )
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
          credentials: userViewModel.user.credentials,
          hsmTransport: gatewayApiClient,
          hsmServerParameters: userViewModel.user.hsmServerParameters,
        )

      case .issuance(let url):
        IssuanceViewWrapper(
          credentialOfferUri: url,
          gatewayApiClient: gatewayApiClient,
          hsmServerParameters: userViewModel.user.hsmServerParameters,
          actions: .init(
            onSaveCredential: userViewModel.saveCredential,
            onComplete: { router.pop() },
            onDismiss: { router.pop() },
          ),
        )

      case .credentialDetails(let credential):
        CredentialDetailsView(credential: credential)
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
