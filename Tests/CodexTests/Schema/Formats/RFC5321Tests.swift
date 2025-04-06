import Testing
@testable import Codex

@Suite("RFC5321 Mailbox/Address Tests")
final class RFC5321MailboxAddressTests {

  @Test(
    "Valid Mailbox Parsing",
    arguments: [
      // Simple valid addresses
      "user@example.com",
      "user.name@example.com",
      "user+tag@example.com",
      "user@subdomain.example.com",
      "user@[127.0.0.1]",

      // Quoted strings in local part
      "\"user name\"@example.com",
      "\"user@name\"@example.com",
      "\"user\\\\name\"@example.com",
      "\"user\\\"name\"@example.com",

      // Special characters in local part
      "!#$%&'*+-/=?^_`{|}~@example.com",
      "user.name!#$%&'*+-/=?^_`{|}~@example.com",

      // Domain literals
      "user@[IPv6:2001:db8::1]",
      "user@[IPv6:2001:db8:85a3:8d3:1319:8a2e:370:7348]",

      // Long but valid addresses
      "a".padding(toLength: 64, withPad: "a", startingAt: 0) + "@example.com",
      "user@" + "a".padding(toLength: 63, withPad: "a", startingAt: 0) + "."
        + "b".padding(toLength: 63, withPad: "b", startingAt: 0) + "."
        + "c".padding(toLength: 63, withPad: "c", startingAt: 0) + "."
        + "d".padding(toLength: 59, withPad: "d", startingAt: 0) + ".com",
    ]
  )
  func validMailboxParsing(address: String) {
    #expect(RFC5321.Mailbox.parse(string: address) != nil, "Should parse valid address: \(address)")
  }

  @Test(
    "Invalid Mailbox Parsing",
    arguments: [
      // Missing @
      "userexample.com",
      // Missing local part
      "@example.com",
      // Missing domain
      "user@",
      // Empty string
      "",
      // Multiple @
      "user@name@example.com",
      // Invalid characters in local part
      "user,name@example.com",
      "user;name@example.com",
      "user:name@example.com",
      "user<name@example.com",
      "user>name@example.com",
      // Invalid domain format
      "user@example..com",
      "user@.example.com",
      "user@example.com.",
      // Invalid domain literal
      "user@[invalid]",
      "user@[127.0.0.1",
      "user@127.0.0.1]",
      // Too long local part (>64 chars)
      "a".padding(toLength: 65, withPad: "a", startingAt: 0) + "@example.com",
      // Too long domain (>255 chars)
      "user@" + "a".padding(toLength: 63, withPad: "a", startingAt: 0) + "."
        + "b".padding(toLength: 63, withPad: "b", startingAt: 0) + "."
        + "c".padding(toLength: 63, withPad: "c", startingAt: 0) + "."
        + "d".padding(toLength: 63, withPad: "d", startingAt: 0) + ".bad.com",
      // Invalid quoted string
      "\"user@example.com",
      "user\"@example.com",
      "\"user\\@example.com\"",
      // Invalid escape sequences
      "\"user\\\"@example.com",
      "\"user\\\\\"@example.com",
    ]
  )
  func invalidMailboxParsing(address: String) {
    #expect(RFC5321.Mailbox.parse(string: address) == nil, "Should reject invalid address: \(address)")
  }

  @Test(
    "Mailbox Properties",
    arguments: [
      ("user", "example.com", "user@example.com"),
      ("user.name", "example.com", "user.name@example.com"),
      ("\"user name\"", "example.com", "\"user name\"@example.com"),
      ("user", "[127.0.0.1]", "user@[127.0.0.1]"),
    ]
  )
  func mailboxProperties(local: String, domain: String, expectedString: String) {
    let mailbox = RFC5321.Mailbox(local: local, domain: domain)
    #expect(mailbox.local == local)
    #expect(mailbox.domain == domain)
    #expect("\(mailbox)" == expectedString)
  }

  @Test(
    "Edge Cases",
    arguments: [
      // Empty quoted string
      "\"\"@example.com",
      // Single character
      "a@b.com",
      // Maximum length local part
      "a".padding(toLength: 64, withPad: "a", startingAt: 0) + "@example.com",
      // All special characters
      "!#$%&'*+-/=?^_`{|}~@example.com",
    ]
  )
  func edgeCases(address: String) {
    #expect(RFC5321.Mailbox.parse(string: address) != nil, "Should handle edge case: \(address)")
  }
}
