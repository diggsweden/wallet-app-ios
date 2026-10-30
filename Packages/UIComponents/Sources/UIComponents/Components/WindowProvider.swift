// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import SwiftUI

struct WindowProvider: UIViewRepresentable {
  let onWindow: (UIWindow?) -> Void

  func makeUIView(context: Context) -> UIView {
    let view = UIView()

    DispatchQueue.main.async {
      onWindow(view.window)
    }

    return view
  }

  func updateUIView(_ uiView: UIView, context: Context) {
    DispatchQueue.main.async {
      onWindow(uiView.window)
    }
  }
}
