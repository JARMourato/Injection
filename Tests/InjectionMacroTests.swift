// Copyright © 2024 JARMourato All rights reserved.

@testable import InjectionMacrosImpl
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
                @DependencyKey
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
                        self [___number.self]
                    }
                    set {
                        self [___number.self] = newValue
                    }
                }

                private struct ___number: DependencyKey {
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
                var number: Int {
                    get {
                        self [___number.self]
                    }
                    set {
                        self [___number.self] = newValue
                    }
                }

                private struct ___number: DependencyKey {
                    static let defaultValue: Int = 10
                }
                var text: String {
                    get {
                        self [___text.self]
                    }
                    set {
                        self [___text.self] = newValue
                    }
                }

                private struct ___text: DependencyKey {
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
                        self [___number.self]
                    }
                    set {
                        self [___number.self] = newValue
                    }
                }

                private struct ___number: DependencyKey {
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
                        self [___number.self]
                    }
                    set {
                        self [___number.self] = newValue
                    }
                }

                private struct ___number: DependencyKey {
                    static let defaultValue: Int = 10
                }
                var text: String {
                    get {
                        self [___text.self]
                    }
                    set {
                        self [___text.self] = newValue
                    }
                }

                private struct ___text: DependencyKey {
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
