import Foundation
import Swift

@freestanding(expression)
public macro URL(_ value: String) -> URL =
  #externalMacro(module: "WalletMacros", type: "URLMacro")
