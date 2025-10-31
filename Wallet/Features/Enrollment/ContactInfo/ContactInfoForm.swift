import SwiftUI

struct ContactInfoForm: View {
  @State var data: ContactInfoData
  @State private var error: String?
  let onSubmit: (ContactInfoData) throws -> Void

  init(
    with registrationData: ContactInfoData?,
    onSubmit: @escaping (ContactInfoData) throws -> Void
  ) {
    self.data = registrationData ?? ContactInfoData()
    self.onSubmit = onSubmit
  }

  var body: some View {
    VStack(spacing: 12) {
      ErrorView(text: error ?? "", show: error != nil)
      emailField(label: "E-post", text: $data.email)
      emailField(label: "Verifiera e-post", text: $data.verifyEmail)
      TextField(
        "Telefonnummer",
        value: $data.phoneNumber,
        format: .optional
      )
      .textFieldStyle(.primary)
      .keyboardType(.phonePad)
      .textContentType(.telephoneNumber)
    }
    .toolbar {
      ToolbarItem(placement: .bottomBar) {
        PrimaryButton(label: "Fortsätt") {
          handleSubmit()
        }
      }
    }
  }

  private func emailField(label: String, text: Binding<String>) -> some View {
    TextField(
      label,
      text: text
    )
    .textFieldStyle(.primary)
    .textInputAutocapitalization(.never)
    .keyboardType(.emailAddress)
    .textContentType(.emailAddress)
  }

  private func handleSubmit() {
    do {
      try onSubmit(data)
      error = nil
    } catch {
      self.error = error.message
    }
  }
}

#Preview {
  ContactInfoForm(with: ContactInfoData()) { _ in }
}
