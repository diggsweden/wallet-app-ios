import SwiftUI

struct EnrollmentInfoView: View {
  let bodyText: String
  let onComplete: () throws -> Void

  var body: some View {
    Text(bodyText)
      .toolbar {
        EnrollmentBottomToolbarButton {
          PrimaryButton("enrollmentNext") {
            try? onComplete()
          }
        }
      }
  }
}

#Preview {
  EnrollmentInfoView(bodyText: "Test") {}
}
