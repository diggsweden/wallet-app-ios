// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import DesignSystem
import SwiftUI

public struct PinView: View {
  let submitLabel: LocalizedStringResource
  let isLoading: Bool
  let onSubmit: (String) throws -> Void

  @Environment(\.theme) private var theme
  @Environment(ToastViewModel.self) private var toastViewModel
  @Environment(\.orientation) private var orientation
  @Environment(\.accessibilityReduceMotion) private var reduceMotion
  @State private var pin = ""
  @State private var isRevealed: Bool
  @State private var errorFeedback = false

  public init(
    submitLabel: LocalizedStringResource,
    isLoading: Bool = false,
    animatesAppearance: Bool = false,
    onSubmit: @escaping (String) throws -> Void,
  ) {
    self.submitLabel = submitLabel
    self.isLoading = isLoading
    self.onSubmit = onSubmit
    _isRevealed = State(initialValue: !animatesAppearance)
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
      .disabled(isLoading)
      .opacity(isLoading ? Constants.loadingKeypadOpacity : 1)
      .animation(.smooth, value: isLoading)
      .scaleEffect(isRevealed || reduceMotion ? 1 : Constants.hiddenScale)
      .opacity(isRevealed ? 1 : 0)
      .animation(
        .bouncy(
          duration: Constants.revealDuration,
          extraBounce: Constants.revealExtraBounce,
        ),
        value: isRevealed,
      )
    }
    .scrollInLandscape(
      topContentPadding: Constants.landscapeTopContentPadding
    )
    .sensoryFeedback(.error, trigger: errorFeedback)
    .onChange(of: isLoading) { _, isLoading in
      if !isLoading {
        resetAfterError()
      }
    }
    .task {
      isRevealed = true
    }
  }
}

private extension PinView {
  enum Constants {
    static let pinLength = 6
    static let sectionSpacing: CGFloat = 38
    static let landscapeSectionSpacing: CGFloat = 20
    static let dotSpacing: CGFloat = 20
    static let dotSize: CGFloat = 20
    static let loadingKeypadOpacity: CGFloat = 0.4
    static let hiddenScale: CGFloat = 0.85
    static let revealDuration: TimeInterval = 0.5
    static let revealExtraBounce: Double = 0.15
    static let waveHeight: CGFloat = 8
    static let waveStep: TimeInterval = 0.08
    static let waveRiseDuration: TimeInterval = 0.18
    static let waveFallDuration: TimeInterval = 0.24
    static let wavePeriod: TimeInterval = 1
    static let reducedMotionDimming: CGFloat = 0.6
    static let landscapeTopContentPadding: CGFloat = 24
  }

  var dotsView: some View {
    let waveHeight = reduceMotion ? 0 : Constants.waveHeight
    let waveDimming = reduceMotion ? Constants.reducedMotionDimming : 0

    return HStack(spacing: Constants.dotSpacing) {
      ForEach(0 ..< Constants.pinLength, id: \.self) { index in
        let dot = PinDot(
          filled: index < pin.count,
          color: theme.colors.buttonSecondaryHover,
          size: Constants.dotSize,
        )

        if isLoading {
          dot
            .keyframeAnimator(initialValue: CGFloat.zero) { dot, lift in
              dot
                .offset(y: -lift * waveHeight)
                .opacity(1 - lift * waveDimming)
            } keyframes: { _ in
              waveKeyframes(for: index)
            }
        } else {
          dot
        }
      }
    }
    .accessibilityElement(children: .ignore)
    .accessibilityLabel("PIN-kod")
    .accessibilityValue("\(pin.count) av \(Constants.pinLength) siffror")
  }

  func waveKeyframes(for index: Int) -> some Keyframes<CGFloat> {
    let delay = Double(index + 1) * Constants.waveStep
    let rest =
      Constants.wavePeriod - delay - Constants.waveRiseDuration
      - Constants.waveFallDuration

    return KeyframeTrack {
      LinearKeyframe(0, duration: delay)
      SpringKeyframe(1, duration: Constants.waveRiseDuration)
      SpringKeyframe(0, duration: Constants.waveFallDuration)
      LinearKeyframe(0, duration: rest)
    }
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

#Preview("Reveal") {
  @Previewable @State var shouldShow = false

  ZStack {
    Group {
      if shouldShow {
        PinView(submitLabel: "Dela", animatesAppearance: true) { _ in }
          .frame(maxWidth: .infinity, maxHeight: .infinity)
          .themed
          .withOrientation
          .withToast
      } else {
        ProgressView()
      }
    }
    .transition(.opacity)
  }
  .animation(.default, value: shouldShow)
  .task {
    try? await Task.sleep(for: .seconds(1))
    shouldShow = true
  }
}

#Preview("Loading") {
  @Previewable @State var isLoading = false

  PinView(submitLabel: "Dela", isLoading: isLoading) { _ in
    Task {
      isLoading = true
      try? await Task.sleep(for: .seconds(3))
      isLoading = false
    }
  }
  .frame(maxWidth: .infinity, maxHeight: .infinity)
  .themed
  .withOrientation
  .withToast
}
