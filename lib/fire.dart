/*
Copyright 2021, 2022 Province of British Columbia

This file is part of FBP Go.

FBP Go is free software: you can redistribute it and/or modify it under the
terms of the GNU General Public License as published by the Free Software
Foundation, either version 3 of the License, or (at your option) any later
version.

FBP Go is distributed in the hope that it will be useful, but WITHOUT ANY
WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
A PARTICULAR PURPOSE. See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with 
FBP Go. If not, see <https://www.gnu.org/licenses/>.
*/
import 'dart:math';

import 'cffdrs/dist_calc.dart';
import 'cffdrs/lb_t_calc.dart';

enum FuelType {
  // ignore: constant_identifier_names
  C1,
  // ignore: constant_identifier_names
  C2,
  // ignore: constant_identifier_names
  C3,
  // ignore: constant_identifier_names
  C4,
  // ignore: constant_identifier_names
  C5,
  // ignore: constant_identifier_names
  C6,
  // ignore: constant_identifier_names
  C7,
  // ignore: constant_identifier_names
  D1,
  // ignore: constant_identifier_names
  D2,
  // ignore: constant_identifier_names
  M1,
  // ignore: constant_identifier_names
  M2,
  // ignore: constant_identifier_names
  M3,
  // ignore: constant_identifier_names
  M4,
  // ignore: constant_identifier_names
  O1A,
  // ignore: constant_identifier_names
  O1B,
  // ignore: constant_identifier_names
  S1,
  // ignore: constant_identifier_names
  S2,
  // ignore: constant_identifier_names
  S3
}

class FuelTypePreset {
  final FuelType code;
  final String description;
  final double cfl;
  final double? pc;
  final double? pdf;
  final double? cbh;
  final double? gfl;
  final double averageBUI;
  FuelTypePreset(this.code, this.description,
      {required this.cfl,
      this.pc,
      this.pdf,
      this.cbh,
      this.gfl,
      required this.averageBUI});

  @override
  String toString() {
    return 'FuelTypePreset{code: $code, description: $description, cfl: $cfl, pc: $pc, pdf: $pdf, cbh: $cbh, gfl: $gfl}';
  }
}

FuelTypePreset getC2BorealSpruce() {
  return FuelTypePreset(FuelType.C2, 'C-2 boreal spruce',
      cfl: 0.8, pc: 100, cbh: 3, averageBUI: 70);
}

List<FuelTypePreset> getFuelTypePresets() {
  return [
    FuelTypePreset(FuelType.C1, 'C-1 spruce-lichen woodland',
        cfl: 0.75, pc: 100, cbh: 2, averageBUI: 50),
    getC2BorealSpruce(),
    FuelTypePreset(FuelType.C3, 'C-3 mature jack or lodgepole pine',
        cfl: 1.15, pc: 100, cbh: 3, averageBUI: 70),
    FuelTypePreset(FuelType.C4, 'C-4 immature jack or lodgepole pine',
        cfl: 1.2, pc: 100, cbh: 4, averageBUI: 70),
    FuelTypePreset(FuelType.C5, 'C-5 red and white pine',
        cfl: 1.2, pc: 100, cbh: 18, averageBUI: 50),
    FuelTypePreset(FuelType.C6, 'C-6 conifer plantation, 7-m CBH',
        cfl: 1.8, pc: 100, cbh: 7, averageBUI: 70),
    FuelTypePreset(FuelType.C6, 'C-6 conifer plantation, 2-m CBH',
        cfl: 1.8, pc: 100, cbh: 7, averageBUI: 70),
    FuelTypePreset(FuelType.C7, 'C-7 ponderosa pine/Douglas-far',
        cfl: 0.5, pc: 100, cbh: 10, averageBUI: 100),
    FuelTypePreset(FuelType.D1, 'D-1 leafless aspen', cfl: 1.0, averageBUI: 35),
    // D2 is not implemented in FBPCalc.r
    // FuelTypePreset(FuelType.D2, 'D-2 green aspen', cfl: 1.0),
    FuelTypePreset(FuelType.M1, 'M-1 boreal mixed-leafless, 75% conifer',
        cfl: 0.8, pc: 75, cbh: 6, averageBUI: 50),
    FuelTypePreset(FuelType.M1, 'M-1 boreal mixed-leafless, 50% conifer',
        cfl: 0.8, pc: 50, cbh: 6, averageBUI: 50),
    FuelTypePreset(FuelType.M1, 'M-1 boreal mixed-leafless, 25% conifer',
        cfl: 0.8, pc: 25, cbh: 6, averageBUI: 50),
    FuelTypePreset(FuelType.M2, 'M-2 boreal mixed-green, 75% conifer',
        cfl: 0.8, pc: 75, cbh: 6, averageBUI: 50),
    FuelTypePreset(FuelType.M2, 'M-2 boreal mixed-green, 50% conifer',
        cfl: 0.8, pc: 50, cbh: 6, averageBUI: 50),
    FuelTypePreset(FuelType.M2, 'M-2 boreal mixed-green, 25% conifer',
        cfl: 0.8, pc: 25, cbh: 6, averageBUI: 50),
    FuelTypePreset(FuelType.M3, 'M-3 dead balsam mixed-leafless, 30% dead fir',
        cfl: 0.8, pdf: 30, cbh: 6, averageBUI: 50),
    FuelTypePreset(FuelType.M3, 'M-3 dead balsam mixed-leafless, 60% dead fir',
        cfl: 0.8, pdf: 60, cbh: 6, averageBUI: 50),
    FuelTypePreset(FuelType.M3, 'M-3 dead balsam mixed-leafless, 100% dead fir',
        cfl: 0.8, pdf: 100, cbh: 6, averageBUI: 50),
    FuelTypePreset(FuelType.M4, 'M-4 dead balsam mixed-green, 30% dead fir',
        cfl: 0.8, pdf: 30, cbh: 6, averageBUI: 50),
    FuelTypePreset(FuelType.M4, 'M-4 dead balsam mixed-green, 60% dead fir',
        cfl: 0.8, pdf: 60, cbh: 6, averageBUI: 50),
    FuelTypePreset(FuelType.M4, 'M-4 dead balsam mixed-green, 100% dead fir',
        cfl: 0.8, pdf: 100, cbh: 6, averageBUI: 50),
    // Taking some liberties here - O1A and O1B don't  have an average
    // BUI a.f.a.i.k.
    FuelTypePreset(FuelType.O1A, 'O-1a matted grass',
        cfl: 0.0, gfl: 0.35, averageBUI: 50),
    FuelTypePreset(FuelType.O1B, 'O-1b standing grass',
        cfl: 0.0, gfl: 0.35, averageBUI: 50),
    FuelTypePreset(FuelType.S1, 'S-1 jack or lodgepole pine slash',
        cfl: 0.0, averageBUI: 35),
    FuelTypePreset(FuelType.S2, 'S-2 white spruce/balsam slash',
        cfl: 0.0, averageBUI: 70),
    FuelTypePreset(FuelType.S3, 'S-3 coastal cedar/hemlock/Douglas-fir slash',
        cfl: 0.0, averageBUI: 35),
  ];
}

double getFireSize(String fuelType, double ros, double bros,
    double elapsedMinutes, double cfb, double lbRatio) {
  /*
    Fire size based on Eq. 8 (Alexander, M.E. 1985. Estimating the
    length-to-breadth ratio of elliptical
    forest fire patterns.).

    Code adapted from from http://github.com/bcgov/wps
    */
  // Using acceleration:
  final fireSpreadDistance =
      DISTtcalc(fuelType, ros + bros, elapsedMinutes, cfb);
  final lengthToBreadthAtTime = LBtcalc(fuelType, lbRatio, elapsedMinutes, cfb);
  // Not using acceleration:
  // fros = cffdrs.flank_rate_of_spread(ros, bros, lb_ratio)
  // # Flank Fire Spread Distance a.k.a. DF in R/FBPcalc.r
  // flank_fire_spread_distance = (ros + bros) / (2.0 * fros)
  // length_to_breadth_at_time = flank_fire_spread_distance
  // fire_spread_distance = (ros + bros) * elapsed_minutes

  // Essentially using Eq. 8 (Alexander, M.E. 1985. Estimating the
  // length-to-breadth ratio of elliptical forest fire patterns.) - but
  // feeding it L/B and ROS from CFFDRS.
  return pi /
      (4.0 * lengthToBreadthAtTime) *
      pow(fireSpreadDistance, 2.0) /
      10000.0;
}

int getHeadFireIntensityClass(double headFireIntensity) {
  /** Return Intensity class as defined in Appendix 7. pg 99 of the Field Guide
   * To The Canadian Forest Fire Behaviour Prediction (FBP) System. 3rd Edition,
   * S.W. Taylor and M.E. Alexander.
   */
  if (headFireIntensity < 10) {
    return 1;
  } else if (headFireIntensity < 500) {
    return 2;
  } else if (headFireIntensity < 2000) {
    return 3;
  } else if (headFireIntensity < 4000) {
    return 4;
  } else if (headFireIntensity < 10000) {
    return 5;
  }
  return 6;
}

// ignore: non_constant_identifier_names
String getFireDescription(String FD) {
  switch (FD) {
    case ("I"):
      return "Intermittent Crowning";
    case ("C"):
      return "Continuous Crowning";
    case ("S"):
      return "Surface";
    default:
      throw Exception("Invalid Fire Description $FD");
  }
}

num calculateApproxFlameLength(double headFireIntensity) {
  /*
    Returns an approximation of flame length (in meters).
    Formula used is a field-use approximation of
    L = (I / 300)^(1/2), where L is flame length in m and I is Fire Intensity
    in kW/m

    Source: Alexander M (1982) Calculating and interpreting forest fire
    intensities. Canadian Journal of Botany 60: 349-357.
    */
  // return sqrt(headFireIntensity / 300.0);
  return pow(headFireIntensity / 259.833, 1 / 2.174);
}

String getFireType(String fuelType, double crownFractionBurned) {
  /*
    Returns Fire Type (as String) based on percentage Crown Fraction Burned
    (CFB). These definitions come from the Red Book (p.69).
    Abbreviations for fire types have been taken from the red book (p.9).

    CROWN FRACTION BURNED           TYPE OF FIRE                ABBREV.
    < 10%                           Surface fire                SUR
    10-89%                          Intermittent crown fire     IC
    > 90%                           Continuous crown fire       CC

    Code adapted from from http://github.com/bcgov/wps
    */
  if (["D1", "O1A", "O1B", "S1", "S2", "S3"].contains(fuelType)) {
    // From red book "crown fires are not expected in deciduous fuel types but
    // high intensity surface fires can occur.
    return "Surface fire";
  }
  // crown fraction burnt is a floating point number from 0 to 1 inclusive.
  else if (crownFractionBurned < 0.1) {
    return "Surface fire";
  } else if (crownFractionBurned < 0.9) {
    return "Intermittent crown fire";
  } else if (crownFractionBurned >= 0.9) {
    return "Continuous crown fire";
  }
  throw Exception(
      "Cannot calculate fire type. Invalid Crown Fraction Burned percentage received.");
}

String degreesToCompassPoint(double azimuth) {
  /** Given an aspect (degree 0 to 360), return compass point.
   * e.g. 0 degrees is North, 90 is East, 180 is South, 270 is West.
   */
  final values = [
    'N',
    'NNE',
    'NE',
    'ENE',
    'E',
    'ESE',
    'SE',
    'SSE',
    'S',
    'SSW',
    'SW',
    'WSW',
    'W',
    'WNW',
    'NW',
    'NNW',
    'N'
  ];
  return values[(azimuth / 22.5).floor()];
}

int getDayOfYear() {
  final now = DateTime.now();
  final diff = now.difference(DateTime(now.year, 1, 1, 0, 0));
  return diff.inDays;
}

double roundDouble(double value, int places) {
  final multiplier = pow(10, places);
  return (value * multiplier).round() / multiplier;
}
