// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import CredentialInterfaces
import Foundation
import OpenId4VCInterface
import SwiftUI
import Testing

@testable import UIComponents
@testable import WalletDemo

@MainActor
@Suite("Presentation snapshots", .snapshots(record: .missing))
struct PresentationSnapshotTests {
  @Test("Loading")
  func loading() {
    assertThemedDeviceSnapshots(of: PresentationLoadingView())
  }

  @Test("Review")
  func review() {
    assertThemedDeviceSnapshots(
      of: PresentationReviewView(
        optionalItems: .constant(Self.optionalItems(isSelected: false)),
        requiredItems: Self.requiredItems,
        verifierName: Self.verifierName,
        verifierPurpose: Self.verifierPurpose,
        onHeaderTap: {},
      )
    )
  }

  @Test("Verification — encrypted")
  func verificationEncrypted() {
    assertThemedDeviceSnapshots(
      of: PresentationVerificationView(
        verifierName: Self.verifierName,
        verifierPurpose: Self.verifierPurpose,
        isEncrypted: true,
      )
    )
  }

  @Test("Verification — without purpose, not encrypted")
  func verificationWithoutPurpose() {
    assertThemedDeviceSnapshots(
      of: PresentationVerificationView(
        verifierName: Self.verifierName,
        verifierPurpose: nil,
        isEncrypted: false,
      )
    )
  }

  @Test("Shared claims — sharing")
  func sharedClaimsSharing() {
    assertThemedDeviceSnapshots(
      of: PresentationSharedClaimsView(
        credentials: [Self.pid, Self.license],
        verifierName: Self.verifierName,
      )
    )
  }

  @Test("Shared claims — shared")
  func sharedClaimsShared() {
    assertThemedDeviceSnapshots(
      of: PresentationSharedClaimsView(
        credentials: [Self.pid, Self.license],
        verifierName: Self.verifierName,
        hasBeenShared: true,
      )
    )
  }

  @Test("Pin — entry")
  func pinEntry() {
    assertThemedDeviceSnapshots(
      of: PresentationPinView(isLoading: false, onPinEntered: { _ in })
        .environment(ToastViewModel())
    )
  }

  @Test("Pin — loading")
  func pinLoading() {
    assertThemedDeviceSnapshots(
      of: PresentationPinView(isLoading: true, onPinEntered: { _ in })
        .environment(ToastViewModel())
    )
  }

  @Test("Success")
  func success() {
    assertThemedDeviceSnapshots(
      of: PresentationSuccessView(
        verifierName: Self.verifierName,
        verifierLogo: nil,
        onShowSharedClaims: {},
      )
    )
  }

  @Test("Success — with logo")
  func successWithLogo() {
    assertThemedDeviceSnapshots(
      of: PresentationSuccessView(
        verifierName: Self.verifierName,
        verifierLogo: Image(systemName: "car.side.fill"),
        onShowSharedClaims: {},
      )
    )
  }

  @Test("Review header — without logo")
  func reviewHeaderWithoutLogo() {
    assertThemedSnapshots(
      of: PresentationReviewHeaderView(
        name: Self.verifierName,
        purpose: Self.verifierPurpose,
        onTap: {},
      ),
      width: 360,
    )
  }

  @Test("Review header — with logo")
  func reviewHeaderWithLogo() {
    assertThemedSnapshots(
      of: PresentationReviewHeaderView(
        name: Self.verifierName,
        purpose: Self.verifierPurpose,
        logo: Image(systemName: "car.side.fill"),
        onTap: {},
      ),
      width: 360,
    )
  }

  @Test("Review header — without purpose")
  func reviewHeaderWithoutPurpose() {
    assertThemedSnapshots(
      of: PresentationReviewHeaderView(name: Self.verifierName, onTap: {}),
      width: 360,
    )
  }

  @Test("Required card")
  func requiredCard() {
    assertThemedSnapshots(
      of: PresentationRequiredCardView(title: "ID-uppgifter", claims: Self.pidClaims),
      width: 360,
    )
  }

  @Test("Optional card — none selected")
  func optionalCardNoneSelected() {
    assertThemedSnapshots(
      of: PresentationOptionalCardView(items: .constant(Self.optionalItems(isSelected: false))),
      width: 360,
    )
  }

  @Test("Optional card — selected")
  func optionalCardSelected() {
    assertThemedSnapshots(
      of: PresentationOptionalCardView(items: .constant(Self.optionalItems(isSelected: true))),
      width: 360,
    )
  }

  @Test("Optional claim list")
  func optionalClaimList() {
    assertThemedSnapshots(
      of: PresentationOptionalClaimListView(
        items: .constant(Self.optionalItems(isSelected: true))
      ),
      width: 360,
    )
  }

  @Test("Claim preview")
  func claimPreview() {
    assertThemedSnapshots(
      of: PresentationClaimPreviewView(claims: Self.pidClaims),
      width: 360,
    )
  }

  @Test("Claim list")
  func claimList() {
    assertThemedSnapshots(
      of: PresentationClaimListView(claims: Self.pidClaims + Self.edgeCaseClaims),
      width: 360,
    )
  }

  @Test("Grouped claim list")
  func groupedClaimList() {
    assertThemedSnapshots(
      of: PresentationGroupedClaimListView(credentials: [Self.pid, Self.license]),
      width: 360,
    )
  }

  @Test("Shared claims button")
  func sharedClaimsButton() {
    assertThemedSnapshots(
      of: PresentationSharedClaimsButtonView(claimCount: 13, action: {}),
      width: 360,
    )
  }
}

private extension PresentationSnapshotTests {
  static let verifierName = "Nordbil Hyrbilar AB"
  static let verifierPurpose = "Identitets- och körkortskontroll vid biluthyrning."

  static let pidClaims = [
    ClaimUiModel(id: "given_name", displayName: "Förnamn", value: .string("Elin")),
    ClaimUiModel(id: "family_name", displayName: "Efternamn", value: .string("Andersson")),
    ClaimUiModel(id: "birthdate", displayName: "Födelsedatum", value: .string("1990-04-12")),
    ClaimUiModel(id: "age_over_18", displayName: "Över 18 år", value: .bool(true)),
    ClaimUiModel(
      id: "address",
      displayName: "Adress",
      value: .object([
        ClaimUiModel(id: "address.locality", displayName: "Ort", value: .string("Stockholm")),
        ClaimUiModel(
          id: "address.street_address",
          displayName: "Gatuadress",
          value: .string("Storgatan 1"),
        ),
        ClaimUiModel(
          id: "address.postal_code",
          displayName: "Postnummer",
          value: .string("111 22"),
        ),
      ]),
    ),
  ]

  static let edgeCaseClaims = [
    ClaimUiModel(id: "nickname", displayName: "Smeknamn", value: .null),
    ClaimUiModel(id: "portrait", displayName: "Porträtt", value: .imageData(Data())),
  ]

  static let pid = CredentialUiModel(
    type: "urn:eudi:pid:1",
    name: "ID-uppgifter",
    claims: pidClaims,
  )

  static let license = CredentialUiModel(
    type: "urn:eudi:mdl:1",
    name: "Mobilt körkort",
    claims: [
      ClaimUiModel(
        id: "document_number",
        displayName: "Körkortsnummer",
        value: .string("SE123456"),
      ),
      ClaimUiModel(id: "expiry_date", displayName: "Giltigt till", value: .string("2031-05-01")),
    ],
  )

  static let student = CredentialUiModel(
    type: "urn:eudi:student:1",
    name: "Studentintyg",
    claims: [
      ClaimUiModel(
        id: "university",
        displayName: "Lärosäte",
        value: .string("Stockholms universitet"),
      )
    ],
  )

  static let requiredItems = [
    PresentationItem(
      candidate: PresentationCandidate(id: "pid", required: true, credentialUiModel: pid),
      isSelected: true,
    )
  ]

  static func optionalItems(isSelected: Bool) -> [PresentationItem] {
    [license, student]
      .map { credential in
        PresentationItem(
          candidate: PresentationCandidate(
            id: credential.type,
            required: false,
            credentialUiModel: credential,
          ),
          isSelected: isSelected,
        )
      }
  }
}
