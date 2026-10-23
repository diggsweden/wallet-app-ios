// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

public enum ServiceType: String {
  case wrpacIssuance = "http://uri.etsi.org/19602/SvcType/WRPAC/Issuance"
  case wrpacRevocation = "http://uri.etsi.org/19602/SvcType/WRPAC/Revocation"
  case wrprcIssuance = "http://uri.etsi.org/19602/SvcType/WRPRC/Issuance"
  case wrprcRevocation = "http://uri.etsi.org/19602/SvcType/WRPRC/Revocation"
}
