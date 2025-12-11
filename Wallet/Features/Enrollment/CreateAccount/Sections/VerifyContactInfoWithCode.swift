import SwiftUI

struct VerifyContactInfoWithCode: View {
  enum ContactInfoType {
    case phone
    case email

    var description: String {
      return switch self {
        case .phone: "ditt telefonnummer"
        case .email: "din e-postadress"
      }
    }
  }

  let contactInfoData: String
  let type: ContactInfoType
  let onComplete: () -> Void

  var body: some View {
    VStack {
      HStack(alignment: .top) {
        Image(.enterEmail)
          .resizable()
          .scaledToFit()
          .frame(height: 86)
        Text(
          "En kod för att bekräfta \(type.description) har skickats till\n\(contactInfoData)"
        )
        .fixedSize(horizontal: false, vertical: true)
      }
      Text("Det kan ta några minuter innan du får din kod, den är aktiv i en timme.")
      Spacer()
      PrimaryButton("enrollmentNext") {
        onComplete()
      }
    }
  }
}
