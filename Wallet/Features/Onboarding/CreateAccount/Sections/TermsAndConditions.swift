import SwiftUI

struct TermsAndConditionsView: View {
  let onComplete: () -> Void
  @State private var hasAccepted: Bool = false
  @State private var didAttemptSubmit: Bool = false
  @Environment(\.theme) private var theme

  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      HStack(alignment: .firstTextBaseline) {
        Checkbox(isOn: $hasAccepted)
          .alignmentGuide(.firstTextBaseline) { d in
            d[VerticalAlignment.center]
          }
          .padding(.trailing, 8)
        Text("Jag samtycker till att DIGG får lagra mina användaruppgifter")
          .fixedSize(horizontal: false, vertical: true)
      }

      if !hasAccepted && didAttemptSubmit {
        HStack(spacing: 6) {
          Image(systemName: "exclamationmark.circle")
            .bold()
          Text("Samtycke krävs för att du ska kunna använda plånboken")
            .textStyle(.bodySmall)
        }
        .foregroundStyle(theme.colors.errorInverse)
      }

      Spacer()

      PrimaryButton("onboardingNext") {
        guard hasAccepted else {
          didAttemptSubmit = true
          return
        }

        onComplete()
      }
    }
  }
}
