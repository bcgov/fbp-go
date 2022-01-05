// ignore_for_file: non_constant_identifier_names

double TFCcalc(String FUELTYPE, double CFL, double CFB, double SFC, double? PC,
    double? PDF,
    {option = "TFC"}) {
  /**#############################################################################
  # Description:
  #   Computes the Total (Surface + Crown) Fuel Consumption by Fuel Type.
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
  #        CFL: Crown Fuel Load (kg/m^2)
  #        CFB: Crown Fraction Burned (0-1)
  #        SFC: Surface Fuel Consumption (kg/m^2)
  #         PC: Percent Conifer (%)
  #        PDF: Percent Dead Balsam Fir (%)
  #     option: Type of output (TFC, CFC, default=TFC)
  # Returns:
  #        TFC: Total (Surface + Crown) Fuel Consumption (kg/m^2)
  #       OR
  #        CFC: Crown Fuel Consumption (kg/m^2)
  # #############################################################################
  */

  // #Eq. 66a (Wotton 2009) - Crown Fuel Consumption (CFC)
  double CFC = CFL * CFB;
  // #Eq. 66b (Wotton 2009) - CFC for M1/M2 types
  if (["M1", "M2"].contains(FUELTYPE)) {
    if (PC == null) {
      throw Exception("PC is required for M1/M2 types");
    }
    CFC = PC / 100 * CFC;
  }
  // #Eq. 66c (Wotton 2009) - CFC for M3/M4 types
  else if (["M3", "M4"].contains(FUELTYPE)) {
    if (PDF == null) {
      throw Exception("PDF is required for M3/M4 types");
    }
    CFC = PDF / 100 * CFC;
  }
  // #Return CFC if requested
  if (option == "CFC") {
    return CFC;
  }
  // #Eq. 67 (FCFDG 1992) - Total Fuel Consumption
  return SFC + CFC;
}
