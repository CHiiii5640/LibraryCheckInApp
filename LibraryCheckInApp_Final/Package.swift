// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "LibraryCheckInApp_Final",
    platforms: [.iOS(.v15)],
    products: [
        .executable(name: "LibraryCheckInApp_Final", targets: ["LibraryCheckInApp_Final"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
    ],
    targets: [
        .executableTarget(
            name: "LibraryCheckInApp_Final",
            dependencies: [],
            path: "LibraryCheckInApp_Final"
        ),
    ]
)
