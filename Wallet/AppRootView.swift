import SwiftData
import SwiftUI

struct AppRootView: View {
  @State private var sessionViewModel: SessionViewModel
  @State private var router = Router()
  @Environment(\.theme) private var theme

  init(sessionStore: SessionStore) {
    _sessionViewModel = State(wrappedValue: .init(sessionStore: sessionStore))
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
      await sessionViewModel.initSession()
    }
  }

  @ViewBuilder
  private var rootView: some View {
    switch sessionViewModel.session {
      case .ready(let session):
        if !sessionViewModel.isEnrolled {
          EnrollmentView(
            appSession: session,
            setKeyAttestation: sessionViewModel.setKeyAttestation,
            signIn: sessionViewModel.signIn
          )
        } else {
          DashboardView(credential: session.credential)
        }

      case .loading, .error:
        ProgressView()
    }
  }

  @ViewBuilder
  private func destination(for route: Route) -> some View {
    switch sessionViewModel.session {
      case .ready(let session):
        destination(for: route, session: session)

      default:
        ProgressView()
    }
  }

  @ViewBuilder
  private func destination(for route: Route, session: AppSession) -> some View {
    switch route {
      case .presentation(let data):
        PresentationView(vpTokenData: data, keyTag: session.keyTag, credential: session.credential)

      case .issuance(let url):
        IssuanceView(
          credentialOfferUri: url,
          keyTag: session.keyTag,
          walletUnitAttestation: session.walletUnitAttestation
        ) { credential in
          await sessionViewModel.setCredential(credential)
        }

      case .credentialDetails(let credential):
        CredentialDetailsView(credential: credential)

      case .settings:
        SettingsView(onLogout: sessionViewModel.signOut)
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
