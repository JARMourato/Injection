// Copyright © 2024 JARMourato All rights reserved.

import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxMacros

// MARK: - Custom Dependency Value Macros

// MARK: Macro that adds Individual macro to every variable in the extension

public struct InjectValuesMacro: MemberAttributeMacro {
    public static func expansion(
        of node: AttributeSyntax,
        attachedTo declaration: some DeclGroupSyntax,
        providingAttributesFor member: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [AttributeSyntax] {
        guard let extensionDeclaration = declaration.as(ExtensionDeclSyntax.self) else {
            context.diagnose(Diagnostic(node: Syntax(node), message: InjectMacroError.attachedToInvalidType))
            return []
        }

        let extensionName = extensionDeclaration.extendedType.as(IdentifierTypeSyntax.self)?.name.text

        guard extensionName == "EnvironmentValues" || extensionName == "DependencyValues" else {
            context.diagnose(Diagnostic(node: Syntax(node), message: InjectMacroError.attachedToInvalidType))
            return []
        }

        guard member.is(VariableDeclSyntax.self) else { return [] }

        let isStatic = member.as(VariableDeclSyntax.self)?.modifiers.contains(where: { $0.name.text == "static" }) ?? false

        guard !isStatic else { return [] }

        if extensionName == "EnvironmentValues" {
            #if os(iOS)
                if #available(iOS 18.0, *) {
                    return [AttributeSyntax(
                        atSign: .atSignToken(),
                        attributeName: IdentifierTypeSyntax(name: .identifier("Entry"))
                    )]
                }
            #elseif os(macOS)
                if #available(macOS 15.0, *) {
                    return [AttributeSyntax(
                        atSign: .atSignToken(),
                        attributeName: IdentifierTypeSyntax(name: .identifier("Entry"))
                    )]
                }
            #elseif os(tvOS)
                if #available(tvOS 18.0, *) {
                    return [AttributeSyntax(
                        atSign: .atSignToken(),
                        attributeName: IdentifierTypeSyntax(name: .identifier("Entry"))
                    )]
                }
            #elseif os(watchOS)
                if #available(watchOS 11.0, *) {
                    return [AttributeSyntax(
                        atSign: .atSignToken(),
                        attributeName: IdentifierTypeSyntax(name: .identifier("Entry"))
                    )]
                }
            #elseif os(visionOS)
                if #available(visionOS 2.0, *) {
                    return [AttributeSyntax(
                        atSign: .atSignToken(),
                        attributeName: IdentifierTypeSyntax(name: .identifier("Entry"))
                    )]
                }
            #endif
        }

        return [
            AttributeSyntax(
                atSign: .atSignToken(),
                attributeName: IdentifierTypeSyntax(name: .identifier("DependencyKey"))
            ),
        ]
    }
}

// MARK: Macro to synthesize a custom DependencyKey conformance

public struct DependencyKeyMacro: PeerMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard let variableDeclarations = declaration.as(VariableDeclSyntax.self) else { return [] }
        guard var binding = variableDeclarations.bindings.first else { return [] }
        guard let identifier = binding.pattern.as(IdentifierPatternSyntax.self)?.identifier else { return [] }

        binding.pattern = PatternSyntax(IdentifierPatternSyntax(identifier: .identifier("defaultValue")))
        let isOptionalType = binding.typeAnnotation?.type.is(OptionalTypeSyntax.self) ?? false
        let hasDefaultValue = binding.initializer != nil

        guard isOptionalType || hasDefaultValue else {
            context.diagnose(Diagnostic(node: Syntax(node), message: InjectMacroError.noDefaultArgument))
            return []
        }

        return [
            """
            private struct __Key_\(raw: identifier.trimmedDescription): DependencyKey {
                static let \(binding) \(raw: isOptionalType && !hasDefaultValue ? "= nil" : "")
            }
            """,
        ]
    }
}

extension DependencyKeyMacro: AccessorMacro {
    public static func expansion(
        of _: AttributeSyntax,
        providingAccessorsOf declaration: some DeclSyntaxProtocol,
        in _: some MacroExpansionContext
    ) throws -> [AccessorDeclSyntax] {
        guard let varDecl = declaration.as(VariableDeclSyntax.self) else { return [] }
        guard let binding = varDecl.bindings.first else { return [] }
        guard let identifier = binding.pattern.as(IdentifierPatternSyntax.self)?.identifier else { return [] }

        return [
            """
            get {
                self[__Key_\(raw: identifier.trimmedDescription).self]
            }
            """,
            """
            set {
                self[__Key_\(raw: identifier.trimmedDescription).self] = newValue
            }
            """,
        ]
    }
}

enum InjectMacroError: String, Identifiable, DiagnosticMessage {
    case attachedToInvalidType
    case attachedToNonVariable
    case noDefaultArgument

    var diagnosticID: MessageID { MessageID(domain: "InjectionMacros", id: id) }
    var id: String { rawValue }
    var severity: DiagnosticSeverity { .error }
    var message: String {
        switch self {
        case .attachedToInvalidType:
            "@Inject can only be attached to extension of EnvironmentValues or DependencyValues"
        case .attachedToNonVariable:
            "@DependencyKey can only be attached to \"stored properties\", not static or computed properties"
        case .noDefaultArgument:
            "No default value provided."
        }
    }
}
