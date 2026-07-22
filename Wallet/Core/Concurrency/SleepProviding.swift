// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import Foundation

protocol SleepProviding: Sendable {
  func sleep(for seconds: Double) async
}

struct SleepProvider: SleepProviding {
  func sleep(for seconds: Double) async {
    try? await Task.sleep(for: .seconds(seconds))
  }
}
