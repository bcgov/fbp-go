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

import '../fire.dart';
import 'dist_calc.dart';
import 'ros_t_calc.dart';
import 'b_ros_calc.dart';
import 'be_calc.dart';
import 'cfb_calc.dart';
import 'f_ros_calc.dart';
import 'fi_calc.dart';
import 'fmc_calc.dart';
import 'lb_calc.dart';
import 'lb_t_calc.dart';
import 'sfc_calc.dart';
import 'slope_calc.dart';
import 'isi_calc.dart';
import 'c6_calc.dart';
import 'ros_calc.dart';
import 'tfc_calc.dart';

class ValueDescriptionPair {
  final String description;
  final Function getValue;
  String? unit;

  ValueDescriptionPair(this.getValue, this.description, {this.unit});

  String _valueToString() {
    final value = getValue();
    if (value is double) {
      return value.toStringAsFixed(2);
    } else if (value is String) {
      return value.toString();
    }
    throw Exception('Unsupported value type for $description');
  }

  @override
  String toString() {
    String stringValue = _valueToString();
    if (unit != null) {
      return '$stringValue ($unit)';
    }
    return stringValue;
  }
}

class PercentageValueDescriptionPair extends ValueDescriptionPair {
  PercentageValueDescriptionPair(value, String description, {unit})
      : super(value, description, unit: unit);

  @override
  String _valueToString() {
    final value = getValue();
    if (value is double) {
      return '${(value * 100).toStringAsFixed(2)}%';
    } else if (value is String) {
      return value.toString();
    }
    throw Exception('Unsupported value type for $description');
  }

  @override
  String toString() {
    String stringValue = _valueToString();
    if (unit != null) {
      return '$stringValue $unit';
    }
    return stringValue;
  }
}

class FireDescriptionValuePair extends ValueDescriptionPair {
  FireDescriptionValuePair(value, String description)
      : super(value, description);

  @override
  String toString() {
    final value = getValue();
    return getFireDescription(value);
  }
}

class CompassValueDescriptionPair extends ValueDescriptionPair {
  CompassValueDescriptionPair(value, String description)
      : super(value, description, unit: '°');

  @override
  String toString() {
    final value = getValue();
    return '${degreesToCompassPoint(value)} ${value.toStringAsFixed(1)}$unit';
  }
}

class FireBehaviourPredictionInput {
  String FUELTYPE; // The Fire Behaviour Prediction FuelType
  double LAT; // Latitude
  double LONG; // Longitude
  double ELV; // Elevation
  int DJ; // Day of year (often referred to as julian date)
  double? D0; // Date of minimum foliar moisture content.
  double? FMC; // Foliar moisture content will be calculated if not provided.
  double FFMC; // Fine Fuel Moisture Code
  double BUI; // Buildup Index
  double WS; // Windspeed (km/h)
  double WD; // Wind direction (degrees)
  double GS; // Ground Slope (%)
  double? SD; // ?? used in CBH calculation.
  double? SH; // ?? used in CBH calculation.
  double? PC; // Percent Conifer (%) (optional, not all FuelTypes have this)
  double? PDF; // Percent Dead Balsam Fir (%)
  double? GFL; // Grass Fuel Load (kg/m^2)
  double? CC; // Degree of Curing (just "C" in FCFDG 1992)
  double? THETA; // Calculate the rate of spread towards angle theta
  bool ACCEL; // Use acceleration.
  double ASPECT; // Terrain aspect (degrees)
  bool BUIEFF; // Use BUI effect.
  double? CBH; // Crown Base Height (m)
  double? CFL;
  double? ISI; // Initial Spread Index
  double HR; // Hours.

  FireBehaviourPredictionInput(
      {required this.FUELTYPE,
      required this.LAT,
      required this.LONG,
      required this.ELV,
      required this.DJ,
      this.D0,
      this.FMC,
      required this.FFMC,
      required this.BUI,
      required this.WS,
      required this.WD,
      required this.GS,
      this.SD,
      this.SH,
      this.PC,
      this.PDF,
      this.GFL,
      this.CC,
      this.THETA,
      required this.ACCEL,
      required this.ASPECT,
      required this.BUIEFF,
      this.CBH,
      this.CFL,
      this.ISI,
      required this.HR});
}

class FireBehaviourPredictionSecondary {
  double SF; // Spread Factor
  double CSI; // Critical Surface Intensity
  double RSO; // Surface fire rate of spread (m/min)
  double BE; // Buildup Effect
  double LB; // Length to breadth ratio
  double LBt; // Length to breadth ratio time
  double BROS; // Back fire rate of spread
  double FROS; // Flank fire rate of spread
  double TROS; // Rate of spread towards angle theta
  double BROSt; // Rate of spread at time t for back fire
  double FROSt; // Rate of spread at time t for flank
  double TROSt; // Rate of spread towards angle theta at time t
  double FCFB; // Crown fraction burned for flank
  double BCFB; // Crown fraction burned for back
  double TCFB; // Crown fraction burned at angle theta
  double FTFC; // Total fuel consumption for the flank
  double BTFC; // Total fuel consumption for the back
  double TTFC; // Total fuel consumption at angle theta
  double FFI; // Fire intensity at the flank
  double BFI; // Fire intensity at the back
  double TFI; // Find intensity at angle theta
  double HROSt; // Rate of spread at time t for head fire
  double TI; // Elapsed time to crown fire initiation for Head
  double FTI; // Elapsed time to crown fire initiation for Flank
  double BTI; // Elapsed time to crown fire initiation for Back
  double TTI; // Elapsed time to crown fire initiation for theta
  double DH; // Fire spread distance head
  double DB; // Fire spread distance back
  double DF; // Fire spread distance flank

  FireBehaviourPredictionSecondary(
      {required this.SF, // not being displayed right now
      required this.CSI, // not being displayed right now
      required this.RSO,
      required this.BE, // not being displayed right now
      required this.LB,
      required this.LBt, // not being displayed right now
      required this.BROS,
      required this.FROS,
      required this.TROS, // not being displayed right now
      required this.BROSt, // not being displayed right now
      required this.FROSt, // not being displayed right now
      required this.TROSt, // not being displayed right now
      required this.FCFB,
      required this.BCFB,
      required this.TCFB, // not being displayed right now
      required this.FTFC,
      required this.BTFC,
      required this.TTFC, // not being displayed right now
      required this.FFI, // not being displayed right now
      required this.BFI,
      required this.TFI,
      required this.HROSt, // not being displayed right now
      required this.TI, // not being displayed right now
      required this.FTI, // not being displayed right now
      required this.BTI, // not being displayed right now
      required this.TTI, // not being displayed right now
      required this.DH,
      required this.DB,
      required this.DF});
}

class FireBehaviourPredictionPrimary {
  double FMC; // Foliar Moisture Content
  double SFC; // Surface Fuel Consumption (kg/m^2)
  double WSV; // net effective wind speed
  double RAZ; // net effective wind direction (RAZ)
  double ISI; // Initial Spread Index
  double ROS; // Rate of Spread
  double CFB; // Crown Fraction Burned
  double TFC; // Total Fuel Consumption
  double HFI; // Head Fire Intensity
  String FD; // Fire Type
  double CFC; // Crown Fuel Consumption

  FireBehaviourPredictionSecondary? secondary;
  FireBehaviourPredictionPrimary(
      {required this.FMC, // not being displayed right now
      required this.SFC,
      required this.WSV,
      required this.RAZ,
      required this.ISI,
      required this.ROS,
      required this.CFB,
      required this.TFC,
      required this.HFI,
      required this.FD,
      required this.CFC,
      this.secondary});
}

FireBehaviourPredictionPrimary FBPcalc(FireBehaviourPredictionInput input,
    {String output = "Primary"}) {
  /*
  #############################################################################
  # Description:
  #   Fire Behavior Prediction System calculations. This is the primary
  #   function for calculating FBP for a single timestep. Not all equations are
  #   calculated within this function, but have been broken down further.
  #
  #
  # Args:
  #   input:  required and optional information needed to 
  #           calculate FBP function. View the arguments section of the fbp 
  #           manual (fbp.Rd) under "input" for the full listing of the 
  #           required and optional inputs.
  #   output: What fbp outputs to return to the user. Options are "Primary", 
  #           "Secondary" and "All".
  #
  # Returns:  
  #   output: Either Primary, Secondary, or all FBP outputs
  #
  #############################################################################
  */
  String FUELTYPE = input.FUELTYPE.toUpperCase();
  double FFMC = input.FFMC;
  double BUI = input.BUI;
  double WS = input.WS;
  double WD = input.WD;
  double FMC = input.FMC ?? 0.0;
  double GS = input.GS;
  double LAT = input.LAT;
  double LONG = input.LONG;
  double ELV = input.ELV;
  int DJ = input.DJ;
  double D0 = input.D0 ?? 0.0;
  double SD = input.SD ?? 0.0;
  double SH = input.SH ?? 0.0;
  double? PC = input.PC;
  double? PDF = input.PDF;
  double? GFL = input.GFL;
  double? CC = input.CC;
  double THETA = input.THETA ?? 0.0;
  bool ACCEL = input.ACCEL;
  double ASPECT = input.ASPECT;
  bool BUIEFF = input.BUIEFF;
  double? CBH = input.CBH;
  double? CFL = input.CFL;
  double ISI = input.ISI ?? 0.0;
  // ############################################################################
  // #                         BEGIN
  // # Throw exceptions for missing and required input variables.
  // # Throw exceptions for invalid values.
  // # Set defaults for inputs that are not already set.
  // # Dart is strongly typed, so we don't to as much checking.
  // # We're also less forgiving, and would rather fail when something is wrong.
  // ############################################################################
  // TODO: Change to using enums, so we don't need this check.
  if (FUELTYPE.isEmpty) {
    throw Exception("FuelType is a required input");
  }
  // #Convert Wind Direction from degrees to radians
  WD = WD * pi / 180;
  // #Convert Theta from degress to radians
  THETA = THETA * pi / 180;
  if (ASPECT < 0 || ASPECT > 360) {
    throw Exception("ASPECT must be between 0 and 360");
  }
  // #Convert Aspect from degrees to radians
  ASPECT = ASPECT * pi / 180;
  if (DJ < 0 || DJ > 366) {
    throw Exception("DJ is out of range, must be between 0 and 366");
  }
  if (D0 < 0 || D0 > 366) {
    throw Exception("D0 is out of range, must be between 0 and 366");
  }
  if (ELV < 0 || ELV > 10000) {
    throw Exception("ELV $ELV is out of range, must be between 0 and 10000");
  }
  if (FFMC < 0 || FFMC > 100) {
    throw Exception("FFMC is out of range, must be between 0 and 100");
  }
  if (ISI < 0 || ISI > 300) {
    throw Exception("ISI is out of range, must be between 0 and 300");
  }
  if (BUI < 0 || BUI > 1000) {
    throw Exception("BUI is out of range, must be between 0 and 1000");
  }
  if (WS < 0 || WS > 300) {
    throw Exception("WS is out of range, must be between 0 and 300");
  }
  if (WD < -2 * pi || WD > 2 * pi) {
    throw Exception("WD is out of range, must be between -2*pi and 2*pi");
  }
  if (GS < 0 || GS > 200) {
    throw Exception("GS is out of range, must be between 0 and 200");
  }
  if (ASPECT < -2 * pi || ASPECT > 2 * pi) {
    throw Exception("ASPECT is out of range, must be between -2pi and 2pi");
  }
  if (PC != null && (PC < 0 || PC > 100)) {
    throw Exception("PC is out of range, must be between 0 and 100");
  }
  if (PC != null && (PC < 0 || PC > 100)) {
    throw Exception("PC is out of range, must be between 0 and 100");
  }
  if (PDF != null && (PDF < 0 || PDF > 100)) {
    throw Exception("PDF is out of range, must be between 0 and 100");
  }
  if (CC != null && (CC < 0 || CC > 100)) {
    throw Exception("CC is out of range, must be between 0 and 100");
  }
  if (GFL != null && (GFL < 0 || GFL > 100)) {
    throw Exception("GFL is out of range, must be between 0 and 100");
  }
  if (LAT < -90 || LAT > 90) {
    throw Exception("LAT is out of range, must be between -90 and 90");
  }
  if (LONG < -180 || LONG > 360) {
    throw Exception("LONG is out of range, must be between -180 and 360");
  }
  if (THETA < -2 * pi || THETA > 2 * pi) {
    throw Exception("THETA is out of range, must be between -2*pi and 2*pi");
  }
  SD = SD < 0 || SD > 1e+05 ? -999 : SD;
  SH = SH < 0 || SH > 100 ? -999 : SH;

  // ############################################################################
  // #                         END
  // ############################################################################
  // ############################################################################
  // #                         START
  // # Corrections
  // ############################################################################
  // #Convert hours to minutes
  double HR = input.HR * 60;
  // #Corrections to reorient Wind Azimuth(WAZ) and Uphill slode azimuth(SAZ)
  double WAZ = WD + pi;
  WAZ = WAZ > (2 * pi) ? WAZ - 2 * pi : WAZ;
  double SAZ = ASPECT + pi;
  SAZ = SAZ > (2 * pi) ? SAZ - 2 * pi : SAZ;
  // #Any negative longitudes (western hemisphere) are translated to positive
  // #  longitudes
  LONG = LONG < 0 ? -LONG : LONG;
  // ############################################################################
  // #                         END
  // ############################################################################
  // ############################################################################
  // #                         START
  // # Initializing variables
  // ############################################################################
  double TFC, HFI, CFB, ROS = 0.0;
  final CBHs = <double>[2, 3, 8, 4, 18, 7, 10, 0, 6, 6, 6, 6, 0, 0, 0, 0, 0];
  final d = [
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
  final int fuelTypeIndex = d.indexOf(FUELTYPE);
  if (CBH == null || CBH <= 0.0 || CBH > 50) {
    CBH = FUELTYPE == "C6" && SD > 0 && SH > 0
        ? -11.2 + 1.06 * SH + 0.0017 * SD
        : CBHs[fuelTypeIndex];
    CBH = CBH < 0 ? 1e-07 : CBH;
  }
  final CFLs = <double>[
    0.75,
    0.8,
    1.15,
    1.2,
    1.2,
    1.8,
    0.5,
    0,
    0.8,
    0.8,
    0.8,
    0.8,
    0,
    0,
    0,
    0,
    0
  ];
  CFL = CFL == null || CFL <= 0 || CFL > 2 ? CFLs[fuelTypeIndex] : CFL;
  FMC = FMC <= 0 || FMC > 120 ? FMCcalc(LAT, LONG, ELV, DJ, D0) : FMC;
  FMC = ["D1", "S1", "S2", "S3", "O1A", "O1B"].contains(FUELTYPE) ? 0 : FMC;
  // ############################################################################
  // #                         END
  // ############################################################################

  // #Calculate Surface fuel consumption (SFC)
  final SFC = SFCcalc(FUELTYPE, FFMC, BUI, PC, GFL);
  // #Disable BUI Effect if necessary
  BUI = BUIEFF ? BUI : 0;
  // #Calculate the net effective windspeed (WSV)
  final WSV0 = Slopecalc(
      FUELTYPE, FFMC, BUI, WS, WAZ, GS, SAZ, FMC, SFC, PC, PDF, CC, CBH, ISI,
      output: "WSV");
  final WSV = GS > 0 && FFMC > 0 ? WSV0 : WS;
  // #Calculate the net effective wind direction (RAZ)
  final RAZ0 = Slopecalc(
      FUELTYPE, FFMC, BUI, WS, WAZ, GS, SAZ, FMC, SFC, PC, PDF, CC, CBH, ISI,
      output: "RAZ");
  double RAZ = GS > 0 && FFMC > 0 ? RAZ0 : WAZ;
  // #Calculate or keep Initial Spread Index (ISI)
  ISI = ISI > 0 ? ISI : ISIcalc(FFMC, WSV, fbpMod: true);
  // #Calculate the Rate of Spread (ROS), C6 has different calculations
  ROS = FUELTYPE == "C6"
      ? C6calc(FUELTYPE, ISI, BUI, FMC, SFC, CBH, option: "ROS")
      : ROScalc(FUELTYPE, ISI, BUI, FMC, SFC, PC, PDF, CC, CBH);
  // #Calculate Crown Fraction Burned (CFB), C6 has different calculations
  CFB = FUELTYPE == "C6"
      ? C6calc(FUELTYPE, ISI, BUI, FMC, SFC, CBH, option: "CFB")
      : CFL > 0
          ? CFBcalc(FUELTYPE, FMC, SFC, ROS, CBH)
          : 0;
  // #Calculate Total Fuel Consumption (TFC)
  TFC = TFCcalc(FUELTYPE, CFL, CFB, SFC, PC, PDF);
  // #Calculate Head Fire Intensity(HFI)
  HFI = FIcalc(TFC, ROS);
  // #Adjust Crown Fraction Burned
  CFB = HR < 0 ? -CFB : CFB;
  // #Adjust RAZ
  RAZ = RAZ * 180 / pi;
  RAZ = RAZ == 360 ? 0 : RAZ;
  // #Calculate Fire Type (S = Surface, C = Crowning, I = Intermittent Crowning)
  String FD = "I";
  FD = CFB < 0.1 ? "S" : FD;
  FD = CFB >= 0.9 ? "C" : FD;
  // #Calculate Crown Fuel Consumption(CFC)
  double CFC = TFCcalc(FUELTYPE, CFL, CFB, SFC, PC, PDF, option: "CFC");

  FireBehaviourPredictionSecondary? secondary;
  if (output == "SECONDARY" ||
      output == "ALL" ||
      output == "S" ||
      output == "A") {
    secondary = FBPcalcSecondary(
        FUELTYPE: FUELTYPE,
        GS: GS,
        FMC: FMC,
        SFC: SFC,
        ROS: ROS,
        CBH: CBH,
        BUI: BUI,
        WSV: WSV,
        ACCEL: ACCEL,
        HR: HR,
        CFB: CFB,
        FFMC: FFMC,
        PC: PC,
        PDF: PDF,
        CC: CC,
        THETA: THETA,
        RAZ: RAZ,
        CFL: CFL);
  }

  FireBehaviourPredictionPrimary FBP = FireBehaviourPredictionPrimary(
      FMC: FMC,
      SFC: SFC,
      WSV: WSV,
      RAZ: RAZ,
      ISI: ISI,
      ROS: ROS,
      CFB: CFB,
      TFC: TFC,
      HFI: HFI,
      FD: FD,
      CFC: CFC,
      secondary: secondary);
  return FBP;
}

FireBehaviourPredictionSecondary FBPcalcSecondary(
    {required String FUELTYPE,
    required double GS,
    required double FMC,
    required double SFC,
    required double ROS,
    required double CBH,
    required double BUI,
    required double WSV,
    required bool ACCEL,
    required double HR,
    required double CFB,
    required double FFMC,
    required double? PC,
    required double? PDF,
    required double? CC,
    required double THETA,
    required double RAZ,
    required double CFL}) {
  // #Calculate the Secondary Outputs

  //   #Eq. 39 (FCFDG 1992) Calculate Spread Factor (GS is group slope)
  double SF = GS >= 70 ? 10 : exp(3.533 * pow((GS / 100), 1.2));
  //   #Calculate Critical Surface Intensity
  double CSI = CFBcalc(FUELTYPE, FMC, SFC, ROS, CBH, option: "CSI");
  //   #Calculate Surface fire rate of spread (m/min)
  double RSO = CFBcalc(FUELTYPE, FMC, SFC, ROS, CBH, option: "RSO");
  //   #Calculate The Buildup Effect
  double BE = BEcalc(FUELTYPE, BUI);
  //   #Calculate length to breadth ratio
  double LB = LBcalc(FUELTYPE, WSV);
  double LBt = ACCEL == false ? LB : LBtcalc(FUELTYPE, LB, HR, CFB);
  //   #Calculate Back fire rate of spread (BROS)
  double BROS = BROScalc(FUELTYPE, FFMC, BUI, WSV, FMC, SFC, PC, PDF, CC, CBH);
  //   #Calculate Flank fire rate of spread (FROS)
  double FROS = FROScalc(ROS, BROS, LB);
  //   #Calculate the eccentricity
  double E = sqrt(1 - 1 / LB / LB);
  //   #Calculate the rate of spread towards angle theta (TROS)
  double TROS = ROS * (1 - E) / (1 - E * cos(THETA - RAZ));
  //   #Calculate rate of spread at time t for Flank, Back of fire and at angle
  //   #  theta.
  double ROSt = ACCEL == false ? ROS : ROStcalc(FUELTYPE, ROS, HR, CFB);
  double BROSt = ACCEL == false ? BROS : ROStcalc(FUELTYPE, BROS, HR, CFB);
  double FROSt = ACCEL == false ? FROS : FROScalc(ROSt, BROSt, LBt);
  //   #Calculate rate of spread towards angle theta at time t (TROSt)
  double TROSt = ACCEL == false
      ? TROS
      : ROSt *
          (1 - sqrt(1 - 1 / LBt / LBt)) /
          (1 - sqrt(1 - 1 / LBt / LBt) * cos(THETA - RAZ));
  //   #Calculate Crown Fraction Burned for Flank, Back of fire and at angle theta.
  double FCFB = CFL == 0
      ? 0
      : FUELTYPE == "C6"
          ? 0
          : CFBcalc(FUELTYPE, FMC, SFC, FROS, CBH);
  double BCFB = CFL == 0
      ? 0
      : FUELTYPE == "C6"
          ? 0
          : CFBcalc(FUELTYPE, FMC, SFC, BROS, CBH);
  double TCFB = CFL == 0
      ? 0
      : FUELTYPE == "C6"
          ? 0
          : CFBcalc(FUELTYPE, FMC, SFC, TROS, CBH);
  //   #Calculate Total fuel consumption for the Flank fire, Back fire and at
  //   #  angle theta
  double FTFC = TFCcalc(FUELTYPE, CFL, FCFB, SFC, PC, PDF);
  double BTFC = TFCcalc(FUELTYPE, CFL, BCFB, SFC, PC, PDF);
  double TTFC = TFCcalc(FUELTYPE, CFL, TCFB, SFC, PC, PDF);
  //   #Calculate the Fire Intensity at the Flank, Back and at angle theta fire
  double FFI = FIcalc(FTFC, FROS);
  double BFI = FIcalc(BTFC, BROS);
  double TFI = FIcalc(TTFC, TROS);
  //   #Calculate Rate of spread at time t for the Head, Flank, Back of fire and
  //   #  at angle theta.
  double HROSt = HR < 0 ? -ROSt : ROSt;
  FROSt = HR < 0 ? -FROSt : FROSt;
  BROSt = HR < 0 ? -BROSt : BROSt;
  TROSt = HR < 0 ? -TROSt : TROSt;

  //   #Calculate the elapsed time to crown fire initiation for Head, Flank, Back
  //   # fire and at angle theta. The (a# variable is a constant for Head, Flank,
  //   # Back and at angle theta used in the *TI equations)
  final a1 = 0.115 - (18.8 * pow(CFB, 2.5) * exp(-8 * CFB));
  final TI = log(1 - RSO / ROS > 0 ? 1 - RSO / ROS : 1) / (-a1);
  final a2 = 0.115 - (18.8 * pow(FCFB, 2.5) * exp(-8 * FCFB));
  final FTI = log(1 - RSO / FROS > 0 ? 1 - RSO / FROS : 1) / (-a2);
  final a3 = 0.115 - (18.8 * pow(BCFB, 2.5) * exp(-8 * BCFB));
  final BTI = log(1 - RSO / BROS > 0 ? 1 - RSO / BROS : 1) / (-a3);
  final a4 = 0.115 - (18.8 * pow(TCFB, 2.5) * exp(-8 * TCFB));
  final TTI = log(1 - RSO / TROS > 0 ? 1 - RSO / TROS : 1) / (-a4);

  //   #Fire spread distance for Head, Back, and Flank of fire
  final DH = ACCEL ? DISTtcalc(FUELTYPE, ROS, HR, CFB) : ROS * HR;
  final DB = ACCEL ? DISTtcalc(FUELTYPE, BROS, HR, CFB) : BROS * HR;
  final DF = ACCEL ? (DH + DB) / (LBt * 2) : (DH + DB) / (LB * 2);

  return FireBehaviourPredictionSecondary(
      SF: SF,
      CSI: CSI,
      RSO: RSO,
      BE: BE,
      LB: LB,
      LBt: LBt,
      BROS: BROS,
      FROS: FROS,
      TROS: TROS,
      BROSt: BROSt,
      FROSt: FROSt,
      TROSt: TROSt,
      FCFB: FCFB,
      BCFB: BCFB,
      TCFB: TCFB,
      FTFC: FTFC,
      BTFC: BTFC,
      TTFC: TTFC,
      FFI: FFI,
      BFI: BFI,
      TFI: TFI,
      HROSt: HROSt,
      TI: TI,
      FTI: FTI,
      BTI: BTI,
      TTI: TTI,
      DH: DH,
      DB: DB,
      DF: DF);
}
