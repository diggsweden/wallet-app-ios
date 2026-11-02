// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import Foundation

enum ToastType { case info, success, warning, error }

struct Toast: Identifiable, Equatable {
  let id = UUID()
  let type: ToastType
  let title: String
}
