// swift-tools-version: 6.1
import PackageDescription

let package = Package(
    name: "MacOSAppTemplate",
    defaultLocalization: "en",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .executable(name: "MacOSAppTemplate", targets: ["MacOSAppTemplate"])
    ],
    targets: [
        .executableTarget(
            name: "MacOSAppTemplate",
            path: "Sources/MacOSAppTemplate"
        ),
        .testTarget(
            name: "MacOSAppTemplateTests",
            dependencies: ["MacOSAppTemplate"],
            path: "Tests/MacOSAppTemplateTests"
        )
    ]
)
