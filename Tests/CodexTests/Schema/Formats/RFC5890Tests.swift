import Testing
@testable import Codex

@Suite("RFC5890 Tests")
final class RFC5890Tests {

  // MARK: - Basic Validation Tests

  @Test("Valid hostnames")
  func validHostnames() throws {
    // Test valid ASCII hostnames
    let example = RFC5890.IDNHostname.parse(string: "example.com")
    let exampleValue = try #require(example?.value, "Failed to parse example.com")
    #expect(exampleValue == "example.com")

    let subExample = RFC5890.IDNHostname.parse(string: "sub.example.com")
    let subValue = try #require(subExample?.value, "Failed to parse sub.example.com")
    #expect(subValue == "sub.example.com")

    let longHostname = RFC5890.IDNHostname.parse(string: "a.b.c.d.e.f.g.h.i.j.k.l.m.n.o.p.q.r.s.t.u.v.w.x.y.z")
    let longValue = try #require(longHostname?.value, "Failed to parse long hostname")
    #expect(longValue == "a.b.c.d.e.f.g.h.i.j.k.l.m.n.o.p.q.r.s.t.u.v.w.x.y.z")

    // Test valid IDN hostnames
    let idnHostname = RFC5890.IDNHostname.parse(string: "xn--bcher-kva.example")
    let idnValue = try #require(idnHostname?.value, "Failed to parse IDN hostname")
    #expect(idnValue == "xn--bcher-kva.example")

    let nestedIdn = RFC5890.IDNHostname.parse(string: "xn--bcher-kva.xn--bcher-kva.example")
    let nestedValue = try #require(nestedIdn?.value, "Failed to parse nested IDN hostname")
    #expect(nestedValue == "xn--bcher-kva.xn--bcher-kva.example")

    // Test valid hostnames with trailing dot
    let trailingDot = RFC5890.IDNHostname.parse(string: "example.com.")
    let trailingValue = try #require(trailingDot?.value, "Failed to parse hostname with trailing dot")
    #expect(trailingValue == "example.com")
  }

  @Test("Invalid hostnames")
  func invalidHostnames() {
    // Test hostnames that are too long
    let longString = String(repeating: "a", count: 256)
    #expect(RFC5890.IDNHostname.parse(string: longString) == nil)

    // Test hostnames with invalid characters
    #expect(RFC5890.IDNHostname.parse(string: "example@.com") == nil)
    #expect(RFC5890.IDNHostname.parse(string: "example!.com") == nil)
    #expect(RFC5890.IDNHostname.parse(string: "example#.com") == nil)

    // Test hostnames with invalid label lengths
    let longLabel = String(repeating: "a", count: 64)
    #expect(RFC5890.IDNHostname.parse(string: "\(longLabel).com") == nil)

    // Test empty hostname
    #expect(RFC5890.IDNHostname.parse(string: "") == nil)

    // Test hostname with empty labels
    #expect(RFC5890.IDNHostname.parse(string: "example..com") == nil)
    #expect(RFC5890.IDNHostname.parse(string: ".example.com") == nil)
  }

  // MARK: - Label Validation Tests

  @Test("Valid labels")
  func validLabels() throws {
    // Test valid ASCII labels
    let simpleLabel = RFC5890.IDNHostname.parse(string: "a.example")
    let simpleValue = try #require(simpleLabel?.value, "Failed to parse simple label")
    #expect(simpleValue == "a.example")

    let hyphenLabel = RFC5890.IDNHostname.parse(string: "a-b.example")
    let hyphenValue = try #require(hyphenLabel?.value, "Failed to parse hyphen label")
    #expect(hyphenValue == "a-b.example")

    let numericLabel = RFC5890.IDNHostname.parse(string: "a1.example")
    let numericValue = try #require(numericLabel?.value, "Failed to parse numeric label")
    #expect(numericValue == "a1.example")

    // Test valid IDN labels
    let idnLabel = RFC5890.IDNHostname.parse(string: "xn--bcher-kva.example")
    let idnValue = try #require(idnLabel?.value, "Failed to parse IDN label")
    #expect(idnValue == "xn--bcher-kva.example")

    let nestedIdnLabel = RFC5890.IDNHostname.parse(string: "xn--bcher-kva.xn--bcher-kva.example")
    let nestedValue = try #require(nestedIdnLabel?.value, "Failed to parse nested IDN label")
    #expect(nestedValue == "xn--bcher-kva.xn--bcher-kva.example")
  }

  @Test("Invalid labels")
  func invalidLabels() {
    // Test labels that start or end with hyphen
    #expect(RFC5890.IDNHostname.parse(string: "-example.com") == nil)
    #expect(RFC5890.IDNHostname.parse(string: "example-.com") == nil)

    // Test labels with consecutive hyphens
    #expect(RFC5890.IDNHostname.parse(string: "exa--mple.com") == nil)

    // Test labels with invalid characters
    #expect(RFC5890.IDNHostname.parse(string: "ex@mple.com") == nil)
    #expect(RFC5890.IDNHostname.parse(string: "ex!mple.com") == nil)
  }

  // MARK: - Parameterized Tests

  @Test("Valid hostname lengths", arguments: [
    "a.b",
    String(repeating: "a", count: 63) + "." + String(repeating: "b", count: 63) + "." + String(repeating: "c", count: 63) + "." + String(repeating: "d", count: 63) + ".com"
  ])
  func validHostnameLengths(hostname: String) throws {
    let result = RFC5890.IDNHostname.parse(string: hostname)
    let value = try #require(result?.value, "Failed for hostname: \(hostname)")
    #expect(value == hostname, "Value mismatch for hostname: \(hostname)")
  }

  @Test("Valid label lengths", arguments: [
    "a.example.com",
    String(repeating: "a", count: 63) + ".com"
  ])
  func validLabelLengths(hostname: String) throws {
    let result = RFC5890.IDNHostname.parse(string: hostname)
    let value = try #require(result?.value, "Failed for hostname: \(hostname)")
    #expect(value == hostname, "Value mismatch for hostname: \(hostname)")
  }

  // MARK: - Edge Cases

  @Test("Edge cases")
  func edgeCases() throws {
    // Test single label
    let localhost = RFC5890.IDNHostname.parse(string: "localhost")
    let localhostValue = try #require(localhost?.value, "Failed to parse localhost")
    #expect(localhostValue == "localhost")

    // Test root domain
    let root = RFC5890.IDNHostname.parse(string: ".")
    let rootValue = try #require(root?.value, "Failed to parse root domain")
    #expect(rootValue == "")

    // Test hostname with all valid characters
    let mixedChars = RFC5890.IDNHostname.parse(string: "a1-b2-c3.example")
    let mixedValue = try #require(mixedChars?.value, "Failed to parse mixed character hostname")
    #expect(mixedValue == "a1-b2-c3.example")

    // Test hostname with mixed case
    let mixedCase = RFC5890.IDNHostname.parse(string: "ExAmPlE.CoM")
    let caseValue = try #require(mixedCase?.value, "Failed to parse mixed case hostname")
    #expect(caseValue == "ExAmPlE.CoM")
  }

  // MARK: - IDN Specific Tests

  @Test("IDN validation")
  func idnValidation() throws {
    // Test valid A-labels (Punycode)
    let validPunycode = RFC5890.IDNHostname.parse(string: "xn--bcher-kva.example")
    let punycodeValue = try #require(validPunycode?.value, "Failed to parse valid Punycode")
    #expect(punycodeValue == "xn--bcher-kva.example")

    let nestedValidPunycode = RFC5890.IDNHostname.parse(string: "xn--bcher-kva.xn--bcher-kva.example")
    let nestedValue = try #require(nestedValidPunycode?.value, "Failed to parse nested valid Punycode")
    #expect(nestedValue == "xn--bcher-kva.xn--bcher-kva.example")

    // Test invalid A-labels
    #expect(RFC5890.IDNHostname.parse(string: "xn--.example") == nil, "Should reject empty A-label")
    #expect(RFC5890.IDNHostname.parse(string: "xn---.example") == nil, "Should reject A-label with only hyphen")
    #expect(RFC5890.IDNHostname.parse(string: "xn--a-.example") == nil, "Should reject A-label ending with hyphen")
    #expect(RFC5890.IDNHostname.parse(string: "xn--a--b.example") == nil, "Should reject A-label with consecutive hyphens")
  }
}
