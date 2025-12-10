import SwiftUI

struct VerifyContactInfoView: View {
  let contactInfoData: String?
  let onComplete: () -> Void

  var body: some View {
    VStack {
      Text("Verifiera \(contactInfoData, default: "")")
      Text("Mata in 6 tecken")
      Spacer()
      PrimaryButton("enrollmentNext") {
        onComplete()
      }
    }
  }
}
