// Copyright © 2024 JARMourato All rights reserved.

import SwiftUI

public typealias DependencyKey = EnvironmentKey

public struct DependencyValues {
    private var values: [ObjectIdentifier: Any] = [:]

    init() {}

    @usableFromInline static var shared = DependencyValues()

    public subscript<K>(key: K.Type) -> K.Value where K: DependencyKey {
        get { values[ObjectIdentifier(key)] as? K.Value ?? key.defaultValue }
        set { values[ObjectIdentifier(key)] = newValue }
    }
}

/// A property wrapper that reads a value from the app dependencies, which are stored
/// on a shared `DependencyValues` instance.
///
/// Use the `Dependency` property wrapper to read a value
/// stored in a app's dependencies. Indicate the value to read using an
/// ``DependencyValues`` key path in the property declaration. For example, you
/// can create a property that reads the analytics manager for the whole app
/// using a custom the key path:
///
///     @Dependency(\.analytics) var analytics: AnalyticsManager
///
/// When using SwiftUI, always prefer using `EnvironmentValues` instead, as it provides
/// view updates when properties change.
/// This should be used for App wide values, on which views should not rely upon.
@propertyWrapper public struct Dependency<Value> {
    @usableFromInline let keyPath: KeyPath<DependencyValues, Value>

    @inlinable public init(_ keyPath: KeyPath<DependencyValues, Value>) {
        self.keyPath = keyPath
    }

    @inlinable public var wrappedValue: Value {
        DependencyValues.shared[keyPath: keyPath]
    }
}

// MARK: SwiftUI helper

public extension View {
    /// Sets the dependency value of the specified key path to the given value.
    ///
    /// Use this modifier to set one of the writable properties of the
    /// ``DependencyValues`` structure.
    ///
    /// This modifier does not affect the given view,
    /// it is just a helper to set a dependency
    ///
    /// - Parameters:
    ///   - keyPath: A key path that indicates the property of the
    ///     ``DependencyValues`` structure to update.
    ///   - value: The new value to set for the item specified by `keyPath`.
    ///
    /// - Returns: The same view, unmodified.
    @inlinable func dependency<V>(_ keyPath: WritableKeyPath<DependencyValues, V>, _ value: V) -> some View {
        DependencyValues.shared[keyPath: keyPath] = value
        return self
    }
}
