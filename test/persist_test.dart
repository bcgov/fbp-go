import 'package:fire_behaviour_app/fire.dart';
import 'package:fire_behaviour_app/persist.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('loadBasic fuel type preset loading', () {
    test('uses the saved preset when the id is valid', () async {
      final preset = getFuelTypePresets().last;
      SharedPreferences.setMockInitialValues({
        'fuelTypePreset': preset.id,
      });

      final settings = await loadBasic();

      expect(settings.fuelTypePreset.id, preset.id);
      expect(settings.fuelTypePreset.code, preset.code);
    });

    test('falls back to C-2 when no preset id is saved', () async {
      SharedPreferences.setMockInitialValues({});

      final settings = await loadBasic();
      final defaultPreset = getC2BorealSpruce();

      expect(settings.fuelTypePreset.id, defaultPreset.id);
      expect(settings.fuelTypePreset.code, defaultPreset.code);
    });

    test('falls back to C-2 when the saved preset id is invalid', () async {
      SharedPreferences.setMockInitialValues({
        'fuelTypePreset': 999,
      });

      final settings = await loadBasic();
      final defaultPreset = getC2BorealSpruce();

      expect(settings.fuelTypePreset.id, defaultPreset.id);
      expect(settings.fuelTypePreset.code, defaultPreset.code);
    });
  });
}
