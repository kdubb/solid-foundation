import Foundation


/// Test data loaded from JSON in test Resources.
protocol TestData: Decodable, Sendable {

  /// Load test data from a JSON file.
  static func load(from url: URL) -> Self

  /// Load test data from a bundled resource.
  static func loadFromBundle(name: String, bundle: Bundle) -> Self

}

extension TestData {

  /// Load test data from a JSON file
  static func load(from url: URL) -> Self {
    do {
      let data = try Data(contentsOf: url)
      let decoder = JSONDecoder()
      return try decoder.decode(Self.self, from: data)
    } catch {
      fatalError("Failed to load test data from \(url): \(error)")
    }
  }

  /// Load test data from a bundled resource
  static func loadFromBundle(name: String = String(describing: Self.self), bundle: Bundle = .module) -> Self {

    guard let url = bundle.url(forResource: name, withExtension: "json", subdirectory: "Resources") else {
      fatalError("Test data for \(name) not found in bundle resources (file: \(name).json)")
    }    
    
    return load(from: url)
  }

}
