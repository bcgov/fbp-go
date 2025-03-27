import 'dart:io';
import 'dart:math';
import 'dart:convert';
import 'package:fire_behaviour_app/cffdrs/buildup_effect.dart';
import 'package:fire_behaviour_app/cffdrs/cfb_calc.dart';
import 'package:fire_behaviour_app/cffdrs/initial_spread_index.dart';
import 'package:fire_behaviour_app/cffdrs/rate_of_spread.dart';
import 'package:fire_behaviour_app/cffdrs/slope_calc.dart';
import 'package:fire_behaviour_app/cffdrs/c6_calc.dart';
import 'package:fire_behaviour_app/cffdrs/surface_fuel_consumption.dart';
import 'package:fire_behaviour_app/cffdrs/total_fuel_consumption.dart';
import 'package:test/test.dart';

import 'package:fire_behaviour_app/cffdrs/fire_behaviour_prediction.dart';

const double tolerance = 0.05;

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

double roundDouble(double value, {int places = 2}) {
  /*Hypothesis A: R has a slightly different way of doing floating point
  calculations resulting in minor differences in the output. We're unlikely
  to care about anything beyond 2 decimal places.
  Hypothesis B: There's a mistake in the translation, some detail in operation
  order or some such which is causing slightly different results.
  */
  var mod = pow(10.0, places);
  return (value * mod).roundToDouble() / mod;
}

void main() {
  group('initialSpreadIndex', () {
    test('initialSpreadIndex - 0 wind speed - fbpMod false', () {
      final result = initialSpreadIndex(88.8, 0);
      expect(roundDouble(result, places: 3), 3.606);
    });
    test('initialSpreadIndex - fbpMod true', () {
      final result = initialSpreadIndex(89.7, 24.3);
      expect(result, closeTo(13.96, tolerance));
    });
  });

  group('cfb_calc', () {
    test('CFBCalc', () {
      final result = CFBcalc('C6', 109.69520000000001, 3.4742543847234075,
          0.0006076755997436044, 7.0);
      expect(result, 0.0);
    });
    test('crownFractionBurned', () {
      double FMC = 323.1;
      double SFC = 13122;
      double ROS = 196.83;
      double CBH = 145.8;
      double CFB = 1.0;

      double CSI = criticalSurfaceIntensity(FMC, CBH);
      double RSO = surfaceFireRateOfSpread(CSI, SFC);
      final result = crownFractionBurned(ROS, RSO);
      expect(result, CFB);
    });
  });

  group('C6calc', () {
    test('C6calc', () {
      final result = C6calc('C6', 0.3454733290959275, -1.0, 109.69520000000001,
          3.4742543847234075, 7.0,
          option: "ROS");
      expect(roundDouble(result), roundDouble(0.0006076756));
    });
    test('crownFractionBurnedC6', () {
      double ISI = 10;
      double BUI = 437.4;
      double FMC = 145.8;
      double SFC = 19683;
      double CBH = 145.8;
      double ROS = 0;
      double CFB =
          1.43; // I don't know why ROS, CFB, and RSC are provided in the R test data when they aren't used.
      double RSC = 196.83;

      double RSI = intermediateSurfaceRateOfSpreadC6(ISI);
      RSC = crownRateOfSpreadC6(ISI, FMC);
      double RSS = surfaceRateOfSpreadC6(RSI, BUI);
      double CSI = criticalSurfaceIntensity(FMC, CBH);
      double RSO = surfaceFireRateOfSpread(CSI, SFC);

      final result = crownFractionBurned(RSS, RSO);
      expect(result, closeTo(0.7344, 0.01));
    });
  });

  group('buildup_effect', () {
    test('buildupEffect - Negative BUI', () {
      final result = buildupEffect('C6', -1.0);
      expect(result, 1.0);
    });
    test('buildupEffect', () {
      final result = buildupEffect('M1', 288.9);
      expect(result, closeTo(1.203, .01));
    });
  });

  group('total_fuel_consumption', () {
    test('Scenario', () {
      final result = totalFuelConsumption('C3', 200.6, 0.62, 13122, 81, 27);
      expect(result, closeTo(13246.37, 0.01));
    });
  });

  group('surface_fuel_consumption', () {
    test('Scenario', () {
      final result = surfaceFuelConsumption('M2', 91.2, 656.1, 81, 54);
      expect(result, closeTo(4.335, 0.01));
    });
  });

  group('rate_of_spread', () {
    test('Scenario', () {
      final result = rateOfSpread(
        "C6",
        182.7,
        437.4,
        218.7,
        6561,
        54,
        0,
        0,
        0,
      );
      expect(result, closeTo(35.01, 0.01));
    });
  });
  group('slope_calc', () {
    test('C6 Scenario', () {
      final slopeVals = slopeAdjustment('C6', 75.3, 437.4, 145.8, -3.142, 0,
          4.492, 437.4, 6561, 81, 27, 0, 0, 0);
      double WSV = slopeVals['WSV'];
      double RAZ = slopeVals['RAZ'];
      expect(WSV, closeTo(145.8, .01));
      expect(RAZ, closeTo(3.142, .01));
    });
    test('M2 Scenario', () {
      final slopeVals = slopeAdjustment(
          'M2', 50.7, 656.1, 0, 4.492, 162, 2.026, 0, 13122, 81, 0, 27, 0, 0);
      double WSV = slopeVals['WSV'];
      double RAZ = slopeVals['RAZ'];
      expect(WSV, closeTo(30.29, .01));
      expect(RAZ, closeTo(2.026, .01));
    });
  });
  group('fire_behaviour_prediction', () {
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
        FireBehaviourPredictionPrimary result =
            fireBehaviourPrediction(input, output: "ALL");
        expect(result.FMC, closeTo(expected.FMC, tolerance), reason: 'FMC $i');
        expect((result.SFC), closeTo(expected.SFC, tolerance),
            reason: 'SFC $i');
        expect((result.WSV), closeTo(expected.WSV, tolerance),
            reason: 'WSV $i');
        expect((result.RAZ), closeTo(expected.RAZ, tolerance),
            reason: 'RAZ $i');
        expect((result.ISI), closeTo(expected.ISI, tolerance),
            reason: 'ISI $i');
        expect((result.ROS), closeTo(expected.ROS, tolerance),
            reason: 'ROS $i');
        expect((result.CFB), closeTo(expected.CFB, tolerance),
            reason: 'CFB $i');
        expect((result.TFC), closeTo(expected.TFC, tolerance),
            reason: 'TFC $i');
        expect((result.HFI), closeTo(expected.HFI, tolerance),
            reason: 'HFI $i');
        expect(result.FD, expected.FD, reason: 'FD $i');
        expect((result.CFC), closeTo(expected.CFC, tolerance),
            reason: 'CFC $i');
        // now check the secondary outputs
        expect(result.secondary == null, expected.secondary == null,
            reason: 'secondary $i');

        FireBehaviourPredictionSecondary? resultSecondary = result.secondary;
        FireBehaviourPredictionSecondary? expectedSecondary =
            expected.secondary;

        if (resultSecondary != null && expectedSecondary != null) {
          expect(resultSecondary.SF, expectedSecondary.SF, reason: 'SF $i');
          expect(
              (resultSecondary.CSI), closeTo(expectedSecondary.CSI, tolerance),
              reason: 'CSI $i');
          expect(
              (resultSecondary.RSO), closeTo(expectedSecondary.RSO, tolerance),
              reason: 'RSO $i');
          expect(resultSecondary.BE, closeTo(expectedSecondary.BE, tolerance),
              reason: 'BE $i');
          expect((resultSecondary.LB), closeTo(expectedSecondary.LB, tolerance),
              reason: 'LB $i');
          expect(
              (resultSecondary.LBt), closeTo(expectedSecondary.LBt, tolerance),
              reason: 'LBt $i');
          expect((resultSecondary.BROS),
              closeTo(expectedSecondary.BROS, tolerance),
              reason: 'BROS $i');
          expect((resultSecondary.FROS),
              closeTo(expectedSecondary.FROS, tolerance),
              reason: 'FROS $i');
          expect((resultSecondary.TROS),
              closeTo(expectedSecondary.TROS, tolerance),
              reason: 'TROS $i');
          expect((resultSecondary.BROSt),
              closeTo(expectedSecondary.BROSt, tolerance),
              reason: 'BROSt $i');
          expect((resultSecondary.FROSt),
              closeTo(expectedSecondary.FROSt, tolerance),
              reason: 'FROSt $i');
          expect((resultSecondary.TROSt),
              closeTo(expectedSecondary.TROSt, tolerance),
              reason: 'TROSt $i');
          expect((resultSecondary.FCFB),
              closeTo(expectedSecondary.FCFB, tolerance),
              reason: 'FCFB $i');
          expect((resultSecondary.BCFB),
              closeTo(expectedSecondary.BCFB, tolerance),
              reason: 'BCFB $i');
          expect((resultSecondary.TCFB),
              closeTo(expectedSecondary.TCFB, tolerance),
              reason: 'TCFB $i');
          expect((resultSecondary.FTFC),
              closeTo(expectedSecondary.FTFC, tolerance),
              reason: 'FTFC $i');
          expect((resultSecondary.BTFC),
              closeTo(expectedSecondary.BTFC, tolerance),
              reason: 'BTFC $i');
          expect((resultSecondary.TTFC),
              closeTo(expectedSecondary.TTFC, tolerance),
              reason: 'TTFC $i');
          expect(
              (resultSecondary.FFI), closeTo(expectedSecondary.FFI, tolerance),
              reason: 'FFI $i');
          expect(
              (resultSecondary.BFI), closeTo(expectedSecondary.BFI, tolerance),
              reason: 'BFI $i');
          expect(
              (resultSecondary.TFI), closeTo(expectedSecondary.TFI, tolerance),
              reason: 'TFI $i');
          expect((resultSecondary.HROSt),
              closeTo(expectedSecondary.HROSt, tolerance),
              reason: 'HROSt $i');
          expect((resultSecondary.TI), closeTo(expectedSecondary.TI, tolerance),
              reason: 'TI $i');
          expect(
              (resultSecondary.FTI), closeTo(expectedSecondary.FTI, tolerance),
              reason: 'FTI $i');
          expect(resultSecondary.BTI, closeTo(expectedSecondary.BTI, tolerance),
              reason: 'BTI $i');
          expect(
              (resultSecondary.TTI), closeTo(expectedSecondary.TTI, tolerance),
              reason: 'TTI $i');
          expect((resultSecondary.DH), closeTo(expectedSecondary.DH, tolerance),
              reason: 'DH $i');
          expect((resultSecondary.DB), closeTo(expectedSecondary.DB, tolerance),
              reason: 'DB $i');
          expect((resultSecondary.DF), closeTo(expectedSecondary.DF, tolerance),
              reason: 'DF $i');
        }
      }
    });
  });
}
