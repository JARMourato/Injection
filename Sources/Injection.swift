import Foundation

public typealias DependencyFactory = () -> Any

public protocol Dependency {
    var factory: DependencyFactory { get }
    var isSingleton: Bool { get }
    var type: Any.Type { get }
}

extension Dependency {
    var typeName: String { String(describing: type) }
}

final class DependencyContainer<T>: Dependency {
    let isSingleton: Bool
    let type: Any.Type
    let factory: DependencyFactory

    init(isSingleton: Bool, factory: @escaping () -> T) {
        self.isSingleton = isSingleton
        type = T.self
        self.factory = { factory() }
    }
}

public enum Error: LocalizedError, Hashable {
    case noDependenciesInjected
    case multipleDependencyInjection
    case duplicateDependency(String)
    case failedToResolveDependency(String)

    public var errorDescription: String? {
        switch self {
        case let .duplicateDependency(name): return "Dependency \(name) can only be registered once."
        case let .failedToResolveDependency(name): return "Dependency \(name) could not be resolved."
        case .multipleDependencyInjection: return "Can only inject dependencies once."
        case .noDependenciesInjected: return "No dependencies injected."
        }
    }
}

final class Dependencies {
    var instances: [String: Any] = [:]
    var injected: [String: Dependency] = [:]
    private let lock: NSLocking = NSRecursiveLock()

    init() {}
    static var shared = Dependencies()

    func inject(_ dependencies: [Dependency]) throws {
        lock.lock()
        defer { lock.unlock() }
        guard !dependencies.isEmpty else { throw Error.noDependenciesInjected }
        guard injected.isEmpty else { throw Error.multipleDependencyInjection }
        for dependency in dependencies {
            guard injected[dependency.typeName] == nil else { throw Error.duplicateDependency(dependency.typeName) }
            injected[dependency.typeName] = dependency
        }
    }

    func resolve<T>() throws -> T {
        let typeName = String(describing: T.self)
        guard let injectedDependency = injected[typeName] else { throw Error.failedToResolveDependency(typeName) }
        let resolved: T
        if injectedDependency.isSingleton {
            let buildBlock: () -> T = {
                let instance = injectedDependency.factory() as! T
                self.instances[typeName] = instance
                return instance
            }
            resolved = instances[typeName] as? T ?? buildBlock()
        } else {
            resolved = injectedDependency.factory() as! T
        }
        return resolved
    }
}

// MARK: - Public API

/// Resolves the dependency by fetching the component of type `T` from the registered dependencies. If the component is not found an error is thrown.
public func resolve<T>() throws -> T { try Dependencies.shared.resolve() }

/// Resolves the dependency by fetching the component of type `T` from the registered dependencies.
public func resolveOptional<T>() -> T? { try? Dependencies.shared.resolve() as T }

// MARK: Property Wrappers

/// Creates a `Dependency` eagerly injectable through `@Inject var variableName: Dependency`.
@propertyWrapper
public struct Inject<T> {
    public let wrappedValue: T
    public init() { wrappedValue = try! resolve() } // As of Swift 5.3 property wrapper initializers cannot use `throws`. It will crash & burn
}

/// Creates a `Dependency` lazily injectable through `@LazyInject var variableName: Dependency`.
@propertyWrapper
public enum LazyInject<T> {
    case unresolved(() throws -> T)
    case resolved(T)

    public init() { self = .unresolved { try resolve() } }

    public var wrappedValue: T {
        mutating get {
            switch self {
            case let .unresolved(resolver):
                let dependency = try! resolver() // As of Swift 5.3 variables cannot use `throws`. It will crash & burn
                self = .resolved(dependency)
                return dependency
            case let .resolved(dependency):
                return dependency
            }
        }
    }
}

/// Creates an `Optional<Dependency>`  injectable through `@OptionalInject var variableName: Dependency?`, lazily instantiated.
@propertyWrapper
public enum OptionalInject<T> {
    case unresolved(() -> T?)
    case resolved(T?)

    public init() { self = .unresolved { resolveOptional() } }

    public var wrappedValue: T? {
        mutating get {
            switch self {
            case let .unresolved(resolver):
                let dependency = resolver()
                self = .resolved(dependency)
                return dependency
            case let .resolved(dependency):
                return dependency
            }
        }
    }
}

// MARK: Function Builders

@resultBuilder
public enum DependenciesBuilder {
    public static func buildBlock(_ children: [Dependency]...) -> [Dependency] {
        children.flatMap { $0 }
    }
}

/// A new instance of `T` is created each time it is injected. The internal container holds no reference to it.
public func factory<T>(constructor: @escaping () -> T) -> [Dependency] {
    [DependencyContainer(isSingleton: false, factory: constructor)]
}

/// The same instance of `T` is returned each time it is injected. An instance like this has its lifetime connected to the internal container instance, which essencially is the app lifetime.
public func singleton<T>(constructor: @escaping () -> T) -> [Dependency] {
    [DependencyContainer(isSingleton: true, factory: constructor)]
}

/// An helper function to create a smaller module of dependencies that can be combined when using the `inject` method.
public func module(@DependenciesBuilder makeChildren: () -> [Dependency]) -> [Dependency] {
    makeChildren()
}

/// This method adds an array of `Dependency`'s to the available dependencies to be injected. It should be called when the
/// app is initialized or at least before any of the injected properties get initialized, otherwise there will be blood.
///
/// - Note: It should be used only once.
public func inject(@DependenciesBuilder makeDependencies: () -> [Dependency]) throws {
    try Dependencies.shared.inject(makeDependencies())
}
