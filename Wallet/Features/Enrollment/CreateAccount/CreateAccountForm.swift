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
    keyTag: UUID,
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
    VStack(spacing: 12) {
      VStack(alignment: .leading, spacing: 4) {
        TextField("Personnummer (ÅÅÅÅMMDDXXXX eller ÅÅMMDD-XXXX)", text: $viewModel.data.pin)
          .textFieldStyle(.primary)
          .keyboardType(.numbersAndPunctuation)
          .textContentType(.oneTimeCode)
          .textInputAutocapitalization(.never)
          .autocorrectionDisabled(true)
          .focused($focusedField, equals: .pin)

        ErrorView(
          text: viewModel.data.pinError,
          show: viewModel.data.pinError != nil && touchedFields.contains(.pin)
        )
      }

      VStack(alignment: .leading, spacing: 4) {
        emailField(label: "E-post", text: $viewModel.data.email)
          .focused($focusedField, equals: .email)

        ErrorView(
          text: viewModel.data.emailError,
          show: viewModel.data.emailError != nil && touchedFields.contains(.email)
        )
      }

      VStack(alignment: .leading, spacing: 4) {
        emailField(label: "Verifiera e-post", text: $viewModel.data.verifyEmail)
          .focused($focusedField, equals: .verifyEmail)

        ErrorView(
          text: viewModel.data.verifyEmailError,
          show: viewModel.data.verifyEmailError != nil && touchedFields.contains(.verifyEmail)
        )
      }

      VStack(alignment: .leading, spacing: 4) {
        TextField(
          "Telefonnummer",
          value: $viewModel.data.phoneNumber,
          format: .optional
        )
        .textFieldStyle(.primary)
        .keyboardType(.phonePad)
        .textContentType(.telephoneNumber)
        .focused($focusedField, equals: .phoneNumber)

        ErrorView(
          text: viewModel.data.phoneError,
          show: viewModel.data.phoneError != nil && touchedFields.contains(.phoneNumber)
        )
      }
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
      .textFieldStyle(.primary)
      .textInputAutocapitalization(.never)
      .keyboardType(.emailAddress)
      .textContentType(.emailAddress)
  }
}

#Preview {
  ContactInfoForm(
    gatewayClient: GatewayClient(),
    keyTag: UUID(),
    onSubmit: { _ in },
  )
}
