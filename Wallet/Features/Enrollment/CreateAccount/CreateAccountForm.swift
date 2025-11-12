import SwiftUI

struct CreateAccountForm: View {
  private enum Field: Hashable {
    case email, verifyEmail, phoneNumber
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
      emailField(label: "E-post", text: $viewModel.data.email)
        .textFieldStyle(
          .primary(
            error: errorMessage(for: .email)
          )
        )
        .focused($focusedField, equals: .email)

      emailField(label: "Verifiera e-post", text: $viewModel.data.verifyEmail)
        .textFieldStyle(
          .primary(
            error: errorMessage(for: .verifyEmail)
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
          error: errorMessage(for: .phoneNumber)
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

  private func errorMessage(for field: Field) -> String? {
    guard shouldShowErrorMessage(for: field) else {
      return nil
    }

    let data = viewModel.data
    return switch field {
      case .email:
        data.emailError
      case .verifyEmail:
        data.verifyEmailError
      case .phoneNumber:
        data.phoneError
    }
  }

  private func shouldShowErrorMessage(for field: Field) -> Bool {
    touchedFields.contains(field) || viewModel.showAllValidationErrors
  }
}

#Preview {
  CreateAccountForm(
    gatewayClient: GatewayClient(),
    keyTag: "",
    onSubmit: { _ in },
  )
}
