// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import DesignSystem
import SwiftUI

public struct PinView: View {
  let submitLabel: LocalizedStringResource
  let onSubmit: (String) throws -> Void

  @Environment(\.theme) private var theme
  @Environment(ToastViewModel.self) private var toastViewModel
  @Environment(\.orientation) private var orientation
  @State private var pin = ""
  @State private var errorFeedback = false

  public init(
    submitLabel: LocalizedStringResource,
    onSubmit: @escaping (String) throws -> Void,
  ) {
    self.submitLabel = submitLabel
    self.onSubmit = onSubmit
  }

  public var body: some View {
    VStack(
      spacing: orientation.isLandscape
        ? Constants.landscapeSectionSpacing : Constants.sectionSpacing
    ) {
      dotsView

      PinKeypadView(
        submitLabel: submitLabel,
        isDeleteEnabled: !pin.isEmpty,
        isSubmitEnabled: pin.count == Constants.pinLength,
        onTapDigit: appendDigit,
        onTapDelete: { pin.removeLast() },
        onTapSubmit: submit,
      )
    }
    .scrollInLandscape(
      topContentPadding: Constants.landscapeTopContentPadding
    )
    .sensoryFeedback(.error, trigger: errorFeedback)
  }
}

private extension PinView {
  enum Constants {
    static let pinLength = 6
    static let sectionSpacing: CGFloat = 38
    static let landscapeSectionSpacing: CGFloat = 20
    static let dotSpacing: CGFloat = 20
    static let dotSize: CGFloat = 20
    static let landscapeTopContentPadding: CGFloat = 24
  }

  var dotsView: some View {
    HStack(spacing: Constants.dotSpacing) {
      ForEach(0 ..< Constants.pinLength, id: \.self) { index in
        PinDot(
          filled: index < pin.count,
          color: theme.colors.buttonSecondaryHover,
          size: Constants.dotSize,
        )
      }
    }
    .accessibilityElement(children: .ignore)
    .accessibilityLabel("PIN-kod")
    .accessibilityValue("\(pin.count) av \(Constants.pinLength) siffror")
  }

  func submit() {
    do {
      try onSubmit(pin)
    } catch {
      toastViewModel.showError(error.message)
      resetAfterError()
    }
  }

  func resetAfterError() {
    pin = ""
    errorFeedback.toggle()
  }

  func appendDigit(_ digit: Character) {
    guard pin.count < Constants.pinLength else {
      return
    }

    pin.append(digit)
  }
}

#Preview("Default") {
  PinView(submitLabel: "Nästa") { _ in }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .themed
    .withOrientation
    .withToast
}
