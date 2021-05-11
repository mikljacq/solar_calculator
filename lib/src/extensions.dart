import 'dart:math';

extension DoubleExtensions on double {
  /// Corrects for very large angles.
  ///
  /// Because astronomical calculations generate very large angles it is necessary to reduce such angles to be between 0 and 360 degrees.
  double correctDegreesForLargeAngles() {
    var value = this % 360;
    if (value < 0) value += 360;
    return value;
  }

  /// Converts this [double] degrees to radians.
  double toRadians() => this * (pi / 180);

  /// Converts this [double] radians to degrees.
  double toDegrees() => this * (180 / pi);
}

extension DurationExtension on Duration {
  /// The total number of days spanned by this [Duration], expressed in whole and fractional days.
  double get totalDays => inMicroseconds / Duration.microsecondsPerDay;

  /// The total number of hours spanned by this [Duration], expressed in whole and fractional hours.
  double get totalHours => inMicroseconds / Duration.microsecondsPerHour;

  /// The total number of minutes spanned by this [Duration], expressed in whole and fractional minutes.
  double get totalMinutes => inMicroseconds / Duration.microsecondsPerMinute;

  /// The total number of seconds spanned by this [Duration], expressed in whole and fractional seconds.
  double get totalSeconds => inMicroseconds / Duration.microsecondsPerSecond;

  /// The total number of milliseconds spanned by this [Duration], expressed in whole and fractional milliseconds.
  double get totalMilliseconds =>
      inMicroseconds / Duration.microsecondsPerMillisecond;
}
