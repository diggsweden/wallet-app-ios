import SwiftData
import SwiftUI

struct AppRootView: View {
  @State private var userViewModel: UserViewModel
  @State private var router = Router()
  @Environment(\.theme) private var theme

  init(userStore: UserStore) {
    _userViewModel = State(wrappedValue: .init(userStore: userStore))
  }

  var body: some View {
    NavigationStack(path: $router.navigationPath) {
      rootView
        .containerRelativeFrame([.horizontal, .vertical])
        .background(theme.colors.background)
        .navigationDestination(for: Route.self) { route in
          destination(for: route)
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
          EnrollmentView(
            userSnapshot: user,
            setKeyAttestation: userViewModel.setKeyAttestation,
            signIn: userViewModel.signIn
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
        IssuanceView(
          credentialOfferUri: url,
          walletUnitAttestation: userSnapshot.walletUnitAttestation
        ) { credential in
          await userViewModel.setCredential(credential)
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
