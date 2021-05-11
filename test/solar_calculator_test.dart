import 'package:solar_calculator/src/instant.dart';
import 'package:solar_calculator/src/solarCalculator.dart';
import 'package:solar_calculator/src/timespan.dart';
import 'package:test/test.dart';

void main() {
  const _kTimesAccuracyInSec = 60;
  const _kAnglesAccuracy = 0.05;

  group('Barcelona with time zone ', () {
    final instant = Instant(year: 2021, month: 05, day: 09, hour: 01, minute: 48, timeZoneOffset: 02);

    final calc = SolarCalculator(instant, 41.387048, 2.17413425);

    test('Sunrise', () {
      print(calc.sunriseTime);
      final sunrise =
          calc.sunriseTime.difference(instant.beginingOfDay().add(Duration(hours: 06, minutes: 39))).inSeconds.abs() <=
              _kTimesAccuracyInSec;
      expect(sunrise, true);
    });

    test('Sunset', () {
      final sunset =
          calc.sunsetTime.difference(instant.beginingOfDay().add(Duration(hours: 20, minutes: 57))).inSeconds.abs() <=
              _kTimesAccuracyInSec;
      expect(sunset, true);
    });

    test('Transit', () {
      final transit = calc.sunTransitTime
              .difference(instant.beginingOfDay().add(Duration(hours: 13, minutes: 47)))
              .inSeconds
              .abs() <=
          _kTimesAccuracyInSec;
      expect(transit, true);
    });

    test('Sun Declination', () {
      final declination = (calc.sunEquatorialPosition.declination - 17.36).abs() <= _kAnglesAccuracy;
      expect(declination, true);
    });

    test('Sun Horizontal position', () {
      final azimuth = (calc.sunHorizontalPosition.azimuth - 0.06459949466776038).abs() <= _kAnglesAccuracy;
      final elevation = (calc.sunHorizontalPosition.elevation - -31.246875568260478).abs() <= _kAnglesAccuracy;

      expect(azimuth, true);
      expect(elevation, true);
    });
  });

  final refDate = Instant(year: 2021, month: 05, day: 02);

  final date = refDate.add(Duration(hours: 13, minutes: 25, seconds: 35));

  Map<String, Map<String, dynamic>> expectedResults = {
    'Barcelona': {
      'latitude': 41.387048,
      'longitude': 2.17413425,
      'sunrise': refDate.add(Duration(hours: 04, minutes: 47)),
      'noon': refDate.add(Duration(hours: 11, minutes: 48)),
      'sunset': refDate.add(Duration(hours: 18, minutes: 50)),
      'declination': 15.55,
      'azimuth': 226.3,
      'elevation': 56.71,
    },
    'Brussels': {
      'latitude': 50.843471,
      'longitude': 4.36431884,
      'sunrise': refDate.add(Duration(hours: 04, minutes: 14)),
      'noon': refDate.add(Duration(hours: 11, minutes: 39)),
      'sunset': refDate.add(Duration(hours: 19, minutes: 06)),
      'declination': 15.55,
      'azimuth': 220.75,
      'elevation': 48.79,
    },
    'Helsinki': {
      'latitude': 60.166114,
      'longitude': 24.9361887,
      'sunrise': refDate.add(Duration(hours: 02, minutes: 14)),
      'noon': refDate.add(Duration(hours: 10, minutes: 17)),
      'sunset': refDate.add(Duration(hours: 18, minutes: 22)),
      'declination': 15.53,
      'azimuth': 238.31,
      'elevation': 34.00,
    },
    'Dubai': {
      'latitude': 25.263792,
      'longitude': 55.3434562,
      'sunrise': refDate.add(Duration(hours: 01, minutes: 42)),
      'noon': refDate.add(Duration(hours: 08, minutes: 15)),
      'sunset': refDate.add(Duration(hours: 14, minutes: 50)),
      'declination': 15.55,
      'azimuth': 279.26,
      'elevation': 17.69,
    },
    'Singapore': {
      'latitude': 1.3102843,
      'longitude': 103.846485,
      'sunrise': refDate.add(Duration(days: -1, hours: 22, minutes: 57)),
      'noon': refDate.add(Duration(hours: 05, minutes: 01)),
      'sunset': refDate.add(Duration(hours: 11, minutes: 07)),
      'declination': 15.55,
      'azimuth': 289.82,
      'elevation': -34.05,
    },
    'Sydney': {
      'latitude': -33.92614,
      'longitude': 151.222826,
      'sunrise': refDate.add(Duration(days: -1, hours: 20, minutes: 30)),
      'noon': refDate.add(Duration(hours: 01, minutes: 52)),
      'sunset': refDate.add(Duration(hours: 07, minutes: 13)),
      'declination': 15.52,
      'azimuth': 199.61,
      'elevation': -70.67,
    },
    'Ushuaïa': {
      'latitude': -54.81631,
      'longitude': -68.327772,
      'sunrise': refDate.add(Duration(hours: 11, minutes: 57)),
      'noon': refDate.add(Duration(hours: 16, minutes: 30)),
      'sunset': refDate.add(Duration(hours: 21, minutes: 03)),
      'declination': 15.55,
      'azimuth': 44.81,
      'elevation': 9.61,
    },
    'Vancouver': {
      'latitude': 49.247112,
      'longitude': -123.10707,
      'sunrise': refDate.add(Duration(hours: 12, minutes: 48)),
      'noon': refDate.add(Duration(hours: 20, minutes: 09)),
      'sunset': refDate.add(Duration(days: 1, hours: 03, minutes: 31)),
      'declination': 15.55,
      'azimuth': 71.66,
      'elevation': 4.96,
    },
    '0° 0°': {
      'latitude': 0.0,
      'longitude': 0.0,
      'sunrise': refDate.add(Duration(hours: 05, minutes: 54)),
      'noon': refDate.add(Duration(hours: 11, minutes: 56)),
      'sunset': refDate.add(Duration(hours: 18, minutes: 00)),
      'declination': 15.55,
      'azimuth': 306.41,
      'elevation': 63.17,
    },
    '80° 12°': {
      'latitude': 80.0,
      'longitude': 12.0,
      'sunrise': Instant(year: 2021, month: 04, day: 13).add(Timespan.fromMinutes(-11.654374107739168)),
      'noon': refDate.add(Duration(hours: 11, minutes: 08)),
      'sunset': Instant(year: 2021, month: 08, day: 30).add(Timespan.fromMinutes(1349.7335155238095)),
      'declination': 15.55,
      'azimuth': 216.22,
      'elevation': 23.76,
    },
    '-80° 12°': {
      'latitude': -80.0,
      'longitude': 12.0,
      'sunrise': Instant(year: 2021, month: 08, day: 25).add(Timespan.fromMinutes(644.7320304778677)),
      'noon': refDate.add(Duration(hours: 11, minutes: 08)),
      'sunset': Instant(year: 2021, month: 04, day: 18).add(Timespan.fromMinutes(678.971344895073)),
      'declination': 15.55,
      'azimuth': 326.96,
      'elevation': -7.16,
    },
    '90° 12°': {
      'latitude': 90.0,
      'longitude': 12.0,
      'sunrise': Instant(year: 2020, month: 03, day: 18).add(Timespan.fromMinutes(370.22985636407043)),
      'noon': refDate.add(Duration(hours: 11, minutes: 08)),
      'sunset': Instant(year: 2021, month: 09, day: 25).add(Timespan.fromMinutes(972.5818948340684)),
      'declination': 15.56,
      'azimuth': 214.17,
      'elevation': 15.69,
    }
  };

  for (var entry in expectedResults.entries) {
    group(entry.key, () {
      final expected = expectedResults[entry.key]!;

      final calc = SolarCalculator(date, expected['latitude'], expected['longitude']);

      test('Sunrise', () {
        final sunrise = calc.sunriseTime.difference(expected['sunrise']).inSeconds.abs() <= _kTimesAccuracyInSec;
        expect(sunrise, true);
      });

      test('Sunset', () {
        final sunset = calc.sunsetTime.difference(expected['sunset']).inSeconds.abs() <= _kTimesAccuracyInSec;
        expect(sunset, true);
      });

      test('Transit', () {
        final transit = calc.sunTransitTime.difference(expected['noon']).inSeconds.abs() <= _kTimesAccuracyInSec;
        expect(transit, true);
      });

      test('Sun Declination', () {
        final declination =
            (calc.sunEquatorialPosition.declination - expected['declination']).abs() <= _kAnglesAccuracy;
        expect(declination, true);
      });

      test('Sun Horizontal position', () {
        final azimuth = (calc.sunHorizontalPosition.azimuth - expected['azimuth']).abs() <= _kAnglesAccuracy;
        final elevation = (calc.sunHorizontalPosition.elevation - expected['elevation']).abs() <= _kAnglesAccuracy;

        expect(azimuth, true);
        expect(elevation, true);
      });
    });
  }
}
