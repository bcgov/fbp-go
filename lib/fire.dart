import 'dart:math';

import 'cffdrs/dist_calc.dart';
import 'cffdrs/lb_t_calc.dart';

double getFireSize(String fuelType, double ros, double bros,
    double ellapsedMinutes, double cfb, double lbRatio) {
  /*
    Fire size based on Eq. 8 (Alexander, M.E. 1985. Estimating the
    length-to-breadth ratio of elliptical
    forest fire patterns.).

    Code adapted from from http://github.com/bcgov/wps
    */
  // Using acceleration:
  final fireSpreadDistance =
      DISTtcalc(fuelType, ros + bros, ellapsedMinutes, cfb);
  final lengthToBreadthAtTime =
      LBtcalc(fuelType, lbRatio, ellapsedMinutes, cfb);
  // Not using acceleration:
  // fros = cffdrs.flank_rate_of_spread(ros, bros, lb_ratio)
  // # Flank Fire Spread Distance a.k.a. DF in R/FBPcalc.r
  // flank_fire_spread_distance = (ros + bros) / (2.0 * fros)
  // length_to_breadth_at_time = flank_fire_spread_distance
  // fire_spread_distance = (ros + bros) * ellapsed_minutes

  // Essentially using Eq. 8 (Alexander, M.E. 1985. Estimating the
  // length-to-breadth ratio of elliptical forest fire patterns.) - but
  // feeding it L/B and ROS from CFFDRS.
  return pi /
      (4.0 * lengthToBreadthAtTime) *
      pow(fireSpreadDistance, 2.0) /
      10000.0;
}

int getHeadFireIntensityClass(double headFireIntensity) {
  /** Return Intensity class as defined in Appendix 7. pg 99 of the Field Guide
   * To The Canadian Forest Fire Behaviour Prediction (FBP) System. 3rd Edition,
   * S.W. Taylor and M.E. Alexander.
   */
  if (headFireIntensity < 10) {
    return 1;
  } else if (headFireIntensity < 500) {
    return 2;
  } else if (headFireIntensity < 2000) {
    return 3;
  } else if (headFireIntensity < 4000) {
    return 4;
  } else if (headFireIntensity < 10000) {
    return 5;
  }
  return 6;
}

String getFireDescription(String FD) {
  switch (FD) {
    case ("I"):
      return "Intermittent Crowning";
    case ("C"):
      return "Crowning";
    case ("S"):
      return "Surface";
    default:
      throw Exception("Invalid Fire Description $FD");
  }
}

String getFireType(String fuelType, double crownFractionBurned) {
  /*
    Returns Fire Type (as String) based on percentage Crown Fraction Burned
    (CFB). These definitions come from the Red Book (p.69).
    Abbreviations for fire types have been taken from the red book (p.9).

    CROWN FRACTION BURNED           TYPE OF FIRE                ABBREV.
    < 10%                           Surface fire                SUR
    10-89%                          Intermittent crown fire     IC
    > 90%                           Continuous crown fire       CC

    Code adapted from from http://github.com/bcgov/wps
    */
  if (["D1", "O1A", "O1B", "S1", "S2", "S3"].contains(fuelType)) {
    // From red book "crown fires are not expected in deciduous fuel types but
    // high intensity surface fires can occur.
    return "Surface fire";
  }
  // crown fraction burnt is a floating point number from 0 to 1 inclusive.
  else if (crownFractionBurned < 0.1) {
    return "Surface fire";
  } else if (crownFractionBurned < 0.9) {
    return "Intermittent crown fire";
  } else if (crownFractionBurned >= 0.9) {
    return "Continuous crown fire";
  }
  throw Exception(
      "Cannot calculate fire type. Invalid Crown Fraction Burned percentage received.");
}

String degreesToCompassPoint(double azimuth) {
  /** Given an aspect (degree 0 to 360), return compass point.
   * e.g. 0 degrees is North, 90 is East, 180 is South, 270 is West.
   */
  final values = [
    'N',
    'NNE',
    'NE',
    'ENE',
    'E',
    'ESE',
    'SE',
    'SSE',
    'S',
    'SSW',
    'SW',
    'WSW',
    'W',
    'WNW',
    'NW',
    'NNW',
    'N'
  ];
  return values[(azimuth / 22.5).floor()];
}
