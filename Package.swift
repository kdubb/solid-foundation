// swift-tools-version: 6.0

import PackageDescription

let package = Package(
  name: "Codex",
  platforms: [
    .macOS("13.3"),
    .iOS("16.3"),
    .tvOS("16.3"),
    .watchOS("9.3"),
  ],
  products: [
    .library(
      name: "Codex",
      targets: ["Codex"])
  ],
  dependencies: [
    .package(url: "https://github.com/apple/swift-atomics.git", from: "1.2.0"),
    .package(url: "https://github.com/apple/swift-collections.git", .upToNextMinor(from: "1.1.4")),
    .package(url: "https://github.com/kdubb/BigDecimal.git", branch: "main"),
    .package(url: "https://github.com/SwiftScream/URITemplate.git", from: "5.0.1"),
    .package(url: "https://github.com/StarLard/SwiftFormatPlugins.git", from: "1.1.1"),
  ],
  targets: [
    .target(
      name: "Codex",
      dependencies: [
        .product(name: "Atomics", package: "swift-atomics"),
        .product(name: "Collections", package: "swift-collections"),
        .product(name: "BigDecimal", package: "BigDecimal"),
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
        .copy("../JSONTestSuite/tests"),
        .copy("../JSONTestSuite/output-tests"),
        .copy("../JSONTestSuite/remotes"),
      ],
      plugins: [
        .plugin(name: "Lint", package: "swiftformatplugins"),
      ]
    ),
  ]
)
