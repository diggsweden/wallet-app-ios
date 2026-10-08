// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import SwiftAccessMechanism
import WalletGatewayInterface

enum WalletSetupStep: Equatable {
  case createAccount
  case setInitialBackendGeneration
  case initHSMState
  case registerPin

  var label: String {
    switch self {
      case .createAccount: "Skapar konto"
      case .setInitialBackendGeneration: "Hämtar konfiguration"
      case .initHSMState: "Upprättar säker anslutning"
      case .registerPin: "Registrerar PIN"
    }
  }
}
