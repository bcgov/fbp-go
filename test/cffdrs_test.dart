import 'dart:io';
import 'dart:math';
import 'dart:convert';
import 'package:fire_behaviour_app/cffdrs/be_calc.dart';
import 'package:fire_behaviour_app/cffdrs/cfb_calc.dart';
import 'package:fire_behaviour_app/cffdrs/isi_calc.dart';
import 'package:fire_behaviour_app/cffdrs/ros_calc.dart';
import 'package:fire_behaviour_app/cffdrs/slope_calc.dart';
import 'package:fire_behaviour_app/cffdrs/c6_calc.dart';
import 'package:test/test.dart';

import 'package:fire_behaviour_app/cffdrs/fbp_calc.dart';

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
    // TODO: add more fields!!! PC, CBH etc. etc.
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
      CFC: outputJson["CFC"],
      secondary: FireBehaviourPredictionSecondary(
        SF: outputJson["SF"],
        CSI: outputJson["CSI"],
        RSO: outputJson["RSO"],
        BE: outputJson["BE"],
        LB: outputJson["LB"],
        LBt: outputJson["LBt"],
        BROS: outputJson["BROS"],
        FROS: outputJson["FROS"],
        TROS: outputJson["TROS"],
        BROSt: outputJson["BROSt"],
        FROSt: outputJson["FROSt"],
        TROSt: outputJson["TROSt"],
        FCFB: outputJson["FCFB"],
        BCFB: outputJson["BCFB"],
        TCFB: outputJson["TCFB"],
        FTFC: outputJson["FTFC"],
        BTFC: outputJson["BTFC"],
        TTFC: outputJson["TTFC"],
        FFI: outputJson["FFI"],
        BFI: outputJson["BFI"],
        TFI: outputJson["TFI"],
        HROSt: outputJson["HROSt"],
        TI: outputJson["TI"],
        FTI: outputJson["FTI"],
        BTI: outputJson["BTI"],
        TTI: outputJson["TTI"],
        DH: outputJson["DH"],
        DB: outputJson["DB"],
        DF: outputJson["DF"],
      ));
}

double roundDouble(double value, {int places = 6}) {
  // TODO: We want to get rid of this function - but it's useful right now
  // to zero in on where the difference is sneaking in!
  var mod = pow(10.0, places);
  return ((value * mod).round().toDouble() / mod);
}

void main() {
  group('ISIcalc', () {
    test('Scenario', () {
      final result = ISIcalc(57.55481411251054, 0);
      expect(roundDouble(result, places: 14),
          roundDouble(0.345473329095927, places: 14));
    });
  });

  group('CFBcalc', () {
    test('Scenario', () {
      final result = CFBcalc('C6', 109.69520000000001, 3.4742543847234075,
          0.0006076755997436044, 7.0);
      expect(result, 0.0);
    });
  });

  group('C6calc', () {
    test('Scenario', () {
      final result = C6calc('C6', 0.3454733290959275, -1.0, 109.69520000000001,
          3.4742543847234075, 7.0,
          option: "ROS");
      expect(roundDouble(result, places: 10), 0.0006076756);
    });
  });

  group('BEcalc', () {
    test('Scenario', () {
      final result = BEcalc('C6', -1.0);
      expect(result, 1.0);
    });
  });

  group('ROScalc', () {
    test('Scenario', () {
      final result = ROScalc(
        "C6",
        0.3454733290959275,
        -1.0,
        109.69520000000001,
        3.4742543847234075,
        0,
        35.0,
        80.0,
        7.0,
      );
      expect(result, 0.0006076755997436044);
    });
  });
  group('Slopecalc', () {
    test('Scenario', () {
      final result = Slopecalc(
          'C6',
          57.55481411251054,
          133.63769408909872,
          16.81983099456876,
          6.247412014352667,
          29.251275109988352,
          4.474380979600264,
          109.69520000000001,
          3.4742543847234075,
          null,
          35,
          80,
          7.0,
          0.0,
          output: "WSV");
      expect(result, 16.604545444707842);
    });
  });
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

    test('Bad FBC', () {
      // TODO: output the input values for _Slopecalc in dart, take those same
      // input values, and plug it into the R script, and compare the output.
      var input = loadInput(inputJson[50]);
      print(input);
      final expected = loadOutput(outputJson[50]);
      final result = FBPcalc(input);
      print('expected: ${expected.WSV}');
      print('result: ${result.WSV}');
    });

    // test('FBCCalc', () {
    //   for (var i = 0; i < inputJson.length; i++) {
    //     final input = loadInput(inputJson[i]);
    //     final expected = loadOutput(outputJson[i]);
    //     final result = FBPcalc(input);
    //     expect(result.FMC, expected.FMC, reason: 'FMC $i');
    //     expect(result.SFC, expected.SFC, reason: 'SFC $i');
    //     expect(roundDouble(result.WSV), roundDouble(expected.WSV),
    //         reason: 'WSV $i');
    //     expect(roundDouble(result.RAZ), roundDouble(expected.RAZ),
    //         reason: 'RAZ $i');
    //     expect(roundDouble(result.ISI), roundDouble(expected.ISI),
    //         reason: 'ISI $i');
    //     expect(roundDouble(result.ROS), roundDouble(expected.ROS),
    //         reason: 'ROS $i');
    //     expect(result.CFB, expected.CFB, reason: 'CFB $i');
    //     expect(result.TFC, expected.TFC, reason: 'TFC $i');
    //     expect(roundDouble(result.HFI), roundDouble(expected.HFI),
    //         reason: 'HFI $i');
    //     expect(result.FD, expected.FD, reason: 'FD $i');
    //     expect(result.CFC, expected.CFC, reason: 'CFC $i');

    //     // expect(result.secondary.BCFB)
    //   }
    // });
  }, skip: true);
}
