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
    ACCEL: inputJson["ACCEL"] == 1,
    ASPECT: inputJson["ASPECT"],
    BUIEFF: inputJson["BUIEFF"] == 1,
    HR: inputJson["HR"],
    THETA: inputJson["THETA"],
    CC: inputJson["CC"],
    PDF: inputJson["PDF"],
    CBH: inputJson["CBH"],
    PC: inputJson["PC"],
    FMC: inputJson["FMC"],
    GFL: inputJson['GFL'],
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

double roundDouble(double value) {
  /*Hypothesis A: R has a slightly different way of doing floating point
  calculations resulting in minor differences in the output. We're unlinkely
  to care about anything beyond 2 decimal places.
  Hypothesis B: There's a mistake in the translation, some detail in operation
  order or some such which is causing slightly different results.
  */
  const int places = 5; // 5 decimal places isn't too bad.
  var mod = pow(10.0, places);
  return ((value * mod).round().toDouble() / mod);
}

void main() {
  group('ISIcalc', () {
    test('Scenario', () {
      final result = ISIcalc(57.55481411251054, 0);
      expect(roundDouble(result), roundDouble(0.345473329095927));
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
      expect(roundDouble(result), roundDouble(0.0006076756));
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
    test('C6 Scenario', () {
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
    test('M2 Scenario', () {
      final result = Slopecalc(
          'M2',
          98.90994700887234,
          0.0,
          24.695621017090957,
          2.755556900847557,
          76.5953764720197,
          4.855878595311738,
          87.7216,
          1.3797772519962974,
          3.7466175923251854,
          28.721259560328726,
          64.82853387092416,
          6.0,
          0.0,
          output: "WSV");
      expect(result, 102.22228707251003);
    });
  });
  group('FBCCcalc', () {
    late dynamic inputJson;
    late dynamic outputJson;

    setUpAll(() async {
      // Use test data generated by a script that runs against the original
      // R package.
      final inputFile = File('test/resources/FBCCalc_input.json');
      inputJson = jsonDecode(await inputFile.readAsString());

      final outputFile = File('test/resources/FBCCalc_output.json');
      outputJson = jsonDecode(await outputFile.readAsString());
    });

    test('FBCCalc', () {
      // Iterate through all samples in the test data, comparing expected
      // with actual.
      for (var i = 0; i < inputJson.length; i++) {
        final input = loadInput(inputJson[i]);
        FireBehaviourPredictionPrimary expected = loadOutput(outputJson[i]);
        FireBehaviourPredictionPrimary result = FBPcalc(input, output: "ALL");
        expect(result.FMC, expected.FMC, reason: 'FMC $i');
        expect(roundDouble(result.SFC), roundDouble(expected.SFC),
            reason: 'SFC $i');
        expect(roundDouble(result.WSV), roundDouble(expected.WSV),
            reason: 'WSV $i');
        expect(roundDouble(result.RAZ), roundDouble(expected.RAZ),
            reason: 'RAZ $i');
        expect(roundDouble(result.ISI), roundDouble(expected.ISI),
            reason: 'ISI $i');
        expect(roundDouble(result.ROS), roundDouble(expected.ROS),
            reason: 'ROS $i');
        expect(roundDouble(result.CFB), roundDouble(expected.CFB),
            reason: 'CFB $i');
        expect(roundDouble(result.TFC), roundDouble(expected.TFC),
            reason: 'TFC $i');
        expect(roundDouble(result.HFI), roundDouble(expected.HFI),
            reason: 'HFI $i');
        expect(result.FD, expected.FD, reason: 'FD $i');
        expect(roundDouble(result.CFC), roundDouble(expected.CFC),
            reason: 'CFC $i');
        // now check the secondary outputs
        expect(result.secondary == null, expected.secondary == null,
            reason: 'secondary $i');

        FireBehaviourPredictionSecondary? resultSecondary = result.secondary;
        FireBehaviourPredictionSecondary? expectedSecondary =
            expected.secondary;

        if (resultSecondary != null && expectedSecondary != null) {
          expect(resultSecondary.SF, expectedSecondary.SF, reason: 'SF $i');
          expect(roundDouble(resultSecondary.CSI),
              roundDouble(expectedSecondary.CSI),
              reason: 'CSI $i');
          expect(roundDouble(resultSecondary.RSO),
              roundDouble(expectedSecondary.RSO),
              reason: 'RSO $i');
          expect(resultSecondary.BE, expectedSecondary.BE, reason: 'BE $i');
          expect(roundDouble(resultSecondary.LB),
              roundDouble(expectedSecondary.LB),
              reason: 'LB $i');
          expect(roundDouble(resultSecondary.LBt),
              roundDouble(expectedSecondary.LBt),
              reason: 'LBt $i');
          expect(roundDouble(resultSecondary.BROS),
              roundDouble(expectedSecondary.BROS),
              reason: 'BROS $i');
          expect(roundDouble(resultSecondary.FROS),
              roundDouble(expectedSecondary.FROS),
              reason: 'FROS $i');
          expect(roundDouble(resultSecondary.TROS),
              roundDouble(expectedSecondary.TROS),
              reason: 'TROS $i');
          expect(roundDouble(resultSecondary.BROSt),
              roundDouble(expectedSecondary.BROSt),
              reason: 'BROSt $i');
          expect(roundDouble(resultSecondary.FROSt),
              roundDouble(expectedSecondary.FROSt),
              reason: 'FROSt $i');
          expect(roundDouble(resultSecondary.TROSt),
              roundDouble(expectedSecondary.TROSt),
              reason: 'TROSt $i');
          expect(resultSecondary.FCFB, expectedSecondary.FCFB,
              reason: 'FCFB $i');
          expect(resultSecondary.BCFB, expectedSecondary.BCFB,
              reason: 'BCFB $i');
          expect(resultSecondary.TCFB, expectedSecondary.TCFB,
              reason: 'TCFB $i');
          expect(roundDouble(resultSecondary.FTFC),
              roundDouble(expectedSecondary.FTFC),
              reason: 'FTFC $i');
          expect(roundDouble(resultSecondary.BTFC),
              roundDouble(expectedSecondary.BTFC),
              reason: 'BTFC $i');
          expect(roundDouble(resultSecondary.TTFC),
              roundDouble(expectedSecondary.TTFC),
              reason: 'TTFC $i');
          expect(roundDouble(resultSecondary.FFI),
              roundDouble(expectedSecondary.FFI),
              reason: 'FFI $i');
          expect(roundDouble(resultSecondary.BFI),
              roundDouble(expectedSecondary.BFI),
              reason: 'BFI $i');
          expect(roundDouble(resultSecondary.TFI),
              roundDouble(expectedSecondary.TFI),
              reason: 'TFI $i');
          expect(roundDouble(resultSecondary.HROSt),
              roundDouble(expectedSecondary.HROSt),
              reason: 'HROSt $i');
          expect(roundDouble(resultSecondary.TI),
              roundDouble(expectedSecondary.TI),
              reason: 'TI $i');
          expect(roundDouble(resultSecondary.FTI),
              roundDouble(expectedSecondary.FTI),
              reason: 'FTI $i');
          expect(resultSecondary.BTI, expectedSecondary.BTI, reason: 'BTI $i');
          expect(roundDouble(resultSecondary.TTI),
              roundDouble(expectedSecondary.TTI),
              reason: 'TTI $i');
          expect(roundDouble(resultSecondary.DH),
              roundDouble(expectedSecondary.DH),
              reason: 'DH $i');
          expect(roundDouble(resultSecondary.DB),
              roundDouble(expectedSecondary.DB),
              reason: 'DB $i');
          expect(roundDouble(resultSecondary.DF),
              roundDouble(expectedSecondary.DF),
              reason: 'DF $i');
        }
      }
    });
  });
}
