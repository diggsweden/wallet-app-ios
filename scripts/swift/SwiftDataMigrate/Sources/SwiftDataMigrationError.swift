// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import Foundation

enum SwiftDataMigrationError: Error, CustomStringConvertible {
  case repoRootNotFound(marker: String)
  case directoryMissing(path: String)
  case fileAlreadyExists(path: String)
  case prevVersionWasZero
  case invalidHeader(path: String)
  case xcodegenFailed(exitCode: Int32)

  var description: String {
    switch self {
    case let .repoRootNotFound(marker):
     "Could not find repo root (no `\(marker)/` directory found walking upward from cwd)."
    case let .directoryMissing(path):
     "Required directory does not exist: \(path)"
    case let .fileAlreadyExists(path):
      "File already exists, refusing to overwrite: \(path)"
    case .prevVersionWasZero:
      "No previous version exists, this should never happen, refusing to continue"
    case let .invalidHeader(path):
      "File does not start with the expected header: \(path)"
    case let .xcodegenFailed(exitCode):
      "xcodegen failed with exit code \(exitCode)"
    }
  }
}
