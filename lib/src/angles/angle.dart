import '../extensions.dart';

/// Represents an angular measurement.
///
/// This class offers an easy way to create an angle from various form:
/// - from degrees;
/// - from radians;
/// - from degrees in the sexagesimal form (degrees, minutes, seconds);
class Angle {
  /// The angle value in degrees.
  late final double degrees;

  /// The angle value in radians.
  late final double radians;

  /// Creates an [Angle] from its sexagesimal form ([degrees], [minutes], [seconds]).
  ///
  /// In case of a negative angle, only the [degrees] value should be negative. If the [minutes] and/or [seconds] are negative,
  /// these will be converted into positive values to avoid confusion.
  ///
  /// So, an angle of ```-12° 32' 44"``` should be entered as:
  /// ```dart
  /// Angle(degrees: -12, minutes: 32, seconds: 44);
  /// ```
  Angle({double degrees = 0, double minutes = 0, double seconds = 0}) {
    final sign = (degrees.isNegative ? -1 : 1);

    this.degrees = (degrees + (minutes / 60) + (seconds / 3600)) * sign;
    radians = this.degrees.toRadians();
  }

  /// Creates an [Angle] from itsvalue given in [degrees].
  Angle.fromDegrees(this.degrees) : radians = degrees.toRadians();

  /// Creates an [Angle] from its value in [radians].
  Angle.fromRadians(this.radians) : degrees = radians.toDegrees();
}
