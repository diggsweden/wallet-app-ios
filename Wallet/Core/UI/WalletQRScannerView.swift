// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import QRScanner
import SwiftUI

struct WalletQRScannerView: View {
  let onSuccess: (URL) -> Void
  let onDismiss: () -> Void

  var body: some View {
    // swiftlint:disable:next closure_body_length
    QRScannerView(onSuccess: onSuccess) {
      ErrorView(
        model: .init(
          imageReference: "cameraPermissionError",
          title: "Kameran är inte tillgänglig",
          subtitle: """
            Kameran behövs för att skanna. Kontrollera att kameraåtkomst är \
            på i Inställningar. Om den redan är på kan Skärmtid eller en begränsning på \
            enheten blockera den.
            """,
          primaryButton: .init(
            label: "Öppna inställningar",
            accessibilityHint: "Tryck här för att öppna kamera-inställningarna för appen",
            action: {
              Task { @MainActor in
                if let url = URL(string: UIApplication.openSettingsURLString) {
                  UIApplication.shared.open(url)
                }
              }
            },
          ),
          secondaryButton: .init(
            label: "Inte nu",
            accessibilityHint: "Tryck här för att stänga",
            action: {
              Task { @MainActor in
                onDismiss()
              }
            },
          ),
        )
      )
    }
  }
}
