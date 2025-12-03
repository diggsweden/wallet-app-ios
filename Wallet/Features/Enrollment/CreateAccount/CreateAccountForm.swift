import SwiftUI
import WalletMacrosClient

struct CreateAccountForm: View {
  private enum Field: Hashable {
    case email, verifyEmail, phoneNumber
  }

  @FocusState private var focusedField: Field?
  @State private var touchedFields = Set<Field>()
  @State private var viewModel: CreateAccountViewModel
  @Environment(ToastViewModel.self) private var toastViewModel
  @Environment(\.theme) private var theme
  @Environment(\.openURL) private var openURL
  private let exampleEmail = "exempel@domän.se"

  init(
    gatewayAPIClient: GatewayAPI,
    onSubmit: @escaping (String) async throws -> Void,
  ) {
    _viewModel = State(
      wrappedValue: CreateAccountViewModel(
        gatewayAPIClient: gatewayAPIClient,
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

      Text(
        "[Så behandlar vi dina personuppgifter](https://www.digg.se/om-oss/sa-behandlar-vi-dina-personuppgifter)"
      )
      .tint(theme.colors.linkPrimary)
      .underline()
      .frame(maxWidth: .infinity, alignment: .center)

      nextButton
        .frame(maxWidth: .infinity, alignment: .center)
    }
    .onChange(of: viewModel.accountIdResult) { _, new in
      if let error = new.error {
        toastViewModel.showError(error.message)
      }
    }
    .onChange(of: focusedField) { old, new in
      guard let old, new != old else {
        return
      }

      touchedFields.insert(old)
    }
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

      phoneNumberField
        .focused($focusedField, equals: .phoneNumber)

      terms.padding(.top, 10)
    }
  }

  private var terms: some View {
    VStack(alignment: .leading, spacing: 8) {
      HStack(alignment: .firstTextBaseline) {
        Checkbox(isOn: $viewModel.data.acceptedTerms)
          .alignmentGuide(.firstTextBaseline) { d in
            d[VerticalAlignment.center]
          }
        Text("Jag samtycker till att DIGG får lagra mina användaruppgifter")
          .fixedSize(horizontal: false, vertical: true)
      }

      if let error = viewModel.data.termsError, viewModel.showAllValidationErrors {
        HStack(spacing: 6) {
          Image(systemName: "exclamationmark.circle")
            .bold()
          Text(error)
            .textStyle(.bodySmall)
        }
        .foregroundStyle(theme.colors.errorInverse)
      }
    }
  }

  private var phoneNumberField: some View {
    PrimaryTextFieldWrapper(
      title: "Telefonnummer 10 siffror (frivilligt)",
      error: errorMessage(for: .phoneNumber)
    ) {
      TextField(
        "070 123 45 67",
        value: $viewModel.data.phoneNumber,
        format: .optional
      )
      .keyboardType(.numberPad)
      .textContentType(.telephoneNumber)
    }
  }

  @ViewBuilder
  private var nextButton: some View {
    if viewModel.accountIdResult.isLoading {
      ProgressView()
    } else {
      PrimaryButton("enrollmentNext") {
        Task {
          await viewModel.createAccount()
        }
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
        data.emailError ?? (showMatchingEmailError ? data.emailMatchError : nil)
      case .verifyEmail:
        data.verifyEmailError ?? (showMatchingEmailError ? data.emailMatchError : nil)
      case .phoneNumber:
        data.phoneError
    }
  }

  private var showMatchingEmailError: Bool {
    if viewModel.showAllValidationErrors {
      return true
    }
    return touchedFields.contains(.email) && touchedFields.contains(.verifyEmail)
  }

  private func shouldShowErrorMessage(for field: Field) -> Bool {
    touchedFields.contains(field) || viewModel.showAllValidationErrors
  }
}

#Preview {
  VStack {
    CreateAccountForm(
      gatewayAPIClient: GatewayAPIMock(),
      onSubmit: { _ in },
    )
  }
  .frame(maxHeight: .infinity)
  .padding()
  .themed
  .withToast
}
