// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

enum PresentationReviewSheet: String, Identifiable {
  case verification
  case sharedClaims

  var id: Self { self }
}
