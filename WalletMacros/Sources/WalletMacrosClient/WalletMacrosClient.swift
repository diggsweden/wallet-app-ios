// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import Foundation
import Swift

@freestanding(expression)
public macro URL(_ value: String) -> URL =
  #externalMacro(module: "WalletMacros", type: "URLMacro")
