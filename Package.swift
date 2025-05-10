// swift-tools-version: 6.0

import PackageDescription

let package = Package(
  name: "SolidFoundation",
  platforms: [
    .macOS("15"),
    .iOS("18"),
    .tvOS("18"),
    .watchOS("11"),
  ],
  products: [
    .library(
      name: "Solid",
      targets: ["Solid"]
    ),
    .executable(
      name: "SolidBench",
      targets: [
        "SolidBench"
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
      name: "Solid",
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
      name: "SolidBench",
      dependencies: [
        "Solid",
        .product(name: "ArgumentParser", package: "swift-argument-parser"),
      ],
    ),
    .testTarget(
      name: "SolidTests",
      dependencies: ["Solid"],
      resources: [
        .copy("Resources")
      ],
      plugins: [
        .plugin(name: "Lint", package: "swiftformatplugins")
      ]
    ),
  ]
)

// Benchmark of SolidNumericBenchmark
package.targets += [
  .executableTarget(
    name: "SolidNumericBenchmark",
    dependencies: [
      "Solid",
      .product(name: "Benchmark", package: "package-benchmark"),
    ],
    path: "Benchmarks/SolidNumericBenchmark",
    plugins: [
      .plugin(name: "BenchmarkPlugin", package: "package-benchmark")
    ]
  )
]
