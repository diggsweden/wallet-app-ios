import Foundation

struct OnboardingContext {
  var phoneNumber: String?
  var email: String = ""
  var pin: String = ""
  var oidcSessionId: String?
  var credentialOfferUri: String?
}
