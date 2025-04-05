import Testing
import Codex

@Suite("RFC6531.Mailbox Tests")
final class RFC6531MailboxTests {

  @Test("Valid ASCII email addresses", arguments: [
    ("user", "example.com"),
    ("user.name", "example.com"),
    ("user+tag", "example.com"),
    ("user!name", "example.com"),
    ("user#name", "example.com"),
    ("user$name", "example.com"),
    ("user%name", "example.com"),
    ("user&name", "example.com"),
    ("user'name", "example.com"),
    ("user*name", "example.com"),
    ("user+name", "example.com"),
    ("user/name", "example.com"),
    ("user=name", "example.com"),
    ("user?name", "example.com"),
    ("user^name", "example.com"),
    ("user_name", "example.com"),
    ("user`name", "example.com"),
    ("user{name", "example.com"),
    ("user|name", "example.com"),
    ("user}name", "example.com"),
    ("user~name", "example.com"),
    ("user-name", "example.com"),
    ("\"user name\"", "example.com"),
    ("\"user@name\"", "example.com"),
    ("user", "[127.0.0.1]")
  ])
  func validAsciiEmails(local: String, domain: String) throws {
    let email = "\(local)@\(domain)"
    let mailbox = try #require(RFC6531.Mailbox.parse(string: email))
    #expect(mailbox.local == local)
    #expect(mailbox.domain == domain)
  }

  @Test("Valid internationalized email addresses", arguments: [
    ("用户", "例子.测试"), // Chinese
    ("사용자", "예시.테스트"), // Korean
    ("ユーザー", "例.テスト"), // Japanese
    ("пользователь", "пример.тест"), // Russian
    ("χρήστης", "παράδειγμα.δοκιμή"), // Greek
    ("مستخدم", "مثال.اختبار"), // Arabic
    ("उपयोगकर्ता", "उदाहरण.परीक्षण"), // Hindi
    ("user", "xn--fsq.jp"), // IDN domain
    ("\"user name with spaces\"", "example.com"),
    ("\"user@name with at\"", "example.com")
  ])
  func validInternationalizedEmails(local: String, domain: String) throws {
    let email = "\(local)@\(domain)"
    let mailbox = try #require(RFC6531.Mailbox.parse(string: email))
    #expect(mailbox.local == local)
    #expect(mailbox.domain == domain)
  }

  @Test("Invalid email addresses", arguments: [
    "", // Empty string
    "@example.com", // Missing local part
    "user@", // Missing domain
    "user@example", // Invalid domain
    "user@example..com", // Double dot in domain
    "user@.example.com", // Leading dot in domain
    "user@example.com.", // Trailing dot in domain
    "user@-example.com", // Leading hyphen in domain
    "user@example-.com", // Trailing hyphen in domain
    "user name@example.com", // Space in local part without quotes
    "user@name@example.com", // Multiple @ symbols
    "user@example.com@", // Multiple @ symbols
    "user@example.com.", // Trailing dot
    "user@example.com..", // Multiple trailing dots
    "user@example.com-", // Trailing hyphen
    "user@example.com--", // Multiple trailing hyphens
    "user@example.com-", // Trailing hyphen
    "user@example.com--", // Multiple trailing hyphens
    "user@example.com-", // Trailing hyphen
    "user@example.com--" // Multiple trailing hyphens
  ])
  func invalidEmails(email: String) throws {
    #expect(RFC6531.Mailbox.parse(string: email) == nil, "Incorrectly parsed invalid email: \(email)")
  }

  @Test("Email address components", arguments: [
    ("user", "example.com"),
    ("user.name", "example.com"),
    ("user+tag", "example.com"),
    ("用户", "例子.测试"),
    ("사용자", "예시.테스트"),
    ("\"user name\"", "example.com"),
    ("\"user@name\"", "example.com"),
    ("user", "[127.0.0.1]")
  ])
  func emailComponents(local: String, domain: String) throws {
    let email = "\(local)@\(domain)"
    let mailbox = try #require(RFC6531.Mailbox.parse(string: email))
    #expect(mailbox.local == local)
    #expect(mailbox.domain == domain)
  }
}
