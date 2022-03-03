class BeaufortScale {
  final String range;
  final String description;
  final String effects;

  BeaufortScale(this.range, this.description, this.effects);

  @override
  toString() {
    return '$range, $description, $effects}';
  }
}

BeaufortScale getBeaufortScale(double windSpeed) {
  if (windSpeed < 1) {
    return BeaufortScale('< 1', 'Calm', 'Smoke rises vertically.');
  }
  if (windSpeed >= 1 && windSpeed < 6) {
    return BeaufortScale('1-5', 'Light air',
        'Direction shown by smoke drift but not by wind vanes.');
  }
  if (windSpeed >= 6 && windSpeed < 12) {
    return BeaufortScale('6-11', 'Light breeze',
        'Wind felt on face;\nleaves rustle;\nwind vane moved by wind.');
  }
  if (windSpeed >= 12 && windSpeed < 20) {
    return BeaufortScale('12-19', 'Gentle breeze',
        'Leaves and small twigs in constant motion;\nlight flags extended.');
  }
  if (windSpeed >= 20 && windSpeed < 29) {
    return BeaufortScale('20-28', 'Moderate breeze',
        'Raises dust and loose paper;\nsmall branches moved.');
  }
  if (windSpeed >= 29 && windSpeed < 39) {
    return BeaufortScale('29-38', 'Fresh breeze',
        'Small trees in leaf begin to sway;\ncrested wavelets form on inland waters.');
  }
  if (windSpeed >= 39 && windSpeed < 50) {
    return BeaufortScale('39-49', 'Strong breeze',
        'Large branches in motion;\nwhistling heard in telephone wires;\numbrellas used with difficulty.');
  }
  if (windSpeed >= 50 && windSpeed < 62) {
    return BeaufortScale('50-61', 'Near gale',
        'Whole trees in motion;\ninconvenience felt when walking against the wind.');
  }
  if (windSpeed >= 62 && windSpeed < 75) {
    return BeaufortScale('62-74', 'Moderate gale',
        'Breaks twigs off tress, generally impedes progress.');
  }
  if (windSpeed >= 75 && windSpeed < 89) {
    return BeaufortScale(
        '75-88', 'Strong gale', 'Slight structural damage occurs.');
  }
  if (windSpeed >= 89 && windSpeed < 103) {
    return BeaufortScale('89-102', 'Whole gale',
        'Seldom experienced inland, tree uprooted;\nconsiderable structural damage.');
  }
  if (windSpeed >= 103 && windSpeed < 118) {
    return BeaufortScale(
        '103-117', 'Storm', 'Very rarely experienced;\nwidespread damage.');
  }
  if (windSpeed >= 118) {
    return BeaufortScale('118+', 'Hurricane',
        'Severe widespread damage to vegetation and significant structural damage possible.');
  }
  throw Exception('Cannot convert wind speed to Beaufort scale');
}
