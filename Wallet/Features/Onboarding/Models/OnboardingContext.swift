// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import Foundation

struct OnboardingContext {
  var phoneNumber: String?
  var email: String = ""
  var pin: String = ""
  var credentialOfferUri: String?
}
