import Foundation

enum IssuanceError: LocalizedError {
  case invalidAuth, invalidCredential, issuerNotFound, authRequestFailed, credentialNotSupported
}
