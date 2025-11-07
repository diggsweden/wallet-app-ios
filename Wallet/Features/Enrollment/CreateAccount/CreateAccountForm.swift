import SwiftUI

struct ContactInfoForm: View {
  private enum Field: Hashable {
    case email, verifyEmail, phoneNumber, pin
  }

  @State var data: ContactInfoData = ContactInfoData()
  @FocusState private var focusedField: Field?
  @State private var touchedFields = Set<Field>()

  let viewModel: CreateAccountViewModel
  let onSubmit: (String) async throws -> Void

  init(
    gatewayClient: GatewayClient,
    keyTag: UUID = UUID(),
    onSubmit: @escaping (String) async throws -> Void,
  ) {
    self.viewModel = CreateAccountViewModel(gatewayClient: gatewayClient, keyTag: keyTag)
    self.onSubmit = onSubmit
  }

  var body: some View {
    VStack(spacing: 12) {
      VStack(alignment: .leading, spacing: 4) {
        TextField("Personnummer (ÅÅÅÅMMDDXXXX eller ÅÅMMDD-XXXX)", text: $data.pin)
          .textFieldStyle(.primary)
          .keyboardType(.numbersAndPunctuation)
          .textContentType(.oneTimeCode)
          .textInputAutocapitalization(.never)
          .autocorrectionDisabled(true)
          .focused($focusedField, equals: .pin)
        ErrorView(
          text: data.pinError,
          show: data.pinError != nil && touchedFields.contains(.pin)
        )
      }

      VStack(alignment: .leading, spacing: 4) {
        emailField(label: "E-post", text: $data.email)
          .focused($focusedField, equals: .email)
        ErrorView(
          text: data.emailError,
          show: data.emailError != nil && touchedFields.contains(.email)
        )
      }

      VStack(alignment: .leading, spacing: 4) {
        emailField(label: "Verifiera e-post", text: $data.verifyEmail)
          .focused($focusedField, equals: .verifyEmail)

        ErrorView(
          text: data.verifyEmailError,
          show: data.verifyEmailError != nil && touchedFields.contains(.verifyEmail)
        )
      }

      VStack(alignment: .leading, spacing: 4) {
        TextField(
          "Telefonnummer",
          value: $data.phoneNumber,
          format: .optional
        )
        .textFieldStyle(.primary)
        .keyboardType(.phonePad)
        .textContentType(.telephoneNumber)
        .focused($focusedField, equals: .phoneNumber)
        ErrorView(
          text: data.phoneError,
          show: data.phoneError != nil && touchedFields.contains(.phoneNumber)
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
            await handleSubmit()
          }
        }
        .disabled(!data.isValid)
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

  private func handleSubmit() async {
    do {
      try await onSubmit("")
    } catch {
    }
  }
}

#Preview {
  ContactInfoForm(
    gatewayClient: GatewayClient(),
    keyTag: UUID(),
    onSubmit: { _ in },
  )
}
