// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "Langy",
    platforms: [.macOS(.v13)],
    targets: [
        .executableTarget(
            name: "Langy",
            linkerSettings: [
                .linkedFramework("AppKit"),
                .linkedFramework("Carbon"),
                .linkedFramework("ServiceManagement"),
                .linkedFramework("ApplicationServices")
            ]
        )
    ]
)
