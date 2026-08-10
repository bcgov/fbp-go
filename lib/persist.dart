import 'package:fire_behaviour_app/coordinate_picker.dart';
import 'package:fire_behaviour_app/fire.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'basic_input.dart';
import 'global.dart';
import 'ignition_type.dart';

class BasicSettings {
  BasicInput basicInput;
  FuelTypePreset fuelTypePreset;

  BasicSettings({required this.basicInput, required this.fuelTypePreset});
}

class AdvancedSettings extends BasicSettings {
  double t;
  IgnitionType ignitionType;

  AdvancedSettings({
    required super.basicInput,
    required super.fuelTypePreset,
    required this.t,
    required this.ignitionType,
  });
}

void persistSetting(String key, double value) {
  SharedPreferences.getInstance().then((prefs) {
    prefs.setDouble(key, value);
  });
}

void persistFuelTypePreset(FuelTypePreset value) {
  SharedPreferences.getInstance().then((prefs) {
    prefs.setInt('fuelTypePreset', value.id);
  });
}

void persistIgnition(String key, IgnitionType value) {
  SharedPreferences.getInstance().then((prefs) {
    prefs.setString(key, value.name);
  });
}

FuelTypePreset _loadFuelTypePreset(SharedPreferences prefs) {
  final c2 = getC2BorealSpruce();
  final savedId = prefs.getInt('fuelTypePreset');
  final fuelTypePresets = getFuelTypePresets();
  return fuelTypePresets.firstWhere(
    (element) => element.id == savedId,
    orElse: () => c2,
  );
}

BasicSettings _loadBasic(SharedPreferences prefs) {
  final fuelTypePreset = _loadFuelTypePreset(prefs);

  BasicInput basicInput = BasicInput(
    ws: prefs.getDouble('ws') ?? 5,
    bui: prefs.getDouble('bui') ?? fuelTypePreset.averageBUI,
    // We pin coordinate values to avoid loading bad data.
    coordinate: Coordinate(
      latitude: pinLatitude(prefs.getDouble('latitude') ?? defaultLatitude),
      longitude: pinLongitude(prefs.getDouble('longitude') ?? defaultLongitude),
      altitude: pinAltitude(prefs.getDouble('altitude') ?? defaultAltitude),
    ),
  );

  // We pin all loaded values, so that stale or out of range saved settings
  // can't put the app into a state where a prediction can't be calculated.
  basicInput.waz = pinAzimuth(prefs.getDouble('waz') ?? 0);
  // we need to pin the ground slope, because the input range has been changed,
  // if a user has the old value saved, we need to override it.
  basicInput.gs = pinGS(prefs.getDouble('gs') ?? 0);
  basicInput.cc = pinCC(prefs.getDouble('cc') ?? defaultCC);
  basicInput.ffmc = pinFFMC(prefs.getDouble('ffmc') ?? defaultFFMC);
  basicInput.aspect = pinAzimuth(prefs.getDouble('aspect') ?? 0);

  return BasicSettings(basicInput: basicInput, fuelTypePreset: fuelTypePreset);
}

IgnitionType loadIgnitionType(SharedPreferences prefs) {
  final value = prefs.getString('ignitionType');
  return IgnitionType.values.firstWhere(
    (e) => e.name == value,
    orElse: () => IgnitionType.point,
  );
}

Future<BasicSettings> loadBasic() async {
  final prefs = await SharedPreferences.getInstance();
  return _loadBasic(prefs);
}

AdvancedSettings _loadAdvanced(SharedPreferences prefs) {
  var basicSettings = _loadBasic(prefs);

  var t = prefs.getDouble('t') ?? 60;
  var ignitionType = loadIgnitionType(prefs);

  return AdvancedSettings(
    t: t,
    ignitionType: ignitionType,
    basicInput: basicSettings.basicInput,
    fuelTypePreset: basicSettings.fuelTypePreset,
  );
}

Future<AdvancedSettings> loadAdvanced() async {
  final prefs = await SharedPreferences.getInstance();
  return _loadAdvanced(prefs);
}
