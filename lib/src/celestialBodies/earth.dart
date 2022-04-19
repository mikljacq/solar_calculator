import 'dart:math';

import 'package:solar_calculator/src/angles/angle.dart';
import 'package:solar_calculator/src/instant.dart';
import 'package:solar_calculator/src/math.dart';
import 'package:solar_calculator/src/extensions.dart';

class Earth {
  static final Map<double, Earth> _cache = <double, Earth>{};

  final Instant instant;

  double? _meanObliquityOfEcliptic;
  double? _correctedObliquityOfEcliptic;
  double? _earthOrbitalEccentricity;

  factory Earth(Instant instant) => _cache.putIfAbsent(instant.julianDay, () => Earth._internal(instant));

  Earth._internal(this.instant);

  /// The axis tilt (obliquity) of the Earth in degrees as it was at the epoch J2000.0.
  static final _earthAxisTiltJ2000 = Angle(degrees: 23, minutes: 26, seconds: 21.448).degrees;

  /// The decreasing rate of the axis tilt of the Earth per 100 years, in degrees.
  ///
  /// The axis tilt (obliquity) of the Earth is currently decreasing 0.013 degrees (47 arcseconds) per hundred years
  /// because of planetary perturbations.
  static final _earthAxisTiltDecreasingRate = Angle(seconds: 46.8093).degrees;

  /// The mean obliquity of the ecliptic in degrees, that is the obliquity free from short-term variations.
  ///
  /// The ecliptic is the plane of Earth's orbit around the Sun. It is the apparent path of the Sun throughout the course of a year.
  ///
  /// The obliquity is an effect caused by the tilt of the Earth on its axis with respect to the celestial equator.
  /// In other words, it is the angle between the plane of the Earth’s equator and the plane across which the Sun and planets
  /// appear to travel.
  double get meanObliquityOfEcliptic => _meanObliquityOfEcliptic ??= evaluatePolynomial(instant.julianCenturies / 100, [
        _earthAxisTiltJ2000,
        -(_earthAxisTiltDecreasingRate * 100),
        -1.55,
        1999.25,
        -51.38,
        -249.67,
        -39.05,
        7.12,
        27.87,
        5.79,
        2.45
      ]);
  // double get meanObliquityOfEcliptic {
  //   var t = instant.julianCenturies;
  //   var seconds = 21.448 - t * (46.8150 + t * (0.00059 - t * (0.001813)));
  //   var e0 = 23.0 + (26.0 + (seconds / 60.0)) / 60.0;
  //   return e0;
  // }

  /// The mean obliquity of the ecliptic in degrees, corrected for nutation and aberration.
  double get correctedObliquityOfEcliptic => _correctedObliquityOfEcliptic ??=
      meanObliquityOfEcliptic + (0.00256 * cos(nutationAndAberrationCorrection.toRadians()));

  /// The eccentricity of the Earth orbit (unitless).
  ///
  /// The eccentricity refers to the "flatness" of the ellipse swept out by the Earth in its orbit around the Sun.
  double get orbitalEccentricity => _earthOrbitalEccentricity ??=
      evaluatePolynomial(instant.julianCenturies, [0.016708634, -0.000042037, -0.0000001267]);

  /// The correction factor for nutation and aberration.
  ///
  /// In astronomy, aberration is a phenomenon which produces an apparent motion of celestial objects about their true positions,
  /// dependent on the velocity of the observer. It causes objects to appear to be displaced towards the direction of motion
  /// of the observer compared to when the observer is stationary.
  ///
  /// Astronomical nutation is a phenomenon which causes the orientation of the axis of rotation of a spinning astronomical
  /// object to vary over time. It is caused by the gravitational forces of other nearby bodies acting upon the spinning object.
  double get nutationAndAberrationCorrection => 125.04 - (1934.136 * instant.julianCenturies);
}
