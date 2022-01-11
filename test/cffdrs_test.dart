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

double roundDouble(double value, {int places = 4}) {
  /* Hypothesis A: R has a slightly different way of doing floating point
  calculations resulting in minor differences in the output. We're unlinkely
  to care about anything beyond 2 decimal places.
  Hypothesis B: There's a mistake in the translation, some detail in operation
  order or some such which is causing slightly different results.
  */
  if (places < 2) {
    // Say what? You want to round to less than 2 decimal places? That's
    // crazy talk.
    throw Exception('Now you\'re just being silly. Check your math.');
  }
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
      const index = 32;
      var input = loadInput(inputJson[index]);
      print(input);
      final FireBehaviourPredictionPrimary expected =
          loadOutput(outputJson[index]);
      final FireBehaviourPredictionPrimary result =
          FBPcalc(input, output: "ALL");

      expect(result.secondary?.LBt, expected.secondary?.LBt);
    }, skip: true);

    test('FBCCalc', () {
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
        expect(result.CFB, expected.CFB, reason: 'CFB $i');
        expect(roundDouble(result.TFC), roundDouble(expected.TFC),
            reason: 'TFC $i');
        expect(roundDouble(result.HFI), roundDouble(expected.HFI),
            reason: 'HFI $i');
        expect(result.FD, expected.FD, reason: 'FD $i');
        expect(result.CFC, expected.CFC, reason: 'CFC $i');
        // now check the secondary outputs
        expect(result.secondary == null, expected.secondary == null,
            reason: 'secondary $i');

        FireBehaviourPredictionSecondary? resultSecondary = result.secondary;
        FireBehaviourPredictionSecondary? expectedSecondary =
            expected.secondary;

        if (resultSecondary != null && expectedSecondary != null) {
          expect(resultSecondary.SF, expectedSecondary.SF, reason: 'SF $i');
          expect(resultSecondary.CSI, expectedSecondary.CSI, reason: 'CSI $i');
          expect(resultSecondary.RSO, expectedSecondary.RSO, reason: 'RSO $i');
          expect(resultSecondary.BE, expectedSecondary.BE, reason: 'BE $i');
          expect(roundDouble(resultSecondary.LB),
              roundDouble(expectedSecondary.LB),
              reason: 'LB $i');
          expect(roundDouble(resultSecondary.LBt, places: 3),
              roundDouble(expectedSecondary.LBt, places: 3),
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
          expect(roundDouble(resultSecondary.FROSt, places: 3),
              roundDouble(expectedSecondary.FROSt, places: 3),
              reason: 'FROSt $i');
          expect(roundDouble(resultSecondary.TROSt, places: 3),
              roundDouble(expectedSecondary.TROSt, places: 3),
              reason: 'TROSt $i');
          expect(resultSecondary.FCFB, expectedSecondary.FCFB,
              reason: 'FCFB $i');
          expect(resultSecondary.BCFB, expectedSecondary.BCFB,
              reason: 'BCFB $i');
          expect(resultSecondary.TCFB, expectedSecondary.TCFB,
              reason: 'TCFB $i');
          expect(resultSecondary.FTFC, expectedSecondary.FTFC,
              reason: 'FTFC $i');
          expect(resultSecondary.BTFC, expectedSecondary.BTFC,
              reason: 'BTFC $i');
          expect(resultSecondary.TTFC, expectedSecondary.TTFC,
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
          expect(roundDouble(resultSecondary.HROSt, places: 3),
              roundDouble(expectedSecondary.HROSt, places: 3),
              reason: 'HROSt $i');
          expect(roundDouble(resultSecondary.TI, places: 5),
              roundDouble(expectedSecondary.TI, places: 5),
              reason: 'TI $i');
          expect(resultSecondary.FTI, expectedSecondary.FTI, reason: 'FTI $i');
          expect(resultSecondary.BTI, expectedSecondary.BTI, reason: 'BTI $i');
          expect(resultSecondary.TTI, expectedSecondary.TTI, reason: 'TTI $i');
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
    }, skip: false);
  });
}
