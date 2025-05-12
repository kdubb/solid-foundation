//
//  main.swift
//  SolidFoundation
//
//  Created by Kevin Wooten on 4/24/25.
//

import SolidNumeric
import ArgumentParser

@main
struct ExcerciseNumerics: ParsableCommand {

  static let configuration = CommandConfiguration(
    abstract: "Excerise Numerics",
    subcommands: [
      ExceriseBigDecimal.self,
      ExceriseBigUInt.self,
      ExceriseBigInt.self,
    ]
  )
}

struct ExceriseBigDecimal: ParsableCommand {

  static let configuration = CommandConfiguration(
    commandName: "excercise-bigdecimal",
    abstract: "Excerise BigDecimal",
    discussion: """
    Excerise BigDecimal

    This command is used to exercise the BigDecimal type. It performs a multiplication,
    division, and remainder operation on `iterations` of random BigDecimal values.
    """,
    aliases: ["ebd"]
  )

  @Argument(help: "The number of iterations to run")
  var iterations: Int = 10_000_000

  @Flag(name: .shortAndLong, help: "Print the duration of the operation")
  var printDuration: Bool = false

  func run() throws {

    let clock = ContinuousClock()
    let start = clock.now

    for _ in 0..<iterations {
      let s = BigDecimal(UInt.random(in: .min ... .max))
      let t = BigDecimal(UInt.random(in: .min ... .max))
      let p = s * t
      let q = p / s
      let r = p.remainder(dividingBy: s)
      blackHole(q)
      blackHole(r)
    }

    let end = clock.now
    let duration = end - start

    if printDuration {
      print("Duration: \(duration)")
    }
  }
}

struct ExceriseBigUInt: ParsableCommand {

  static let configuration = CommandConfiguration(
    commandName: "excercise-biguint",
    abstract: "Excerise BigUInt",
    discussion: """
    Excerise BigUInt

    This command is used to exercise the BigUInt type. It performs a multiplication,
    division/remainder operation on `iterations` of random BigUInt values.
    """,
    aliases: ["ebu"]
  )

  @Argument(help: "The number of iterations to run")
  var iterations: Int = 10_000_000

  @Flag(help: "Print the duration of the operation")
  var printDuration: Bool = false

  func run() throws {

    let clock = ContinuousClock()
    let start = clock.now

    for _ in 0..<iterations {
      let s = BigUInt(UInt.random(in: .min ... .max))
      let t = BigUInt(UInt.random(in: .min ... .max))
      let p = s * t
      let (q, r) = p.quotientAndRemainder(dividingBy: s)
      blackHole(q)
      blackHole(r)
    }

    let end = clock.now
    let duration = end - start

    if printDuration {
      print("Duration: \(duration)")
    }
  }
}

struct ExceriseBigInt: ParsableCommand {

  static let configuration = CommandConfiguration(
    commandName: "excercise-bigint",
    abstract: "Excerise BigInt",
    discussion: """
    Excerise BigInt

    This command is used to exercise the BigInt type. It performs a multiplication,
    division/remainder operation on `iterations` of random BigInt values.
    """,
    aliases: ["ebi"]
  )

  @Argument(help: "The number of iterations to run")
  var iterations: Int = 10_000_000

  @Flag(help: "Print the duration of the operation")
  var printDuration: Bool = false

  func run() throws {

    let clock = ContinuousClock()
    let start = clock.now

    for _ in 0..<iterations {
      let s = BigInt(Int.random(in: .min ... .max))
      let t = BigInt(Int.random(in: .min ... .max))
      let p = s * t
      let (q, r) = p.quotientAndRemainder(dividingBy: s)
      blackHole(q)
      blackHole(r)
    }

    let end = clock.now
    let duration = end - start

    if printDuration {
      print("Duration: \(duration)")
    }
  }
}
