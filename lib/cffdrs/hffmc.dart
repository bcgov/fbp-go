/*
Copyright 2022 Province of British Columbia.

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

class Weather {
  double temp;
  double rh;
  double ws;
  double prec;
  double hr;

  Weather(
      {required this.temp,
      required this.rh,
      required this.ws,
      required this.prec,
      required this.hr});
}

double hffmc(Weather weatherstream,
    {ffmc_old = 85,
    time_step = 1,
    calc_step = false,
    batch = true,
    hourlyFWI = false}) {
  /**
  #############################################################################
  # Description: Diurnal (Hourly) Fine Fuel Moisture Code Calculation. Most of
  #              the equations in this code refer to the Van Wagner (1977), with
  #              some equations contained in Van Wagner & Pickett (1985).
  #              Additionally, some modifications were made for precision.
  #
  #              Van Wagner, C.E. 1977. A method of computing fine fuel moisture
  #              content throughout the diurnal cycle. Environment Canada,
  #              Canadian Forestry Service, Petawawa Forest Experiment Station,
  #              Chalk River, Ontario. Information Report PS-X-69.
  #              http://cfs.nrcan.gc.ca/pubwarehouse/pdfs/25591.pdf
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
  # Args: weatherstream:   Input weather stream data.frame which includes
  #                        temperature, relative humidity, wind speed,
  #                        precipitation, hourly value, and bui. More specific
  #                        info can be found in the hffmc.Rd help file.
  #            ffmc_old:   ffmc from previous timestep
  #           time.step:   The time (hours) between previous FFMC and current
  #                        time.
  #           calc.step:   Whether time step between 2 obs is calculated
  #                        (optional)
  #               batch:   Single step or iterative (default=TRUE)
  #           hourlyFWI:   Can calculated hourly ISI & FWI as well
  #                        (TRUE/FALSE, default=FALSE)
  #
  # Returns: A single or multiple hourly ffmc value(s)
  #
  #############################################################################
  */
  int t0 = time_step;
  var Fo = ffmc_old;

  // set some local scope variables
  var Tp = weatherstream.temp;
  var H = weatherstream.rh;
  var W = weatherstream.ws;
  var ro = weatherstream.prec;

  // Length of weather run
  // n0 = 1;
  // var f = null;
//   #For each day in the run
//   for (i in 1:n0){
//     #k is the data for all stations by day
//     k <- ((i - 1) * n + 1):(i * n)
//     if (calc.step & i > 1) {
//       t0 <- ifelse(n0 > 1, hr[k] - hr[k-n], t0)
//       t0 <- ifelse(t0 == -23, 1, t0)
//       t0 <- ifelse(t0 < 0, -1 * t0, t0)
//     }
//     #Eq. 1 (with a more precise multiplier than the daily)
//     mo <- 147.27723 * (101 - Fo)/(59.5 + Fo)
//     rf <- ro[k]
//     #Eqs. 3a & 3b (Van Wagner & Pickett 1985)
//     mr <- ifelse(mo <= 150,
//             mo + 42.5 * rf * exp(-100 / (251 - mo)) * (1 - exp(-6.93 / rf)),
//             mo + 42.5 * rf * exp(-100 / (251 - mo)) * (1 - exp(-6.93 / rf)) +
//               0.0015 * ((mo - 150)^2) * (rf^0.5))
//     #The real moisture content of pine litter ranges up to about 250 percent,
//     # so we cap it at 250
//     mr <- ifelse(mr > 250, 250, mr)
//     mo <- ifelse(ro[k] > 0.0, mr, mo)
//     #Eq. 2a Equilibrium moisture content from drying
//     Ed <- 0.942 * (H[k]^0.679) + 11 * exp((H[k] - 100) / 10) + 0.18 *
//           (21.1 - Tp[k]) * (1 - exp(-0.115 * H[k]))
//     #Eq. 3a Log drying rate at the normal temperature of 21.1C
//     ko <- 0.424 * (1 - (H[k] / 100)^1.7) + 0.0694 * (W[k]^0.5) *
//           (1 - (H[k] / 100)^8)
//     #Eq. 3b
//     kd <- ko * 0.0579 * exp(0.0365 * Tp[k])
//     #Eq. 8 (Van Wagner & Pickett 1985)
//     md <- Ed + (mo - Ed) * (10^(-kd * t0))
//     #Eq. 2b Equilibrium moisture content from wetting
//     Ew <- 0.618 * (H[k]^0.753) + 10 * exp((H[k] - 100) / 10) + 0.18 *
//           (21.1 - Tp[k]) * (1 - exp(-0.115 * H[k]))
//     #Eq. 7a Log wetting rate at the normal temperature of 21.1 C
//     k1 <- 0.424 * (1 - ((100 - H[k]) / 100)^1.7) + 0.0694 *
//       (W[k]^0.5) * (1 - ((100 - H[k]) / 100)^8)
//     #Eq. 4b
//     kw <- k1 * 0.0579 * exp(0.0365 * Tp[k])
//     #Eq. 8 (Van Wagner & Pickett 1985)
//     mw <- Ew - (Ew - mo) * (10^(-kw * t0))
//     #Constraints
//     m <- ifelse(mo > Ed, md, mw)
//     m <- ifelse(Ed >= mo & mo >= Ew, mo, m)
//     #Eq. 6 - Final hffmc calculation (modified 3rd constant to 147.27723)
//     Fo <- 59.5 * (250 - m) / (147.27723 + m)
//     Fo <- ifelse(Fo <=0, 0, Fo)
//     f <- c(f, Fo)
//   }
//   #Calculate hourly isi and fwi
//   if (hourlyFWI){
//     bui <- weatherstream$bui
//     if (!exists("bui") | is.null(bui)){
//       warning("Daily BUI is required to calculate hourly FWI")
//     } else {
//       #Calculate ISI
//       isi <- .ISIcalc(f, W, FALSE)
//       #Calculate FWI
//       fwi <- .fwiCalc(isi, bui)
//       #Calculate DSR
//       dsr <- 0.0272 * (fwi^1.77)
//       #Put all data into a data.frame to return
//       output <- cbind(weatherstream,
//                       data.frame(ffmc = f, isi = isi, fwi = fwi, dsr = dsr))
//       return(output)
//     }
//     #otherwise just return hffmc
//   } else {
//     return(f)
//   }
// }
  return 0.0;
}
