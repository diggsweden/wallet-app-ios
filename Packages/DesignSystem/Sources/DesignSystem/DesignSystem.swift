// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import CoreText
import Foundation

public enum DesignSystem {
  /// Registers the design system's bundled fonts with the current process.
  /// Call once at app launch, before any view renders. Safe to call repeatedly.
  public static func registerFonts() {
    _ = fontsRegistered
  }

  private static let fontsRegistered: Void = {
    for name in ["Ubuntu-Regular", "Ubuntu-Bold", "Ubuntu-Medium"] {
      guard let url = Bundle.module.url(forResource: name, withExtension: "ttf") else {
        assertionFailure("DesignSystem: missing bundled font \(name).ttf")
        continue
      }
      CTFontManagerRegisterFontsForURL(url as CFURL, .process, nil)
    }
  }()
}
