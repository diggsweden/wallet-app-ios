import Foundation

enum ToastType { case info, success, warning, error }

struct Toast: Identifiable, Equatable {
  let id = UUID()
  let type: ToastType
  let title: String
}
