// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import SwiftCompilerPlugin
import SwiftSyntaxMacros

@main
struct WalletMacros: CompilerPlugin {
  let providingMacros: [Macro.Type] = [URLMacro.self]
}
