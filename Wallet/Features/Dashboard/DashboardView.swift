import SwiftUI

struct DashboardView: View {
  @Environment(\.openURL) var openURL
  @StateObject private var viewModel = DashboardViewModel()

  var body: some View {
    NavigationStack(path: $viewModel.navigationPath) {
      VStack(alignment: .center) {
        Image("logo")
        Text("dashboard_welcome").font(.title).padding(.bottom, 10)
        Text("dashboard_content_1").multilineTextAlignment(.center)
        Text("dashboard_content_2").multilineTextAlignment(.center)
          .padding(
            .bottom,
            10
          )

        Text("dashboard_more_info_1")
        Text("dashboard_more_info_2")
          .padding(.bottom, 10)
          .foregroundColor(.blue)
          .underline()
          .onTapGesture {
            if let url = URL(
              string:
                "https://ec.europa.eu/digital-building-blocks/sites/display/EUDIGITALIDENTITYWALLET/EU+Digital+Identity+Wallet+Home"
            ) {
              openURL(url)
            }
          }

        Text("dashboard_pid_1")
        Text("dashboard_more_info_2")
          .foregroundColor(.blue)
          .underline()
          .onTapGesture {
            if let url = URL(
              string:
                "https://wallet.sandbox.digg.se/prepare-credential-offer"
            ) {
              openURL(url)
            }
          }
      }
      .frame(alignment: .center)
      .padding()
      .navigationDestination(for: String.self) { credentialOfferUri in
        PidDetailView(credentialOfferUri: credentialOfferUri)
      }
      .onOpenURL { url in
        print("URL: absolute " + url.absoluteString)
        viewModel.handleDeepLink(url: url)
      }
    }
  }
}

#Preview {
  DashboardView().environment(\.locale, .init(identifier: "swe"))
}
