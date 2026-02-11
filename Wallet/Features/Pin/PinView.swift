// SPDX-FileCopyrightText: 2026 diggsweden/wallet-app-ios
//
// SPDX-License-Identifier: EUPL-1.2

import SwiftUI

struct PinView: View {
  let maxDigits: Int = 6
  let buttonText: String
  let onComplete: (String) throws -> Void
  @Environment(\.theme) private var theme
  @Environment(\.dynamicTypeSize) private var dynamicType
  @Environment(\.orientation) private var orientation
  @Environment(ToastViewModel.self) private var toastViewModel
  @State private var pin: String = ""
  @State private var error: String?
  @State private var onErrorFeedback: Bool = false
  @State private var gridWidth: CGFloat = 0

  init(
    buttonText: String = "Identifiera",
    onComplete: @escaping (String) throws -> Void,
  ) {
    self.buttonText = buttonText
    self.onComplete = onComplete
  }

  var body: some View {
    let verticalSpacing = orientation.isLandscape ? 20.0 : 38.0

    VStack(spacing: verticalSpacing) {
      pinDots

      T9KeypadView(
        onTapDigit: { updatePin(with: $0) },
        clearButtonDisabled: pin.count < 1,
        onClear: { pin.removeLast() }
      )
      .background(
        GeometryReader { proxy in
          Color.clear.preference(
            key: GridWidthKey.self,
            value: proxy.size.width
          )
        }
      )
      .padding(.bottom, 10)
      PrimaryButton(buttonText, maxWidth: gridWidth) {
        handlePinComplete()
      }
    }
    .onPreferenceChange(GridWidthKey.self) { gridWidth = $0 }
    .scrollInLandscape
    .sensoryFeedback(.error, trigger: onErrorFeedback)
  }

  private var pinDots: some View {
    HStack(spacing: 20) {
      ForEach(0 ..< maxDigits, id: \.self) { index in
        PinDot(
          filled: index < pin.count,
          color: theme.colors.buttonSecondaryHover,
          size: 20
        )
      }
    }
  }

  private struct GridWidthKey: PreferenceKey {
    static let defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
      value = max(value, nextValue())
    }
  }

  private func updatePin(with digit: Character) {
    guard pin.count < maxDigits else {
      return
    }

    pin.append(digit)
  }

  private func handlePinComplete() {
    do {
      try onComplete(pin)
      error = nil
    } catch {
      toastViewModel.showError(error.message)
      onErrorFeedback.toggle()
      pin = ""
    }
  }
}

#Preview {
  PinView { _ in }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .themed
    .withOrientation
    .withToast
}
