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

double BEcalc(String fuelType, double BUI) {
  /**
  #############################################################################
  # Description:
  #   Computes the Buildup Effect on Fire Spread Rate. 
  #
  #   All variables names are laid out in the same manner as Forestry Canada 
  #   Fire Danger Group (FCFDG) (1992). Development and Structure of the 
  #   Canadian Forest Fire Behavior Prediction System." Technical Report 
  #   ST-X-3, Forestry Canada, Ottawa, Ontario.
  #
  # Args:
  #   FUELTYPE: The Fire Behaviour Prediction FuelType
  #   BUI:      The Buildup Index value
  # Returns:
  #   BE: The Buildup Effect
  #
  #############################################################################
  */
  // #Fuel Type String represenations
  var d = [
    "C1",
    "C2",
    "C3",
    "C4",
    "C5",
    "C6",
    "C7",
    "D1",
    "M1",
    "M2",
    "M3",
    "M4",
    "S1",
    "S2",
    "S3",
    "O1A",
    "O1B"
  ];
  // #The average BUI for the fuel type - as referenced by the "d" list above
  var BUIo = <double>[
    72,
    64,
    62,
    66,
    56,
    62,
    106,
    32,
    50,
    50,
    50,
    50,
    38,
    63,
    31,
    01,
    01
  ];
  // #Proportion of maximum possible spread rate that is reached at a standard BUI
  var Q = <double>[
    0.9,
    0.7,
    0.75,
    0.8,
    0.8,
    0.8,
    0.85,
    0.9,
    0.8,
    0.8,
    0.8,
    0.8,
    0.75,
    0.75,
    0.75,
    1.0,
    1.0
  ];

  final int FUELTYPE = d.indexOf(fuelType);

  // #Eq. 54 (FCFDG 1992) The Buildup Effect
  return (BUI > 0 && BUIo[FUELTYPE] > 0)
      ? exp(50 * log(Q[FUELTYPE]) * (1 / BUI - 1 / BUIo[FUELTYPE]))
      : 1;
}
