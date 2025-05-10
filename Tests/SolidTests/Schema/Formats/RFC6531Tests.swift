//
//  RFC6531Tests.swift
//  SolidFoundation
//
//  Created by Kevin Wooten on 5/12/25.
//

import Testing
import Solid

@Suite("RFC6531 Internationalized Mailbox/Address Tests")
final class RFC6531InternationalizedMailboxAddressTests {

  @Test(
    "Valid ASCII email addresses",
    arguments: [
      ("user", "example.com", "Basic ASCII email"),
      ("user.name", "example.com", "ASCII email with dot"),
      ("user+tag", "example.com", "ASCII email with plus tag"),
      ("user!name", "example.com", "ASCII email with exclamation"),
      ("user#name", "example.com", "ASCII email with hash"),
      ("user$name", "example.com", "ASCII email with dollar"),
      ("user%name", "example.com", "ASCII email with percent"),
      ("user&name", "example.com", "ASCII email with ampersand"),
      ("user'name", "example.com", "ASCII email with apostrophe"),
      ("user*name", "example.com", "ASCII email with asterisk"),
      ("user+name", "example.com", "ASCII email with plus"),
      ("user/name", "example.com", "ASCII email with slash"),
      ("user=name", "example.com", "ASCII email with equals"),
      ("user?name", "example.com", "ASCII email with question mark"),
      ("user^name", "example.com", "ASCII email with caret"),
      ("user_name", "example.com", "ASCII email with underscore"),
      ("user`name", "example.com", "ASCII email with backtick"),
      ("user{name", "example.com", "ASCII email with opening brace"),
      ("user|name", "example.com", "ASCII email with pipe"),
      ("user}name", "example.com", "ASCII email with closing brace"),
      ("user~name", "example.com", "ASCII email with tilde"),
      ("user-name", "example.com", "ASCII email with hyphen"),
      ("\"user name\"", "example.com", "ASCII email with quoted spaces"),
      ("\"user@name\"", "example.com", "ASCII email with quoted at symbol"),
      ("user", "[127.0.0.1]", "ASCII email with IP address domain"),
    ]
  )
  func validAsciiEmails(local: String, domain: String, description: String) throws {
    let email = "\(local)@\(domain)"
    let mailbox = try #require(RFC6531.Mailbox.parse(string: email))
    #expect(
      mailbox.local == local,
      "Local part mismatch for \(description): expected '\(local)', got '\(mailbox.local)'"
    )
    #expect(
      mailbox.domain == domain,
      "Domain mismatch for \(description): expected '\(domain)', got '\(mailbox.domain)'"
    )
  }

  @Test(
    "Valid internationalized email addresses",
    arguments: [
      ("用户", "例子.测试", "Chinese email"),
      ("사용자", "예시.테스트", "Korean email"),
      ("ユーザー", "例.テスト", "Japanese email"),
      ("пользователь", "пример.тест", "Russian email"),
      ("χρήστης", "παράδειγμα.δοκιμή", "Greek email"),
      ("مستخدم", "مثال.اختبار", "Arabic email"),
      ("उपयोगकर्ता", "उदाहरण.परीक्षण", "Hindi email"),
      ("user", "xn--fsq.jp", "IDN domain email"),
      ("\"user name with spaces\"", "example.com", "Quoted local part with spaces"),
      ("\"user@name with at\"", "example.com", "Quoted local part with at symbol"),
    ]
  )
  func validInternationalizedEmails(local: String, domain: String, description: String) throws {
    let email = "\(local)@\(domain)"
    let mailbox = try #require(RFC6531.Mailbox.parse(string: email))
    #expect(
      mailbox.local == local,
      "Local part mismatch for \(description): expected '\(local)', got '\(mailbox.local)'"
    )
    #expect(
      mailbox.domain == domain,
      "Domain mismatch for \(description): expected '\(domain)', got '\(mailbox.domain)'"
    )
  }

  @Test(
    "Invalid email addresses",
    arguments: [
      ("", "Empty string"),
      ("@example.com", "Missing local part"),
      ("user@", "Missing domain"),
      ("user@example", "Invalid domain"),
      ("user@example..com", "Double dot in domain"),
      ("user@.example.com", "Leading dot in domain"),
      ("user@example.com.", "Trailing dot in domain"),
      ("user@-example.com", "Leading hyphen in domain"),
      ("user@example-.com", "Trailing hyphen in domain"),
      ("user name@example.com", "Space in local part without quotes"),
      ("user@name@example.com", "Multiple @ symbols"),
      ("user@example.com@", "Multiple @ symbols"),
      ("user@example.com..", "Multiple trailing dots"),
      ("user@example.com-", "Trailing hyphen"),
      ("user@example.com--", "Multiple trailing hyphens"),
    ]
  )
  func invalidEmails(email: String, description: String) throws {
    #expect(RFC6531.Mailbox.parse(string: email) == nil, "Incorrectly parsed invalid email: \(email) - \(description)")
  }

  @Test(
    "Email address components",
    arguments: [
      ("user", "example.com", "Basic email components"),
      ("user.name", "example.com", "Email with dot in local part"),
      ("user+tag", "example.com", "Email with plus tag"),
      ("用户", "例子.测试", "Internationalized email components"),
      ("사용자", "예시.테스트", "Korean email components"),
      ("\"user name\"", "example.com", "Quoted local part components"),
      ("\"user@name\"", "example.com", "Quoted local part with at symbol"),
      ("user", "[127.0.0.1]", "IP address domain components"),
    ]
  )
  func emailComponents(local: String, domain: String, description: String) throws {
    let email = "\(local)@\(domain)"
    let mailbox = try #require(RFC6531.Mailbox.parse(string: email))
    #expect(
      mailbox.local == local,
      "Local part mismatch for \(description): expected '\(local)', got '\(mailbox.local)'"
    )
    #expect(
      mailbox.domain == domain,
      "Domain mismatch for \(description): expected '\(domain)', got '\(mailbox.domain)'"
    )
  }
}
