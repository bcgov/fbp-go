import 'package:fire_behaviour_app/coordinate_picker.dart';
import 'package:fire_behaviour_app/fire.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'basic_input.dart';
import 'global.dart';

class BasicSettings {
  BasicInput basicInput;
  FuelTypePreset fuelTypePreset;

  BasicSettings({required this.basicInput, required this.fuelTypePreset});
}

class AdvancedSettings extends BasicSettings {
  double t;

  AdvancedSettings(
      {required BasicInput basicInput,
      required FuelTypePreset fuelTypePreset,
      required this.t})
      : super(basicInput: basicInput, fuelTypePreset: fuelTypePreset);
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

BasicSettings _loadBasic(SharedPreferences prefs) {
  final c2 = getC2BorealSpruce();

  var fuelTypePresets = getFuelTypePresets();
  var fuelTypePreset = fuelTypePresets.firstWhere(
      (element) => element.id == (prefs.getInt('fuelTypePreset') ?? c2.id));

  BasicInput basicInput = BasicInput(
      ws: prefs.getDouble('ws') ?? 5,
      bui: prefs.getDouble('bui') ?? fuelTypePreset.averageBUI,
      coordinate: Coordinate(
          latitude: prefs.getDouble('latitude') ?? defaultLatitude,
          longitude: prefs.getDouble('longitude') ?? defaultLongitude,
          // We need to in altitude, if a value below zero was persisted, it will cause the FBP calculation
          // to fail.
          altitude:
              pinAltitude(prefs.getDouble('altitude') ?? defaultAltitude)));

  basicInput.waz = prefs.getDouble('waz') ?? 0;
  // we need to pin the ground slope, because the input range has been changed,
  // if a user has the old value saved, we need to override it.
  basicInput.gs = pinGS(prefs.getDouble('gs') ?? 0);
  basicInput.cc = prefs.getDouble('cc') ?? defaultCC;
  basicInput.ffmc = prefs.getDouble('ffmc') ?? defaultFFMC;
  basicInput.aspect = prefs.getDouble('aspect') ?? 0;

  return BasicSettings(basicInput: basicInput, fuelTypePreset: fuelTypePreset);
}

Future<BasicSettings> loadBasic() async {
  final prefs = await SharedPreferences.getInstance();
  return _loadBasic(prefs);
}

AdvancedSettings _loadAdvanced(SharedPreferences prefs) {
  var basicSettings = _loadBasic(prefs);

  var t = prefs.getDouble('t') ?? 60;

  return AdvancedSettings(
      t: t,
      basicInput: basicSettings.basicInput,
      fuelTypePreset: basicSettings.fuelTypePreset);
}

Future<AdvancedSettings> loadAdvanced() async {
  final prefs = await SharedPreferences.getInstance();
  return _loadAdvanced(prefs);
}
