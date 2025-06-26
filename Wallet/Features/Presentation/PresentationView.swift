import SiopOpenID4VP
import SwiftUI

struct PresentationView: View {
  let presentationDefinition: PresentationDefinition

  var body: some View {
    Text(presentationDefinition.name ?? "No name")
    Text(presentationDefinition.purpose ?? "No purpose")
    Text("\(presentationDefinition.inputDescriptors)")
  }
}
