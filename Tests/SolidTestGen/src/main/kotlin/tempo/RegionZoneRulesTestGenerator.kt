package io.github.solidswift.tempo

import java.time.Duration
import java.time.Instant
import java.time.LocalDateTime
import java.time.Period
import java.time.ZoneId
import java.time.temporal.TemporalAmount
import java.time.zone.ZoneOffsetTransition
import java.time.zone.ZoneRules


class RegionZoneRulesTestGenerator : TempoTestGenerator() {

  override fun generateTestCasesForZone(zone: ZoneId, rules: ZoneRules): List<Map<String, Any?>>? {
    if (rules.transitions.isEmpty()) {
      verbose("-- No transitions, skipping")
      return null
    }
    verbose("-- ${rules.transitions.size} transitions")

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

    return pairs
      .map { (instant, local) ->
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
          "designation" to designation(instant, zone)
        )
      }
  }

}
