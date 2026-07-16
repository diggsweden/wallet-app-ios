// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import SwiftUI

public struct Theme: Sendable {
  public struct Colors: Sendable {
    public let background: Color
    public let backgroundDisabled: Color
    public let surface: Color
    public let onSurface: Color
    public let textPrimary: Color
    public let textPlaceholder: Color
    public let textInformation: Color
    public let linkPrimary: Color
    public let button: Color
    public let buttonSecondaryHover: Color
    public let primary: Color
    public let primaryAccent: Color
    public let onPrimary: Color
    public let primaryVariant: Color
    public let secondary: Color
    public let secondaryAccent: Color
    public let tertiary: Color
    public let error = Color.rgba(248, 229, 229)
    public let errorInverse: Color
    public let warning = Color.rgba(254, 247, 231)
    public let warningInverse = Color.rgba(244, 176, 19)
    public let success = Color.rgba(234, 245, 236)
    public let successInverse = Color.rgba(43, 155, 68)
    public let info = Color.rgba(232, 240, 249)
    public let infoInverse = Color.rgba(24, 108, 198)
    public let iconDisabled: Color
    public let stroke: Color
    public let strokeDisabled: Color
    public let textError: Color
    public let backgroundPage: Color
    public let layerAccent: Color
    public let borderInteractive: Color
    public let pidBackground: Color
  }

  public let colors: Colors
  public let cornerRadius: CGFloat = 10
  public let spacing: CGFloat = 12
  public let horizontalPadding: CGFloat = 30
}

extension Theme {
  public static let light: Theme = .init(
    colors: .init(
      background: Color.white,
      backgroundDisabled: BrandColors.neutral.10,
      surface: BrandColors.green.25,
      onSurface: BrandColors.green.100,
      textPrimary: Color.rgba(43, 42, 41),
      textPlaceholder: BrandColors.neutral.25,
      textInformation: BrandColors.neutral.70,
      linkPrimary: BrandColors.green.100,
      button: BrandColors.green.100,
      buttonSecondaryHover: BrandColors.pink.130,
      primary: BrandColors.green.100,
      primaryAccent: BrandColors.green.10,
      onPrimary: Color.white,
      primaryVariant: BrandColors.green.25,
      secondary: BrandColors.pink.25,
      secondaryAccent: BrandColors.pink.10,
      tertiary: BrandColors.yellow.25,
      errorInverse: Color.rgba(181, 0, 0),
      iconDisabled: Color.rgba(232, 232, 232),
      stroke: BrandColors.neutral.100,
      strokeDisabled: BrandColors.neutral.50,
      textError: Color.rgba(181, 0, 0),
      backgroundPage: Color.rgba(243, 243, 243),
      layerAccent: BrandColors.yellow.100,
      borderInteractive: BrandColors.green.100,
      pidBackground: BrandColors.brown.70
    ),
  )

  public static let dark: Theme = .init(
    colors: .init(
      background: Color.rgba(43, 42, 41),
      backgroundDisabled: BrandColors.neutral.50,
      surface: BrandColors.green.150,
      onSurface: BrandColors.green.25,
      textPrimary: Color.white,
      textPlaceholder: BrandColors.neutral.10,
      textInformation: BrandColors.neutral.10,
      linkPrimary: Color.white,
      button: BrandColors.green.25,
      buttonSecondaryHover: BrandColors.pink.50,
      primary: BrandColors.green.150,
      primaryAccent: BrandColors.green.150,
      onPrimary: Color.rgba(43, 42, 41),
      primaryVariant: BrandColors.green.150,
      secondary: BrandColors.pink.150,
      secondaryAccent: BrandColors.pink.175,
      tertiary: BrandColors.yellow.150,
      errorInverse: Color.rgba(237, 191, 191),
      iconDisabled: Color.rgba(148, 147, 147),
      stroke: Color.white,
      strokeDisabled: BrandColors.neutral.100,
      textError: Color.rgba(237, 191, 191),
      backgroundPage: BrandColors.neutral.130,
      layerAccent: BrandColors.yellow.130,
      borderInteractive: BrandColors.green.25,
      pidBackground: BrandColors.brown.100
    ),
  )
}
