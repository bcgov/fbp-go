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

import 'be_calc.dart';
import 'cfb_calc.dart';

double C6calc(
    String FUELTYPE, double ISI, double BUI, double FMC, double SFC, double CBH,
    {double? ROS, double? CFB, double? RSC, String option = "CFB"}) {
  /**
  #############################################################################
  # Description:
  #   Calculate c6 (Conifer plantation) Fire Spread. C6 is a special case, and 
  #     thus has it's own function. To calculate C6 fire spread, this function 
  #     also calculates and can return ROS, CFB, RSC, or RSI by specifying in 
  #     the option parameter.
  #
  #   All variables names are laid out in the same manner as Forestry Canada 
  #   Fire Danger Group (FCFDG) (1992). Development and Structure of the 
  #   Canadian Forest Fire Behavior Prediction System." Technical Report 
  #   ST-X-3, Forestry Canada, Ottawa, Ontario.
  #
  # Args:
  #   FUELTYPE: The Fire Behaviour Prediction FuelType
  #   ISI:      Initial Spread Index
  #   BUI:      Buildup Index
  #   FMC:      Foliar Moisture Content
  #   SFC:      Surface Fuel Consumption
  #   CBH:      Crown Base Height
  #   ROS:      Rate of Spread
  #   CFB:      Crown Fraction Burned
  #   RSC:      Crown Fire Spread Rate (m/min)
  #   option:   Which variable to calculate(ROS, CFB, RSC, or RSI)
  #
  # Returns:
  #   ROS, CFB, RSC or RSI depending on which option was selected
  #
  #############################################################################
  */
  // #Average foliar moisture effect
  double FMEavg = 0.778;
  // #Eq. 59 (FCFDG 1992) Crown flame temperature (degrees K)
  // this calculation is done in the original R code, but the variable isn't
  // used anywhere.
  // double tt = 1500 - 2.75 * FMC;
  // #Eq. 60 (FCFDG 1992) Head of ignition (kJ/kg)
  // this calculation is done in the original R code, but the variable isn't
  // used anywhere.
  // double H = 460 + 25.9 * FMC;
  // #Eq. 61 (FCFDG 1992) Average foliar moisture effect
  double FME = pow((1.5 - 0.00275 * FMC), 4.0) / (460 + 25.9 * FMC) * 1000;
  // #Eq. 62 (FCFDG 1992) Intermediate surface fire spread rate
  double RSI = 30.0 * pow((1 - exp(-0.08 * ISI)), 3.0);
  // #Return at this point, if specified by caller
  if (option == "RSI") {
    return (RSI);
  }
  // #Eq. 63 (FCFDG 1992) Surface fire spread rate (m/min)
  double RSS = RSI * BEcalc(FUELTYPE, BUI);
  // #Eq. 64 (FCFDG 1992) Crown fire spread rate (m/min)
  RSC = 60 * (1 - exp(-0.0497 * ISI)) * FME / FMEavg;
  // #Return at this point, if specified by caller
  if (option == "RSC") {
    return (RSC);
  }
  // #Crown Fraction Burned
  double CFB = RSC > RSS ? CFBcalc(FUELTYPE, FMC, SFC, RSS, CBH) : 0;
  // #Return at this point, if specified by caller
  if (option == "CFB") {
    return (CFB);
  }
  // #Eq. 65 (FCFDG 1992) Calculate Rate of spread (m/min)
  ROS = RSC > RSS ? RSS + (CFB) * (RSC - RSS) : RSS;
  return (ROS);
}
