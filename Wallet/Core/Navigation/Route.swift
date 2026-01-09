import Foundation
import OpenID4VP

enum Route: Hashable {
  case presentation(vpTokenData: ResolvedRequestData.VpTokenData)
  case issuance(credentialOfferUri: String)
  case credentialDetails(_ credential: Credential)
  case settings
}
