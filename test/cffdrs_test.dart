import 'dart:io';
import 'dart:convert';

import 'package:fire_behaviour_app/cffdrs/fbp_calc.dart';
import 'package:test/test.dart';

FireBehaviourPredictionInput loadInput(dynamic inputJson) {
  return FireBehaviourPredictionInput(
    FUELTYPE: inputJson["FUELTYPE"],
    LAT: inputJson["LAT"],
    LONG: inputJson["LONG"],
    ELV: inputJson["ELV"],
    DJ: inputJson["DJ"],
    FFMC: inputJson["FFMC"],
    BUI: inputJson["BUI"],
    WS: inputJson["WS"],
    WD: inputJson["WD"],
    GS: inputJson["GS"],
    ACCEL: inputJson["ACCEL"],
    ASPECT: inputJson["ASPECT"],
    BUIEFF: inputJson["BUIEFF"],
    MINUTES: inputJson["MINUTES"],
  );
}

FireBehaviourPredictionPrimary loadOutput(dynamic outputJson) {
  return FireBehaviourPredictionPrimary(
      FMC: outputJson["FMC"],
      SFC: outputJson["SFC"],
      WSV: outputJson["WSV"],
      RAZ: outputJson["RAZ"],
      ISI: outputJson["ISI"],
      ROS: outputJson["ROS"],
      CFB: outputJson["CFB"],
      TFC: outputJson["TFC"],
      HFI: outputJson["HFI"],
      FD: outputJson["FD"],
      CFC: outputJson["CFC"]);
}

void main() {
  group('FBCCcalc', () {
    late dynamic inputJson;
    late dynamic outputJson;

    setUpAll(() async {
      final inputFile = File('test/resources/FBCCalc_input.json');
      inputJson = jsonDecode(await inputFile.readAsString());

      final outputFile = File('test/resources/FBCCalc_output.json');
      outputJson = jsonDecode(await outputFile.readAsString());
    });
    // final directory = await getApplicationDocumentsDirectory();
    // print(json);

    test('FBCCalc', () {
      for (var i = 0; i < inputJson.length; i++) {
        final input = loadInput(inputJson[i]);
        final expected = loadOutput(outputJson[i]);
        final result = FBPcalc(input);
        expect(result.FMC, expected.FMC, reason: 'FMC $i');
        expect(result.SFC, expected.SFC, reason: 'SFC $i');
        expect(result.WSV, expected.WSV, reason: 'WSV $i');
        expect(result.RAZ, expected.RAZ, reason: 'RAZ $i');
        expect(result.ISI, expected.ISI, reason: 'ISI $i');
        expect(result.ROS, expected.ROS, reason: 'ROS $i');
        expect(result.CFB, expected.CFB, reason: 'CFB $i');
        expect(result.TFC, expected.TFC, reason: 'TFC $i');
        expect(result.HFI, expected.HFI, reason: 'HFI $i');
        expect(result.FD, expected.FD, reason: 'FD $i');
        expect(result.CFC, expected.CFC, reason: 'CFC $i');
      }
    });
  });
}
