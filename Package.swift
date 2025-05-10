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
      targets: ["Codex"]
    ),
    .executable(
      name: "CodexBench",
      targets: [
        "CodexBench"
      ]
    ),
  ],
  dependencies: [
    .package(url: "https://github.com/apple/swift-atomics.git", from: "1.2.0"),
    .package(url: "https://github.com/apple/swift-algorithms.git", .upToNextMinor(from: "1.2.0")),
    .package(url: "https://github.com/apple/swift-collections.git", .upToNextMinor(from: "1.1.4")),
    .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.5.0"),
    .package(url: "https://github.com/StarLard/SwiftFormatPlugins.git", from: "1.1.1"),
    .package(url: "https://github.com/SwiftScream/URITemplate.git", from: "5.0.1"),
    .package(url: "https://github.com/ordo-one/package-benchmark", .upToNextMajor(from: "1.0.0")),
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
        "Path/Path.g4"
      ],
      plugins: [
        .plugin(name: "Lint", package: "swiftformatplugins")
      ]
    ),
    .executableTarget(
      name: "CodexBench",
      dependencies: [
        "Codex",
        .product(name: "ArgumentParser", package: "swift-argument-parser"),
      ],
    ),
    .testTarget(
      name: "CodexTests",
      dependencies: ["Codex"],
      resources: [
        .copy("Resources")
      ],
      plugins: [
        .plugin(name: "Lint", package: "swiftformatplugins")
      ]
    ),
  ]
)

// Benchmark of CodexNumericBenchmark
package.targets += [
  .executableTarget(
    name: "CodexNumericBenchmark",
    dependencies: [
      "Codex",
      .product(name: "Benchmark", package: "package-benchmark"),
    ],
    path: "Benchmarks/CodexNumericBenchmark",
    plugins: [
      .plugin(name: "BenchmarkPlugin", package: "package-benchmark")
    ]
  )
]
