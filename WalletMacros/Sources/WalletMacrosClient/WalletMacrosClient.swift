// SPDX-FileCopyrightText: 2026 diggsweden/wallet-app-ios
//
// SPDX-License-Identifier: EUPL-1.2

import Foundation
import Swift

@freestanding(expression)
public macro URL(_ value: String) -> URL =
  #externalMacro(module: "WalletMacros", type: "URLMacro")
