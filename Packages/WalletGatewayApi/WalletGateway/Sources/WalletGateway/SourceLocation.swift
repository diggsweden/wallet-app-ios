// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

public struct SourceLocation: Sendable {
  public let fileID: String
  public let line: Int

  public init(fileID: String = #fileID, line: Int = #line) {
    self.fileID = fileID
    self.line = line
  }
}
