// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

public struct CryptoSpec: Sendable {
  public let key: WalletJoseJWK
  public let enc: WalletJoseContentEncryptionAlgorithm
  public let alg: WalletJoseKeyManagementAlgorithm

  public init(
    key: WalletJoseJWK,
    enc: WalletJoseContentEncryptionAlgorithm,
    alg: WalletJoseKeyManagementAlgorithm = .ecdhES,
  ) {
    self.key = key
    self.enc = enc
    self.alg = alg
  }
}
