@testable import Injection
import XCTest

final class InjectionTests: XCTestCase {
    let container = Dependencies()

    typealias Action = () -> Void

    class A { init(block: Action? = nil) { block?() } }
    class B { init(block: Action? = nil) { block?() } }
    struct C {}

    enum Fail: Swift.Error {
        case mock
    }

    enum Failable {
        static func create() throws -> Failable { throw Fail.mock }
    }

    override func setUp() {
        super.setUp()
        Dependencies.shared.injected = [:]
        Dependencies.shared.instances = [:]
    }

    func testDependenciesContainerCreationProperties() {
        XCTAssertTrue(container.injected.isEmpty, "The dependency stack should be empty on creation.")
        XCTAssertTrue(container.instances.isEmpty, "The instance stack should be empty on creation.")
    }

    func testDependencyContainerEmptyInjection() {
        assert(try container.inject([]), throws: Injection.Error.noDependenciesInjected)
    }

    func testDependencyContainerDuplicateInjection() {
        let duplicates = [
            DependencyContainer(isSingleton: true, factory: { A() }),
            DependencyContainer(isSingleton: false, factory: { A() }),
        ]
        assert(try container.inject(duplicates), throws: Injection.Error.duplicateDependency("A"))
    }

    func testDependencyContainerMultipleInjections() {
        let first = [DependencyContainer(isSingleton: true, factory: { A() })]
        XCTAssertNoThrow(try container.inject(first))
        let second = [DependencyContainer(isSingleton: true, factory: { B() })]
        assert(try container.inject(second), throws: Injection.Error.multipleDependencyInjection)
    }

    func testDependencyContainerCannotResolveDependency() {
        assert(try container.resolve() as C, throws: Injection.Error.failedToResolveDependency("C"))
    }

    func testDependencyContainerProperInjection() {
        let dependencies: [Dependency] = [
            DependencyContainer(isSingleton: true, factory: { A() }),
            DependencyContainer(isSingleton: false, factory: { B() }),
        ]
        XCTAssertNoThrow(try container.inject(dependencies))
        let dependencyA = container.injected["A"]
        XCTAssertNotNil(dependencyA)
        XCTAssertTrue(dependencyA!.isSingleton)
        let instanceA = try! dependencyA!.factory()
        XCTAssertTrue(instanceA is A)
        XCTAssertFalse(instanceA is B)
        let dependencyB = container.injected["B"]
        XCTAssertNotNil(dependencyB)
        XCTAssertFalse(dependencyB!.isSingleton)
        let instanceB = try! dependencyB!.factory()
        XCTAssertTrue(instanceB is B)
        XCTAssertFalse(instanceB is A)
    }

    func testDependencyContainerResolve() {
        XCTAssertNoThrow(try container.inject([DependencyContainer(isSingleton: true, factory: { A() })]))
        XCTAssertNoThrow(try container.resolve() as A)
    }

    func testFactoryDependency() {
        XCTAssertNoThrow(try container.inject([DependencyContainer(isSingleton: false, factory: { B() })]))
        var instance1: B?
        XCTAssertNoThrow(instance1 = try container.resolve() as B)
        XCTAssertNotNil(instance1)
        var instance2: B?
        XCTAssertNoThrow(instance2 = try container.resolve() as B)
        XCTAssertNotNil(instance2)
        XCTAssertNotEqual(ObjectIdentifier(instance1!), ObjectIdentifier(instance2!))
    }

    // MARK: Inject/Resolve Public API

    func testInjectSingleDependencyDSL() {
        XCTAssertNoThrow(try inject { singleton { A() } })
        var a: A?
        XCTAssertNoThrow(a = try resolve() as A)
        XCTAssertNotNil(a)
    }

    func testInjectMultipleDependenciesDSL() {
        let mod = module { () -> [Dependency] in
            singleton { A() }
            factory { B() }
        }
        let cDependency = singleton { C() }
        XCTAssertNoThrow(try inject { mod; cDependency })
        var a: A?
        XCTAssertNoThrow(a = try resolve() as A)
        XCTAssertNotNil(a)
        var b: B?
        XCTAssertNoThrow(b = try resolve() as B)
        XCTAssertNotNil(b)
        var c: C?
        XCTAssertNoThrow(c = try resolve() as C)
        XCTAssertNotNil(c)
    }

    // MARK: Public Property Wrappers

    func testEagerInject() {
        var hasInitializedA = false
        var hasInitializedB = false

        XCTAssertNoThrow(try inject {
            factory { A { hasInitializedA = true } }
            singleton { B { hasInitializedB = true } }
        })

        class TestInjected1 {
            @Inject var a: A
            @Inject var b: B
        }

        class TestInjected2 {
            @Inject var a: A
            @Inject var b: B
        }

        let test1 = TestInjected1()
        let test2 = TestInjected2()

        // Since the instances are initialized on creation of the object, the second time no more initializations happen
        XCTAssertTrue(hasInitializedA)
        hasInitializedA = false
        _ = test1.a
        XCTAssertFalse(hasInitializedA)
        XCTAssertTrue(hasInitializedB)
        hasInitializedB = false
        _ = test1.b
        XCTAssertFalse(hasInitializedB)
        XCTAssertNotEqual(ObjectIdentifier(test1.a), ObjectIdentifier(test2.a))
        XCTAssertEqual(ObjectIdentifier(test1.b), ObjectIdentifier(test2.b))
    }

    func testLazyInject() {
        var hasInitializedA = false
        var hasInitializedB = false

        XCTAssertNoThrow(try inject {
            factory { A { hasInitializedA = true } }
            lazySingleton { B { hasInitializedB = true } }
        })

        class TestInjected1 {
            @LazyInject var e: A
            @LazyInject var f: B
        }

        class TestInjected2 {
            @LazyInject var e: A
            @LazyInject var f: B
        }

        let test1 = TestInjected1()
        let test2 = TestInjected2()

        XCTAssertFalse(hasInitializedA)
        _ = test1.e
        XCTAssertTrue(hasInitializedA)
        XCTAssertFalse(hasInitializedB)
        _ = test1.f
        XCTAssertTrue(hasInitializedB)
        hasInitializedA = false
        hasInitializedB = false
        XCTAssertFalse(hasInitializedA)
        _ = test2.e
        XCTAssertTrue(hasInitializedA)
        XCTAssertFalse(hasInitializedB)
        _ = test2.f
        XCTAssertFalse(hasInitializedB) // Singleton so it was already initialized and therefore it won't be initialized.
        XCTAssertNotEqual(ObjectIdentifier(test1.e), ObjectIdentifier(test2.e))
        XCTAssertEqual(ObjectIdentifier(test1.f), ObjectIdentifier(test2.f))
    }

    func testOptionalInject() {
        var hasInitializedA = false
        var hasInitializedB = false

        XCTAssertNoThrow(try inject {
            factory { A { hasInitializedA = true } }
            singleton { B { hasInitializedB = true } }
        })

        class TestInjected1 {
            @OptionalInject var a: A?
            @OptionalInject var b: B?
        }

        class TestInjected2 {
            @OptionalInject var a: A?
            @OptionalInject var b: B?
        }

        let test1 = TestInjected1()
        let test2 = TestInjected2()

        XCTAssertFalse(hasInitializedA)
        XCTAssertNotNil(test1.a)
        XCTAssertTrue(hasInitializedA)
        XCTAssertTrue(hasInitializedB) // `singleton` is immediately initialized
        XCTAssertNotNil(test1.b)
        XCTAssertTrue(hasInitializedB)
        hasInitializedA = false
        hasInitializedB = false
        XCTAssertFalse(hasInitializedA)
        XCTAssertNotNil(test2.a)
        XCTAssertTrue(hasInitializedA)
        XCTAssertFalse(hasInitializedB)
        XCTAssertNotNil(test2.b)
        XCTAssertFalse(hasInitializedB) // Singleton so it was already initialized and therefore it won't be initialized.
        XCTAssertNotEqual(ObjectIdentifier(test1.a!), ObjectIdentifier(test2.a!))
        XCTAssertEqual(ObjectIdentifier(test1.b!), ObjectIdentifier(test2.b!))
    }

    func test_factoryCreationWithFailure_wontThrowError() {
        XCTAssertNoThrow(try inject { factory { try Failable.create() } })
        assert(try resolve() as Failable, throws: Fail.mock)
    }

    func test_lazySingletonCreationWithFailure_wontThrowError() {
        XCTAssertNoThrow(try inject { lazySingleton { try Failable.create() } })
        assert(try resolve() as Failable, throws: Fail.mock)
    }

    func test_singletonCreationWithFailure_willThrowErrorImmediately() {
        assert(try inject { try singleton { try Failable.create() } }, throws: Fail.mock)
    }
}

extension XCTestCase {
    func assert<T, E: Swift.Error & Equatable>(_ expression: @autoclosure () throws -> T, throws error: E, in file: StaticString = #file, line: UInt = #line) {
        var thrownError: Swift.Error?
        XCTAssertThrowsError(try expression(), file: file, line: line) { thrownError = $0 }
        XCTAssertTrue(thrownError is E, "Unexpected error type: \(type(of: thrownError))", file: file, line: line)
        XCTAssertEqual(thrownError as? E, error, file: file, line: line)
        XCTAssertEqual(thrownError?.localizedDescription, (thrownError as? E)?.localizedDescription)
    }
}
