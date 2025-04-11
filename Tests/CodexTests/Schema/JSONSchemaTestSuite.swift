//
//  JSONSchemaTestSuite.swift
//  Codex
//
//  Created by Kevin Wooten on 2/11/25.
//

import Foundation
import Testing
@testable import Codex

@Suite("JSON Schema Test")
public struct JSONSchemaTestSuite {

  @Test(
    "Specific Test Cases",
    .disabled(),
    arguments: [
      (draft: .draft2020_12, group: "ref", case: "root pointer ref", test: "match")
    ] as [(Draft.Version, String, String, String)],
  )
  func specificTests(draftVersion: Draft.Version, groupName: String, caseName: String, testName: String) throws {
    guard
      let (testCase, test) =
        Draft.load(version: draftVersion)
        .group(name: groupName)?
        .case(name: caseName)?
        .test(name: testName)
    else {
      return
    }
    Self.executeTest(testCase: testCase, test: test)
  }

  @Suite("Draft 2020-12") struct Draft2020_12 {

    static let draft = Draft.load(version: .draft2020_12)

    @Test("Additional Properties", arguments: draft.tests(group: "additionalProperties"))
    func additionalProperties(testCase: TestCase, test: Test) throws {
      executeTest(testCase: testCase, test: test)
    }

    @Test("All Of", arguments: draft.tests(group: "allOf"))
    func allOf(testCase: TestCase, test: Test) throws {
      executeTest(testCase: testCase, test: test)
    }

    @Test("Anchor", arguments: draft.tests(group: "anchor"))
    func anchor(testCase: TestCase, test: Test) throws {
      executeTest(testCase: testCase, test: test)
    }

    @Test("Any Of", arguments: draft.tests(group: "anyOf"))
    func anyOf(testCase: TestCase, test: Test) throws {
      executeTest(testCase: testCase, test: test)
    }

    @Test("Boolean Schema", arguments: draft.tests(group: "boolean_schema"))
    func boolean_schema(testCase: TestCase, test: Test) throws {
      executeTest(testCase: testCase, test: test)
    }

    @Test("Const", arguments: draft.tests(group: "const"))
    func const(testCase: TestCase, test: Test) throws {
      executeTest(testCase: testCase, test: test)
    }

    @Test("Contains", arguments: draft.tests(group: "contains"))
    func contains(testCase: TestCase, test: Test) throws {
      executeTest(testCase: testCase, test: test)
    }

    @Test("Content", arguments: draft.tests(group: "content"))
    func content(testCase: TestCase, test: Test) throws {
      executeTest(testCase: testCase, test: test)
    }

    @Test("Default", arguments: draft.tests(group: "default"))
    func `default`(testCase: TestCase, test: Test) throws {
      executeTest(testCase: testCase, test: test)
    }

    @Test("Defs", arguments: draft.tests(group: "defs"))
    func defs(testCase: TestCase, test: Test) throws {
      executeTest(testCase: testCase, test: test)
    }

    @Test("Dependent Required", arguments: draft.tests(group: "dependentRequired"))
    func dependentRequired(testCase: TestCase, test: Test) throws {
      executeTest(testCase: testCase, test: test)
    }

    @Test("Dependent Schemas", arguments: draft.tests(group: "dependentSchemas"))
    func dependentSchemas(testCase: TestCase, test: Test) throws {
      executeTest(testCase: testCase, test: test)
    }

    @Test("Dynamic Ref", arguments: draft.tests(group: "dynamicRef"))
    func dynamicRef(testCase: TestCase, test: Test) throws {
      executeTest(testCase: testCase, test: test)
    }

    @Test("Enum", arguments: draft.tests(group: "enum"))
    func `enum`(testCase: TestCase, test: Test) throws {
      executeTest(testCase: testCase, test: test)
    }

    @Test("Exclusive Maximum", arguments: draft.tests(group: "exclusiveMaximum"))
    func exclusiveMaximum(testCase: TestCase, test: Test) throws {
      executeTest(testCase: testCase, test: test)
    }

    @Test("Exclusive Minimum", arguments: draft.tests(group: "exclusiveMinimum"))
    func exclusiveMinimum(testCase: TestCase, test: Test) throws {
      executeTest(testCase: testCase, test: test)
    }

    @Test("Format", arguments: draft.tests(group: "format"))
    func format(testCase: TestCase, test: Test) throws {
      executeTest(testCase: testCase, test: test)
    }

    @Test("If-Then-Else", arguments: draft.tests(group: "if-then-else"))
    func if_then_else(testCase: TestCase, test: Test) throws {
      executeTest(testCase: testCase, test: test)
    }

    @Test("Infinite Loop Detection", arguments: draft.tests(group: "infinite-loop-detection"))
    func infiniteLoopDetection(testCase: TestCase, test: Test) throws {
      executeTest(testCase: testCase, test: test)
    }

    @Test("Items", arguments: draft.tests(group: "items"))
    func items(testCase: TestCase, test: Test) throws {
      executeTest(testCase: testCase, test: test)
    }

    @Test("Max Contains", arguments: draft.tests(group: "maxContains"))
    func maxContains(testCase: TestCase, test: Test) throws {
      executeTest(testCase: testCase, test: test)
    }

    @Test("Maximum", arguments: draft.tests(group: "maximum"))
    func maximum(testCase: TestCase, test: Test) throws {
      executeTest(testCase: testCase, test: test)
    }

    @Test("Max Items", arguments: draft.tests(group: "maxItems"))
    func maxItems(testCase: TestCase, test: Test) throws {
      executeTest(testCase: testCase, test: test)
    }

    @Test("Max Length", arguments: draft.tests(group: "maxLength"))
    func maxLength(testCase: TestCase, test: Test) throws {
      executeTest(testCase: testCase, test: test)
    }

    @Test("Max Properties", arguments: draft.tests(group: "maxProperties"))
    func maxProperties(testCase: TestCase, test: Test) throws {
      executeTest(testCase: testCase, test: test)
    }

    @Test("Min Contains", arguments: draft.tests(group: "minContains"))
    func minContains(testCase: TestCase, test: Test) throws {
      executeTest(testCase: testCase, test: test)
    }

    @Test("Minimum", arguments: draft.tests(group: "minimum"))
    func minimum(testCase: TestCase, test: Test) throws {
      executeTest(testCase: testCase, test: test)
    }

    @Test("Min Items", arguments: draft.tests(group: "minItems"))
    func minItems(testCase: TestCase, test: Test) throws {
      executeTest(testCase: testCase, test: test)
    }

    @Test("Min Length", arguments: draft.tests(group: "minLength"))
    func minLength(testCase: TestCase, test: Test) throws {
      executeTest(testCase: testCase, test: test)
    }

    @Test("Min Properties", arguments: draft.tests(group: "minProperties"))
    func minProperties(testCase: TestCase, test: Test) throws {
      executeTest(testCase: testCase, test: test)
    }

    @Test("Multiple Of", arguments: draft.tests(group: "multipleOf"))
    func multipleOf(testCase: TestCase, test: Test) throws {
      executeTest(testCase: testCase, test: test)
    }

    @Test("Not", arguments: draft.tests(group: "not"))
    func not(testCase: TestCase, test: Test) throws {
      executeTest(testCase: testCase, test: test)
    }

    @Test("One Of", arguments: draft.tests(group: "oneOf"))
    func oneOf(testCase: TestCase, test: Test) throws {
      executeTest(testCase: testCase, test: test)
    }

    @Test("Pattern", arguments: draft.tests(group: "pattern"))
    func pattern(testCase: TestCase, test: Test) throws {
      executeTest(testCase: testCase, test: test)
    }

    @Test("Pattern Properties", arguments: draft.tests(group: "patternProperties"))
    func patternProperties(testCase: TestCase, test: Test) throws {
      executeTest(testCase: testCase, test: test)
    }

    @Test("Prefix Items", arguments: draft.tests(group: "prefixItems"))
    func prefixItems(testCase: TestCase, test: Test) throws {
      executeTest(testCase: testCase, test: test)
    }

    @Test("Properties", arguments: draft.tests(group: "properties"))
    func properties(testCase: TestCase, test: Test) throws {
      executeTest(testCase: testCase, test: test)
    }

    @Test("Property Names", arguments: draft.tests(group: "propertyNames"))
    func propertyNames(testCase: TestCase, test: Test) throws {
      executeTest(testCase: testCase, test: test)
    }

    @Test("Ref", arguments: draft.tests(group: "ref"))
    func ref(testCase: TestCase, test: Test) throws {
      executeTest(testCase: testCase, test: test)
    }

    @Test("Ref Remote", arguments: draft.tests(group: "refRemote"))
    func refRemote(testCase: TestCase, test: Test) throws {
      executeTest(testCase: testCase, test: test)
    }

    @Test("Required", arguments: draft.tests(group: "required"))
    func required(testCase: TestCase, test: Test) throws {
      executeTest(testCase: testCase, test: test)
    }

    @Test("Type", arguments: draft.tests(group: "type"))
    func type(testCase: TestCase, test: Test) throws {
      executeTest(testCase: testCase, test: test)
    }

    @Test("Unevaluated Items", arguments: draft.tests(group: "unevaluatedItems"))
    func unevaluatedItems(testCase: TestCase, test: Test) throws {
      executeTest(testCase: testCase, test: test)
    }

    @Test("Unevaluated Properties", arguments: draft.tests(group: "unevaluatedProperties"))
    func unevaluatedProperties(testCase: TestCase, test: Test) throws {
      executeTest(testCase: testCase, test: test)
    }

    @Test("Unique Items", arguments: draft.tests(group: "uniqueItems"))
    func uniqueItems(testCase: TestCase, test: Test) throws {
      executeTest(testCase: testCase, test: test)
    }

    @Test("Vocabulary", arguments: draft.tests(group: "vocabulary"))
    func vocabulary(testCase: TestCase, test: Test) throws {
      executeTest(testCase: testCase, test: test)
    }

    @Suite("Optional")
    public struct Optional {

      @Test("Anchor", arguments: draft.tests(group: "optional/anchor"))
      func anchor(testCase: TestCase, test: Test) throws {
        executeTest(testCase: testCase, test: test)
      }

      @Test("BigNum", arguments: draft.tests(group: "optional/bignum"))
      func bignum(testCase: TestCase, test: Test) throws {
        executeTest(testCase: testCase, test: test)
      }

      @Test(
        "Cross Draft",
        .disabled("Older drafts not currently supported"),
        arguments: draft.tests(group: "optional/cross-draft")
      )
      func crossDraft(testCase: TestCase, test: Test) throws {
        executeTest(testCase: testCase, test: test)
      }

      @Test(
        "Dependencies Compatibility",
        arguments: draft.tests(group: "optional/dependencies-compatibility")
      )
      func dependenciesCompatibility(testCase: TestCase, test: Test) throws {
        executeTest(testCase: testCase, test: test)
      }

      @Test("Dynamic Ref", arguments: draft.tests(group: "optional/dynamicRef"))
      func dynamicRef(testCase: TestCase, test: Test) throws {
        executeTest(testCase: testCase, test: test)
      }

      @Test(
        "Ecmascript Regex",
        .disabled("Failing, uninvestigated"),
        arguments: draft.tests(group: "optional/ecmascript-regex")
      )
      func ecmascriptRegex(testCase: TestCase, test: Test) throws {
        executeTest(testCase: testCase, test: test)
      }

      @Test("Float Overflow", arguments: draft.tests(group: "optional/float-overflow"))
      func floatOverflow(testCase: TestCase, test: Test) throws {
        executeTest(testCase: testCase, test: test)
      }

      @Test(
        "Format Assertion",
        arguments: draft.tests(group: "optional/format-assertion")
      )
      func formatAssertion(testCase: TestCase, test: Test) throws {
        executeTest(testCase: testCase, test: test)
      }

      @Test("Id", arguments: draft.tests(group: "optional/id"))
      func id(testCase: TestCase, test: Test) throws {
        executeTest(testCase: testCase, test: test)
      }

      @Test("No Schema", arguments: draft.tests(group: "optional/no-schema"))
      func noSchema(testCase: TestCase, test: Test) throws {
        executeTest(testCase: testCase, test: test)
      }

      @Test("Non BMP Regex", arguments: draft.tests(group: "optional/non-bmp-regex"))
      func noBmpRegex(testCase: TestCase, test: Test) throws {
        executeTest(testCase: testCase, test: test)
      }

      @Test(
        "Ref of Unknown Keyword",
        arguments: draft.tests(group: "optional/refOfUnknownKeyword")
      )
      func refOfUnknownKeyword(testCase: TestCase, test: Test) throws {
        executeTest(testCase: testCase, test: test, trace: true)
      }

      @Test("Unknown Keyword", arguments: draft.tests(group: "optional/unknownKeyword"))
      func unknownKeyword(testCase: TestCase, test: Test) throws {
        executeTest(testCase: testCase, test: test)
      }
    }
  }

  static func executeTest(
    testCase: TestCase,
    test: Test,
    trace: Bool = false,
    sourceLocation: SourceLocation = #_sourceLocation
  ) {
    let options = Schema.Options.default
      .schemaLocator(JSONSchemaTestSuite.remoteSchemas)
      .trace(trace)

    let schema: Schema
    do {
      schema = try Schema.Builder.build(from: testCase.schema, options: options)
    } catch {
      Issue.record(error, "Failed to build schema", sourceLocation: sourceLocation)
      return
    }

    let result: Schema.Validator.Result
    do {
      result = try schema.validate(instance: test.data, outputFormat: .verbose, options: options)
    } catch {
      Issue.record(error, "Failed to validate instance", sourceLocation: sourceLocation)
      return
    }
    #expect(result.isValid == test.valid, "Expected \(test.valid ? "valid" : "invalid")", sourceLocation: sourceLocation)
    if trace {
      print("Output:\n\(result)")
    }
  }

  public struct Draft: Sendable, CustomStringConvertible {

    public enum Version: String, CaseIterable, Sendable, CustomStringConvertible {
      case draftNext = "draft-next"
      case draft2020_12 = "draft2020-12"
      case draft2019_09 = "draft2019-09"
      case draft7 = "draft7"
      case draft6 = "draft6"
      case draft4 = "draft4"
      case draft3 = "draft3"

      public var description: String { String(rawValue.trimmingPrefix("draft")) }
    }

    public static func load(version: Version) -> Draft {
      guard
        let draftDir = Bundle.module.resourceURL?.appending(path: "tests/\(version.rawValue)"),
        let reachable = try? draftDir.checkResourceIsReachable(),
        reachable
      else {
        fatalError("Could not locate JSON Schema Test Suite for \(version)")
      }
      do {
        return try Draft(directory: draftDir)
      } catch {
        fatalError("Could not load JSON Schema Test Suite: \(error)")
      }
    }

    public let name: String
    public let directory: URL
    nonisolated(unsafe) private static var cachedGroups: [URL: TestGroup] = [:]
    private static let cachedGroupsLock = NSLock()

    public var description: String { name }

    public init(directory: URL) throws {
      self.name = directory.lastPathComponent
      self.directory = directory
    }

    public func group(
      name: String,
      sourceLocation: SourceLocation = #_sourceLocation
    ) -> TestGroup? {
      Self.cachedGroupsLock.lock()
      defer { Self.cachedGroupsLock.unlock() }

      let groupFile = directory.appending(path: "\(name).json").absoluteURL
      if let group = Self.cachedGroups[groupFile] {
        return group
      }

      do {
        let group = try TestGroup(file: groupFile, rootDirectory: directory)
        Self.cachedGroups[groupFile] = group
        return group
      } catch {
        Issue.record(error, "Failed to load group '\(name)'", sourceLocation: sourceLocation)
        return nil
      }
    }

    public func tests(
      group groupName: String,
      sourceLocation: SourceLocation = #_sourceLocation
    ) -> [(case: TestCase, test: Test)] {
      guard let group = group(name: groupName, sourceLocation: sourceLocation) else {
        return []
      }
      return group.tests()
    }
  }

  public struct TestGroup: Identifiable, Sendable, CustomStringConvertible {

    public let name: String
    public let testCases: [TestCase]

    public var id: String { name }
    public var description: String { name }

    public init(file: URL, rootDirectory: URL) throws {
      let fullName = file.deletingPathExtension()
      let relName = String(fullName.path().dropFirst(rootDirectory.path.count + 1))
      self.name = relName
      let jsonData = try Data(contentsOf: file)
      self.testCases = try JSONValueReader(data: jsonData).readValue()
        .decode(as: \.array)
        .map(TestCase.init)
    }

    public func `case`(
      name: String,
      sourceLocation: SourceLocation = #_sourceLocation
    ) -> TestCase? {
      guard let testCase = testCases.first(where: { $0.name == name }) else {
        Issue.record("Test case \(name) not found in group \(self.name)", sourceLocation: sourceLocation)
        return nil
      }
      return testCase
    }

    public func tests() -> [(case: TestCase, test: Test)] {
      return testCases.flatMap { testCase in
        testCase.tests.map { test in (testCase, test) }
      }
    }
  }

  public struct TestCase: Identifiable, Sendable, CustomStringConvertible {

    public let name: String
    public let schema: Value
    public let tests: [Test]

    public var id: String { name }
    public var description: String { name }

    public init(from value: Value) throws {
      self.name = try value.decode("description", as: \.string)
      self.schema = try value.decode("schema")
      self.tests = try value.decode("tests", as: \.array).map(Test.init)
    }

    public func test(name: String, sourceLocation: SourceLocation = #_sourceLocation) -> (TestCase, Test)? {
      guard let test = tests.first(where: { $0.name == name }) else {
        Issue.record("Test '\(name)' not found in test case '\(self.name)'", sourceLocation: sourceLocation)
        return nil
      }
      return (self, test)
    }
  }

  public struct Test: Identifiable, Sendable, CustomStringConvertible {

    public let name: String
    public let data: Value
    public let valid: Bool

    public var id: String { name }
    public var description: String { name }

    public init(from value: Value) throws {
      self.name = try value.decode("description", as: \.string)
      self.data = try value.decode("data")
      self.valid = try value.decode("valid", as: \.bool)
    }
  }

  static let resourcesDirectoryURL: URL = {
    Bundle.module.resourceURL.neverNil("No resources directory for module")
  }()
  static let remoteSchemas: SchemaLocator = {
    LocalDirectorySchemaContainer(for: resourcesDirectoryURL.appending(path: "/remotes")).neverNil()
  }()

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
