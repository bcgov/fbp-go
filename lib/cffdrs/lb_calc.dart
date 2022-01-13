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

double LBcalc(String FUELTYPE, double WSV) {
  /*
  #############################################################################
  # Description:
  #   Computes the Length to Breadth ratio of an elliptically shaped fire. 
  #   Equations are from listed FCFDG (1992) except for errata 80 from 
  #   Wotton et. al. (2009).
  #
  #   All variables names are laid out in the same manner as Forestry Canada 
  #   Fire Danger Group (FCFDG) (1992). Development and Structure of the 
  #   Canadian Forest Fire Behavior Prediction System." Technical Report 
  #   ST-X-3, Forestry Canada, Ottawa, Ontario.
  #
  #   Wotton, B.M., Alexander, M.E., Taylor, S.W. 2009. Updates and revisions to
  #   the 1992 Canadian forest fire behavior prediction system. Nat. Resour. 
  #   Can., Can. For. Serv., Great Lakes For. Cent., Sault Ste. Marie, Ontario, 
  #   Canada. Information Report GLC-X-10, 45p.
  #
  # Args:
  #   FUELTYPE: The Fire Behaviour Prediction FuelType
  #        WSV: The Wind Speed (km/h)
  # Returns:
  #   LB: Length to Breadth ratio
  #
  #############################################################################
  */
  // #calculation is depending on if fuel type is grass (O1) or other fueltype
  if (["O1A", "O1B"].contains(FUELTYPE)) {
    // #Correction to orginal Equation 80 is made here
    // #Eq. 80a / 80b from Wotton 2009
    return WSV >= 1.0 ? 1.1 * pow(WSV, 0.464) : 1.0; // #Eq. 80/81
  } else {
    return 1.0 + 8.729 * pow((1 - exp(-0.030 * WSV)), (2.155)); // #Eq. 79
  }
}
