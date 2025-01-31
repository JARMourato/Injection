// Copyright © 2024 JARMourato All rights reserved.

@testable import InjectionMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

final class InjectionMacroTests: XCTestCase {
    func testEnvironmentValuesInjectExpandedMacro() {
        assertMacroExpansion(
            """
            @Inject
            extension EnvironmentValues {
                var number: Int = 10
            }
            """,
            expandedSource:
            """
            extension EnvironmentValues {
                @Entry
                var number: Int = 10
            }
            """,
            macros: ["Inject": InjectValuesMacro.self]
        )
    }

    func testEnvironmentValuesDependencyKeyExpandedMacro() {
        assertMacroExpansion(
            """
            extension EnvironmentValues {
                @DependencyKey var number: Int = 10
            }
            """,
            expandedSource:
            """
            extension EnvironmentValues {
                var number: Int {
                    get {
                        self[__Key_number.self]
                    }
                    set {
                        self[__Key_number.self] = newValue
                    }
                }

                private struct __Key_number: DependencyKey {
                    static let defaultValue: Int = 10
                }
            }
            """,
            macros: ["DependencyKey": DependencyKeyMacro.self]
        )
    }

    func testEnvironmentValuesCombinationExpandedMacro() {
        assertMacroExpansion(
            """
            @Inject
            extension EnvironmentValues {
                var number: Int = 10
                var text: String = "Hello"
            }
            """,
            expandedSource:
            """
            extension EnvironmentValues {
                @Entry
                var number: Int = 10
                @Entry
                var text: String = "Hello"
            }
            """,
            macros: [
                "Inject": InjectValuesMacro.self,
                "DependencyKey": DependencyKeyMacro.self,
            ]
        )
    }

    func testDependencyValuesInjectExpandedMacro() {
        assertMacroExpansion(
            """
            @Inject
            extension DependencyValues {
                var number: Int = 10
            }
            """,
            expandedSource:
            """
            extension DependencyValues {
                @DependencyKey
                var number: Int = 10
            }
            """,
            macros: ["Inject": InjectValuesMacro.self]
        )
    }

    func testDependencyValuesDependencyKeyExpandedMacro() {
        assertMacroExpansion(
            """
            extension DependencyValues {
                @DependencyKey var number: Int = 10
            }
            """,
            expandedSource:
            """
            extension DependencyValues {
                var number: Int {
                    get {
                        self[__Key_number.self]
                    }
                    set {
                        self[__Key_number.self] = newValue
                    }
                }

                private struct __Key_number: DependencyKey {
                    static let defaultValue: Int = 10
                }
            }
            """,
            macros: ["DependencyKey": DependencyKeyMacro.self]
        )
    }

    func testDependencyValuesCombinationExpandedMacro() {
        assertMacroExpansion(
            """
            @Inject
            extension DependencyValues {
                var number: Int = 10
                var text: String = "Hello"
            }
            """,
            expandedSource:
            """
            extension DependencyValues {
                var number: Int {
                    get {
                        self[__Key_number.self]
                    }
                    set {
                        self[__Key_number.self] = newValue
                    }
                }

                private struct __Key_number: DependencyKey {
                    static let defaultValue: Int = 10
                }
                var text: String {
                    get {
                        self[__Key_text.self]
                    }
                    set {
                        self[__Key_text.self] = newValue
                    }
                }

                private struct __Key_text: DependencyKey {
                    static let defaultValue: String = "Hello"
                }
            }
            """,
            macros: [
                "Inject": InjectValuesMacro.self,
                "DependencyKey": DependencyKeyMacro.self,
            ]
        )
    }
}
