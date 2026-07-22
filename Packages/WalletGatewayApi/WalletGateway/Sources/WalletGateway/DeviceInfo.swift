// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import Foundation

public struct DeviceInfo: Sendable {
  public let os: String
  public let osVersion: String
  public let model: String
  public let appVersion: String

  public init(
    os: String,
    osVersion: String,
    model: String,
    appVersion: String,
  ) {
    self.os = os
    self.osVersion = osVersion
    self.model = model
    self.appVersion = appVersion
  }
}
