import SwiftUI

struct ToastModifier: ViewModifier {
  @State var toastViewModel = ToastViewModel()

  func body(content: Content) -> some View {
    content
      .environment(toastViewModel)
      .overlay {
        if let toast = toastViewModel.current {
          ZStack {
            Color.clear
              .ignoresSafeArea()
              .contentShape(Rectangle())
              .onTapGesture {
                toastViewModel.hide()
              }

            VStack {
              ToastView(toast) {
                toastViewModel.hide()
              }
              .padding(.top, 12)
              .padding(.horizontal, 12)
              Spacer()
            }
          }
          .frame(maxWidth: .infinity, maxHeight: .infinity)
          .transition(
            .move(edge: .top)
              .combined(with: .blurReplace)
          )
        }
      }
  }
}

extension View {
  var withToast: some View { modifier(ToastModifier()) }
}
