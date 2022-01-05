// ignore_for_file: non_constant_identifier_names

import 'dart:math';

double SFCcalc(
    String FUELTYPE, double FFMC, double? BUI, double? PC, double? GFL) {
  /**
  #############################################################################
  # Description:
  #   Computes the Surface Fuel Consumption by Fuel Type.
  #   All variables names are laid out in the same manner as FCFDG (1992) or
  #   Wotton et. al (2009) 
  
  #   Forestry Canada Fire Danger Group (FCFDG) (1992). "Development and 
  #   Structure of the Canadian Forest Fire Behavior Prediction System." 
  #   Technical Report ST-X-3, Forestry Canada, Ottawa, Ontario.
  #
  #   Wotton, B.M., Alexander, M.E., Taylor, S.W. 2009. Updates and revisions to
  #   the 1992 Canadian forest fire behavior prediction system. Nat. Resour. 
  #   Can., Can. For. Serv., Great Lakes For. Cent., Sault Ste. Marie, Ontario, 
  #   Canada. Information Report GLC-X-10, 45p.
  #
  # Args:
  #   FUELTYPE: The Fire Behaviour Prediction FuelType
  #        BUI: Buildup Index
  #       FFMC: Fine Fuel Moisture Code
  #         PC: Percent Conifer (%)
  #        GFL: Grass Fuel Load (kg/m^2)
  # Returns:
  #        SFC: Surface Fuel Consumption (kg/m^2)
  #
  #############################################################################
  */
  double SFC = -999;
  // #Eqs. 9a, 9b (Wotton et. al. 2009) - Solving the lower bound of FFMC value
  // # for the C1 fuel type SFC calculation
  if (FUELTYPE == 'C1') {
    SFC = FFMC > 84
        ? 0.75 + 0.75 * pow((1 - exp(-0.23 * (FFMC - 84))), 0.5)
        : 0.75 - 0.75 * pow((1 - exp(-0.23 * (84 - FFMC))), 0.5);
  }
  // #Eq. 10 (FCFDG 1992) - C2, M3, and M4 Fuel Types
  else if (["C2", "M3", "M4"].contains(FUELTYPE)) {
    if (BUI == null) {
      throw Exception('BUI is required for C2, M3, and M4 Fuel Types');
    }
    SFC = 5.0 * (1 - exp(-0.0115 * BUI));
  }
  // #Eq. 11 (FCFDG 1992) - C3, C4 Fuel Types
  else if (["C3", "C4"].contains(FUELTYPE)) {
    if (BUI == null) {
      throw Exception('BUI is required for C3, C4 Fuel Types');
    }
    SFC = 5.0 * pow((1 - exp(-0.0164 * BUI)), 2.24);
  }
  // #Eq. 12 (FCFDG 1992) - C5, C6 Fuel Types
  else if (["C5", "C6"].contains(FUELTYPE)) {
    if (BUI == null) {
      throw Exception('BUI is required for C5, C6 Fuel Types');
    }
    SFC = 5.0 * pow((1 - exp(-0.0149 * BUI)), 2.48);
  }
  // #Eqs. 13, 14, 15 (FCFDG 1992) - C7 Fuel Types
  else if (FUELTYPE == 'C7') {
    if (BUI == null) {
      throw Exception('BUI is required for C7 Fuel Type');
    }
    SFC = (FFMC > 70 ? 2 * (1 - exp(-0.104 * (FFMC - 70))) : 0) +
        1.5 * (1 - exp(-0.0201 * BUI));
  }
  // #Eq. 16 (FCFDG 1992) - D1 Fuel Type
  else if (FUELTYPE == 'D1') {
    if (BUI == null) {
      throw Exception('BUI is required for D1 Fuel Type');
    }
    SFC = 1.5 * (1 - exp(-0.0183 * BUI));
  }
  // #Eq. 17 (FCFDG 1992) - M1 and M2 Fuel Types
  else if (["M1", "M2"].contains(FUELTYPE)) {
    if (PC == null) {
      throw Exception("PC is null");
    }
    if (BUI == null) {
      throw Exception('BUI is required for M1, M2 Fuel Types');
    }
    SFC = PC / 100 * (5.0 * (1 - exp(-0.0115 * BUI))) +
        ((100 - PC) / 100 * (1.5 * (1 - exp(-0.0183 * BUI))));
  }
  // #Eq. 18 (FCFDG 1992) - Grass Fuel Types
  else if (["O1A", "O1B"].contains(FUELTYPE)) {
    if (GFL == null) {
      throw Exception("GFL is null");
    }
    SFC = GFL;
  }
  // #Eq. 19, 20, 25 (FCFDG 1992) - S1 Fuel Type
  else if (FUELTYPE == 'S1') {
    if (BUI == null) {
      throw Exception('BUI is required for S1 Fuel Type');
    }
    SFC = 4.0 * (1 - exp(-0.025 * BUI)) + 4.0 * (1 - exp(-0.034 * BUI));
  }
  // #Eq. 21, 22, 25 (FCFDG 1992) - S2 Fuel Type
  else if (FUELTYPE == 'S2') {
    if (BUI == null) {
      throw Exception('BUI is required for S2 Fuel Type');
    }
    SFC = 10.0 * (1 - exp(-0.013 * BUI)) + 6.0 * (1 - exp(-0.060 * BUI));
  }
  // #Eq. 23, 24, 25 (FCFDG 1992) - S3 Fuel Type
  else if (FUELTYPE == 'S3') {
    if (BUI == null) {
      throw Exception('BUI is required for S3 Fuel Type');
    }
    SFC = 12.0 * (1 - exp(-0.0166 * BUI)) + 20.0 * (1 - exp(-0.0210 * BUI));
  }
  // #Constrain SFC value
  return SFC < 0 ? 0.000001 : SFC;
}
