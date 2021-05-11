import 'dart:math';

import 'package:solar_calculator/solar_calculator.dart';
import 'package:solar_calculator/src/celestialBodies/earth.dart';
import 'package:solar_calculator/src/coordinateSystems/horizontalCoordinate.dart';
import 'package:solar_calculator/src/instant.dart';
import 'package:solar_calculator/src/math.dart';
import 'package:solar_calculator/src/extensions.dart';

class Sun {
  // Cache
  static final Map<double, Sun> _cache = <double, Sun>{};

  final Instant instant;

  double? _meanLongitude;
  double? _meanAnomaly;
  double? _uncorrectedMeanAnomaly;
  double? _equationOfCenter;
  double? _trueLongitude;
  double? _trueAnomaly;
  double? _radiusVector;
  double? _apparentLongitude;
  double? _equationOfTime;

  EquatorialCoordinate? _equatorialPosition;

  factory Sun(Instant instant) =>
      _cache.putIfAbsent(instant.julianDay, () => Sun._internal(instant));

  Sun._internal(this.instant);

  /// The equation of time in minutes.
  ///
  /// Due to the eccentricity of its orbit, and to a less degree due to the perturbations by the Moon and the planets, the Earth's
  /// heliocentric longitude does not vary uniformly. It follows that the Sun appears to describe the ecliptic at a non uniform rate.
  /// Due to this, and also to the fact that the Sun is moving in the ecliptic and not along the celestial equator, its right
  /// ascension does not increase uniformly.
  ///
  /// When the mean Sun crosses the observer's meridian, it is mean noon there. True noon is the instant when the true Sun crosses
  /// the meridian. The equation of time is the difference between apparent et mean time. In other words, it is the difference between the
  /// hour angles of the true Sun et the mean Sun.
  ///
  /// Equation of time is an astronomical term accounting for changes in the time of solar noon for a given location over the course of a year.
  /// Earth's elliptical orbit and Kepler's law of equal areas in equal times are the culprits behind this phenomenon.
  double get equationOfTime {
    if (_equationOfTime == null) {
      final earth = Earth(instant);

      final epsilonRadians = earth.correctedObliquityOfEcliptic.toRadians();
      final l0Radians = meanLongitude.toRadians();
      final e = earth.orbitalEccentricity;
      final mRadians = uncorrectedMeanAnomaly.toRadians();

      final y = pow(tan(epsilonRadians / 2), 2);

      final eTime = (y * sin(2.0 * l0Radians)) -
          (2.0 * e * sin(mRadians)) +
          (4.0 * e * y * sin(mRadians) * cos(2.0 * l0Radians)) -
          (0.5 * y * y * sin(4.0 * l0Radians)) -
          (1.25 * e * e * sin(2.0 * mRadians));

      _equationOfTime = eTime.toDegrees() * 4.0;
    }

    return _equationOfTime!;
  }

  /// The mean longitude of the Sun in degrees.
  ///
  /// The mean longitude is the ecliptic longitude at which an orbiting body could be found if its orbit were circular and
  /// free of perturbations.
  double get meanLongitude => _meanLongitude ??= evaluatePolynomial(
          instant.julianCenturies, [280.46646, 36000.76983, 0.0003032])
      .correctDegreesForLargeAngles();

  /// The geometric mean anomaly of the Sun in degrees.
  ///
  /// Anomaly here refers to the non-uniform apparent motion of the Sun and planets along the plane of the ecliptic.
  /// It is defined as the angular distance from perihelion which the Earth would have if it moved around the Sun with
  /// a constant angular velocity.
  ///
  /// Note that the word "apparent" is always used to denote that the Sun, planets, and stars appear to move across the
  /// sky in a 24-hour period. Obviously, the true movement is the rotation of the Earth on its axis but it is convenient
  /// to talk of the apparent motion of the Sun and planets across the sky.
  double get meanAnomaly =>
      _meanAnomaly ??= uncorrectedMeanAnomaly.correctDegreesForLargeAngles();

  /// The geometric mean anomaly of the Sun in degrees, uncorrected for large angles.
  ///
  /// See [meanAnomaly].
  double get uncorrectedMeanAnomaly =>
      _uncorrectedMeanAnomaly ??= evaluatePolynomial(
          instant.julianCenturies, [357.52911, 35999.05029, -0.0001537]);

  /// The Sun's equation of center, in degrees.
  ///
  /// In two-body, Keplerian orbital mechanics, the equation of the center is the angular difference between
  /// the actual position of a body in its elliptical orbit and the position it would occupy if its motion were uniform,
  /// in a circular orbit of the same period.
  ///
  /// It is defined as the difference of true anomaly minus mean anomaly, and is typically expressed as a function of
  /// mean anomaly and orbital eccentricity.
  ///
  /// https://en.wikipedia.org/wiki/Equation_of_the_center
  double get equationOfCenter {
    if (_equationOfCenter == null) {
      final mRadians = meanAnomaly.toRadians();

      final julianCenturies = instant.julianCenturies;

      _equationOfCenter = (sin(mRadians) *
              (1.914602 -
                  julianCenturies * (0.004817 + 0.000014 * julianCenturies))) +
          (sin(mRadians * 2.0) * (0.019993 - 0.000101 * julianCenturies)) +
          (sin(mRadians * 3.0) * 0.000289);
    }

    return _equationOfCenter!;
  }

  /// The true longitude of the Sun in degrees.
  ///
  /// In celestial mechanics, true longitude is the ecliptic longitude at which an orbiting body could actually be found if
  /// its inclination were zero. Together with the inclination and the ascending node, the true longitude can tell us
  /// the precise direction from the central object at which the body would be located at a particular time.
  double get trueLongitude => _trueLongitude ??=
      (meanLongitude + equationOfCenter).correctDegreesForLargeAngles();

  /// The true anomaly of the Sun in degrees.
  ///
  /// In celestial mechanics, true anomaly is an angular parameter that defines the position of a body moving along a
  /// Keplerian orbit. It is the angle between the direction of periapsis and the current position of the body, as seen
  /// from the main focus of the ellipse (the point around which the object orbits)
  double get trueAnomaly => _trueAnomaly ??=
      (meanAnomaly + equationOfCenter).correctDegreesForLargeAngles();

  /// The radius vector in Astronomical Units.
  ///
  /// It is the distance between the center of the Sun and the center of the Earth.
  double get radiusVector {
    // var v = sunTrueAnomaly;
    // var e = earthOrbitalEccentricity;

    // var r = (1.000001018 * (1 - pow(e, 2))) / (1 + e * cos(_k * v));

    if (_radiusVector == null) {
      // U.S. Naval Observatory function for radius vector
      final mRadians = meanAnomaly.toRadians();
      _radiusVector =
          1.00014 - (0.01671 * cos(mRadians)) - (0.00014 * cos(2 * mRadians));
    }

    return _radiusVector!;
  }

  /// The apparent longitude of the Sun in degrees.
  ///
  /// Apparent longitude is the celestial longitude corrected for aberration and nutation as opposed to mean longitude.
  double get apparentLongitude => _apparentLongitude ??= trueLongitude -
      0.00569 -
      (0.00478 *
          sin(Earth(instant).nutationAndAberrationCorrection.toRadians()));

  /// The Apparent position of the Sun in the Equatorial Coordinate System.
  ///
  /// Its declination angle varies from -23.44° at the (northern hemisphere) winter solstice, through 0° at the vernal equinox,
  /// to +23.44° at the summer solstice.
  /// The variation in solar declination is the astronomical description of the sun going south (in the northern hemisphere)
  /// for the winter.
  EquatorialCoordinate get equatorialPosition {
    if (_equatorialPosition == null) {
      final earth = Earth(instant);

      final rightAscension = atan2(
        cos(earth.correctedObliquityOfEcliptic.toRadians()) *
            sin(apparentLongitude.toRadians()),
        cos(apparentLongitude.toRadians()),
      );

      final declination = asin(
          sin(earth.correctedObliquityOfEcliptic.toRadians()) *
              sin(apparentLongitude.toRadians()));

      _equatorialPosition = EquatorialCoordinate(
          HourAngle.fromRadians(rightAscension), declination.toDegrees());
    }

    return _equatorialPosition!;
  }

  /// Gets the apparent position of the Sun in the Horizontal Coordinate System.
  HorizontalCoordinate horizontalPosition(double latitude, double longitude) {
    final hourAngle = _calculateLocalHourAngle(longitude);
    final hourAngleRadians = hourAngle.toRadians();

    final latitudeRadians = latitude.toRadians();

    final sunDeclinationRadians = equatorialPosition.declination.toRadians();

    final zenithRadians = _calculateSolarZenithAngle(
        latitudeRadians, sunDeclinationRadians, hourAngleRadians);
    final zenith = zenithRadians.toDegrees();

    final azimuth = _calculateAzimuth(
        latitudeRadians, zenithRadians, sunDeclinationRadians, hourAngle);
    final elevation = _calculateElevation(zenith);

    return HorizontalCoordinate(azimuth, elevation);
  }

  /// Calculates the solar zenith angle in radians.
  ///
  /// The [latitude], [declination] and [hourAngle] must be in radians.
  double _calculateSolarZenithAngle(
      double latitude, double declination, double hourAngle) {
    final cosinusSolarZenith = (sin(latitude) * sin(declination)) +
        (cos(latitude) * cos(declination) * cos(hourAngle));

    if (cosinusSolarZenith > 1.0) return acos(1.0);
    if (cosinusSolarZenith < -1.0) return acos(-1.0);

    return acos(cosinusSolarZenith);
  }

  /// Calculates the Sun local hour angle in degrees for the given [longitude].
  ///
  /// The local hour angle is calculated from the local meridian.
  ///
  /// The [longitude] is given in degrees.
  double _calculateLocalHourAngle(double longitude) {
    final timeOffset = equationOfTime +
        (4.0 * longitude) -
        (Duration.minutesPerHour * instant.timeZoneOffset);

    // final utcDateTime = instant.toUtc();
    // final time = utcDateTime.time;

    // var trueSolarTime = time.totalMinutes + timeOffset;
    var trueSolarTime = instant.time.totalMinutes + timeOffset;

    while (trueSolarTime > Duration.minutesPerDay) {
      trueSolarTime -= Duration.minutesPerDay;
    }

    var hourAngle =
        (trueSolarTime / 4.0) - 180.0; // Solar hour angle in degrees
    if (hourAngle < -180) hourAngle += 360.0;

    return hourAngle;
  }

  /// Calculates the elevation of the Sun in degrees.
  ///
  /// [zenithAngle] is given in degrees.
  double _calculateElevation(double zenithAngle) {
    // Atmospheric Refraction correction
    final refractionCorrection =
        _calculateAtmosphericRefractionCorrection(90.0 - zenithAngle);

    final correctedSolarZenith = zenithAngle - refractionCorrection;
    return 90.0 - correctedSolarZenith;
  }

  /// Calculates the azimuth of the Sun in degrees.
  ///
  /// The [latitude], [zenithAngle] and [declination] must be in radians.
  /// The [hourAgngle] must be in degrees.
  double _calculateAzimuth(double latitude, double zenithAngle,
      double declination, double hourAngle) {
    double azimuth;

    final azimuthDenominator = cos(latitude) * sin(zenithAngle);

    if (azimuthDenominator.abs() > 0.001) {
      var azimuthRadians =
          ((sin(latitude) * cos(zenithAngle)) - sin(declination)) /
              azimuthDenominator;

      if (azimuthRadians.abs() > 1.0) {
        azimuthRadians = (azimuthRadians < 0) ? -1.0 : 1.0;
      }

      azimuth = 180.0 - acos(azimuthRadians).toDegrees();

      if (hourAngle > 0.0) azimuth = -azimuth;
    } else {
      azimuth = (latitude > 0.0) ? 180.0 : 0.0;
    }

    if (azimuth < 0.0) azimuth += 360.0;

    return azimuth;
  }

  /// Calculates the approximate Atmospheric Refraction Correction in degrees for the given [elevation].
  ///
  /// As light from the sun (or another celestial body) travels from the vacuum of space into Earth's atmosphere, the path of the light
  /// is bent due to refraction. This causes stars and planets near the horizon to appear higher in the sky than they actually are,
  /// and explains how the sun can still be visible after it has physically passed beyond the horizon at sunset.
  ///
  /// https://www.esrl.noaa.gov/gmd/grad/solcalc/calcdetails.html
  double _calculateAtmosphericRefractionCorrection(double elevation) {
    if (elevation > 85.0) return 0.0;

    final tanElevation = tan(elevation.toRadians());
    double correction;

    if (elevation > 5.0) {
      correction = evaluatePolynomial(
          1 / tanElevation, [0, 58.1, 0, -0.07, 0, 0.000086]);
    } else if (elevation > -0.575) {
      correction =
          evaluatePolynomial(elevation, [1735, -518.2, 103.4, -12.79, 0.711]);
    } else {
      correction = -20.774 / tanElevation;
    }

    return correction / 3600.0;
  }
}
