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
// ignore_for_file: non_constant_identifier_names, constant_identifier_names

import 'dart:math';

import 'package:fire_behaviour_app/cffdrs/cfb_calc.dart';

import 'c6_calc.dart';
import 'buildup_effect.dart';

Map<String, dynamic> rateOfSpreadExtended(
    String fuelType,
    double ISI,
    double BUI,
    double FMC,
    double SFC,
    double? PC,
    double? PDF,
    double? CC,
    double? CBH) {
  /**
  #############################################################################
  # Description:
  #   Computes the Rate of Spread prediction based on fuel type and FWI
  #   conditions. Equations are from listed FCFDG (1992) and Wotton et. al. 
  #   (2009), and are marked as such.
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
  #        ISI: Intiial Spread Index
  #        BUI: Buildup Index
  #        FMC: Foliar Moisture Content
  #        SFC: Surface Fuel Consumption (kg/m^2)
  #         PC: Percent Conifer (%)
  #        PDF: Percent Dead Balsam Fir (%)
  #         CC: Constant
  #        CBH: Crown to base height(m)
  # Returns:
  #   ROS: Rate of spread (m/min)
  #
  #############################################################################
   */
  // #Set up some data vectors
  const double NoBUI = -1;
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
  var a = <double>[
    90,
    110,
    110,
    110,
    30,
    30,
    45,
    30,
    0,
    0,
    120,
    100,
    75,
    40,
    55,
    190,
    250
  ];
  var b = <double>[
    0.0649,
    0.0282,
    0.0444,
    0.0293,
    0.0697,
    0.0800,
    0.0305,
    0.0232,
    0,
    0,
    0.0572,
    0.0404,
    0.0297,
    0.0438,
    0.0829,
    0.0310,
    0.0350
  ];
  var c0 = <double>[
    4.5,
    1.5,
    3.0,
    1.5,
    4.0,
    3.0,
    2.0,
    1.6,
    0,
    0,
    1.4,
    1.48,
    1.3,
    1.7,
    3.2,
    1.4,
    1.7
  ];

  final int FUELTYPE = d.indexOf(fuelType);

  final Map<String, dynamic> rosValues = {};

  // #Calculate RSI (set up data vectors first)
  // #Eq. 26 (FCFDG 1992) - Initial Rate of Spread for Conifer and Slash types
  double RSI = -1;
  if (["C1", "C2", "C3", "C4", "C5", "C7", "D1", "S1", "S2", "S3"]
      .contains(fuelType)) {
    RSI = a[FUELTYPE] * pow((1 - exp(-b[FUELTYPE] * ISI)), c0[FUELTYPE]);
  }
  // #Eq. 27 (FCFDG 1992) - Initial Rate of Spread for M1 Mixedwood type
  else if (fuelType == "M1") {
    if (PC == null) {
      throw Exception("PC is required for M1 fuel type");
    }
    RSI =
        PC / 100 * rateOfSpread("C2", ISI, NoBUI, FMC, SFC, PC, PDF, CC, CBH) +
            (100 - PC) /
                100 *
                rateOfSpread("D1", ISI, NoBUI, FMC, SFC, PC, PDF, CC, CBH);
  }
  // #Eq. 27 (FCFDG 1992) - Initial Rate of Spread for M2 Mixedwood type
  else if (fuelType == 'M2') {
    if (PC == null) {
      throw Exception("PC is required for M2 fuel type");
    }
    RSI =
        PC / 100 * rateOfSpread("C2", ISI, NoBUI, FMC, SFC, PC, PDF, CC, CBH) +
            0.2 *
                (100 - PC) /
                100 *
                rateOfSpread("D1", ISI, NoBUI, FMC, SFC, PC, PDF, CC, CBH);
  }
  // #Initial Rate of Spread for M3 Mixedwood
  else if (fuelType == 'M3') {
    if (PDF == null) {
      throw Exception("PDF is null");
    }
    // #Eq. 30 (Wotton et. al 2009)
    double RSI_m3 =
        a[FUELTYPE] * (pow((1 - exp(-b[FUELTYPE] * ISI)), c0[FUELTYPE]));
    // #Eq. 29 (Wotton et. al 2009)
    RSI = PDF / 100 * RSI_m3 +
        (1 - PDF / 100) *
            rateOfSpread("D1", ISI, NoBUI, FMC, SFC, PC, PDF, CC, CBH);
  }
  // #Initial Rate of Spread for M4 Mixedwood
  else if (fuelType == 'M4') {
    if (PDF == null) {
      throw Exception("PDF is null");
    }
    // #Eq. 30 (Wotton et. al 2009)
    double RSI_m4 =
        a[FUELTYPE] * (pow((1 - exp(-b[FUELTYPE] * ISI)), c0[FUELTYPE]));
    // #Eq. 33 (Wotton et. al 2009)
    RSI = PDF / 100 * RSI_m4 +
        0.2 *
            (1 - PDF / 100) *
            rateOfSpread("D1", ISI, NoBUI, FMC, SFC, PC, PDF, CC, CBH);
  } else if (["O1A", "O1B"].contains(fuelType)) {
    if (CC == null) {
      throw Exception("CC is null");
    }
    // #Eq. 35b (Wotton et. al. 2009) - Calculate Curing function for grass
    double CF =
        CC < 58.8 ? 0.005 * (exp(0.061 * CC) - 1) : 0.176 + 0.02 * (CC - 58.8);
    // #Eq. 36 (FCFDG 1992) - Calculate Initial Rate of Spread for Grass
    RSI = a[FUELTYPE] * (pow((1 - exp(-b[FUELTYPE] * ISI)), c0[FUELTYPE])) * CF;
  }

  // Calculate Critical Surface Intensity
  double CSI = criticalSurfaceIntensity(FMC, CBH!);
  // Calculate Surface fire rate of spread (m/min)
  double RSO = surfaceFireRateOfSpread(CSI, SFC);
  double ROS;

  // #Calculate C6 separately because ROS depends on CFB (opposite of other fuels)
  RSI = fuelType == 'C6' ? intermediateSurfaceRateOfSpreadC6(ISI) : RSI;
  final RSC = fuelType == "C6" ? crownRateOfSpreadC6(ISI, FMC) : null;

  // HACK: need ROS first for non-C6 this is RSS for C6 and ROS otherwise
  final RSS = fuelType == "C6"
      ? surfaceRateOfSpreadC6(RSI, BUI)
      : buildupEffect(fuelType, BUI) * RSI;

  // Calculate Crown Fraction Burned (CFB), C6 has different calculations
  final CFB = fuelType == "C6"
      ? crownFractionBurnedC6(RSC!, RSS, RSO)
      : crownFractionBurned(RSS, RSO);
  ROS = fuelType == "C6" ? rateOfSpreadC6(RSC!, RSS, CFB) : RSS;

  // #add a constraint
  ROS = ROS <= 0 ? 0.000001 : ROS;

  rosValues['ROS'] = ROS;
  rosValues['CFB'] = CFB;
  rosValues['CSI'] = CSI;
  rosValues['RSO'] = RSO;

  return rosValues;
}

double rateOfSpread(String fuelType, double ISI, double BUI, double FMC,
    double SFC, double? PC, double? PDF, double? CC, double? CBH) {
  final rosVars =
      rateOfSpreadExtended(fuelType, ISI, BUI, FMC, SFC, PC, PDF, CC, CBH);
  return rosVars['ROS'];
}

@Deprecated("Use rateOfSpread instead.")
double ROScalc(String fuelType, double ISI, double BUI, double FMC, double SFC,
    double? PC, double? PDF, double? CC, double? CBH) {
  return rateOfSpread(fuelType, ISI, BUI, FMC, SFC, PC, PDF, CC, CBH);
}
