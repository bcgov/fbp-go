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
