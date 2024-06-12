// Copyright © 2024 JARMourato All rights reserved.

import SwiftCompilerPlugin
import SwiftSyntaxMacros

@main
struct InjectionMacros: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        InjectValuesMacro.self,
        DependencyKeyMacro.self,
    ]
}
