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
        "SolidCore",
        "SolidNumeric",
        "SolidURI",
        "SolidTempo",
        "SolidData",
        "SolidSchema",
        "SolidJSON",
        "SolidYAML",
        "SolidCBOR",
      ],
      path: "Sources/Solid/Root",
    ),
    .target(
      name: "SolidCore",
      dependencies: [
        .product(name: "Algorithms", package: "swift-algorithms"),
        .product(name: "Atomics", package: "swift-atomics"),
        .product(name: "Collections", package: "swift-collections"),
      ],
      path: "Sources/Solid/Core",
      plugins: [
        .plugin(name: "Lint", package: "swiftformatplugins")
      ]
    ),
    .target(
      name: "SolidNumeric",
      dependencies: [
        "SolidCore",
        .product(name: "Atomics", package: "swift-atomics"),
        .product(name: "Collections", package: "swift-collections"),
      ],
      path: "Sources/Solid/Numeric",
      plugins: [
        .plugin(name: "Lint", package: "swiftformatplugins")
      ]
    ),
    .target(
      name: "SolidNet",
      dependencies: [
        "SolidCore",
      ],
      path: "Sources/Solid/Net",
      plugins: [
        .plugin(name: "Lint", package: "swiftformatplugins")
      ]
    ),
    .target(
      name: "SolidURI",
      dependencies: [
        "SolidCore",
        "SolidNet",
        .product(name: "ScreamURITemplate", package: "uritemplate"),
      ],
      path: "Sources/Solid/URI",
      plugins: [
        .plugin(name: "Lint", package: "swiftformatplugins")
      ]
    ),
    .target(
      name: "SolidTempo",
      dependencies: [
        "SolidCore",
        .product(name: "Atomics", package: "swift-atomics"),
      ],
      path: "Sources/Solid/Tempo",
      plugins: [
        .plugin(name: "Lint", package: "swiftformatplugins")
      ]
    ),
    .target(
      name: "SolidData",
      dependencies: [
        "SolidCore",
        "SolidNumeric",
        "SolidURI",
      ],
      path: "Sources/Solid/Data",
      exclude: [
        "Path/Path.g4"
      ],
      plugins: [
        .plugin(name: "Lint", package: "swiftformatplugins")
      ]
    ),
    .target(
      name: "SolidSchema",
      dependencies: [
        "SolidData",
        "SolidURI",
        "SolidNumeric",
        "SolidJSON",
        "SolidNet",
        .product(name: "Collections", package: "swift-collections"),
      ],
      path: "Sources/Solid/Schema",
    ),
    .target(
      name: "SolidJSON",
      dependencies: ["SolidData"],
      path: "Sources/Solid/JSON",
      plugins: [
        .plugin(name: "Lint", package: "swiftformatplugins")
      ]
    ),
    .target(
      name: "SolidYAML",
      dependencies: ["SolidData"],
      path: "Sources/Solid/YAML",
      plugins: [
        .plugin(name: "Lint", package: "swiftformatplugins")
      ]
    ),
    .target(
      name: "SolidCBOR",
      dependencies: ["SolidData"],
      path: "Sources/Solid/CBOR",
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
    .target(
      name: "SolidTesting",
      dependencies: ["Solid"],
      path: "Tests/SolidTesting",
      resources: [
        .copy("Resources")
      ],
      plugins: [
        .plugin(name: "Lint", package: "swiftformatplugins")
      ]
    ),
    .testTarget(
      name: "SolidDataTests",
      dependencies: ["SolidTesting", "SolidData"],
      resources: [
        .copy("Resources")
      ],
      plugins: [
        .plugin(name: "Lint", package: "swiftformatplugins")
      ]
    ),
    .testTarget(
      name: "SolidNumericTests",
      dependencies: ["SolidTesting", "SolidNumeric"],
      resources: [
        .copy("Resources")
      ],
      plugins: [
        .plugin(name: "Lint", package: "swiftformatplugins")
      ]
    ),
    .testTarget(
      name: "SolidSchemaTests",
      dependencies: ["SolidTesting", "SolidSchema"],
      resources: [
        .copy("Resources")
      ],
      plugins: [
        .plugin(name: "Lint", package: "swiftformatplugins")
      ]
    ),
    .testTarget(
      name: "SolidTempoTests",
      dependencies: ["SolidTesting", "SolidTempo"],
      resources: [
        .copy("Resources")
      ],
      plugins: [
        .plugin(name: "Lint", package: "swiftformatplugins")
      ]
    ),
    .testTarget(
      name: "SolidURITests",
      dependencies: ["SolidTesting", "SolidURI"],
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
