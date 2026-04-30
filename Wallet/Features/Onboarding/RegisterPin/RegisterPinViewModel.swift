import SwiftAccessMechanism
import SwiftUI

@MainActor
@Observable
final class RegisterPinViewModel {
  let pin: String = "Confess"

  func createClient() async throws {
    // Init client
    let params = try ServerParameters()
    var (client, _) = try await BFFHttpClient.createClient(
      baseUrl: "http://localhost:8088",
      serverParameters: params
    )

    // Register
    //    let pinStretch = PINStretch()
    //    let stretched = try pinStretch.stretch(input: pin.utf8Data)
    let registrationResponse = try await client.registration(password: pin.utf8Data)
    print("DEBUG: Registration Response: \(registrationResponse)")

    // Authenticate
    let authResult = try await client.authenticate(password: pin.utf8Data)

    // HSM
    let createdKey = try await client.createHsmKey()
    let key = createdKey.public_key
    print("DEBUG: HSM-key: \(key)")
  }
}
