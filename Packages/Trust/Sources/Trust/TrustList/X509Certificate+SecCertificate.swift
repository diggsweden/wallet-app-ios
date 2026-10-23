// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import Foundation
import Jose

extension X509Certificate {
  var secCertificate: SecCertificate? {
    guard let data = Data(base64UrlEncoded: self.val) else {
      return nil
    }

    return SecCertificateCreateWithData(nil, data as CFData)
  }
}
