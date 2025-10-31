import Foundation

struct AppError: LocalizedError {
  let reason: String
  var errorDescription: String? {
    return reason
  }
}
