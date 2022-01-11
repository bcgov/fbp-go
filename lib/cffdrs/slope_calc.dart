// ignore_for_file: non_constant_identifier_names

import 'dart:math';
import 'isi_calc.dart';
import 'ros_calc.dart';

double Slopecalc(
    String fuelType,
    double FFMC,
    double? BUI,
    double WS,
    double WAZ,
    double GS,
    double SAZ,
    double FMC,
    double SFC,
    double? PC,
    double? PDF,
    double? CC,
    double? CBH,
    double ISI,
    {String output = "RAZ"}) {
  /*
  # output options include: RAZ and WSV
  #############################################################################
  # Description:
  #   Calculate the net effective windspeed (WSV), the net effective wind 
  #   direction (RAZ) or the wind azimuth (WAZ).
  #
  #   All variables names are laid out in the same manner as FCFDG (1992) and
  #   Wotton (2009).
  #
  #   
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
  #       FFMC: Fine Fuel Moisture Code
  #        BUI: The Buildup Index value
  #         WS: Windspeed (km/h)
  #        WAZ: Wind Azimuth
  #         GS: Ground Slope (%)
  #        SAZ: Slope Azimuth
  #        FMC: Foliar Moisture Content
  #        SFC: Surface Fuel Consumption (kg/m^2)
  #         PC: Percent Conifer (%)
  #        PDF: Percent Dead Balsam Fir (%)
  #         CC: Constant
  #        CBH: Crown Base Height (m)
  #        ISI: Initial Spread Index
  #     output: Type of variable to output (RAZ/WSV, default=RAZ)
  # Returns:
  #   BE: The Buildup Effect
  #
  #############################################################################
  */
  // #check for valid output types
  if (!["RAZ", "WAZ", "WSV"].contains(output)) {
    throw Exception("In 'slopecalc()', '$output' is an invalid 'output' type.");
  }
  double NoBUI = -1;
  // #Eq. 39 (FCFDG 1992) - Calculate Spread Factor
  double SF = GS >= 70 ? 10 : exp(3.533 * pow((GS / 100), 1.2));
  // #ISI with 0 wind on level grounds
  double ISZ = ISIcalc(FFMC, 0);
  // #Surface spread rate with 0 wind on level ground
  double RSZ = ROScalc(fuelType, ISZ, NoBUI, FMC, SFC, PC, PDF, CC, CBH);
  // #Eq. 40 (FCFDG 1992) - Surface spread rate with 0 wind upslope
  double RSF = RSZ * SF;

  // #setup some reference vectors
  var d = <String>[
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

  // #initialize some local vars
  RSZ = -99;
  double RSF_C2 = -99;
  double RSF_D1 = -99;
  double RSF_M3 = -99;
  double RSF_M4 = -99;
  double CF = -99;
  double ISF = -99;
  double ISF_C2 = -99;
  double ISF_D1 = -99;
  double ISF_M3 = -99;
  double ISF_M4 = -99;

  // #Eqs. 41a, 41b (Wotton 2009) - Calculate the slope equivalend ISI
  if (["C1", "C2", "C3", "C4", "C5", "C6", "C7", "D1", "S1", "S2", "S3"]
      .contains(fuelType)) {
    ISF = (1 - pow((RSF / a[FUELTYPE]), (1 / c0[FUELTYPE]))) >= 0.01
        ? log(1 - pow((RSF / a[FUELTYPE]), (1 / c0[FUELTYPE]))) / (-b[FUELTYPE])
        : log(0.01) / (-b[FUELTYPE]);
  }
  // #When calculating the M1/M2 types, we are going to calculate for both C2
  // # and D1 types, and combine
  // #Surface spread rate with 0 wind on level ground
  else if (["M1", "M2"].contains(fuelType)) {
    RSZ = ROScalc("C2", ISZ, NoBUI, FMC, SFC, PC, PDF, CC, CBH);
    // #Eq. 40 (FCFDG 1992) - Surface spread rate with 0 wind upslope for C2
    RSF_C2 = RSZ * SF;
    RSZ = ROScalc("D1", ISZ, NoBUI, FMC, SFC, PC, PDF, CC, CBH);
    // #Eq. 40 (FCFDG 1992) - Surface spread rate with 0 wind upslope for D1
    RSF_D1 = RSZ * SF;
  }
  int c2Index = d.indexOf("C2");
  double RSF0 = 1.0 - pow((RSF_C2 / a[c2Index]), (1 / c0[c2Index]));

  if (["M1", "M2"].contains(fuelType)) {
    if (RSF0 >= 0.01) {
      // #Eq. 41a (Wotton 2009) - Calculate the slope equivalent ISI
      ISF_C2 = log(1 - pow((RSF_C2 / a[c2Index]), (1 / c0[c2Index]))) /
          (-b[c2Index]);
    } else if (RSF0 < 0.01) {
      // #Eq. 41b (Wotton 2009) - Calculate the slope equivalent ISI
      ISF_C2 = log(0.01) / (-b[c2Index]);
    }
  }
  int d1Index = d.indexOf("D1");
  RSF0 = 1.0 - pow((RSF_D1 / a[d1Index]), (1 / c0[d1Index]));
  if (["M1", "M2"].contains(fuelType)) {
    if (RSF0 >= 0.01) {
      // #Eq. 41a (Wotton 2009) - Calculate the slope equivalent ISI
      ISF_D1 = log(1 - pow((RSF_D1 / a[d1Index]), (1 / c0[d1Index]))) /
          (-b[d1Index]);
    } else {
      // #Eq. 41b (Wotton 2009) - Calculate the slope equivalent ISI
      ISF_D1 = log(0.01) / (-b[d1Index]);
    }
    // #Eq. 42a (Wotton 2009) - Calculate weighted average for the M1/M2 types
    if (PC == null) {
      throw Exception("PC is null");
    }
    ISF = PC / 100 * ISF_C2 + (1 - PC / 100) * ISF_D1;
  }
  // #Set % Dead Balsam Fir to 100%
  double PDF100 = 100;
  // #Surface spread rate with 0 wind on level ground
  if (fuelType == "M3") {
    RSZ = ROScalc("M3", ISI = ISZ, BUI = NoBUI, FMC, SFC, PC, PDF100, CC, CBH);
    // #Eq. 40 (FCFDG 1992) - Surface spread rate with 0 wind upslope for M3
    RSF_M3 = RSZ * SF;
    // #Surface spread rate with 0 wind on level ground, using D1
    RSZ = ROScalc("D1", ISZ, BUI = NoBUI, FMC, SFC, PC, PDF100, CC, CBH);
    // #Eq. 40 (FCFDG 1992) - Surface spread rate with 0 wind upslope for M3
    RSF_D1 = RSZ * SF;
  }
  int m3index = d.indexOf("M3");
  RSF0 = 1.0 - pow((RSF_M3 / a[m3index]), (1 / c0[m3index]));

  if (fuelType == "M3") {
    if (RSF0 >= 0.01) {
      // #Eq. 41a (Wotton 2009) - Calculate the slope equivalent ISI
      ISF_M3 = log(1 - pow((RSF_M3 / a[m3index]), (1 / c0[m3index]))) /
          (-b[m3index]);
    } else {
      // #Eq. 41b (Wotton 2009) - Calculate the slope equivalent ISI
      ISF_M3 = log(0.01) / (-b[m3index]);
    }
  }

  // #Eq. 40 (FCFDG 1992) - Surface spread rate with 0 wind upslope for D1
  RSF0 = 1.0 - pow((RSF_D1 / a[d1Index]), (1 / c0[d1Index]));

  if (fuelType == 'M3') {
    // #Eq. 41a (Wotton 2009) - Calculate the slope equivalent ISI
    if (RSF0 >= 0.01) {
      ISF_D1 = log(1 - pow((RSF_D1 / a[d1Index]), (1 / c0[d1Index]))) /
          (-b[d1Index]);
    } else {
      // #Eq. 41b (Wotton 2009) - Calculate the slope equivalent ISI
      ISF_D1 = log(0.01) / (-b[d1Index]);
    }
    // #Eq. 42b (Wotton 2009) - Calculate weighted average for the M3 type
    if (PDF == null) {
      throw Exception("PDF is null");
    }
    ISF = PDF / 100 * ISF_M3 + (1 - PDF / 100) * ISF_D1;
  }
  // #Surface spread rate with 0 wind on level ground, using M4
  if (fuelType == 'M4') {
    RSZ = ROScalc("M4", ISI = ISZ, BUI = NoBUI, FMC, SFC, PC, PDF100, CC, CBH);
    // #Eq. 40 (FCFDG 1992) - Surface spread rate with 0 wind upslope for M4
    RSF_M4 = RSZ * SF;
    // #Surface spread rate with 0 wind on level ground, using D1
    RSZ = ROScalc("D1", ISZ, BUI = NoBUI, FMC, SFC, PC, PDF100, CC, CBH);
    // #Eq. 40 (FCFDG 1992) - Surface spread rate with 0 wind upslope for D1
    RSF_D1 = RSZ * SF;
  }
  // #Eq. 40 (FCFDG 1992) - Surface spread rate with 0 wind upslope for D1
  int m4index = d.indexOf("M4");
  RSF0 = 1.0 - pow((RSF_M4 / a[m4index]), (1 / c0[m4index]));
  if (fuelType == 'M4') {
    // #Eq. 41a (Wotton 2009) - Calculate the slope equivalent
    if (RSF0 >= 0.01) {
      ISF_M4 = log(1 - pow((RSF_M4 / a[m4index]), (1 / c0[m4index]))) /
          (-b[m4index]);
    } else {
      // #Eq. 41b (Wotton 2009) - Calculate the slope equivalent ISI
      ISF_M4 = log(0.01) / (-b[m4index]);
    }
  }
  // #Eq. 40 (FCFDG 1992) - Surface spread rate with 0 wind upslope for D1
  RSF0 = 1.0 - pow((RSF_D1 / a[d1Index]), (1 / c0[d1Index]));
  if (fuelType == 'M4') {
    if (RSF0 >= 0.01) {
      // #Eq. 41a (Wotton 2009) - Calculate the slope equivalent ISI (D1)
      ISF_D1 = log(1 - pow((RSF_D1 / a[d1Index]), (1 / c0[d1Index]))) /
          (-b[d1Index]);
    } else {
      // #Eq. 41b (Wotton 2009) - Calculate the slope equivalent ISI (D1)
      ISF_D1 = log(0.01) / (-b[d1Index]);
    }
    // #Eq. 42c (Wotton 2009) - Calculate weighted average for the M4 type
    if (PDF == null) {
      throw Exception("PDF is null");
    }
    ISF = PDF / 100 * ISF_M4 + (1 - PDF / 100.0) * ISF_D1;
  }

  if (["O1A", "O1B"].contains(fuelType)) {
    if (CC == null) {
      throw Exception("CC is null");
    }
    // #Eqs. 35a, 35b (Wotton 2009) - Curing Factor pivoting around % 58.8
    CF = CC < 58.8 ? 0.005 * (exp(0.061 * CC) - 1) : 0.176 + 0.02 * (CC - 58.8);
    // #Eqs. 43a, 43b (Wotton 2009) - slope equivilent ISI for Grass
    ISF = (1 - pow((RSF / (CF * a[FUELTYPE])), (1 / c0[FUELTYPE]))) >= 0.01
        ? log(1 - pow((RSF / (CF * a[FUELTYPE])), (1 / c0[FUELTYPE]))) /
            (-b[FUELTYPE])
        : log(0.01) / (-b[FUELTYPE]);
  }
  // #Eq. 46 (FCFDG 1992)
  double m = 147.2 * (101 - FFMC) / (59.5 + FFMC);
  // #Eq. 45 (FCFDG 1992) - FFMC function from the ISI equation
  double fF = 91.9 * exp(-.1386 * m) * (1 + (pow(m, 5.31)) / 4.93e7);
  // #Eqs. 44a, 44d (Wotton 2009) - Slope equivalent wind speed
  double WSE = 1 / 0.05039 * log(ISF / (0.208 * fF));
  // #Eqs. 44b, 44e (Wotton 2009) - Slope equivalent wind speed
  WSE = (WSE > 40.0 && ISF < (0.999 * 2.496 * fF))
      ? 28 - (1 / 0.0818 * log(1 - ISF / (2.496 * fF)))
      : WSE;

  // #Eqs. 44c (Wotton 2009) - Slope equivalent wind speed
  WSE = WSE > 40 && ISF >= (0.999 * 2.496 * fF) ? 112.45 : WSE;
  // #Eq. 47 (FCFDG 1992) - resultant vector magnitude in the x-direction
  double WSX = WS * sin(WAZ) + WSE * sin(SAZ);
  // #Eq. 48 (FCFDG 1992) - resultant vector magnitude in the y-direction
  double WSY = WS * cos(WAZ) + WSE * cos(SAZ);
  // #Eq. 49 (FCFDG 1992) - the net effective wind speed
  double WSV = sqrt(WSX * WSX + WSY * WSY);
  // #stop execution here and return WSV if requested
  if (output == "WSV") {
    return WSV;
  }
  // #Eq. 50 (FCFDG 1992) - the net effective wind direction (radians)
  double RAZ = acos(WSY / WSV);
  // #Eq. 51 (FCFDG 1992) - convert possible negative RAZ into more understandable
  // # directions
  RAZ = WSX < 0 ? 2 * pi - RAZ : RAZ;
  return RAZ;
}
