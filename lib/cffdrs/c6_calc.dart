/*
Copyright 2021, 2022 Province of British Columbia.

This file is part of FBP Go.

The code contained in this file was copied from the CRAN R package CFFDRS
(Wang X, Wotton B M, Cantin A, Parisien M-A, Anderson K, Moore B and
Flannigan M D (2017).
cffdrs: An R package for the Canadian Forest Fire Danger Rating System.
Ecological Processes, 6(1), 5.
URL
https://ecologicalprocesses.springeropen.com/articles/10.1186/s13717-017-0070-z)
and translated into dart for FBP Go.

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

// ignore_for_file: non_constant_identifier_names

import 'dart:math';
import 'dart:developer' as developer;

import 'buildup_effect.dart';
import 'cfb_calc.dart';

/// Eq. 62 (FCFDG 1992) - Intermediate surface fire spread rate
double intermediateSurfaceRateOfSpreadC6(double ISI) {
  return 30 * pow(1 - exp(-0.08 * ISI), 3).toDouble();
}

/// Eq. 63 (FCFDG 1992) - Surface fire spread rate (m/min)
double surfaceRateOfSpreadC6(double RSI, double BUI) {
  return RSI * buildupEffect("C6", BUI);
}

/// Eq. 64 (FCFDG 1992) - Crown fire spread rate (m/min)
double crownRateOfSpreadC6(double ISI, double FMC) {
  double FMEavg = 0.778;
  double tt = 1500 -
      2.75 * FMC; // Eq. 59 (FCFDG 1992) Crown flame temperature (degrees K)
  double H = 460 + 25.9 * FMC; // Eq. 60 (FCFDG 1992) Head of ignition (kJ/kg)
  double FME = (pow((1.5 - 0.00275 * FMC), 4) / (460 + 25.9 * FMC)) *
      1000; // Eq. 61 (FCFDG 1992) Average foliar moisture effect
// Eq. 64 (FCFDG 1992) Crown fire spread rate (m/min)
  return 60 * (1 - exp(-0.0497 * ISI)) * FME / FMEavg;
}

/// Crown fraction burned
double crownFractionBurnedC6(double RSC, double RSS, double RSO) {
  return (RSC > RSS && RSS > RSO) ? crownFractionBurned(RSS, RSO) : 0;
}

/// Eq. 65 (FCFDG 1992) - Calculate Rate of Spread (m/min)
double rateOfSpreadC6(double RSC, double RSS, double CFB) {
  return (RSC > RSS) ? RSS + (CFB * (RSC - RSS)) : RSS;
}

/// Calculates fire rate parameters for a given fuel type (C6).
///
/// The function can return one of several values based on the `option` parameter:
/// - `RSI` for Intermediate Surface Rate of Spread
/// - `RSC` for Crown Rate of Spread
/// - `CFB` for Crown Fraction Burned
/// - `ROS` for Rate of Spread
///
/// The default value is `CFB`.
///
/// Parameters:
/// - [fuelType] The Fire Behaviour Prediction Fuel Type (assumed to be "C6").
/// - [ISI] Initial Spread Index, which is used to calculate various fire spread parameters.
/// - [BUI] Buildup Index, which is used for surface fire rate of spread calculation.
/// - [FMC] Foliar Moisture Content, which affects several calculations such as crown fire spread rate.
/// - [SFC] Surface Fuel Consumption, used to calculate the surface fire rate of spread.
/// - [CBH] Crown Base Height, used to calculate the critical surface intensity.
/// - [ROS] Rate of Spread, which is the final result returned when using the `ROS` option.
/// - [CFB] Crown Fraction Burned, calculated based on fire rate parameters.
/// - [RSC] Crown Fire Spread Rate (m/min), used to calculate crown fraction burned and other parameters.
/// - [option] A string that determines which variable to calculate:
///     - `"RSI"`: Intermediate Surface Rate of Spread (returns RSI)
///     - `"RSC"`: Crown Rate of Spread (returns RSC)
///     - `"CFB"`: Crown Fraction Burned (returns CFB)
///     - `"ROS"`: Rate of Spread (returns ROS)
///
/// Returns:
/// - Returns the value of `RSI`, `RSC`, `CFB`, or `ROS` based on the `option` provided.
double C6calc(
    String fuelType, double ISI, double BUI, double FMC, double SFC, double CBH,
    {double? ROS, double? CFB, double? RSC, String option = "CFB"}) {
  // Ensure that the fuelType is "C6" as expected in the original function
  if (fuelType != "C6") {
    throw ArgumentError("The fuel type must be 'C6'.");
  }

  // feels like this should make sense, but fails when called from fbp() and not all C6
  // Intermediate Surface Rate of Spread
  double RSI = intermediateSurfaceRateOfSpreadC6(ISI);

  // Return RSI if requested
  if (option == "RSI") {
    developer.log("Deprecated: Use intermediateSurfaceRateOfSpreadC6 instead.",
        name: "c6Calc");
    return RSI;
  }

  // Crown Rate of Spread
  RSC = crownRateOfSpreadC6(ISI, FMC);

  // Return RSC if requested
  if (option == "RSC") {
    developer.log("Deprecated: Use crownRateOfSpreadC6 instead.",
        name: "c6Calc");
    return RSC;
  }

  // Surface Fire Rate of Spread (RSS)
  double RSS = surfaceRateOfSpreadC6(RSI, BUI);
  // Critical Surface Intensity (CSI)
  double CSI = criticalSurfaceIntensity(FMC, CBH);
  // Surface Fire Rate of Spread (RSO)
  double RSO = surfaceFireRateOfSpread(CSI, SFC);

  // Crown Fraction Burned (CFB)
  CFB = crownFractionBurnedC6(RSC, RSS, RSO);

  // Return CFB if requested
  if (option == "CFB") {
    developer.log("Deprecated: Use crownFractionBurnedC6 instead.",
        name: "c6Calc");
    return CFB;
  }

  // Rate of Spread (ROS)
  ROS = rateOfSpreadC6(RSC, RSS, CFB);
  developer.log("Deprecated: Use rateOfSpreadC6 instead.", name: "c6Calc");
  return ROS;
}
