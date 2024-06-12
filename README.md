# Injection

[![Build Status][build status badge]][build status]
[![codebeat badge][codebeat status badge]][codebeat status]
[![codecov][codecov status badge]][codecov status]
![Platforms][platforms badge]

`Injection` is a tiny utility to help managing dependency injection with SwiftUI.

## Why would I use this?

You shouldn't 😅 there's plenty of dependency injection libraries for swift out there - by no means is this intended to replace any of those.
For my personal use cases, there's two main intents: 

- Simplify adding custom `EnvironmentValues` 
- Be able to use a similar api to `EnvironmentValues` for objects that aren't meant to be `Observable` or should not belong in the `View`'s `EnvironmentValues`

## Usage

```swift
import Injection

struct DependencyOne { ... }
struct DependencyTwo { ... }

// 1: Add the @Inject macro to the extension
@Inject 
extension EnvironmentValues {
    var dep1 = DependencyOne()
    var dep2 = DependencyTwo()
}

// 2: Use it normally with the @Environment property wrapper
struct ExampleView: View {
    @Environment(\.dep1) var dep1
    @Environment(\.dep2) var dep2

    var body: some View { ... }
}

```

The same logic also applies to the simpler container `DependencyValues`: 

```swift
import Injection

struct DependencyOne { ... }
struct DependencyTwo { ... }

// 1: Add the @Inject macro to the extension
@Inject 
extension DependencyValues {
    var dep1 = DependencyOne()
    var dep2 = DependencyTwo()
}

// (optionally) set it elsewhere in the view hierarchy

@main
struct ExampleApp: App {    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .dependency(\.dep1, DependencyOne())
        }
    }
}

// 2: Use it with the @Dependency property wrapper
struct ExampleView: View {
    @Dependency(\.dep1) var dep1
    @Dependency(\.dep2) var dep2

    var body: some View { ... }
}
```

## Installation

### Swift Package Manager

If you're working directly in a Package, add Injection to your Package.swift file

```swift
dependencies: [
    .package(url: "https://github.com/JARMourato/Injection.git", .upToNextMajor(from: "2.0.0" )),
]
```

If working in an Xcode project select `File->Swift Packages->Add Package Dependency...` and search for the package name: `Injection` or the git url:

`https://github.com/JARMourato/Injection.git`

## Contributions

If you feel like something is missing or you want to add any new functionality, please open an issue requesting it and/or submit a pull request with passing tests 🙌

## License

MIT

## Contact

João ([@_JARMourato](https://twitter.com/_JARMourato))

[build status]: https://github.com/JARMourato/Injection/actions?query=workflow%3ACI
[build status badge]: https://github.com/JARMourato/Injection/workflows/CI/badge.svg
[codebeat status]: https://codebeat.co/projects/github-com-jarmourato-injection-main
[codebeat status badge]: https://codebeat.co/badges/2702c785-2ecd-4798-abe9-fe7ee77c2616
[codecov status]: https://codecov.io/gh/JARMourato/Injection
[codecov status badge]: https://codecov.io/gh/JARMourato/Injection/branch/main/graph/badge.svg?token=XAHCCI1JNM
[platforms badge]: https://img.shields.io/static/v1?label=Platforms&message=iOS%20|%20macOS%20|%20tvOS%20|%20watchOS%20&color=brightgreen
