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

double LBtcalc(String FUELTYPE, double LB, double HR, double CFB) {
  /*
  #############################################################################
  # Description:
  #   Computes the Length to Breadth ratio of an elliptically shaped fire at
  #   elapsed time since ignition. Equations are from listed FCFDG (1992) and
  #   Wotton et. al. (2009), and are marked as such.
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
  #         LB: Length to Breadth ratio
  #         HR: Time since ignition (hours)
  #        CFB: Crown Fraction Burned
  # Returns:
  #   LBt: Length to Breadth ratio at time since ignition
  #
  #############################################################################
  */
  // #Eq. 72 (FCFDG 1992) - alpha constant value, dependent on fuel type
  final alpha = ["C1", "O1A", "O1B", "S1", "S2", "S3", "D1"].contains(FUELTYPE)
      ? 0.115
      : 0.115 - 18.8 * pow(CFB, 2.5) * exp(-8 * CFB);
  // #Eq. 81 (Wotton et.al. 2009) - LB at time since ignition
  return (LB - 1) * (1 - exp(-alpha * HR)) + 1;
}
