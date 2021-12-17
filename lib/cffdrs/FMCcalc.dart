// ignore_for_file: non_constant_identifier_names

import 'dart:math';

double FMCcalc(double LAT, double LONG, double ELV, int DJ, double D0) {
  /**
  #############################################################################
  # Description:
  #   Calculate Foliar Moisture Content on a specified day.
  #
  #   All variables names are laid out in the same manner as Forestry Canada 
  #   Fire Danger Group (FCFDG) (1992). Development and Structure of the 
  #   Canadian Forest Fire Behavior Prediction System." Technical Report 
  #   ST-X-3, Forestry Canada, Ottawa, Ontario.
  #
  # Args:
  #   LAT:    Latitude (decimal degrees)
  #   LONG:   Longitude (decimal degrees)
  #   ELV:    Elevation (metres)
  #   DJ:     Day of year (offeren referred to as julian date)
  #   D0:     Date of minimum foliar moisture content
  #   
  # Returns:
  #   FMC:    Foliar Moisture Content
  #
  #############################################################################
  */
  double FMC = -1;
  double LATN = 0;
  // #Calculate Normalized Latitude
  // #Eqs. 1 & 3 (FCFDG 1992)
  if (D0 <= 0) {
    LATN = ELV <= 0
        ? 46 + 23.4 * exp(-0.0360 * (150 - LONG))
        : 43 + 33.7 * exp(-0.0351 * (150 - LONG));
  }
  // #Calculate Date of minimum foliar moisture content
  // #Eqs. 2 & 4 (FCFDG 1992)
  if (D0 <= 0) {
    D0 = ELV <= 0 ? 151 * (LAT / LATN) : 142.1 * (LAT / LATN) + 0.0172 * ELV;
  }
  // #Round D0 to the nearest integer because it is a date
  D0 = D0.roundToDouble();
  // #Number of days between day of year and date of min FMC
  // #Eq. 5 (FCFDG 1992)
  double ND = (DJ - D0).abs();
  // #Calculate final FMC
  // #Eqs. 6, 7, & 8 (FCFDG 1992)
  if (ND < 30) {
    FMC = 85 + 0.0189 * pow(ND, 2);
  } else {
    FMC = ND >= 30 && ND < 50 ? 32.9 + 3.17 * ND - 0.0288 * pow(ND, 2) : 120;
  }
  return FMC;
}
