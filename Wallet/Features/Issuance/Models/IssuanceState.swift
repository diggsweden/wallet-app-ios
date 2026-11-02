// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

enum IssuanceState {
  case idle
  case step(IssuanceStep)
  case failed(at: IssuanceStep, CaughtError)

  var activeStep: IssuanceStep? {
    guard case let .step(step) = self else {
      return nil
    }

    return step
  }
}
