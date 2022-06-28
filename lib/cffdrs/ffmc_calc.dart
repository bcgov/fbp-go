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

FBP Go is free software: This program is free software; you can
redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with 
FBP Go. If not, see <https://www.gnu.org/licenses/>.
*/

import 'dart:math';

double ifelse(bool condition, double trueValue, double falseValue) {
  if (condition) {
    return trueValue;
  } else {
    return falseValue;
  }
}

double ffmcCalc(ffmc_yda, temp, rh, ws, prec) {
  /*
  #############################################################################
  # Description: Fine Fuel Moisture Code Calculation. All code
  #              is based on a C code library that was written by Canadian
  #              Forest Service Employees, which was originally based on
  #              the Fortran code listed in the reference below. All equations
  #              in this code refer to that document.
  #
  #              Equations and FORTRAN program for the Canadian Forest Fire 
  #              Weather Index System. 1985. Van Wagner, C.E.; Pickett, T.L. 
  #              Canadian Forestry Service, Petawawa National Forestry 
  #              Institute, Chalk River, Ontario. Forestry Technical Report 33. 
  #              18 p.
  #
  #              Additional reference on FWI system
  #
  #              Development and structure of the Canadian Forest Fire Weather 
  #              Index System. 1987. Van Wagner, C.E. Canadian Forestry Service,
  #              Headquarters, Ottawa. Forestry Technical Report 35. 35 p.
  #  
  #
  # Args: ffmc_yda:   The Fine Fuel Moisture Code from previous iteration
  #           temp:   Temperature (centigrade)
  #             rh:   Relative Humidity (%)
  #           prec:   Precipitation (mm)
  #             ws:   Wind speed (km/h)
  #       
  #
  # Returns: A single ffmc value
  #
  #############################################################################
  */
  // Eq. 1
  double wmo = 147.2 * (101 - ffmc_yda) / (59.5 + ffmc_yda);
  // Eq. 2 Rain reduction to allow for loss in
  //   overhead canopy
  double ra = prec > 0.5 ? prec - 0.5 : prec;
  // Eqs. 3a & 3b
  wmo = ifelse(
      prec > 0.5,
      ifelse(
          wmo > 150,
          wmo +
              0.0015 * (wmo - 150) * (wmo - 150) * sqrt(ra) +
              42.5 * ra * exp(-100 / (251 - wmo)) * (1 - exp(-6.93 / ra)),
          wmo + 42.5 * ra * exp(-100 / (251 - wmo)) * (1 - exp(-6.93 / ra))),
      wmo);
  // The real moisture content of pine litter ranges up to about 250 percent,
  //  so we cap it at 250
  wmo < -ifelse(wmo > 250, 250, wmo);
  // Eq. 4 Equilibrium moisture content from drying
  double ed = 0.942 * pow(rh, 0.679) +
      (11 * exp((rh - 100) / 10)) +
      0.18 * (21.1 - temp) * (1 - 1 / exp(rh * 0.115));
  // Eq. 5 Equilibrium moisture content from wetting
  double ew = 0.618 * pow(rh, 0.753) +
      (10 * exp((rh - 100) / 10)) +
      0.18 * (21.1 - temp) * (1 - 1 / exp(rh * 0.115));
  // Eq. 6a (ko) Log drying rate at the normal
  // temperature of 21.1 C
  double z = ifelse(
      wmo < ed && wmo < ew,
      0.424 * (1 - pow(((100 - rh) / 100), 1.7)) +
          0.0694 * sqrt(ws) * (1 - pow(((100 - rh) / 100), 8)),
      0);
  // #Eq. 6b Affect of temperature on  drying rate
  double x = -z * 0.581 * exp(0.0365 * temp);
  // #Eq. 8
  double wm = ifelse(wmo < ed && wmo < ew, ew - (ew - wmo) / pow(10, x), wmo);
  // Eq. 7a (ko) Log wetting rate at the normal
  //  temperature of 21.1 C
  z = ifelse(
      wmo > ed,
      0.424 * (1 - pow((rh / 100), 1.7)) +
          0.0694 * sqrt(ws) * (1 - pow((rh / 100), 8)),
      z);
  // Eq. 7b Affect of temperature on  wetting rate
  x = z * 0.581 * exp(0.0365 * temp);
  // Eq. 9
  wm = ifelse(wmo > ed, ed + (wmo - ed) / pow(10, x), wm);
  // Eq. 10 Final ffmc calculation
  double ffmc1 = (59.5 * (250 - wm)) / (147.2 + wm);
  // Constraints
  ffmc1 = ifelse(ffmc1 > 101, 101, ffmc1);
  ffmc1 = ifelse(ffmc1 < 0, 0, ffmc1);
  return ffmc1;
}
