import JOSESwift
import OpenID4VCI

extension CredentialRequestEncryption? {
  func toCryptoSpec() -> CryptoSpec? {
    guard case let .required(jwks, methods, _) = self,
      let jwk = jwks.first,
      let method = methods.first,
      let enc = ContentEncryptionAlgorithm(encryptionMethod: method)
    else {
      return nil
    }

    return CryptoSpec(key: jwk, enc: enc)
  }
}
