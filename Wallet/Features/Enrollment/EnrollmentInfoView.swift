import SwiftUI

struct EnrollmentInfoView: View {
  let bodyText: String
  let onComplete: () throws -> Void

  var body: some View {
    Text(bodyText)
      .toolbar {
        ToolbarItem(placement: .bottomBar) {
          PrimaryButton(label: "Fortsätt") {
            try? onComplete()
          }
        }
      }
  }
}

#Preview {
  EnrollmentInfoView(bodyText: "Test") {}
}
