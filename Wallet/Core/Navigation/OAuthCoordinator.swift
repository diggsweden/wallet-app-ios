// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import AuthenticationServices

@MainActor
final class OAuthCoordinator: NSObject,
  ASWebAuthenticationPresentationContextProviding
{
  private var session: ASWebAuthenticationSession?
  private var anchor: ASPresentationAnchor?

  func start(
    url: URL,
    callbackScheme: String,
    anchor: ASPresentationAnchor?
  ) async throws -> URL {
    self.anchor = anchor

    return try await withCheckedThrowingContinuation { cont in
      let session = ASWebAuthenticationSession(
        url: url,
        callbackURLScheme: callbackScheme
      ) { [weak self] url, error in
        defer {
          self?.session = nil
          self?.anchor = nil
        }

        if let url {
          cont.resume(returning: url)
          return
        }

        cont.resume(throwing: error ?? URLError(.cancelled))
      }

      session.presentationContextProvider = self
      session.prefersEphemeralWebBrowserSession = true

      self.session = session
      _ = session.start()
    }
  }

  func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
    anchor ?? UIApplication.shared.connectedScenes
      .compactMap { $0 as? UIWindowScene }
      .flatMap { $0.windows }
      .first { $0.isKeyWindow } ?? ASPresentationAnchor()
  }
}
