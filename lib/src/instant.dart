import 'package:solar_calculator/src/extensions.dart';
import 'package:solar_calculator/src/timespan.dart';

/// Represents an instant in time which is time zone aware.
///
/// A Instant object is anchored in a time zone which is specified by an offset from UTC.
///
/// Once created, neither the value nor the time zone of a Instant object may be changed.
class Instant {
  late final int year;
  late final int month;
  late final int day;
  late final int hour;
  late final int minute;
  late final int second;

  /// The time zone offset in hours from UTC. It can be positive or negative.
  final double timeZoneOffset;

  double? _julianDay;

  Duration? _sinceEpoch;

  /// Creates a new [Instant]. The [Instant] will be created in the UTC time zone unless a [timeZoneOffset] is specified.
  /// If so, it must be in hours from UTC and it can be positive or negative.
  ///
  /// For example, to create a [Instant] object representing the 12th of March 2021 at 1:15pm in the UTC+02:00 time zone:
  ///
  /// ```
  /// var instant = Instant(year: 2021, month: 03, day: 12, hour: 13, minute: 15, second: 0, timeZoneOffset: 2.0);
  /// ```
  Instant({
    required this.year,
    this.month = 1,
    this.day = 1,
    this.hour = 0,
    this.minute = 0,
    this.second = 0,
    this.timeZoneOffset = 0.0,
  });

  /// Creates a new [Instant] from the given [dateTime]. The [Instant] will be created in the time zone of the [dateTime]
  /// unless a [timeZoneOffset] is specified. If so, it will be created in the time zone corresponding to that offset from UTC.
  ///
  /// Example (local time zone is UTC+02:00):
  /// ```
  /// var instant = Instant.fromDateTime(DateTime(2021, 05, 09, 13, 00), timezoneOffset: 4.0);
  /// print(instant.toIso8601String()); //2021-05-09T17:00:00+04:00
  /// ```
  /// If no [timeZoneOffset] is specified, the [Instant] object is created in the same time zone as the [dateTime] object.
  /// Example:
  /// ```
  /// var instantNow = Instant.fromDateTime(DateTime.now().toUtc());
  /// // The timezone offset of instantNow will be 0.0 hour.
  /// ```
  Instant.fromDateTime(DateTime dateTime, {double? timeZoneOffset})
      : timeZoneOffset = (timeZoneOffset != null) ? timeZoneOffset : dateTime.timeZoneOffset.totalHours {
    final offsetDateTime =
        (timeZoneOffset == null) ? dateTime : dateTime.toUtc().add(Timespan.fromHours(timeZoneOffset));

    year = offsetDateTime.year;
    month = offsetDateTime.month;
    day = offsetDateTime.day;
    hour = offsetDateTime.hour;
    minute = offsetDateTime.minute;
    second = offsetDateTime.second;
  }

  /// The day of year of this [Instant].
  int get dayOfYear {
    final k = (isLeapYear ? 1 : 2);
    return ((275 * month) / 9).floor() - (k * ((month + 9) / 12).floor()) + day - 30;
  }

  /// Returns true if `this` is in a leap year.
  ///
  /// In the Gregorian calendar, three criteria must be taken into account to identify leap years:
  /// - the year must be evenly divisible by 4;
  /// - if the year can also be evenly divided by 100, it is not a leap year;
  /// - unless the year is also evenly divisible by 400. Then it is a leap year.
  bool get isLeapYear => _isLeapYear(year);

  /// The number of Julian centuries of `this` [Instant] since the J2000.0 epoch.
  ///
  /// Since a Julian year counts exactly 365.25 Julian days, a Julian century counts 36,525.0 Julian days.
  ///
  /// The J2000.0 epoch is precisely Julian date 2451545.0 TT (Terrestrial Time), or January 1, 2000, noon TT.
  /// This is equivalent to January 1, 2000, 11:59:27.816 TAI or January 1, 2000, 11:58:55.816 UTC.
  double get julianCenturies => (julianDay - 2451545.0) / 36525.0;

  /// The Julian day of `this` [Instant].
  ///
  /// The Julian day of any instant is the Julian day number plus the fraction of a day since the preceding noon in
  /// Universal Time. Julian dates are expressed as a Julian day number with a decimal fraction added.
  ///
  /// The Julian day number (JDN) is the number assigned to a whole solar day in the Julian day count starting from
  /// 1 Jan -4712 at noon Universal time (January 1, 4713 BC at noon Universal Time) in the proleptic Julian calendar, or
  /// 24 Nov -4713 at noon Universal time (November 24th, 4714 BC) in the proleptic Gregorian calendar.
  double get julianDay => _julianDay ??= _computeJulianDay();

  /// The elapsed time since the "Unix epoch" 1970-01-01T00:00:00Z (UTC).
  ///
  /// The returned value is independent of the time zone.
  Duration get sinceEpoch => _sinceEpoch ??= _computeSinceEpoch();

  /// The time of this [Instant] elapsed since the begining of the day.
  Duration get time => Duration(hours: hour, minutes: minute, seconds: second);

  Instant operator +(Duration duration) => Instant.fromDateTime(
        DateTime.utc(1970, 1, 1).add(sinceEpoch + duration),
        timeZoneOffset: timeZoneOffset,
      );

  Instant operator -(Duration duration) => Instant.fromDateTime(
        DateTime.utc(1970, 1, 1).add(sinceEpoch - duration),
        timeZoneOffset: timeZoneOffset,
      );

  /// Returns a new [Instant] instance with [duration] added to `this`.
  ///
  /// The returned [Instant] is in the same time zone as `this` and does not take into account daylight saving
  /// offsets.
  Instant add(Duration duration) => this + duration;

  /// Returns a new [Instant] value corresponding to the begining of the day represented by `this` [Instant].
  Instant beginingOfDay() => Instant(year: year, month: month, day: day, timeZoneOffset: timeZoneOffset);

  // double get julianDay {
  //   final jd = difference(Instant(-4713, 11, 24, 12)).totalDays;

  //   // if (compareTo(Instant(1582, 10, 14)) <= 0) return jd - 10;

  //   return jd;
  // }

  /// Compares this [Instant] to [other], returning zero if the values are equal.
  ///
  /// Returns a negative value if [this] is before [other]. It returns 0
  /// if [this] is the same as [other], and returns a positive value otherwise
  /// (when [this] is after [other]).
  int compareTo(Instant other) => sinceEpoch.compareTo(other.sinceEpoch);

  /// Returns a [Duration] with the difference when subtracting [other] from `this`.
  ///
  /// The returned [Duration] will be negative if [other] occurs after `this`.
  Duration difference(Instant other) => sinceEpoch - other.sinceEpoch;

  /// Returns true if `this` occurs after [other].
  ///
  /// The comparison is independent of the time zone.
  bool isAfter(Instant other) => sinceEpoch > other.sinceEpoch;

  /// Returns true if `this` occurs at the same instant as [other].
  ///
  /// The comparison is independent of the time zone.
  bool isAtSameInstantAs(Instant other) => sinceEpoch == other.sinceEpoch;

  /// Returns true if `this` occurs before [other].
  ///
  /// The comparison is independent of the time zone.
  bool isBefore(Instant other) => sinceEpoch < other.sinceEpoch;

  /// Returns a new [Instant] instance with [duration] subtracted from `this`.
  ///
  /// The returned [Instant] is in the same time zone as `this` and does not take into account daylight saving
  /// offsets.
  Instant subtract(Duration duration) => this - duration;

  /// Returns an ISO-8601 full-precision extended format representation.
  ///
  /// The format is `yyyy-MM-ddTHH:mm:sszzzzzz` where:
  ///
  /// * `yyyy` is a, possibly negative, four digit representation of the year,
  ///   if the year is in the range -9999 to 9999, otherwise it is a signed six digit representation of the year.
  /// * `MM` is the month in the range 01 to 12,
  /// * `dd` is the day of the month in the range 01 to 31,
  /// * `HH` are hours in the range 00 to 23,
  /// * `mm` are minutes in the range 00 to 59,
  /// * `ss` are seconds in the range 00 to 59 (no leap seconds),
  /// * `zzzzzz` is the time zone (Z if UTC, otherwise +HH:mm or -HH:mm),
  String toIso8601String() {
    final y = (year >= -9999 && year <= 9999) ? _fourDigits(year) : _sixDigits(year);
    final m = _twoDigits(month);
    final d = _twoDigits(day);
    final h = _twoDigits(hour);
    final min = _twoDigits(minute);
    final sec = _twoDigits(second);

    if (timeZoneOffset == 0) {
      return '$y-$m-${d}T$h:$min:${sec}Z';
    } else {
      final strTimeZoneOffset = _timeZoneOffsetAsString();

      return '$y-$m-${d}T$h:$min:$sec$strTimeZoneOffset';
    }
  }

  /// Returns a string representation of `this` instance.
  @override
  String toString() {
    final y = _fourDigits(year);
    final m = _twoDigits(month);
    final d = _twoDigits(day);
    final h = _twoDigits(hour);
    final min = _twoDigits(minute);
    final sec = _twoDigits(second);

    if (timeZoneOffset == 0) {
      return '$y-$m-$d $h:$min:${sec}Z';
    } else {
      final strTimeZoneOffset = _timeZoneOffsetAsString();
      return '$y-$m-$d $h:$min:$sec $strTimeZoneOffset';
    }
  }

  /// Returns `this` [Instant] value in the UTC time zone.
  ///
  /// Returns `this` if it is already in UTC.
  Instant toUtc() => (timeZoneOffset == 0) ? this : Instant.fromDateTime(DateTime.utc(1970, 1, 1).add(sinceEpoch));

  /// Returns a [DateTime] object in the UTC time zone based on `this` [Instant].
  DateTime toUtcDateTime() {
    final utcInstant = toUtc();
    return DateTime.utc(
      utcInstant.year,
      utcInstant.month,
      utcInstant.day,
      utcInstant.hour,
      utcInstant.minute,
      utcInstant.second,
    );
  }

  double _computeJulianDay() {
    final utcDate = toUtc();

    var year = utcDate.year;
    var month = utcDate.month;

    final day = utcDate.day +
        (utcDate.hour / Duration.hoursPerDay) +
        (utcDate.minute / Duration.minutesPerDay) +
        (utcDate.second / Duration.secondsPerDay);

    var b = 0; // Julian calendar by default

    // If the month is Jan or Feb then the date is considered to be in the 13th or 14th month of the preceding year for
    // calculation purposes.
    if (month <= 2) {
      year -= 1;
      month += 12;
    }

    // Pope Gregory introduced the Gregorian calendar in October 1582 when the calendar had drifted 10 days.
    // Dates prior to October 4, 1582 are Julian dates and dates after October 15, 1582 are Gregorian dates.
    // Any date in the gap is invalid on the Gregorian calendar.
    if (isAfter(Instant(year: 1582, month: 10, day: 14))) // Convert to Gregorian calendar
    {
      final a = (year / 100).floor();
      b = 2 - a + (a / 4).floor();
    }

    return (365.25 * (year + 4716)).floor() + (30.6001 * (month + 1)).floor() + day + b - 1524.5;
  }

  Duration _computeSinceEpoch() {
    final c = ((14 - month) / 12).floor();
    final m = ((12 * c + month - 3) * 30.6001).round() + 59 - 365 * c;

    final y = year - 1970;
    var a = y * 365;
    var b = ((y + 2) / 4).floor() - ((y + 70) / 100).floor() + ((y + 1570) / 400).floor() - 3;

    if (_isLeapYear(year) && month <= 2) b -= 1;

    final days = day - 1 + m + a + b;

    final seconds = (days * Duration.secondsPerDay) +
        (hour * Duration.secondsPerHour) +
        (minute * Duration.secondsPerMinute) +
        second -
        (timeZoneOffset * Duration.secondsPerHour);

    return Timespan.fromSeconds(seconds);

    // final days = day -
    //     1 +
    //     m +
    //     a +
    //     b +
    //     (hour / Duration.hoursPerDay) +
    //     (minute / Duration.minutesPerDay) +
    //     (second / Duration.secondsPerDay) -
    //     (timeZoneOffset / Duration.hoursPerDay);

    // return Timespan.fromDays(days);
  }

  String _timeZoneOffsetAsString() {
    final timezoneSign = timeZoneOffset.isNegative ? '-' : '+';
    final hours = timeZoneOffset.truncate();

    final tzH = _twoDigits(hours.abs());
    final tzM = _twoDigits(((timeZoneOffset - hours) * Duration.minutesPerHour).round().abs());
    return '$timezoneSign$tzH:$tzM';
  }

  static String _fourDigits(int n) {
    final absN = n.abs();
    final sign = n < 0 ? '-' : '';
    if (absN >= 1000) return '$n';
    if (absN >= 100) return '${sign}0$absN';
    if (absN >= 10) return '${sign}00$absN';
    return '${sign}000$absN';
  }

  static bool _isLeapYear(int year) => (year % 4 == 0 && year % 100 != 0) || year % 400 == 0;

  static String _sixDigits(int n) {
    assert(n < -9999 || n > 9999);
    final absN = n.abs();
    final sign = n < 0 ? '-' : '+';
    if (absN >= 100000) return '$sign$absN';
    return '${sign}0$absN';
  }

  static String _twoDigits(int n) {
    if (n >= 10) return '$n';
    return '0$n';
  }
}
