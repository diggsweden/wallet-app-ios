// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import QRScanner
import SwiftAccessMechanism
import SwiftUI
import Trust
import UIComponents
import User
import WalletGatewayInterface

struct AppRootView: View {
  private let gatewayApiClient: any GatewayApi & HSMTransport
  private let trustStore: any TrustStoreInterface
  @State private var userViewModel: UserViewModel
  @State private var router = Router()

  init(appDependencies: AppDependencies) {
    _userViewModel = State(wrappedValue: appDependencies.userViewModel)
    self.gatewayApiClient = appDependencies.gatewayApiClient
    self.trustStore = appDependencies.trustStore
  }

  var body: some View {
    NavigationStack(path: $router.navigationPath) {
      rootView
        .defaultScreenStyle
        .navigationDestination(for: Route.self, destination: destinationContent)
    }
    .sheet(item: $router.presentedSheet, content: sheetContent)
    .fullScreenCover(item: $router.presentedFullScreenCover, content: fullScreenCoverContent)
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
        trustStore: trustStore,
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
  @ContentBuilder
  func destinationContent(for route: Route) -> some View {
    Group {
      switch route {
        case .issuance(let url):
          IssuanceViewWrapper(
            url: url,
            gatewayApiClient: gatewayApiClient,
            hsmServerParameters: userViewModel.user.hsmServerParameters,
            trustStore: trustStore,
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
    .defaultScreenStyle
  }

  @ContentBuilder
  func sheetContent(for sheet: Router.Sheet) -> some View {
    switch sheet {
      case .settings:
        SettingsView(
          showsLogout: userViewModel.isOnboardingCompleted,
          onLogout: userViewModel.signOut,
        )

      case .presentation(let url):
        PresentationView(
          url: url,
          credentials: userViewModel.user.credentials,
          hsmTransport: gatewayApiClient,
          hsmServerParameters: userViewModel.user.hsmServerParameters,
          trustStore: trustStore,
        )
    }
  }

  @ContentBuilder
  func fullScreenCoverContent(for cover: Router.FullScreenCover) -> some View {
    switch cover {
      case .camera:
        WalletQRScannerView(
          onSuccess: { url in
            router.dismiss()
            handleOpenURL(url)
          },
          onDismiss: {
            router.dismiss()
          },
        )
    }
  }

  func handleOpenURL(_ url: URL) {
    guard let deeplink = Deeplink(url) else {
      return
    }

    router.open(deeplink)
  }
}
