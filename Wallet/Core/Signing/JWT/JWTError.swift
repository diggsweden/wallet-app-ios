import Foundation

enum JWTError: Error {
  case invalidFormat
  case invalidBase64
  case invalidSigner
  case invalidJWE
}
