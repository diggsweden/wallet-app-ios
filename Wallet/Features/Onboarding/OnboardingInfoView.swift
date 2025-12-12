import SwiftUI

struct OnboardingInfoView: View {
  let bodyText: String
  let onComplete: () throws -> Void

  var body: some View {
    Text(bodyText)
      .toolbar {
        OnboardingBottomToolbarButton {
          PrimaryButton("onboardingNext") {
            try? onComplete()
          }
        }
      }
  }
}

#Preview {
  OnboardingInfoView(bodyText: "Test") {}
}
