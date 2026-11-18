// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

enum PresentationPhase: Equatable {
  case loading
  case error(CaughtError)
  case ready
}
