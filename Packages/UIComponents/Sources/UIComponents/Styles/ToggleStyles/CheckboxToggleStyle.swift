// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import DesignSystem
import SwiftUI

public struct CheckboxToggleStyle: ToggleStyle {
  public init() {}

  public func makeBody(configuration: Configuration) -> some View {
    CheckboxToggleView(configuration: configuration)
  }
}

extension ToggleStyle where Self == CheckboxToggleStyle {
  public static var checkbox: CheckboxToggleStyle { CheckboxToggleStyle() }
}

private struct CheckboxToggleView: View {
  @Environment(\.theme) private var theme

  let configuration: ToggleStyleConfiguration

  var body: some View {
    Button {
      configuration.isOn.toggle()
    } label: {
      HStack(spacing: Constants.labelSpacing) {
        indicatorView

        configuration.label
          .frame(maxWidth: .infinity, alignment: .leading)
          .fixedSize(horizontal: false, vertical: true)
      }
      .frame(minHeight: Constants.minimumHeight)
      .contentShape(Rectangle())
    }
    .buttonStyle(.plain)
    .accessibilityElement(children: .combine)
    .accessibilityAddTraits(.isToggle)
    .accessibilityAddTraits(configuration.isOn ? .isSelected : [])
  }
}

private extension CheckboxToggleView {
  enum Constants {
    static let indicatorSize: CGFloat = 24
    static let labelSpacing: CGFloat = 14
    static let minimumHeight: CGFloat = 44
  }

  var isOn: Bool {
    configuration.isOn
  }

  @ContentBuilder
  var indicatorView: some View {
    Image(systemName: isOn ? "checkmark.circle.fill" : "circle")
      .font(.system(size: Constants.indicatorSize))
      .symbolRenderingMode(.palette)
      .foregroundStyle(
        isOn ? theme.colors.onPrimary : theme.colors.borderInteractive,
        theme.colors.button,
      )
      .contentTransition(.symbolEffect(isOn ? .replace : .replace.offUp))
      .animation(.spring, value: isOn)
      .accessibilityHidden(false)
  }
}

#Preview {
  @Previewable @State var isAddressSelected = true
  @Previewable @State var isCitizenshipSelected = false

  VStack {
    Toggle(isOn: $isAddressSelected) {
      Text("Adress")
    }
    Toggle(isOn: $isCitizenshipSelected) {
      Text("Medborgarskap")
    }
  }
  .toggleStyle(.checkbox)
  .padding()
  .themed
}
