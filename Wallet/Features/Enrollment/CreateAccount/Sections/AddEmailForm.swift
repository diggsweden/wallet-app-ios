import SwiftUI
import WalletMacrosClient

struct AddEmailForm: View {
  private enum Field: Hashable {
    case email, verifyEmail
  }

  @FocusState private var focusedField: Field?
  @State private var touchedFields = Set<Field>()
  @State private var viewModel: CreateAccountViewModel
  @Environment(ToastViewModel.self) private var toastViewModel
  @Environment(\.theme) private var theme
  @Environment(\.openURL) private var openURL
  private let exampleEmail = "exempel@domän.se"
  private let emailFields: Set<Field> = [.email, .verifyEmail]

  init(
    gatewayAPIClient: GatewayAPI,
    phoneNumber: String? = nil,
    onSubmit: @escaping (String, String) async throws -> Void,
  ) {
    _viewModel = State(
      wrappedValue: CreateAccountViewModel(
        gatewayAPIClient: gatewayAPIClient,
        phoneNumber: phoneNumber,
        onSubmit: onSubmit
      )
    )
  }

  var body: some View {
    VStack(alignment: .leading, spacing: 30) {
      header
        .padding(.bottom, 10)

      form
        .disabled(viewModel.accountIdResult.isLoading)

      Spacer()

      submitButton
        .frame(maxWidth: .infinity, alignment: .center)
    }
    .onChange(of: viewModel.accountIdResult) { _, new in
      if let error = new.error {
        toastViewModel.showError(error.message)
      }
    }
    .onChange(of: focusedField, handleFocusChange)
  }

  private var header: some View {
    VStack(alignment: .leading, spacing: 5) {
      Text(
        "Med användaruppgifterna kan du administrera din plånbok även om du till exempel tappar bort din telefon. "
      )
      HStack(alignment: .firstTextBaseline) {
        Text("Läs mer om plånboken på wallet.se")
          .underline()
        Image(systemName: "arrow.up.forward.app")
      }
      .onTapGesture {
        openURL(#URL("https://wallet.sandbox.digg.se"))
      }
    }
  }

  private var form: some View {
    VStack(alignment: .leading, spacing: 15) {
      PrimaryTextFieldWrapper(
        title: "E-postadress",
        error: errorMessage(for: .email)
      ) {
        emailField(label: exampleEmail, text: $viewModel.data.email)
          .focused($focusedField, equals: .email)
      }

      PrimaryTextFieldWrapper(
        title: "Skriv din e-postadress igen",
        error: errorMessage(for: .verifyEmail)
      ) {
        emailField(label: exampleEmail, text: $viewModel.data.verifyEmail)
          .focused($focusedField, equals: .verifyEmail)
      }
    }
  }

  @ViewBuilder
  private var submitButton: some View {
    if viewModel.accountIdResult.isLoading {
      ProgressView()
    } else {
      PrimaryButton("enrollmentNext") {
        Task { await viewModel.createAccount() }
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
    guard shouldShowErrorMessage(for: field) else { return nil }

    let data = viewModel.data
    switch field {
      case .email:
        return data.emailError ?? (shouldShowMatchingError ? data.emailMatchError : nil)
      case .verifyEmail:
        return data.verifyEmailError ?? (shouldShowMatchingError ? data.emailMatchError : nil)
    }
  }

  private var shouldShowMatchingError: Bool {
    if viewModel.showAllValidationErrors { return true }
    return emailFields.isSubset(of: touchedFields)
  }

  private func shouldShowErrorMessage(for field: Field) -> Bool {
    viewModel.showAllValidationErrors || touchedFields.contains(field)
  }

  private func handleFocusChange(old: Field?, new: Field?) {
    guard let old, new != old else {
      return
    }
    touchedFields.insert(old)
  }
}

#Preview {
  VStack {
    AddEmailForm(
      gatewayAPIClient: GatewayAPIMock(),
      onSubmit: { _, _ in },
    )
  }
  .frame(maxHeight: .infinity)
  .padding()
  .themed
  .withToast
}
