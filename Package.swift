// swift-tools-version: 6.0

import PackageDescription

let package = Package(
  name: "Codex",
  platforms: [
    .macOS("15"),
    .iOS("18"),
    .tvOS("18"),
    .watchOS("11"),
  ],
  products: [
    .library(
      name: "Codex",
      targets: ["Codex"])
  ],
  dependencies: [
    .package(url: "https://github.com/apple/swift-atomics.git", from: "1.2.0"),
    .package(url: "https://github.com/apple/swift-collections.git", .upToNextMinor(from: "1.1.4")),
    .package(url: "https://github.com/apple/swift-algorithms.git", .upToNextMinor(from: "1.2.0")),
    .package(url: "https://github.com/SwiftScream/URITemplate.git", from: "5.0.1"),
    .package(url: "https://github.com/StarLard/SwiftFormatPlugins.git", from: "1.1.1"),
  ],
  targets: [
    .target(
      name: "Codex",
      dependencies: [
        .product(name: "Algorithms", package: "swift-algorithms"),
        .product(name: "Atomics", package: "swift-atomics"),
        .product(name: "Collections", package: "swift-collections"),
        .product(name: "ScreamURITemplate", package: "uritemplate"),
      ],
      exclude: [
        "Path/Path.g4",
      ],
      plugins: [
        .plugin(name: "Lint", package: "swiftformatplugins"),
      ]
    ),
    .testTarget(
      name: "CodexTests",
      dependencies: ["Codex"],
      resources: [
        .copy("Resources"),
      ],
      plugins: [
        .plugin(name: "Lint", package: "swiftformatplugins"),
      ]
    ),
  ]
)
