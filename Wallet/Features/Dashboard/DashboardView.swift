// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import SwiftAccessMechanism
import SwiftUI

struct DashboardView: View {
  let pid: SavedCredential?
  let credentials: [SavedCredential]
  @Environment(\.openURL) private var openURL
  @Environment(Router.self) private var router
  @Environment(\.theme) private var theme

  var body: some View {
    ScrollView {
      VStack(alignment: .center, spacing: 30) {
        WalletTitleView()
          .padding(.top, 20)

        if let pid {
          PidCard(credential: pid)
            .padding(5)
        }

        if !credentials.isEmpty {
          VStack(alignment: .leading, spacing: 20) {
            Text("Handlingar")
              .textStyle(.h2)
            ForEach(credentials, id: \.self) { credential in
              DocumentCard(credential: credential)
            }
          }
        }
      }
    }
    .toolbar {
      ToolbarItem(placement: .topBarTrailing) {
        Button {
          openURL(AppConfig.pidIssuerUrl)
        } label: {
          Image(systemName: "plus")
            .accessibilityLabel("Lägg till dokument")
        }
      }
      if #available(iOS 26.0, *) {
        ToolbarSpacer(.fixed, placement: .topBarTrailing)
      }
      ToolbarItem(placement: .topBarTrailing) {
        Button {
          router.go(to: .settings)
        } label: {
          Image(systemName: "gearshape")
            .accessibilityLabel("Inställningar")
        }
      }
    }
    .background(.clear)
    .navigationBarTitleDisplayMode(.inline)
  }
}

#if DEBUG
  // swiftlint:disable async_without_await
  private struct PreviewBFFTransport: BFFTransport {
    func registerState(
      publicKey: JwkKey,
      overwrite: Bool,
      ttl: String?,
    ) async throws -> RegisterStateResponse {
      RegisterStateResponse(clientId: "", devAuthorizationCode: nil)
    }

    func registerPin(request: BFFRequest) async throws -> Data { Data() }
    func createSession(request: BFFRequest) async throws -> Data { Data() }
    func createKey(request: BFFRequest) async throws -> Data { Data() }
    func listKeys(request: BFFRequest) async throws -> Data { Data() }
    func sign(request: BFFRequest) async throws -> Data { Data() }
    func deleteKey(request: BFFRequest) async throws {}
    func changePin(request: SwiftAccessMechanism.BFFRequest) async throws -> Data { Data() }
  }
  // swiftlint:enable async_without_await

  #Preview {
    NavigationStack {
      DashboardView(
        pid: .previewPidCredential,
        credentials: [],
      )
      .environment(Router())
      .defaultScreenStyle
      .themed
    }
  }

  #Preview("PID + Flera Dokument") {
    NavigationStack {
      DashboardView(
        pid: .previewPidCredential,
        credentials: [
          .previewCredential(named: "Körkort"),
          .previewCredential(named: "Handlingar"),
          .previewCredential(named: "Biljetter"),
        ],
      )
      .environment(Router())
      .defaultScreenStyle
      .themed
    }
  }
#endif

private extension SavedCredential {
  static let previewPidCredential = SavedCredential(
    issuer: IssuerDisplay(name: "Digg", info: "Svensk e-legitimation", imageUrl: nil),
    compactSerialized: "",
    claimDisplayNames: [
      "given_name": "Förnamn",
      "family_name": "Efternamn",
    ],
    claimsCount: 2,
    issuedAt: .now,
    type: CredentialType.pid.rawValue,
    displayData: nil,
  )

  static func previewCredential(named name: String) -> SavedCredential {
    SavedCredential(
      issuer: IssuerDisplay(name: "Digg", info: "Digital plånbok", imageUrl: nil),
      compactSerialized: "",
      claimDisplayNames: [:],
      claimsCount: 4,
      issuedAt: .now,
      type: "preview.\(name.lowercased())",
      displayData: CredentialDisplayData(name: name),
    )
  }
}
