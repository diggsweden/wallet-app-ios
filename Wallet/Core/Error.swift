import Foundation

struct AppError: LocalizedError {
  let message: String
  var errorDescription: String? {
    return message
  }
}
