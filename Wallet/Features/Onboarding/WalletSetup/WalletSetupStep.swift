// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import SwiftAccessMechanism
import WalletGateway

enum WalletSetupStep: Equatable {
  case createAccount
  case initHSMState
  case registerPin
  case authenticate(StretchedPIN)
  case generateHSMKey
  case saveKey(PublicKeyComponents)

  var label: String {
    switch self {
      case .createAccount: "Skapar konto"
      case .initHSMState: "Upprättar säker anslutning"
      case .registerPin: "Registrerar PIN"
      case .authenticate: "Autentiserar"
      case .generateHSMKey: "Genererar säker nyckel"
      case .saveKey: "Sparar nyckel"
    }
  }
}
