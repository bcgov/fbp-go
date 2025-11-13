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

import 'package:fire_behaviour_app/global.dart';

import 'cffdrs/distance_at_time.dart';
import 'cffdrs/length_to_breadth_at_time.dart';
import 'cffdrs/crown_fuel_load.dart';

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
  S3,
}

class FuelTypePreset {
  final int id;
  final FuelType code;
  final String description;
  final double? cfl;
  final double? pc;
  final double? pdf;
  final double? cbh;
  final double? gfl;
  final double averageBUI;
  FuelTypePreset(
    this.id,
    this.code,
    this.description, {
    this.cfl,
    this.pc,
    this.pdf,
    this.cbh,
    this.gfl,
    required this.averageBUI,
  });

  @override
  String toString() {
    return 'FuelTypePreset{code: $code, description: $description, cfl: $cfl, pc: $pc, pdf: $pdf, cbh: $cbh, gfl: $gfl}';
  }
}

FuelTypePreset createPreset(
  int id,
  FuelType fuelType,
  String name, {
  double? pc,
  required double averageBUI,
  double? cbh,
  double? pdf,
  double? gfl,
}) {
  return FuelTypePreset(
    id,
    fuelType,
    name,
    cfl: crownFuelLoad(fuelType.name),
    pc: pc,
    cbh: cbh,
    pdf: pdf,
    gfl: gfl,
    averageBUI: averageBUI,
  );
}

FuelTypePreset getC2BorealSpruce() {
  return createPreset(
    1,
    FuelType.C2,
    'C-2 boreal spruce',
    pc: 100,
    averageBUI: 70,
  );
}

List<FuelTypePreset> getFuelTypePresets() {
  // We're only including CBH (Crown Base height) if we want specific settings for a predefined fuel type.
  // ie. C6 7m & C6 2m. If CBH is otherwise null, the CFFDRS library handles setting it correctly (see crown_base_height.dart)
  // crownFuelLoad also handles setting the CFL correctly for the fuel type
  int id = 0;
  return [
    createPreset(
      id++,
      FuelType.C1,
      'C-1 spruce-lichen woodland',
      pc: 100,
      averageBUI: 50,
    ),
    getC2BorealSpruce(),
    createPreset(
      ++id,
      FuelType.C3,
      'C-3 mature jack or lodgepole pine',
      pc: 100,
      averageBUI: 70,
    ),
    createPreset(
      ++id,
      FuelType.C4,
      'C-4 immature jack or lodgepole pine',
      pc: 100,
      averageBUI: 70,
    ),
    createPreset(
      ++id,
      FuelType.C5,
      'C-5 red and white pine',
      pc: 100,
      averageBUI: 50,
    ),
    createPreset(
      ++id,
      FuelType.C6,
      'C-6 conifer plantation',
      pc: 100,
      cbh: 2,
      averageBUI: 70,
    ),
    createPreset(
      ++id,
      FuelType.C7,
      'C-7 ponderosa pine/Douglas-fir',
      pc: 100,
      averageBUI: 100,
    ),
    createPreset(++id, FuelType.D1, 'D-1 leafless aspen', averageBUI: 35),
    // D2 is not implemented in FBPCalc.r
    // createPreset(FuelType.D2, 'D-2 green aspen',
    createPreset(
      ++id,
      FuelType.M1,
      'M-1 boreal mixedwood - leafless',
      pc: 50,
      averageBUI: 50,
    ),
    createPreset(
      ++id,
      FuelType.M2,
      'M-2 boreal mixedwood - green',
      pc: 50,
      averageBUI: 50,
    ),
    createPreset(
      ++id,
      FuelType.M3,
      'M-3 dead balsam mixedwood - leafless',
      pdf: 60,
      averageBUI: 50,
    ),
    createPreset(
      ++id,
      FuelType.M4,
      'M-4 dead balsam mixedwood - green',
      pdf: 60,
      averageBUI: 50,
    ),
    // Taking some liberties here - O1A and O1B don't  have an average
    // BUI a.f.a.i.k.
    createPreset(
      ++id,
      FuelType.O1A,
      'O-1a matted grass',
      gfl: 0.35,
      averageBUI: 50,
    ),
    createPreset(
      ++id,
      FuelType.O1B,
      'O-1b standing grass',
      gfl: 0.35,
      averageBUI: 50,
    ),
    createPreset(
      ++id,
      FuelType.S1,
      'S-1 jack or lodgepole pine slash',
      averageBUI: 35,
    ),
    createPreset(
      ++id,
      FuelType.S2,
      'S-2 white spruce/balsam slash',
      averageBUI: 70,
    ),
    createPreset(
      ++id,
      FuelType.S3,
      'S-3 coastal cedar/hemlock/Douglas-fir slash',
      averageBUI: 35,
    ),
  ];
}

double getFireSize(
  String fuelType,
  double ros,
  double bros,
  double elapsedMinutes,
  double cfb,
  double lbRatio,
) {
  /*
    Fire size based on Eq. 8 (Alexander, M.E. 1985. Estimating the
    length-to-breadth ratio of elliptical
    forest fire patterns.).

    Code adapted from from http://github.com/bcgov/wps
    */
  // Using acceleration:
  final fireSpreadDistance = distanceAtTime(
    fuelType,
    ros + bros,
    elapsedMinutes,
    cfb,
  );
  final lengthToBreadthAtTime = lengthToBreadAtTime(
    fuelType,
    lbRatio,
    elapsedMinutes,
    cfb,
  );
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

double calculateFireArea(double lengthToBreadthAtTime, double distanceAtTime) {
  return (pi / (4 * lengthToBreadthAtTime) * pow(distanceAtTime, 2)) / 10000;
}

bool isSlashFuelType(FuelType fuelType) {
  return fuelType == FuelType.S1 ||
      fuelType == FuelType.S2 ||
      fuelType == FuelType.S3;
}

bool isGrassFuelType(FuelType fuelType) {
  return fuelType == FuelType.O1A || fuelType == FuelType.O1B;
}

bool canAdjustDeadFir(FuelType fuelType) {
  return fuelType == FuelType.M3 || fuelType == FuelType.M4;
}

bool canAdjustConifer(FuelType fuelType) {
  return fuelType == FuelType.M1 || fuelType == FuelType.M2;
}

bool canAdjustCBH(FuelType fuelType) {
  return fuelType == FuelType.C6;
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

    Source: Alexander M (1982) Calculating and interpreting forest fire
    intensities. Canadian Journal of Botany 60: 349-357.

    eq. [9] I = 259.833(L)^2.174
    */
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
    "Cannot calculate fire type. Invalid Crown Fraction Burned percentage received.",
  );
}

double razToNetEffectiveWindDirection(double raz) {
  // The net effective wind direction is 180 degrees opposite from the direction of spread.
  return (raz + 180.0) % 360.0;
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
    'N',
  ];
  return values[(azimuth / 22.5).floor()];
}

int getDayOfYear(DateTime currentDate) {
  final diff = currentDate.difference(DateTime(currentDate.year, 1, 1, 0, 0));
  return diff.inDays;
}

double roundDouble(double value, int places) {
  final multiplier = pow(10, places);
  return (value * multiplier).round() / multiplier;
}

double pinValue(double value, double minValue, double maxValue) {
  if (value < minValue) {
    return minValue;
  } else if (value > maxValue) {
    return maxValue;
  }
  return value;
}

double pinGFL(double gfl) {
  return pinValue(gfl, minGFL, maxGFL);
}

double pinGS(double gs) {
  return pinValue(gs, minGS, maxGS);
}

double pinAltitude(double altitude) {
  return pinValue(altitude, minAltitude, maxAltitude);
}

double pinLongitude(double longitude) {
  return pinValue(longitude, minLongitude, maxLongitude);
}

double pinLatitude(double latitude) {
  return pinValue(latitude, minLatitude, maxLatitude);
}
