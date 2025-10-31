import SwiftCompilerPlugin
import SwiftSyntaxMacros

@main
struct WalletMacros: CompilerPlugin {
  let providingMacros: [Macro.Type] = [URLMacro.self]
}
