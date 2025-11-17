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
