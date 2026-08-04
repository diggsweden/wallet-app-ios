// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import CredentialInterfaces
import Foundation
import SwiftUI
import Testing

@testable import WalletDemo

@MainActor
@Suite("Credential details snapshots", .snapshots(record: .missing))
struct CredentialDetailsSnapshotTests {
  @Test("Credential details")
  func credentialDetails() {
    assertThemedDeviceSnapshots(
      of: NavigationStack {
        CredentialDetailsView(credential: credential)
          .defaultScreenStyle
      }
    )
  }
}

private extension CredentialDetailsSnapshotTests {
  var issuedAt: Date { Date(timeIntervalSince1970: 1_700_000_000) }

  var credential: SavedCredential {
    SavedCredential(
      issuer: IssuerDisplay(name: "Digg", info: "Testintyg", imageUrl: nil),
      compactSerialized: compactSdJwt,
      claimDisplayNames: [
        "given_name": "Förnamn",
        "family_name": "Efternamn",
        "birthdate": "Födelsedatum",
        "nationalities": "Medborgarskap",
        "address": "Adress",
        "address.street_address": "Gatuadress",
        "address.postal_code": "Postnummer",
        "address.locality": "Ort",
        "address.country": "Land",
      ],
      claimsCount: 5,
      issuedAt: issuedAt,
      type: "",
      displayData: nil,
    )
  }

  var compactSdJwt: String {
    [
      "eyJhbGciOiAiRVMyNTYiLCAidHlwIjogImV4YW1wbGUrc2Qtand0In0.eyJfc2QiOiBbIkczU0laclAzWmZl",
      "c1FDNGVuYkp0a2g3UzY5YlFlcm01ejRSRG5EUmhMN00iLCAiS3daaDRjdllWZ1JlOUhOcXNSZXh4U3lZck1P",
      "dGVVOEtSVEpadGdKZEloRSIsICJQVlFfeHB4X1VQNGJZNVpVYXlkVm1fcTN6YTRCdkpSYjVaMVRDb3JURElV",
      "IiwgImk5NG13TkV1LVVTTmd1ajJJNHp1eUI3YUtXeWZsWE1JMTlzOFl2MDJCR1kiLCAidmdXMk9PSDRMbHlL",
      "ODM4VWFGYkVYeG1fYWF1eU8yQnhkNXBjRDZ5c1BLQSJdLCAiaXNzIjogImh0dHBzOi8vaXNzdWVyLmV4YW1w",
      "bGUuY29tIiwgImlhdCI6IDE2ODMwMDAwMDAsICJleHAiOiAxODgzMDAwMDAwLCAic3ViIjogInVzZXJfNDIi",
      "LCAiX3NkX2FsZyI6ICJzaGEtMjU2IiwgImNuZiI6IHsiandrIjogeyJrdHkiOiAiRUMiLCAiY3J2IjogIlAt",
      "MjU2IiwgIngiOiAiVENBRVIxOVp2dTNPSEY0ajRXNHZmU1ZvSElQMUlMaWxEbHM3dkNlR2VtYyIsICJ5Ijog",
      "Ilp4amlXV2JaTVFHSFZXS1ZRNGhiU0lpcnNWZnVlY0NFNnQ0alQ5RjJIWlEifX19.ZfSxIFLHf7f84WIMqt7",
      "Fzme8-586WutjFnXH4TO5XuWG_peQ4hPsqDpiMBClkh2aUJdl83bwyyOriqvdFra-bg~WyIyR0xDNDJzS1F2",
      "ZUNmR2ZyeU5STjl3IiwgImdpdmVuX25hbWUiLCAiSm9obm55Il0~WyJlbHVWNU9nM2dTTklJOEVZbnN4QV9B",
      "IiwgImZhbWlseV9uYW1lIiwgIkpvaG5zc29uIl0~WyI2SWo3dE0tYTVpVlBHYm9TNXRtdlZBIiwgImJpcnRo",
      "ZGF0ZSIsICIxOTg1LTAzLTEyIl0~WyJlSThaV205UW5LUHBOUGVOZW5IZGhRIiwgIm5hdGlvbmFsaXRpZXMi",
      "LCBbIlNFIl1d~WyJRZ19PNjR6cUF4ZTQxMmExMDhpcm9BIiwgImFkZHJlc3MiLCB7InN0cmVldF9hZGRyZXN",
      "zIjogIlN2ZWF2w6RnZW4gMSIsICJwb3N0YWxfY29kZSI6ICIxMTEgNTciLCAibG9jYWxpdHkiOiAiU3RvY2t",
      "ob2xtIiwgImNvdW50cnkiOiAiU0UifV0~",
    ]
    .joined()
  }
}
