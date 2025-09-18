import SwiftUI

struct T9Key: Identifiable, Hashable {
  let digit: Character
  let letters: String
  var id: Character { digit }
}

struct PinView: View {
  let maxDigits: Int = 6
  let onComplete: (String) throws -> Void
  @State private var pin: String = ""
  @State private var error: String?
  @State private var onErrorFeedback: Bool = false
  @State private var onTapFeedback: Bool = false

  private let digitRows: [[T9Key]] = [
    [
      .init(digit: "1", letters: ""),
      .init(digit: "2", letters: "ABC"),
      .init(digit: "3", letters: "DEF"),
    ],
    [
      .init(digit: "4", letters: "GHI"),
      .init(digit: "5", letters: "JKL"),
      .init(digit: "6", letters: "MNO"),
    ],
    [
      .init(digit: "7", letters: "PQRS"),
      .init(digit: "8", letters: "TUV"),
      .init(digit: "9", letters: "WXYZ"),
    ],
    [.init(digit: "0", letters: "+")],
  ]

  private func updatePin(with digit: Character) {
    guard pin.count < maxDigits else {
      return
    }

    pin.append(digit)
    onTapFeedback.toggle()

    if pin.count == maxDigits {
      handlePinComplete()
    }
  }

  private func clearPin() {
    pin = ""
    onTapFeedback.toggle()
  }

  private func handlePinComplete() {
    do {
      try onComplete(pin)
      error = nil
    } catch {
      self.error = error.message
      onErrorFeedback.toggle()
      pin = ""
    }
  }

  var body: some View {
    VStack(spacing: 12) {
      ErrorView(text: error, show: error != nil)
      VStack {
        pinField
        t9Grid
      }
      .phaseAnimator([0, 10], trigger: onErrorFeedback) { view, phase in
        view.offset(x: phase)
      } animation: { _ in
        .spring(response: 0.15, dampingFraction: 0.3)
      }
    }
    .sensoryFeedback(.error, trigger: onErrorFeedback)
    .sensoryFeedback(.impact, trigger: onTapFeedback)
    .frame(maxWidth: 400, maxHeight: 400)
    .padding()
  }

  var pinField: some View {
    SecureField("6-siffrig PIN", text: $pin)
      .multilineTextAlignment(.center)
      .keyboardType(.numberPad)
      .textFieldStyle(.primary)
      .allowsHitTesting(false)
  }

  var clearButton: some View {
    Button(action: clearPin) {
      Image(systemName: "chevron.left")
    }
    .buttonStyle(.plain)
  }

  var t9Grid: some View {
    Grid {
      ForEach(digitRows, id: \.self) { row in
        GridRow {
          ForEach(row) { key in
            if row.count == 1 {
              clearButton
              keyCell(for: key)
            } else {
              keyCell(for: key)
            }
          }
        }
      }
    }
  }

  @ViewBuilder
  private func keyCell(for key: T9Key) -> some View {
    VStack(spacing: 2) {
      Text(String(key.digit))
        .font(.title2)
        .fontWeight(.semibold)
      Text(key.letters)
        .font(.footnote)
        .foregroundStyle(.secondary)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .contentShape(Rectangle())
    .onTapGesture {
      updatePin(with: key.digit)
    }
  }
}

#Preview {
  PinView {
    _ in
  }
}
