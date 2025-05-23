package io.github.solidswift.tempo

import io.github.solidswift.TestGenerator
import java.math.BigInteger
import java.time.Instant
import java.time.ZoneId
import java.time.format.DateTimeFormatter
import java.time.zone.ZoneOffsetTransition
import java.time.zone.ZoneRules
import java.time.zone.ZoneRulesProvider
import java.util.*


abstract class TempoTestGenerator : TestGenerator() {

  override val testPkgName: String = "Tempo"

  private val zoneIds =
    listOf(
      "Pacific/Midway",
      "Pacific/Apia",
      "Pacific/Honolulu",
      "America/St_Johns",
      "America/Los_Angeles",
      "America/Phoenix",
      "America/New_York",
      "UTC",
      "Europe/London",
      "Europe/Kyiv",
      "Europe/Moscow",
      "Asia/Tehran",
      "Asia/Gaza",
      "Asia/Kathmandu",
      "Australia/Adelaide",
      "Australia/Lord_Howe",
      "Pacific/Chatham",
      "Pacific/Kiritimati",
      "Antarctica/Troll"
    )

  override fun generate() {
    val testCases = generateTestCases()
    output(testCases)
  }

  abstract fun generateTestCasesForZone(zone: ZoneId, rules: ZoneRules): Any?

  open fun generateTestCases(): List<Any> = buildList {
    for (zoneId in zoneIds) {
      val zone = ZoneId.of(zoneId)
      val (rules, version) = loadRules(zone)
      verbose("Generating Zone ${zone.id}\n-- Version $version")
      generateTestCasesForZone(zone, rules)
        ?.let { entries ->
          add(
            mapOf(
              "zone" to zone.id,
              "entries" to entries
            )
          )
        }
    }
  }

  private fun loadRules(zone: ZoneId): Pair<ZoneRules, String> {
    val rulesVersions = ZoneRulesProvider.getVersions(zone.id)
    val (rulesVersion, rules) = rulesVersions.lastEntry()
    return (rules to rulesVersion)
  }

  private val designationFormatter: DateTimeFormatter = DateTimeFormatter.ofPattern("z").withLocale(Locale.ROOT)

  fun designation(instant: Instant, zone: ZoneId): String {
    return designationFormatter.format(instant.atZone(zone))
  }

  fun Instant.toBigEpoch(): BigInteger {
    return BigInteger.valueOf(epochSecond)
      .multiply(BigInteger.valueOf(1_000_000_000L))
      .plus(BigInteger.valueOf(nano.toLong()))
  }

  fun ZoneOffsetTransition.toMap(): Map<String, Any> {
    return mapOf(
      "instant" to instant.toBigEpoch(),
      "localBefore" to dateTimeBefore,
      "localAfter" to dateTimeAfter,
      "offsetBefore" to offsetBefore.totalSeconds,
      "offsetAfter" to offsetAfter.totalSeconds,
      "isGap" to isGap,
      "duration" to duration.toNanos(),
    )
  }

}
