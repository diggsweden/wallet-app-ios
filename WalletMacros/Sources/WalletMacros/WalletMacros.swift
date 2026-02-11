// SPDX-FileCopyrightText: 2026 diggsweden/wallet-app-ios
//
// SPDX-License-Identifier: EUPL-1.2

import SwiftCompilerPlugin
import SwiftSyntaxMacros

@main
struct WalletMacros: CompilerPlugin {
  let providingMacros: [Macro.Type] = [URLMacro.self]
}
