// RUN: %empty-directory(%t)
// RUN: %target-build-swift -I %swift-host-lib-dir -L %swift-host-lib-dir -emit-library -o %t/%target-library-name(MacroDefinition) -module-name=MacroDefinition %S/Inputs/syntax_macro_definitions.swift -g -no-toolchain-stdlib-rpath -swift-version 5

// Make sure the diagnostic comes through...
// RUN: %target-typecheck-verify-swift -enable-experimental-feature Macros -load-plugin-library %t/%target-library-name(MacroDefinition) -I %swift-host-lib-dir -module-name MacroUser

// Make sure the diagnostic doesn't crash in SILGen
// RUN: not %target-swift-frontend -emit-sil -enable-experimental-feature Macros -enable-experimental-feature Macros -load-plugin-library %t/%target-library-name(MacroDefinition) -I %swift-host-lib-dir %s -module-name MacroUser -o - -g

@freestanding(expression) macro myWarning(_ message: String) = #externalMacro(module: "MacroDefinition", type: "WarningMacro")

func testThrownError() {
  let name = "hello"
  #myWarning(name) // expected-error{{#myWarning macro requires a string literal (from macro 'myWarning')}}

  #myWarning("experimental features ahead") // expected-warning{{experimental features ahead}}
}
