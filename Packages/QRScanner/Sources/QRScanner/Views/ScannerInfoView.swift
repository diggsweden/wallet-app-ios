// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import DesignSystem
import SwiftUI

struct ScannerInfoView: View {
  @Environment(\.theme) private var theme
  @Environment(\.dismiss) private var dismiss

  var body: some View {
    NavigationStack {
      ScrollView {
        VStack(spacing: Constants.parentStackSpacing) {
          header
          scannableCodes
          consentCard
          tips
        }
        .padding(.horizontal, theme.horizontalPadding)
        .padding(.bottom, Constants.contentVerticalPadding)
      }
      .background(theme.colors.background.ignoresSafeArea())
      .toolbar {
        ToolbarItem(placement: .cancellationAction) {
          Button {
            dismiss()
          } label: {
            Image(systemName: "xmark")
              .accessibilityLabel("Stäng")
          }
        }
      }
    }
    .presentationDragIndicator(.visible)
  }
}

private extension ScannerInfoView {
  enum Constants {
    static let parentStackSpacing: CGFloat = 32
    static let contentVerticalPadding: CGFloat = 32
    static let headingStackSpacing: CGFloat = 16
    static let illustrationSize: CGFloat = 112
    static let sectionSpacing: CGFloat = 16
    static let cardRowSpacing: CGFloat = 20
    static let cardPadding: CGFloat = 20
    static let cardCornerRadius: CGFloat = 20
    static let rowSpacing: CGFloat = 16
    static let rowTextSpacing: CGFloat = 4
    static let iconWidth: CGFloat = 32
    static let tipSpacing: CGFloat = 14
  }

  var header: some View {
    VStack(spacing: Constants.headingStackSpacing) {
      Image(systemName: "qrcode.viewfinder")
        .textStyle(.h1)
        .foregroundStyle(theme.colors.onSurface)
        .frame(
          width: Constants.illustrationSize,
          height: Constants.illustrationSize,
        )
        .background(theme.colors.primaryAccent, in: Circle())
        .accessibilityHidden(true)

      Text("Skanna en QR-kod")
        .textStyle(.h1)
        .accessibilityAddTraits(.isHeader)

      Text("Med kameran kan du legitimera dig, dela uppgifter och lägga till dokument i plånboken.")
        .textStyle(.body)
        .foregroundStyle(theme.colors.textInformation)
    }
    .multilineTextAlignment(.center)
  }

  var scannableCodes: some View {
    section("Vad kan jag skanna?") {
      VStack(alignment: .leading, spacing: Constants.cardRowSpacing) {
        infoRow(
          "Legitimera dig och dela uppgifter",
          detail: "När en tjänst vill veta vem du är eller behöver uppgifter från dina dokument.",
          systemImage: "person.text.rectangle",
        )

        infoRow(
          "Lägga till ett dokument",
          detail: "När du får ett nytt dokument att spara i plånboken.",
          systemImage: "plus.rectangle.on.rectangle",
        )
      }
      .padding(Constants.cardPadding)
      .frame(maxWidth: .infinity, alignment: .leading)
      .background(
        theme.colors.primaryAccent,
        in: RoundedRectangle(cornerRadius: Constants.cardCornerRadius),
      )
    }
  }

  var consentCard: some View {
    infoRow(
      "Du bestämmer alltid",
      detail: "Innan något delas ser du vem som frågar och vilka uppgifter det gäller. "
        + "Inget skickas förrän du godkänner med din PIN-kod.",
      systemImage: "checkmark.shield",
    )
    .padding(Constants.cardPadding)
    .frame(maxWidth: .infinity, alignment: .leading)
    .background(
      theme.colors.secondaryAccent,
      in: RoundedRectangle(cornerRadius: Constants.cardCornerRadius),
    )
  }

  var tips: some View {
    section("Om det inte fungerar") {
      VStack(alignment: .leading, spacing: Constants.tipSpacing) {
        tipRow("Få med hela koden i bilden.", systemImage: "viewfinder")
        tipRow("Se till att det är tillräckligt ljust.", systemImage: "sun.max")
        tipRow("Håll telefonen stilla en kort stund.", systemImage: "hand.raised")
        tipRow(
          "Bara koder från tjänster som stöder ID-plånboken fungerar.",
          systemImage: "checkmark.seal",
        )
        tipRow(
          "Är koden på den här telefonen? Tryck på länken i stället.",
          systemImage: "iphone",
        )
      }
    }
  }

  func section(
    _ title: String,
    @ContentBuilder content: () -> some View,
  ) -> some View {
    VStack(alignment: .leading, spacing: Constants.sectionSpacing) {
      Text(LocalizedStringKey(title))
        .textStyle(.h4)
        .accessibilityAddTraits(.isHeader)

      content()
    }
    .frame(maxWidth: .infinity, alignment: .leading)
  }

  func infoRow(
    _ title: String,
    detail: String,
    systemImage: String,
  ) -> some View {
    HStack(alignment: .top, spacing: Constants.rowSpacing) {
      Image(systemName: systemImage)
        .textStyle(.h3)
        .foregroundStyle(theme.colors.onSurface)
        .frame(width: Constants.iconWidth)
        .accessibilityHidden(true)

      VStack(alignment: .leading, spacing: Constants.rowTextSpacing) {
        Text(LocalizedStringKey(title))
          .textStyle(.h5)

        Text(LocalizedStringKey(detail))
          .textStyle(.bodySmall)
          .foregroundStyle(theme.colors.onSurface)
      }
      .frame(maxWidth: .infinity, alignment: .leading)
    }
    .accessibilityElement(children: .combine)
  }

  func tipRow(_ text: String, systemImage: String) -> some View {
    HStack(alignment: .firstTextBaseline, spacing: Constants.rowSpacing) {
      Image(systemName: systemImage)
        .textStyle(.body)
        .foregroundStyle(theme.colors.linkPrimary)
        .frame(width: Constants.iconWidth)
        .accessibilityHidden(true)

      Text(LocalizedStringKey(text))
        .textStyle(.body)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
  }
}

#Preview {
  ScannerInfoView()
    .themed
}
