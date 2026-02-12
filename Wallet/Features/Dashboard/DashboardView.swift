// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import SwiftUI

struct DashboardView: View {
  let credential: Credential?
  @Environment(Router.self) private var router
  @Environment(\.theme) private var theme

  var body: some View {
    ScrollView {
      VStack(alignment: .center, spacing: 20) {
        Text("dashboard_welcome")
          .textStyle(.h5)
          .padding(.top, 10)
        Text("dashboard_content_1")

        VStack {
          if let credential {
            CredentialCard(credential: credential)
          }
          CredentialCard(credential: nil)
        }
      }
    }
    .toolbar {
      ToolbarItem(placement: .title) {
        Text("ID-plånboken")
          .textStyle(.caption)
      }
      ToolbarItem(placement: .topBarTrailing) {
        Button {
          router.go(to: .settings)
        } label: {
          Image(systemName: "gearshape")
        }
      }
    }
    .background(.clear)
    .toolbarRole(.editor)
  }
}

#Preview {
  DashboardView(credential: nil)
    .environment(Router())
}
