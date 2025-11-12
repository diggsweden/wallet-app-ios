import SwiftUI

struct ContactInfoForm: View {
  private enum Field: Hashable {
    case email, verifyEmail, phoneNumber, pin
  }

  @FocusState private var focusedField: Field?
  @State private var touchedFields = Set<Field>()
  @State var viewModel: CreateAccountViewModel

  init(
    gatewayClient: GatewayClient,
    keyTag: String,
    onSubmit: @escaping (String) async throws -> Void,
  ) {
    _viewModel = State(
      wrappedValue: CreateAccountViewModel(
        gatewayClient: gatewayClient,
        keyTag: keyTag,
        onSubmit: onSubmit
      )
    )
  }

  var body: some View {
    VStack(spacing: 18) {
      TextField("Personnummer", text: $viewModel.data.pin)
        .textFieldStyle(
          .primary(
            error: touchedFields.contains(.pin) ? viewModel.data.pinError : nil
          )
        )
        .keyboardType(.numbersAndPunctuation)
        .textContentType(.oneTimeCode)
        .textInputAutocapitalization(.never)
        .autocorrectionDisabled(true)
        .focused($focusedField, equals: .pin)

      emailField(label: "E-post", text: $viewModel.data.email)
        .textFieldStyle(
          .primary(
            error: touchedFields.contains(.email) ? viewModel.data.emailError : nil
          )
        )
        .focused($focusedField, equals: .email)

      emailField(label: "Verifiera e-post", text: $viewModel.data.verifyEmail)
        .textFieldStyle(
          .primary(
            error: touchedFields.contains(.verifyEmail) ? viewModel.data.verifyEmailError : nil
          )
        )
        .focused($focusedField, equals: .verifyEmail)

      TextField(
        "Telefonnummer",
        value: $viewModel.data.phoneNumber,
        format: .optional
      )
      .textFieldStyle(
        .primary(
          error: touchedFields.contains(.phoneNumber) ? viewModel.data.phoneError : nil
        )
      )
      .keyboardType(.phonePad)
      .textContentType(.telephoneNumber)
      .focused($focusedField, equals: .phoneNumber)
    }
    .onChange(of: focusedField) { old, new in
      guard let old, new != old else {
        return
      }

      touchedFields.insert(old)
    }
    .toolbar {
      EnrollmentBottomToolbarButton {
        PrimaryButton("enrollmentNext") {
          Task {
            await viewModel.createAccount()
          }
        }
        .disabled(viewModel.accountIdResult == .loading)
      }
    }
  }

  private func emailField(label: String, text: Binding<String>) -> some View {
    TextField(label, text: text)
      .textInputAutocapitalization(.never)
      .keyboardType(.emailAddress)
      .textContentType(.emailAddress)
  }
}

#Preview {
  ContactInfoForm(
    gatewayClient: GatewayClient(),
    keyTag: "",
    onSubmit: { _ in },
  )
}
