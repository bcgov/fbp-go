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
