// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import CredentialInterfaces
import DesignSystem
import SwiftUI

struct PresentationClaimPreviewView: View {
  @Environment(\.theme) private var theme

  let claims: [ClaimUiModel]

  var body: some View {
    VStack(alignment: .leading, spacing: Constants.spacing) {
      ForEach(previewClaims) { claim in
        if let displayName = claim.displayName {
          Text(displayName)
            .textStyle(.bodySmall)
            .foregroundStyle(theme.colors.textInformation)
        }
      }

      if hiddenClaimCount > .zero {
        Text("+ \(hiddenClaimCount) till")
          .textStyle(.labelLarge)
          .foregroundStyle(theme.colors.linkPrimary)
      }
    }
  }
}

private extension PresentationClaimPreviewView {
  enum Constants {
    static let previewCount = 4
    static let spacing: CGFloat = 4
  }

  var previewClaims: [ClaimUiModel] {
    Array(claims.prefix(Constants.previewCount))
  }

  var hiddenClaimCount: Int {
    claims.count - previewClaims.count
  }
}

#Preview {
  PresentationClaimPreviewView(
    claims: ["Förnamn", "Efternamn", "Födelsedatum", "Personnummer", "Kön", "Över 18 år"]
      .map { name in ClaimUiModel(id: name, displayName: name, value: .null) }
  )
  .padding()
  .themed
}
