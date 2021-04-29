/// Represents a twilight.
///
/// Twilight is that period before sunrise and after sunset when refracted light from the Earth’s atmosphere gives an amount of illumination.
/// The amount of illumination varies with the Sun’s depression below the sensible horizon and with atmospheric conditions.
class Twilight {
  /// The begining time of this [Twilight].
  final DateTime begining;

  /// The ending time of this [Twilight].
  final DateTime ending;

  /// The duration of this [Twilight].
  Duration get duration => ending.difference(begining);

  Twilight(this.begining, this.ending);
}
