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
    .package(url: "https://github.com/mgriebling/BigDecimal.git", from: "3.0.2"),
    .package(url: "https://github.com/SwiftScream/URITemplate.git", from: "5.0.1"),
    .package(url: "https://github.com/antlr/antlr4.git", from: "4.13.2"),
  ],
  targets: [
    .target(
      name: "Codex",
      dependencies: [
        .product(name: "Atomics", package: "swift-atomics"),
        .product(name: "Collections", package: "swift-collections"),
        .product(name: "BigDecimal", package: "BigDecimal"),
        .product(name: "ScreamURITemplate", package: "uritemplate"),
        .product(name: "Antlr4", package: "Antlr4"),
      ],
      exclude: [
        "Path/Parsing/Path.g4",
        "Path/Parsing/Path.interp",
        "Path/Parsing/Path.tokens",
        "Path/Parsing/PathLexer.interp",
        "Path/Parsing/PathLexer.tokens",
      ]
    ),
    .testTarget(
      name: "CodexTests",
      dependencies: ["Codex"],
      resources: [
        .copy("../JSONTestSuite/tests"),
        .copy("../JSONTestSuite/output-tests"),
        .copy("../JSONTestSuite/remotes"),
      ]
    ),
  ]
)
