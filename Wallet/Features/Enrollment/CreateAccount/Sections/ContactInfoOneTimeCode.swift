import SwiftUI

struct ContactInfoOneTimeCode: View {
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
  let length: Int = 6

  @State private var code = ""
  @FocusState private var focused: Bool

  var body: some View {
    VStack(spacing: 30) {
      HStack(alignment: .top) {
        Text(
          "En kod för att bekräfta \(type.description) har skickats till:\n**\(contactInfoData)**"
        )
        .fixedSize(horizontal: false, vertical: true)
        Image(.verifyCode)
          .resizable()
          .scaledToFit()
          .frame(width: 134)
      }

      Text("Det kan ta några minuter innan du får din kod, den är aktiv i en timme.\n\nKom inte koden gå ett steg tillbaka.")
        .textStyle(.bodySmall)

      codeInput

      Spacer()

      PrimaryButton("enrollmentNext") {
        onComplete()
      }
    }
  }

  private var codeInput: some View {
    ZStack {
      HStack(spacing: 15) {
        ForEach(0 ..< length, id: \.self) { i in
          Text(char(at: i))
            .textStyle(.h2)
            .frame(width: 30, height: 50)
            .overlay(
              Rectangle().frame(height: 2),
              alignment: .bottom
            )
            .padding(.trailing, ((i + 1) == length / 2 ? 15 : 0))
            .accessibilityHidden(true)
        }
      }
      .contentShape(Rectangle())
      .onTapGesture {
        focused = true
      }

      TextField("", text: $code)
        .focused($focused)
        .textContentType(.oneTimeCode)
        .keyboardType(.numberPad)
        .textInputAutocapitalization(.never)
        .disableAutocorrection(true)
        .onChange(of: code) {
          if code.count == length {
            focused = false
          }
        }
        .foregroundStyle(.clear)
        .opacity(0)
        .accessibilityLabel("Verifieringskod")
        .accessibilityValue("\(code.count) av \(length) siffror")
    }
    .accessibilityElement(children: .combine)
  }

  private func char(at index: Int) -> String {
    guard index < code.count else {
      return " "
    }
    let i = code.index(code.startIndex, offsetBy: index)
    return String(code[i])
  }
}

#Preview {
  VStack {
    ContactInfoOneTimeCode(contactInfoData: "test", type: .email) {
    }
  }
  .themed
  .padding()
}
