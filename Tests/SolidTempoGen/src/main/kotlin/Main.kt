package io.solidfoundation

import com.fasterxml.jackson.databind.ObjectMapper
import com.fasterxml.jackson.databind.SerializationFeature
import com.github.ajalt.clikt.core.CliktCommand
import com.github.ajalt.clikt.core.Context
import com.github.ajalt.clikt.core.main
import com.github.ajalt.clikt.core.subcommands
import com.github.ajalt.clikt.parameters.arguments.argument
import com.github.ajalt.clikt.parameters.arguments.multiple
import com.github.ajalt.clikt.parameters.types.int
import java.math.BigInteger
import java.time.*
import java.time.format.DateTimeFormatter
import java.time.temporal.TemporalAmount
import java.time.zone.ZoneOffsetTransition
import java.time.zone.ZoneRules
import java.time.zone.ZoneRulesProvider
import java.util.*

val defaultZoneIds = listOf(
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

class TempoTesting : CliktCommand("tempo-testing") {
  override fun run() = Unit
}

val designationFormatter: DateTimeFormatter = DateTimeFormatter.ofPattern("z").withLocale(Locale.ROOT)

fun CliktCommand.loadRules(zone: ZoneId): ZoneRules {
  val rulesVersions = ZoneRulesProvider.getVersions(zone.id)
  val (rulesVersion, rules) = rulesVersions.lastEntry()
  echo("Zone ${zone.id} (version: $rulesVersion)", trailingNewline = false, err = true)
  return rules
}

class ProjectedZoneRuleDetails : CliktCommand(name = "projected") {

  override fun help(context: Context) = "Output zone details using projected rules"

  private val zones by argument(
    help = "Name of the zone",
  ).multiple(default = defaultZoneIds)

  private val year by argument(
    help = "Year to project",
  ).int()

  override fun run() {
    val out = zones.mapNotNull { zoneId ->
      val zone = ZoneId.of(zoneId)
      val rules = loadRules(zone)
      if (rules.transitionRules.isEmpty()) {
        echo(" has no projection rules, skipping", err = true)
        return@mapNotNull null
      }
      echo(" has ${rules.transitionRules.size} projection rules", err = true)
      val startOfYear = LocalDateTime.of(year, 1, 1, 0, 0, 0)
      val endOfYear = LocalDateTime.of(year, 12, 31, 0, 0, 0)
      val firstTransition = rules.nextTransition(startOfYear.atZone(zone).toInstant())
      val secondTransition = rules.nextTransition(firstTransition.instant.plusSeconds(60 * 60 * 12))
      val locals = listOf(
        startOfYear,
        firstTransition.dateTimeBefore.minusNanos(1),
        firstTransition.dateTimeBefore,
        firstTransition.dateTimeBefore.plus(firstTransition.duration),
        secondTransition.dateTimeBefore.minusNanos(1),
        secondTransition.dateTimeBefore,
        secondTransition.dateTimeBefore.plus(secondTransition.duration),
        endOfYear,
      )
      mapOf(
        "zone" to zone.id,
        "entries" to locals.map { local ->
          val instant = local.atZone(zone).toInstant()
          mapOf(
            "local" to local,
            "instant" to instant.toBigEpoch(),
            "localOffset" to rules.getOffset(local).totalSeconds,
            "instantOffset" to rules.getOffset(instant).totalSeconds,
            "localValidOffsets" to rules.getValidOffsets(local).map { it.totalSeconds },
            "localApplicableTransition" to rules.getTransition(local)?.toMap(),
            "instantNextTransition" to rules.nextTransition(instant)?.toMap(),
            "instantPriorTransition" to rules.previousTransition(instant)?.toMap(),
            "instantDstDuration" to rules.getDaylightSavings(instant).toNanos(),
            "designation" to designationFormatter.format(instant.atZone(zone))
          )
        }
      )
    }
    val mapper = ObjectMapper().findAndRegisterModules()
    mapper.configure(SerializationFeature.INDENT_OUTPUT, true)
    mapper.writeValue(System.out, out)
  }
}

class RegionZoneRulesDetails : CliktCommand(name = "region") {

  override fun help(context: Context) = "Output zone details using rules"

  private val zones by argument(
    help = "Name of the zone",
  ).multiple(default = defaultZoneIds)

  override fun run() {
    val out = zones.mapNotNull { zoneId ->
      val zone = ZoneId.of(zoneId)
      val rules = loadRules(zone)
      if (rules.transitions.isEmpty()) {
        echo(" has no transitions, skipping", err = true)
        return@mapNotNull null
      }
      echo(" has ${rules.transitions.size} transitions", err = true)
      val firstTransition = rules.transitions.first()
      val midTransition = rules.transitions.elementAt(rules.transitions.size / 2)
      val lastTransition = rules.transitions.last()
      val recentStart = LocalDateTime.of(2024, 1, 1, 0, 0, 0)
      val recentEnd = LocalDateTime.of(2024, 12, 31, 0, 0, 0)

      fun instantLocalPair(
        instant: Instant,
        local: LocalDateTime,
        plus: TemporalAmount? = null
      ): Pair<Instant, LocalDateTime> {
        if (plus != null) {
          return instant.atZone(zone).plus(plus).toInstant() to local.atZone(zone).plus(plus).toLocalDateTime()
        }
        return instant to local
      }

      fun instantLocalPair(local: LocalDateTime, plus: TemporalAmount? = null): Pair<Instant, LocalDateTime> {
        if (plus != null) {
          val zoned = local.atZone(zone).plus(plus)
          return zoned.toInstant() to zoned.toLocalDateTime()
        }
        return local.atZone(zone).toInstant() to local
      }

      fun transitionInstants(transition: ZoneOffsetTransition): List<Pair<Instant, LocalDateTime>> {
        return listOf(
          instantLocalPair(transition.instant, transition.dateTimeBefore, Period.ofYears(-1)),
          instantLocalPair(transition.instant, transition.dateTimeBefore, Duration.ofNanos(-1)),
          instantLocalPair(transition.instant, transition.dateTimeBefore),
          instantLocalPair(transition.instant, transition.dateTimeAfter, Duration.ofNanos(-1)),
          instantLocalPair(transition.instant, transition.dateTimeAfter),
          instantLocalPair(transition.instant, transition.dateTimeAfter, Period.ofYears(1)),
        )
      }

      val pairs =
        transitionInstants(firstTransition) +
          transitionInstants(midTransition) +
          transitionInstants(lastTransition) +
          listOf(
            instantLocalPair(recentStart, Duration.ZERO),
            instantLocalPair(recentStart, Duration.ofDays(90)),
            instantLocalPair(recentStart, Duration.ofDays(180)),
            instantLocalPair(recentEnd, Duration.ofDays(-180)),
            instantLocalPair(recentEnd, Duration.ofDays(-90)),
            instantLocalPair(recentEnd, Duration.ZERO),
          )

      mapOf(
        "zone" to zone.id,
        "entries" to pairs.map { (instant, local) ->
          mapOf(
            "instant" to instant.toBigEpoch(),
            "local" to local,
            "instantStandardOffset" to rules.getStandardOffset(instant).totalSeconds,
            "instantDstDuration" to rules.getDaylightSavings(instant).toNanos(),
            "instantDstFlag" to rules.isDaylightSavings(instant),
            "instantOffset" to rules.getOffset(instant).totalSeconds,
            "localOffset" to rules.getOffset(local).totalSeconds,
            "localValidOffsets" to rules.getValidOffsets(local).map { it.totalSeconds },
            "localApplicableTransition" to rules.getTransition(local)?.toMap(),
            "instantNextTransition" to rules.nextTransition(instant)?.toMap(),
            "instantPriorTransition" to rules.previousTransition(instant)?.toMap(),
            "designation" to designationFormatter.format(instant.atZone(zone))
          )
        }
      )
    }
    val mapper = ObjectMapper().findAndRegisterModules()
    mapper.configure(SerializationFeature.INDENT_OUTPUT, true)
    mapper.writeValue(System.out, out)
  }
}

fun main(args: Array<String>) =
  TempoTesting()
    .subcommands(ProjectedZoneRuleDetails())
    .subcommands(RegionZoneRulesDetails())
    .main(args)

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
