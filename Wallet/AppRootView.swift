import SwiftData
import SwiftUI

struct AppRootView: View {
  private enum RootDestination: Equatable {
    case dashboard, enrollment
  }

  @Environment(\.modelContext) private var modelContext
  @State private var router = Router()
  @Query private var sessions: [AppSession]
  private var session: AppSession? { sessions.first }

  private var isEnrolled: Bool { session?.user != nil && session?.wallet.unitAttestation != nil }
  private var rootDestination: RootDestination { isEnrolled ? .dashboard : .enrollment }

  var body: some View {
    baseContainer
      .animation(.easeInOut, value: rootDestination)
      .animation(.easeInOut, value: session)
      .task(id: session) {
        initSession()
      }
  }

  @ViewBuilder
  private var baseContainer: some View {
    if let session {
      NavigationStack(path: $router.navigationPath) {
        rootView(session: session)
          .transition(.blurReplace)
          .navigationDestination(for: Route.self) { route in
            return destination(for: route, session: session)
          }
          .onOpenURL(perform: handleOpenURL)
      }
      .environment(router)
    } else {
      ProgressView()
    }
  }

  @ViewBuilder
  private func rootView(session: AppSession) -> some View {
    switch rootDestination {
      case .dashboard:
        DashboardView(credential: session.wallet.credential)
      case .enrollment:
        EnrollmentView(appSession: session)
    }
  }

  @ViewBuilder
  private func destination(for route: Route, session: AppSession) -> some View {
    switch route {
      case .presentation(let data):
        if let credential = session.wallet.credential {
          PresentationView(vpTokenData: data, credential: credential)
        } else {
          Text("No credential found on device!")
        }
      case .issuance(let url):
        IssuanceView(credentialOfferUri: url, keyTag: session.keyTag, wallet: session.wallet)
      case .credentialDetails(let credential):
        CredentialDetailsView(credential: credential)
      case .settings:
        SettingsView(onLogout: logout)
    }
  }

  private func initSession() {
    guard session == nil else {
      return
    }

    modelContext.insert(AppSession())
    try? modelContext.save()
  }

  private func handleOpenURL(_ url: URL) {
    guard isEnrolled else {
      return
    }

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

  private func logout() {
    try? modelContext.delete(model: AppSession.self)
    try? modelContext.save()
  }
}
