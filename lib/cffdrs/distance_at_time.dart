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

double distanceAtTime(String FUELTYPE, double ROSeq, double HR, double CFB) {
  /*
  #############################################################################
  # Description:
  #   Calculate the Head fire spread distance at time t. In the documentation
  #   this variable is just "D".
  #
  #   All variables names are laid out in the same manner as Forestry Canada 
  #   Fire Danger Group (FCFDG) (1992). Development and Structure of the 
  #   Canadian Forest Fire Behavior Prediction System." Technical Report 
  #   ST-X-3, Forestry Canada, Ottawa, Ontario.
  #
  # Args:
  #   FUELTYPE: The Fire Behaviour Prediction FuelType
  #   ROSeq:    The predicted equilibrium rate of spread (m/min)
  #   HR (t):   The elapsed time (min)
  #   CFB:      Crown Fraction Burned
  #   
  # Returns:
  #   DISTt:    Head fire spread distance at time t
  #
  #############################################################################
  */
  // #Eq. 72 (FCFDG 1992)
  // #Calculate the alpha constant for the DISTt calculation
  final alpha =
      (["C1", "O1A", "O1B", "S1", "S2", "S3", "D1"].contains(FUELTYPE))
          ? 0.115
          : 0.115 - 18.8 * pow(CFB, 2.5) * exp(-8 * CFB);
  // #Eq. 71 (FCFDG 1992) Calculate Head fire spread distance
  return ROSeq * (HR + exp(-alpha * HR) / alpha - 1 / alpha);
}
