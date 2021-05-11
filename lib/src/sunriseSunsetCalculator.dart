import 'dart:math';

import 'package:solar_calculator/src/celestialBodies/sun.dart';
import 'package:solar_calculator/src/instant.dart';

import 'timespan.dart';
import 'extensions.dart';

class SunriseSunsetCalculator {
  /// Zenith distance of the Sun used as reference.
  ///
  /// It is the angular distance of the Sun from the zenith. It is 90° minus the Sun altitude above the horizon.
  ///
  /// For the special case of sunrise and sunset, the zenith is set to 90.833 degrees (the approximate correction for
  /// atmospheric refraction at sunrise and sunset, and the size of the solar disk).
  final double sunZenithDistance;

  final Instant instant;

  final double latitude;
  final double longitude;

  SunriseSunsetCalculator(this.instant, this.latitude, this.longitude,
      {this.sunZenithDistance = 90.833});

  double _calculateSunriseMinutes(Instant instant) {
    final sun = Sun(instant);

    final hourAngle = _calculateSolarHourAngleForSunriseSunset(
        sun.equatorialPosition.declination);

    // 1 degree of longitude = 4 minutes
    // 720 = noon time in minutes
    return 720 - 4 * (longitude + hourAngle) - sun.equationOfTime;
  }

  double _calculateSunsetMinutes(Instant instant) {
    final sun = Sun(instant);

    final hourAngle = _calculateSolarHourAngleForSunriseSunset(
        sun.equatorialPosition.declination);

    // 1 degree of longitude = 4 minutes
    // 720 = noon time in minutes
    return 720 - 4 * (longitude - hourAngle) - sun.equationOfTime;
  }

  Instant calculateSunTransitTime() {
    final beginingOfDay = instant.beginingOfDay();

    var tNoon = (beginingOfDay - Timespan.fromDays(longitude / 360));
    final solarNoonOffset =
        720 - (longitude * 4) - Sun(tNoon).equationOfTime; // in minutes

    tNoon = (beginingOfDay + Timespan.fromMinutes(solarNoonOffset));
    final solarNoonUtc =
        720 - (longitude * 4) - Sun(tNoon).equationOfTime; // in minutes

    return beginingOfDay +
        Timespan.fromMinutes(
            solarNoonUtc + (instant.timeZoneOffset * Duration.minutesPerHour));
  }

  Instant calculateSunrise() {
    final beginingOfDay = instant.beginingOfDay();

    final sunriseTime = _calculateSunriseMinutes(beginingOfDay);
    final newSunriseTime = sunriseTime.isNaN
        ? double.nan
        : _calculateSunriseMinutes(
            beginingOfDay + Timespan.fromMinutes(sunriseTime));

    if (newSunriseTime.isNaN) {
      // No sunrise found
      final dayOfYear = instant.dayOfYear;

      if ((latitude > 66.4 && dayOfYear > 79 && dayOfYear < 267) ||
          (latitude < -66.4 && (dayOfYear < 83 || dayOfYear > 263))) {
        //previous sunrise/next sunset
        return _calculatePreviousSunrise();
      }

      //previous sunset/next sunrise
      return _calculateNextSunrise();
    }

    return beginingOfDay +
        Timespan.fromMinutes(newSunriseTime +
            (instant.timeZoneOffset * Duration.minutesPerHour));
  }

  Instant calculateSunset() {
    final beginingOfDay = instant.beginingOfDay();

    final sunsetTime = _calculateSunsetMinutes(beginingOfDay);
    final newSunsetTime = sunsetTime.isNaN
        ? double.nan
        : _calculateSunsetMinutes(
            beginingOfDay + Timespan.fromMinutes(sunsetTime));

    if (newSunsetTime.isNaN) {
      // No sunset found
      final dayOfYear =
          instant.dayOfYear; //julianDate.gregorianDateTime.dayOfYear;

      if ((latitude > 66.4 && dayOfYear > 79 && dayOfYear < 267) ||
          (latitude < -66.4 && (dayOfYear < 83 || dayOfYear > 263))) {
        //previous sunrise/next sunset
        return _calculateNextSunset();
      }

      //previous sunset/next sunrise
      return _calculatePreviousSunset();
    }

    return beginingOfDay +
        Timespan.fromMinutes(
            newSunsetTime + (instant.timeZoneOffset * Duration.minutesPerHour));
  }

  Instant _calculateNextSunrise() =>
      _calculateNextPreviousEvent(Duration(days: 1), _calculateSunriseMinutes);

  Instant _calculatePreviousSunrise() =>
      _calculateNextPreviousEvent(Duration(days: -1), _calculateSunriseMinutes);

  Instant _calculateNextSunset() =>
      _calculateNextPreviousEvent(Duration(days: 1), _calculateSunsetMinutes);

  Instant _calculatePreviousSunset() =>
      _calculateNextPreviousEvent(Duration(days: -1), _calculateSunsetMinutes);

  Instant _calculateNextPreviousEvent(
      Duration duration, double Function(Instant instant) getEvent) {
    var beginingOfDay = instant.beginingOfDay();
    var time = double.nan;

    while (time.isNaN) {
      beginingOfDay = beginingOfDay + duration;
      time = getEvent(beginingOfDay);
    }

    return beginingOfDay +
        Timespan.fromMinutes(
            time + (instant.timeZoneOffset * Duration.minutesPerHour));
  }

  /// Gets the solar hour angle in degrees for sunset and sunrise calculation, corrected for atmospheric refraction,
  /// for the given [sunDeclination].
  ///
  /// Observing the sun from earth, the solar hour angle is an expression of time, expressed in angular measurement, usually degrees,
  /// from solar noon. At solar noon the hour angle is 0.000 degree, with the time before solar noon expressed as negative degrees, and
  /// the local time after solar noon expressed as positive degrees. For example, at 10:30 AM local apparent time
  /// the hour angle is −22.5° (15° per hour times 1.5 hours before noon).
  ///
  /// The cosine of the hour angle (cos(h)) is used to calculate the solar zenith angle. At solar noon, h = 0.000 so cos(h)=1,
  /// and before and after solar noon the cos(± h) term = the same value for morning (negative hour angle) or afternoon (positive hour angle),
  /// i.e. the sun is at the same altitude in the sky at 11:00AM and 1:00PM solar time, etc.
  double _calculateSolarHourAngleForSunriseSunset(double sunDeclination) =>
      acos((cos(sunZenithDistance.toRadians()) /
                  (cos(latitude.toRadians()) *
                      cos(sunDeclination.toRadians()))) -
              (tan(latitude.toRadians()) * tan(sunDeclination.toRadians())))
          .toDegrees();
}
