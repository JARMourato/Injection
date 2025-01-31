// Copyright © 2024 JARMourato All rights reserved.

// MARK: - Macros

/// Creates an unique `DependencyKey` for the variable and adds getters and setters.
/// The initial value of the variable becomes the default value of the `DependencyKey`.
@attached(peer, names: prefixed(__Key_))
@attached(accessor, names: named(get), named(set))
public macro DependencyKey() = #externalMacro(module: "InjectionMacros", type: "DependencyKeyMacro")

/// Applies the @DependencyKey macro to each child in the scope.
/// This should only be applied on an `EnvironmentValues` or `DependencyValues` extensions.
@attached(memberAttribute)
public macro Inject() = #externalMacro(module: "InjectionMacros", type: "InjectValuesMacro")
