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
  double gfl;
  double t;

  AdvancedSettings(
      {required BasicInput basicInput,
      required FuelTypePreset fuelTypePreset,
      required this.gfl,
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
          altitude: prefs.getDouble('altitude') ?? defaultAltitude));

  basicInput.waz = prefs.getDouble('waz') ?? 0;
  basicInput.gs = prefs.getDouble('gs') ?? 0;
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

  var gfl = prefs.getDouble('gfl') ?? 0.35;
  var t = prefs.getDouble('t') ?? 60;

  if (gfl < 0) {
    // In v1.0.5, it was possible to set a negative gfl, which would cause the app to crash. On re-starting the app,
    // the invalid gfl would be loaded, and the app would crash again.
    // Pinning the GFL to 0, avoids this problem.
    gfl = 0;
  }

  return AdvancedSettings(
      gfl: gfl,
      t: t,
      basicInput: basicSettings.basicInput,
      fuelTypePreset: basicSettings.fuelTypePreset);
}

Future<AdvancedSettings> loadAdvanced() async {
  final prefs = await SharedPreferences.getInstance();
  return _loadAdvanced(prefs);
}
