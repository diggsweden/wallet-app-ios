// SPDX-FileCopyrightText: 2026 diggsweden/wallet-app-ios
//
// SPDX-License-Identifier: EUPL-1.2

import Foundation

struct OnboardingContext {
  var phoneNumber: String?
  var email: String = ""
  var pin: String = ""
  var oidcSessionId: String?
  var credentialOfferUri: String?
}
