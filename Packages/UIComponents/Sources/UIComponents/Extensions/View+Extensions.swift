// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import SwiftUI

extension View {
  @ViewBuilder
  public func glassEffectIfPossible() -> some View {
    if #available(iOS 26.0, *) {
      self.glassEffect(
        .regular.interactive(),
        in: RoundedRectangle(cornerRadius: 12),
      )
    } else {
      self
        .background(
          .ultraThinMaterial,
          in: RoundedRectangle(cornerRadius: 12),
        )
    }
  }

  @ViewBuilder
  public func lineHeightIfAvailable(multiple factor: CGFloat?) -> some View {
    if #available(iOS 26.0, *) {
      if let factor {
        self.lineHeight(.multiple(factor: factor))
      } else {
        self.lineHeight(nil)
      }
    } else {
      self
    }
  }

  @ContentBuilder
  public func safeAreaBarIfPossible<Content: View>(
    edge: VerticalEdge,
    @ContentBuilder content: () -> Content,
  ) -> some View {
    if #available(iOS 26.0, *) {
      self.safeAreaBar(edge: edge, content: content)
    } else {
      self.safeAreaInset(edge: edge) {
        content()
          .background(.bar)
      }
    }
  }

  @ContentBuilder
  public func softScrollEdgeEffectIfPossible(for edge: Edge.Set) -> some View {
    if #available(iOS 26.0, *) {
      self.scrollEdgeEffectStyle(.soft, for: edge)
    } else {
      self
    }
  }

  public func staticAnimation(setTo animation: Animation?) -> some View {
    self
      .transaction { t in
        t.animation = animation
      }
  }
}
