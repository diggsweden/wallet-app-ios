// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

enum IssuanceState {
  case idle
  case step(IssuanceStep)
  case failed(at: IssuanceStep, CaughtError)
}
