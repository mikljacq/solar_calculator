A Dart library that calculates the position of the Sun, the sunrise, sunset, solar noon times, and the different twilight periods, for any given moment in time and position on Earth.

The calculations are based on equations from Astronomical Algorithms, by Jean Meeus. The sunrise and sunset results are theoretically accurate to within a minute for locations between +/- 72° of latitude, and within 10 minutes outside of those latitudes. However, due to variations in atmospheric composition, temperature, pressure and conditions, the calculated values may differ from the observed values.

## Features

For a given moment in time and position on Earth:

* Get the apparent position of the Sun in equatorial coordinates (right ascension and declination);
* Get the apparent position of the Sun in horizontal coordinates (azimuth and elevation);
* Get the sunrise time;
* Get the solar noon time;
* Get the sunset time;
* Get the morning and evening astronomical twilights (begining and ending times);
* Get the morning and evening nautical twilights (begining and ending times);
* Get the morning and evening civil twilights (begining and ending times);
* Get if, at that moment and position, it is hours of darkness (based on the civil twilight).

## Limitations

In the current version, the time zone offset is not retrieved automatically from the specified position. So, you need to take care of that.

For sunrise, sunset and twilights calculations, 0.833° of atmospheric refraction is assumed.

The effects of the atmosphere vary with atmospheric pressure, humidity and other variables. Therefore the Sun position calculated is approximate. Related to these effects, the further away you are from the equator, errors in sunrise, sunset and twilight times can be expected to increase because the sun rises and sets at a very shallow angle; in this condition, small variations in the atmosphere can have a larger effect.

The approximations used in this calculator are very good for years between 1800 and 2100. Results should still be sufficiently accurate for the range from -1000 to 3000. Outside of this range, the risk of error is higher.

## Usage

Create a SolarCalculator instance with the desired instant in time, latitude and longitude.

The instant in time can be specified in UTC or with a time zone. Just make sure to specify the correct time according to the position on Earth and for what you want. This is particularly important for the position of the Sun.

For example, if you want the data for Barcelona, Spain, on the 10th of May 2021 at 14:00 local time during summer, enter the following:

```dart
import 'package:solar_calculator/solar_calculator.dart';

void main() {
  final latitude = 41.387048;
  final longitude = 2.17413425;

  final instant = Instant(year: 2021, month: 0, day: 10, hour: 14, timeZoneOffset: 2.0);

  final calc = SolarCalculator(instant, latitude, longitude);

  bool isHoursOfDarkness = calc.isHoursOfDarkness;
}
```