// swift-tools-version: 5.10
import PackageDescription

let package = Package(
    name: "NotchTeleprompter",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(name: "NotchTeleprompter", targets: ["NotchTeleprompter"])
    ],
    targets: [
        .executableTarget(
            name: "NotchTeleprompter",
            path: "Sources/NotchTeleprompter"
        )
    ]
)
