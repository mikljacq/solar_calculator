import 'package:solar_calculator/solar_calculator.dart';
import 'package:solar_calculator/src/instant.dart';

void main() {
  final latitude = 41.387048;
  final longitude = 2.17413425;

  final instant = Instant(year: 2021, month: 5, day: 10, hour: 14, timeZoneOffset: 2.0);

  final calc = SolarCalculator(instant, latitude, longitude);

  print('Sun Equatorial position:');
  print(
      '    Right ascension: ${calc.sunEquatorialPosition.rightAscension} = ${calc.sunEquatorialPosition.rightAscension.decimalDegrees}');
  print('    Declination: ${calc.sunEquatorialPosition.declination}');

  print('Sun Horizontal position:');
  print('    Azimuth: ${calc.sunHorizontalPosition.azimuth}');
  print('    Elevation: ${calc.sunHorizontalPosition.elevation}');

  print('Morning astronomical twilight:');
  print('    Begining: ${calc.morningAstronomicalTwilight.begining}');
  print('    Ending: ${calc.morningAstronomicalTwilight.ending}');
  print('    Duration: ${calc.morningAstronomicalTwilight.duration}');

  print('Morning nautical twilight:');
  print('    Begining: ${calc.morningNauticalTwilight.begining}');
  print('    Ending: ${calc.morningNauticalTwilight.ending}');
  print('    Duration: ${calc.morningNauticalTwilight.duration}');

  print('Morning civil twilight:');
  print('    Begining: ${calc.morningCivilTwilight.begining}');
  print('    Ending: ${calc.morningCivilTwilight.ending}');
  print('    Duration: ${calc.morningCivilTwilight.duration}');

  print('Sunrise: ${calc.sunriseTime}');
  print('Noon: ${calc.sunTransitTime}');
  print('Sunset: ${calc.sunsetTime}');

  print('Evening civil twilight:');
  print('    Begining: ${calc.eveningCivilTwilight.begining}');
  print('    Ending: ${calc.eveningCivilTwilight.ending}');
  print('    Duration: ${calc.eveningCivilTwilight.duration}');

  print('Evening nautical twilight:');
  print('    Begining: ${calc.eveningNauticalTwilight.begining}');
  print('    Ending: ${calc.eveningNauticalTwilight.ending}');
  print('    Duration: ${calc.eveningNauticalTwilight.duration}');

  print('Evening astronomical twilight:');
  print('    Begining: ${calc.eveningAstronomicalTwilight.begining}');
  print('    Ending: ${calc.eveningAstronomicalTwilight.ending}');
  print('    Duration: ${calc.eveningAstronomicalTwilight.duration}');

  if (calc.isHoursOfDarkness) print('===> IS DARK <===');
}
