// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import CredentialInterfaces
import Foundation
import OpenId4VCInterface
import Presentation
import SwiftAccessMechanism
import User

@MainActor
@Observable
final class PresentationViewModel {
  let url: URL
  let credentials: [SavedCredential]
  private let flow = PresentationSession()
  private let hsmTransport: any HSMTransport
  private let hsmServerParameters: HsmServerParameters?
  private var resolved: ResolvedPresentation?
  private(set) var phase: PresentationPhase = .loading
  private(set) var requiredItems: [PresentationItem] = []
  private(set) var isSending = false
  var optionalItems: [PresentationItem] = []
  var sendError = false

  init(
    url: URL,
    credentials: [SavedCredential],
    hsmTransport: any HSMTransport,
    hsmServerParameters: HsmServerParameters?,
  ) {
    self.url = url
    self.credentials = credentials
    self.hsmTransport = hsmTransport
    self.hsmServerParameters = hsmServerParameters
  }

  func resolveAndMatchClaims() async {
    do {
      let resolved = try await flow.resolve(url: url, credentials: credentials)
      self.resolved = resolved

      let items = resolved.candidates.map { candidate in
        PresentationItem(candidate: candidate, isSelected: candidate.required)
      }
      requiredItems = items.filter(\.required)
      optionalItems = items.filter { !$0.required }
      phase = .ready
    } catch {
      phase = .error(CaughtError(error))
    }
  }

  func sendPresentation(_ pin: String) async -> PresentationOutcome? {
    guard let resolved else {
      sendError = true
      return nil
    }

    isSending = true
    defer { isSending = false }

    do {
      let signer = HsmProofSigner(
        transport: hsmTransport,
        parameters: hsmServerParameters,
        pin: pin,
      )
      let selectedIds = (requiredItems + optionalItems.filter(\.isSelected)).map(\.id)
      return try await flow.submit(resolved, selectedIds: selectedIds, signer: signer)
    } catch {
      sendError = true
      return nil
    }
  }
}
