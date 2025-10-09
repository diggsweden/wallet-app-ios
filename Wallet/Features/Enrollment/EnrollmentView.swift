import SwiftData
import SwiftUI

struct EnrollmentView: View {
  let appSession: AppSession
  @Environment(\.modelContext) private var modelContext
  @Environment(\.gatewayClient) private var gatewayClient
  @State private var flow = EnrollmentFlow()
  @State private var context = EnrollmentContext()

  var body: some View {
    VStack(spacing: 24) {
      headerView
        .id(flow.step)
        .transition(.blurReplace)
      currentStepView
        .transition(.slide)
    }
    .animation(.easeInOut, value: flow.step)
    .padding()
  }

  private func advanceIfValid() throws {
    try flow.advance(with: context)
  }

  private var headerView: some View {
    VStack(spacing: 12) {
      switch flow.step {
        case .intro:
          Image(.diggLogo)
          Text("Välkommen!")
        case .contactInfo:
          Image(systemName: "person.badge.plus")
          Text("Kontaktuppgifter")
        case .pin:
          Image(systemName: "lock.open.fill")
          Text("Ange ny PIN-kod")
        case .verifyPin:
          Image(systemName: "lock.fill")
          Text("Bekräfta PIN-kod")
        case .wua:
          Image(systemName: "gearshape.arrow.trianglehead.2.clockwise.rotate.90")
          Text("Sätter upp plånbok...")
        case .done:
          Image(systemName: "checkmark.circle.fill")
            .foregroundStyle(Color.green)
          Text("Klart!")
      }
    }
    .font(.title)
  }

  @ViewBuilder
  private var currentStepView: some View {
    switch flow.step {
      case .intro:
        EnrollmentInfoView(
          bodyText:
            "Detta är ett demo för svenska identitetsplånboken. Gå vidare för att skapa ett konto och ladda ner ditt ID-bevis."
        ) {
          try advanceIfValid()
        }

      case .contactInfo:
        ContactInfoForm(
          with: context.userData
        ) { userData in
          context.apply(userData)
          try advanceIfValid()
        }

      case .pin:
        PinView { pin in
          context.pin = pin
          try advanceIfValid()
        }

      case .verifyPin:
        PinView { pin in
          context.verifyPin = pin
          try advanceIfValid()
        }

      case .wua:
        WuaView(
          walletId: appSession.wallet.unitId,
          keyTag: appSession.keyTag,
          gatewayClient: gatewayClient
        ) { jwt in
          appSession.wallet.unitAttestation = jwt
          try modelContext.save()
          try advanceIfValid()
        }

      case .done:
        EnrollmentInfoView(bodyText: "Nu är din plånbok redo för att användas!") {
          appSession.user = User(
            email: context.email,
            pin: context.pin,
            phoneNumber: context.phoneNumber
          )
          try modelContext.save()
        }
    }
  }
}

#Preview {
  EnrollmentView(appSession: AppSession())
}
