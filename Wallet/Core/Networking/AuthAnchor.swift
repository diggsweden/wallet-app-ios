// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import AuthenticationServices
import SwiftUI

extension EnvironmentValues {
  @Entry var authPresentationAnchor: ASPresentationAnchor? = nil
}

struct PresentationAnchorProvider: UIViewRepresentable {
  let provideAnchor: (UIWindow?) -> Void

  func makeUIView(context: Context) -> UIView {
    let view = UIView()

    DispatchQueue.main.async {
      provideAnchor(view.window)
    }

    return view
  }

  func updateUIView(_ uiView: UIView, context: Context) {
    DispatchQueue.main.async {
      provideAnchor(uiView.window)
    }
  }
}
