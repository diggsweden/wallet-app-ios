// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

public enum ServiceType: String, Sendable {
  case access = "http://uri.etsi.org/19602/SvcType/WRPAC/Issuance"
  case registration = "http://uri.etsi.org/19602/SvcType/WRPRC/Issuance"
  case pid = "http://uri.etsi.org/19602/SvcType/PID/Issuance"
  case walletSolution = "http://uri.etsi.org/19602/SvcType/WalletSolution/Issuance"
}
