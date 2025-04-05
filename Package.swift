// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "Codex",
  platforms: [
    .macOS("13.3"),
    .iOS("16.3"),
    .tvOS("16.3"),
    .watchOS("9.3")
  ],
  products: [
    // Products define the executables and libraries a package produces, making them visible to other packages.
    .library(
      name: "Codex",
      targets: ["Codex"]),
  ],
  dependencies: [
    .package(url: "https://github.com/apple/swift-collections.git", .upToNextMinor(from: "1.1.4")),
    .package(url: "https://github.com/apple/swift-atomics.git", from: "1.2.0"),
    .package(url: "https://github.com/antlr/antlr4.git", from: "4.13.2"),
    .package(url: "https://github.com/mgriebling/BigDecimal.git", from: "3.0.2"),
    .package(url: "https://github.com/SwiftScream/URITemplate.git", from: "5.0.1"),
  ],
  targets: [
    .target(
      name: "Codex",
      dependencies: [
        .product(name: "Collections", package: "swift-collections"),
        .product(name: "BigDecimal", package: "BigDecimal"),
        .product(name: "Antlr4", package: "Antlr4"),
        .product(name: "Atomics", package: "swift-atomics"),
        .product(name: "ScreamURITemplate", package: "uritemplate"),
      ],
      exclude: [
        "*.interp",
        "*.tokens",
        "*.g4",
      ]
    ),
    .testTarget(
      name: "CodexTests",
      dependencies: ["Codex"],
      exclude: ["JSONTestSuite"],
      resources: [
        .copy("JSONTestSuite/tests"),
        .copy("JSONTestSuite/output-tests"),
        .copy("JSONTestSuite/remotes"),
      ]),
  ]
)
