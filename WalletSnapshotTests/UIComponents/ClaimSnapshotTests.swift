// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import Foundation
import Testing

@testable import WalletDemo

@MainActor
@Suite("Claim snapshots", .snapshots(record: .missing))
struct ClaimSnapshotTests {
  @Test("Claim — string")
  func string() {
    let claim = ClaimUiModel(id: "name", displayName: "Namn", value: .string("Anna Andersson"))
    assertThemedSnapshots(of: ClaimView(claim: claim), width: 320)
  }

  @Test("Claim — boolean")
  func boolean() {
    let claim = ClaimUiModel(id: "verified", displayName: "Verifierad", value: .bool(true))
    assertThemedSnapshots(of: ClaimView(claim: claim), width: 320)
  }

  @Test("Claim — date")
  func date() {
    let claim = ClaimUiModel(
      id: "birth_date",
      displayName: "Födelsedatum",
      value: .date(Date(timeIntervalSince1970: 631_152_000))
    )
    assertThemedSnapshots(of: ClaimView(claim: claim), width: 320)
  }

  @Test("Claim — null")
  func null() {
    let claim = ClaimUiModel(id: "note", displayName: "Anteckning", value: .null)
    assertThemedSnapshots(of: ClaimView(claim: claim), width: 320)
  }

  @Test("Claim — array")
  func array() {
    let claim = ClaimUiModel(
      id: "nationalities",
      displayName: "Nationaliteter",
      value: .array([
        ClaimUiModel(id: "n0", displayName: nil, value: .string("Svensk")),
        ClaimUiModel(id: "n1", displayName: nil, value: .string("Norsk")),
      ])
    )
    assertThemedSnapshots(of: ClaimView(claim: claim), width: 320)
  }

  @Test("Claim — object")
  func object() {
    let claim = ClaimUiModel(
      id: "address",
      displayName: "Adress",
      value: .object([
        ClaimUiModel(id: "street", displayName: "Gatuadress", value: .string("Kungsgatan 1")),
        ClaimUiModel(id: "city", displayName: "Stad", value: .string("Stockholm")),
      ])
    )
    assertThemedSnapshots(of: ClaimView(claim: claim), width: 320)
  }

  @Test("Credential — with title")
  func credentialWithTitle() {
    assertThemedSnapshots(
      of: CredentialView(title: "Körkort", claims: Self.claims),
      width: 320
    )
  }

  @Test("Credential — without title")
  func credentialNoTitle() {
    assertThemedSnapshots(
      of: CredentialView(claims: Self.claims),
      width: 320
    )
  }

  private static let claims: [ClaimUiModel] = [
    ClaimUiModel(id: "name", displayName: "Namn", value: .string("Anna Andersson")),
    ClaimUiModel(id: "age", displayName: "Ålder", value: .int(34)),
    ClaimUiModel(id: "verified", displayName: "Verifierad", value: .bool(true)),
  ]
}
