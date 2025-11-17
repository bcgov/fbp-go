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
import 'fine_fuel_moisture_code.dart';

double initialSpreadIndex(double ffmc, double ws, {bool fbpMod = false}) {
  /*
  #############################################################################
  # Description:
  #   Computes the Initial Spread Index From the FWI System. Equations are from
  #   Van Wagner (1985) as listed below, except for the modification for fbp
  #   takene from FCFDG (1992).
  
  #   Equations and FORTRAN program for the Canadian Forest Fire 
  #   Weather Index System. 1985. Van Wagner, C.E.; Pickett, T.L. 
  #   Canadian Forestry Service, Petawawa National Forestry 
  #   Institute, Chalk River, Ontario. Forestry Technical Report 33. 
  #   18 p.
  #
  #   Forestry Canada  Fire Danger Group (FCFDG) (1992). Development and 
  #   Structure of the Canadian Forest Fire Behavior Prediction System."  
  #   Technical ReportST-X-3, Forestry Canada, Ottawa, Ontario.
  #
  # Args:
  #   ffmc:   Fine Fuel Moisture Code
  #     ws:   Wind Speed (km/h)
  # fbpMod:   TRUE/FALSE if using the fbp modification at the extreme end
  #
  # Returns:
  #   ISI:    Intial Spread Index
  #
  #############################################################################
  */
  // #Eq. 10 - Moisture content
  double fm = FFMC_COEFFICIENT * (101 - ffmc) / (59.5 + ffmc);
  // #Eq. 24 - Wind Effect
  // #the ifelse, also takes care of the ISI modification for the fbp functions
  // # This modification is Equation 53a in FCFDG (1992)
  double fW = ws >= 40 && fbpMod == true
      ? 12 * (1 - exp(-0.0818 * (ws - 28)))
      : exp(0.05039 * ws);
  // #Eq. 25 - Fine Fuel Moisture
  double fF = 91.9 * exp(-0.1386 * fm) * (1 + (pow(fm, 5.31)) / 49300000);
  // #Eq. 26 - Spread Index Equation
  return 0.208 * fW * fF;
}
