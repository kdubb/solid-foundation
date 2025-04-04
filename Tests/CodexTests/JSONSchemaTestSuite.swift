//
//  JSONSchemaTestSuite.swift
//  Codex
//
//  Created by Kevin Wooten on 2/11/25.
//

import Foundation
import Testing
@testable import Codex

public struct JSONSchemaTestSuite {

  public let drafts = ["2020-12"]

  static let resourcesDirectoryURL: URL = {
    Bundle.module.resourceURL.neverNil("No resources directory for module")
  }()
  static let remoteSchemas: SchemaLocator = {
    LocalDirectorySchemaContainer(for: resourcesDirectoryURL.appending(path: "/remotes")).neverNil()
  }()

  @Test("Specific Test Case") func specificTestCase() throws {
    let testCasesURL = try #require(
      Bundle.module.url(
        forResource: "dynamicRef",
        withExtension: "json",
        subdirectory: "tests/draft2020-12"
      )
    )
    var testCases = try JSONValueReader(data: Data(contentsOf: testCasesURL))
      .readValue()
      .decode(as: \.array)
      .map(JSONSchemaTestSuite.TestCase.init)
    //      testCases = testCases
    //        .filter { $0.description == "A $dynamicRef to an $anchor in the same schema resource behaves like a normal $ref to an $anchor" }
    try #require(!testCases.isEmpty)
    for testCase in testCases {
      print("🧩 \(testCase.description)")
      let tests = testCase.tests
      //        let tests = testCase.tests.filter { $0.description == "An array of strings is valid" }
      try #require(!tests.isEmpty)
      for test in tests {
        print("  🧩 \(test.description)")
        let options = Schema.Options.default.schemaLocator(Self.remoteSchemas)
        let schema = try Schema.Builder.build(from: testCase.schema, options: options)
        let (result, annotations) = try Schema.Validator.validate(
          instance: test.data,
          using: schema,
          options: .default.schemaLocator(Self.remoteSchemas).collectAnnotations(.matching(.keywords([.properties])))
        )
        let valid = result.isValid == test.valid
        if valid {
          print("    ✅ Expected \(test.valid ? "valid" : "invalid")")
        } else {
          print("    ⚠️ Expected \(test.valid ? "valid" : "invalid")")
          print(result.description)
        }
        if !annotations.isEmpty {
          print("    Annotations:")
          for annotation in annotations {
            print("    - \(annotation.description.split(separator: "\n").joined(separator: "\n      "))")
          }
        }
        #expect(valid, "\(test.description)")
      }
    }
  }

  @Test("Draft 2020-12", arguments: drafts["draft2020-12"]!.groups)
  func draft2020_12(group: TestGroup) throws {
    for testCase in group.testCases {
      print("🧩 \(testCase.description)")
      let options = Schema.Options.default.schemaLocator(JSONSchemaTestSuite.remoteSchemas)
      let schema: Schema
      do {
        schema = try Schema.Builder.build(from: testCase.schema, options: options)
      } catch {
        print("  💥 Failed to parse schema: \(error)")
        #expect(Bool(false), "Failed to parse schema: \(error)")
        continue
      }
      for test in testCase.tests {
        print("  🧪 \(test.description)")
        do {
          let testValid = try schema.validate(instance: test.data, options: options).isValid == test.valid
          #expect(testValid, "\(testCase.description) - \(test.description), expected \(test.valid ? "valid" : "invalid")")
          if testValid {
            print("    ✅ Expected \(test.valid ? "valid" : "invalid")")
          }
        } catch {
          #expect(Bool(false), "Failed to validate test case '\(test.description)': \(error)")
          continue
        }
      }
    }
  }

  public static let drafts: [String: Draft] = {
    guard
      let testsDir = Bundle.module.resourceURL?.appending(path: "tests"),
      let reachable = try? testsDir.checkResourceIsReachable(),
      reachable
    else {
      fatalError("Could not locate JSON Schema Test Suite")
    }
    do {
      var drafts: [String: Draft] = [:]
      let dirs = try FileManager.default.contentsOfDirectory(
        at: testsDir,
        includingPropertiesForKeys: [.isDirectoryKey],
        options: [.skipsHiddenFiles, .skipsPackageDescendants, .skipsSubdirectoryDescendants]
      ).filter { try $0.resourceValues(forKeys: [.isDirectoryKey]).isDirectory == true }
      for dir in dirs {
        let draft = try Draft(directory: dir)
        drafts[dir.lastPathComponent] = draft
      }
      return drafts
    } catch {
      fatalError("Could not load JSON Schema Test Suite: \(error)")
    }
  }()

  public struct Draft: Sendable, CustomStringConvertible {

    public let description: String
    public let groups: [TestGroup]

    public init(description: String, groups: [TestGroup]) {
      self.description = description
      self.groups = groups
    }

    public init(directory: URL) throws {
      let files = try FileManager.default.contentsOfDirectory(
        at: directory,
        includingPropertiesForKeys: [.isRegularFileKey],
        options: [.skipsHiddenFiles, .skipsSubdirectoryDescendants, .skipsPackageDescendants]
      ).filter { $0.pathExtension == "json" }

      self.init(
        description: directory.lastPathComponent,
        groups: try files.map { try TestGroup(file: $0) }
      )
    }
  }

  public struct TestGroup: Sendable, CustomStringConvertible, CustomTestStringConvertible {

    public let description: String
    public let testCases: [TestCase]

    public var testDescription: String { description }

    public init(description: String, testCases: [TestCase]) {
      self.description = description
      self.testCases = testCases
    }

    public init(file: URL) throws {
      let description = file.deletingPathExtension().lastPathComponent
      let jsonData = try Data(contentsOf: file)
      let testCases = try JSONValueReader(data: jsonData).readValue()
        .decode(as: \.array)
        .map(TestCase.init)
      self.init(description: description, testCases: testCases)
    }
  }

  public struct TestCase: Sendable, CustomStringConvertible {

    public struct Test: Sendable, CustomStringConvertible {

      public let description: String
      public let data: Value
      public let valid: Bool

      public init(description: String, data: Value, valid: Bool) {
        self.description = description
        self.data = data
        self.valid = valid
      }

      public init(from value: Value) throws {
        self.description = try value.decode("description", as: \.string)
        self.data = try value.decode("data")
        self.valid = try value.decode("valid", as: \.bool)
      }
    }

    public let description: String
    public let schema: Value
    public let tests: [Test]

    public init(description: String, schema: Value, tests: [Test]) {
      self.description = description
      self.schema = schema
      self.tests = tests
    }

    public init(from value: Value) throws {
      self.description = try value.decode("description", as: \.string)
      self.schema = try value.decode("schema")
      self.tests = try value.decode("tests", as: \.array).map(Test.init)
    }
  }

}

extension Value {

  public enum Error: Swift.Error {
    case missingProperty(String)
    case unexpectedType(Value, expected: Any.Type)
  }

  fileprivate func decode<T>(as keypath: KeyPath<Value, T?>) throws -> T {
    guard let value = self[keyPath: keypath] else {
      throw Error.unexpectedType(self, expected: T.self)
    }
    return value
  }

  fileprivate func decode<T>(_ key: String, as keypath: KeyPath<Value, T?>) throws -> T {
    guard let property = self[.string(key)] else {
      throw Error.missingProperty(key)
    }
    guard let value = property[keyPath: keypath] else {
      throw Error.unexpectedType(property, expected: T.self)
    }
    return value
  }

  fileprivate func decode(_ key: String) throws -> Value {
    guard let property = self[.string(key)] else {
      throw Error.missingProperty(key)
    }
    return property
  }
}
