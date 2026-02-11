// SPDX-FileCopyrightText: 2026 diggsweden/wallet-app-ios
//
// SPDX-License-Identifier: EUPL-1.2

import Foundation

enum ToastType { case info, success, warning, error }

struct Toast: Identifiable, Equatable {
  let id = UUID()
  let type: ToastType
  let title: String
}
