// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import Foundation
import OpenId4VCInterface

extension RegistrationCertificate {
  public var verifierUiModel: VerifierUiModel {
    VerifierUiModel(
      name: name,
      country: country,
      descriptions: srvDescription.stringDict,
      purpose: purpose.stringDict,
    )
  }
}

fileprivate extension Array where Element == Display {
  var stringDict: [String: String] {
    self.reduce(into: [String: String]()) { dict, display in
      dict[display.lang] = display.value
    }
  }
}
