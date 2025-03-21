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

/// Computes the Total (Surface + Crown) Fuel Consumption by Fuel Type.
///
/// All variable names are based on FCFDG (1992) or Wotton et al. (2009).
///
/// References:
/// - Forestry Canada Fire Danger Group (FCFDG) (1992). "Development and Structure
///   of the Canadian Forest Fire Behavior Prediction System." Technical Report ST-X-3,
///   Forestry Canada, Ottawa, Ontario.
/// - Wotton, B.M., Alexander, M.E., Taylor, S.W. (2009). Updates and revisions to
///   the 1992 Canadian forest fire behavior prediction system. Nat. Resour. Can.,
///   Can. For. Serv., Great Lakes For. Cent., Sault Ste. Marie, Ontario, Canada.
///   Information Report GLC-X-10, 45p.
///
/// Parameters:
/// - [fuelType] The Fire Behaviour Prediction Fuel Type.
/// - [cfl] Crown Fuel Load (kg/m²).
/// - [cfb] Crown Fraction Burned (0-1).
/// - [sfc] Surface Fuel Consumption (kg/m²).
/// - [pc] Percent Conifer (%).
/// - [pdf] Percent Dead Balsam Fir (%).
/// - [option] Type of output ("TFC" for Total Fuel Consumption, "CFC" for Crown Fuel Consumption, default: "TFC").
///
/// Returns:
/// - `TFC` Total (Surface + Crown) Fuel Consumption (kg/m²), or
/// - `CFC` Crown Fuel Consumption (kg/m²) if `option == "CFC"`.
double crownFuelConsumption(
    String fuelType, double cfl, double cfb, double? pc, double? pdf) {
  // Eq. 66a (Wotton 2009) - Crown Fuel Consumption (CFC)
  double cfc = cfl * cfb;

  if (pc != null && pdf != null) {
    if (fuelType == "M1" || fuelType == "M2") {
      // Eq. 66b (Wotton 2009) - CFC for M1/M2 types
      cfc = (pc / 100) * cfc;
    } else if (fuelType == "M3" || fuelType == "M4") {
      // Eq. 66c (Wotton 2009) - CFC for M3/M4 types
      cfc = (pdf / 100) * cfc;
    }
  }

  return cfc;
}

double totalFuelConsumption(String fuelType, double cfl, double cfb, double sfc,
    double? pc, double? pdf,
    {String option = "TFC"}) {
  double cfc = crownFuelConsumption(fuelType, cfl, cfb, pc, pdf);

  // Return CFC if requested
  if (option == "CFC") {
    return cfc;
  }

  // Eq. 67 (FCFDG 1992) - Total Fuel Consumption
  return sfc + cfc;
}

@Deprecated('use totalFuelConsumption')
double TFCcalc(String fuelType, double cfl, double cfb, double sfc, double? pc,
    double? pdf,
    {String option = "TFC"}) {
  return totalFuelConsumption(fuelType, cfl, cfb, sfc, pc, pdf);
}
