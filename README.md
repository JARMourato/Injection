# Injection

[![Build Status][build status badge]][build status]
[![codebeat badge][codebeat status badge]][codebeat status]
[![codecov][codecov status badge]][codecov status]
![Platforms][platforms badge]


`Injection` is a tiny utility to help managing dependency injection.

**Features:**
- `Singleton`, dependencies that are only instantiated once and are shared amongst its users
- `LazySingleton`, dependencies that are only instantiated once, lazily, and are shared amongst its users
- `Factory`, dependencies that are instancied upon usage, unique to each user
- Utility property wrappers


## Installation

### Swift Package Manager

If you're working directly in a Package, add Injection to your Package.swift file

```swift
dependencies: [
    .package(url: "https://github.com/JARMourato/Injection.git", .upToNextMajor(from: "1.0.0" )),
]
```

If working in an Xcode project select `File->Swift Packages->Add Package Dependency...` and search for the package name: `Injection` or the git url:

`https://github.com/JARMourato/Injection.git`


## Usage

1. Define dependencies:
```swift
import Injection

// A dependency that gets created every time it needs to be resolved, and therefore its lifetime is bounded to the instance that uses it
let reader = factory { RSSReader() }

// A dependency that gets created immediately and is shared throughout the lifetime of the application.
let database = singleton { Analytics() }

// A dependency that gets created only once, the first time it needs to be resolved and has the lifetime of the application.
let database = lazySingleton { Realm() }

// Syntatic sugar to combine dependencies to inject
let cacheModule = module {
    singleton { ImageCache() }
    factory { AudioCache() }
    factory { VideoCache() }
}
```

2. Inject the dependencies before the application is initialized:
```swift
import Injection

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        do {
            try inject {
                reader
                database
                cacheModule
            }
        } catch {
            print("TODO: Handle error properly... \(error)")
        }
        return true
    }
}
```

3. Use the injected dependencies using the provided property wrappers:
```swift
import Injection

class VideoPlayer: BackendProtocol {
    // Will resolve the dependency immediately upon type instantiation
    @Inject var database: Database
    
    // The dependency only gets resolved on the first time the property gets accessed
    @LazyInject var videoCache: VideoCache
    
    // The functionality is similar to `LazyInject` except the property may or may not have been injected.
    @OptionalInject var network: Network?
}
```

or via the initializer:

```swift
import Injection

struct Reader {
    private let rssReader: RSSReader
    
    init(rssReader: RSSReader = resolve()) {
        self.rssReader = rssReader
    }
}
```


## Contributions

If you feel like something is missing or you want to add any new functionality, please open an issue requesting it and/or submit a pull request with passing tests 🙌

## License

MIT

## Contact

João ([@_JARMourato](https://twitter.com/_JARMourato))

[build status]: https://github.com/JARMourato/Injection/actions?query=workflow%3ACI
[build status badge]: https://github.com/JARMourato/Injection/workflows/CI/badge.svg
[codebeat status]: https://codebeat.co/projects/github-com-jarmourato-injection-master
[codebeat status badge]: https://codebeat.co/badges/3666b65d-490d-49fe-85c6-a31c3ddd8ae9
[codecov status]: https://codecov.io/gh/JARMourato/Injection
[codecov status badge]: https://codecov.io/gh/JARMourato/Injection/branch/main/graph/badge.svg?token=XAHCCI1JNM
[platforms badge]: https://img.shields.io/static/v1?label=Platforms&message=iOS%20|%20macOS%20|%20tvOS%20|%20watchOS%20&color=brightgreen
