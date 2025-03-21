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

double criticalSurfaceIntensity(double FMC, double CBH) {
  // Eq. 56 (FCFDG 1992) Critical surface intensity
  return 0.001 * pow(CBH, 1.5) * pow(460 + 25.9 * FMC, 1.5);
}

double surfaceFireRateOfSpread(double CSI, double SFC) {
  // Eq. 57 (FCFDG 1992) Surface fire rate of spread (m/min)
  // if (SFC == 0) {
  //   return 0;
  // }
  return CSI / (300 * SFC);
}

double crownFractionBurned(double ROS, double RSO) {
  // Eq. 58 (FCFDG 1992) Crown fraction burned
  return ROS > RSO ? 1 - exp(-0.23 * (ROS - RSO)) : 0;
}

/// Calculates Crown Fraction Burned (CFB).
///
/// To calculate CFB, we also need to compute:
/// - Critical Surface Intensity (CSI)
/// - Surface Fire Rate of Spread (RSO)
///
/// This function avoids unnecessary recalculations by returning the requested
/// variable based on the `option` parameter.
///
/// The variable names and equations follow the Forestry Canada Fire
/// Danger Group (FCFDG) (1992).
///
/// Reference:
/// [Development and Structure of the Canadian Forest Fire Behavior Prediction System](https://cfs.nrcan.gc.ca/publications/download-pdf/10068)
///
/// #### Parameters:
/// - [fuelType] The Fire Behaviour Prediction Fuel Type.
/// - [FMC] Foliar Moisture Content.
/// - [SFC] Surface Fuel Consumption.
/// - [CBH] Crown Base Height.
/// - [ROS] Rate of Spread.
/// - [option] Which variable to calculate: `"CSI"`, `"RSO"`, or `"CFB"` (default).
///
/// #### Returns:
/// - Returns `CFB`, `CSI`, or `RSO` based on the selected option.
double CFBcalc(String FUELTYPE, double FMC, double SFC, double ROS, double CBH,
    {option = "CFB"}) {
  double CSI = criticalSurfaceIntensity(FMC, CBH);

  // Return CSI if requested
  if (option == "CSI") {
    developer.log("Deprecated: Use criticalSurfaceIntensity instead.");
    return CSI;
  }

  double RSO = surfaceFireRateOfSpread(CSI, SFC);

  // Return RSO if requested
  if (option == "RSO") {
    developer.log("Deprecated: Use surfaceFireRateOfSpread instead.");
    return RSO;
  }

  double CFB = crownFractionBurned(ROS, RSO);
  developer.log("Deprecated: Use crownFractionBurned instead.");
  return CFB;
}
