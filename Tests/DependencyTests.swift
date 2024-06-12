// Copyright © 2024 JARMourato All rights reserved.

@testable import Injection
import SwiftUI
import XCTest

final class DependencyTests: XCTestCase {
    func testReadDependency() {
        // Given
        let assertionValue = 100
        DependencyValues.NumberKey.defaultValue = assertionValue
        // When
        let readValue = DependencyValues.shared[keyPath: \.number]
        // Then
        XCTAssertEqual(assertionValue, readValue)
    }

    func testWriteDependency() {
        // Given
        let assertionValue = 100
        // When
        DependencyValues.shared[keyPath: \.number] = assertionValue
        let readValue = DependencyValues.shared[keyPath: \.number]
        // Then
        XCTAssertEqual(assertionValue, readValue)
    }

    func testPropertyWrapperReadDependency() {
        // Given
        struct Test {
            @Dependency(\.number) var number: Int
        }
        // When
        let test = Test()
        let value = test.number
        // Then
        XCTAssertEqual(value, DependencyValues.NumberKey.defaultValue)
    }

    func testSwiftUIViewUtilityWriter() {
        // Given
        let view = EmptyView()
        let assertionValue = 100
        // When
        _ = view.dependency(\.number, assertionValue)
        let readValue = DependencyValues.shared[keyPath: \.number]
        // Then
        XCTAssertEqual(readValue, assertionValue)
    }
}

// MARK: Helper extension

extension DependencyValues {
    var number: Int {
        get { self[NumberKey.self] }
        set { self[NumberKey.self] = newValue }
    }

    struct NumberKey: DependencyKey {
        static var defaultValue: Int = 10
    }
}
