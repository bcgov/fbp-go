import 'dart:math';

import 'cffdrs/dist_calc.dart';
import 'cffdrs/lb_t_calc.dart';

double getFireSize(String fuel_type, double ros, double bros,
    double ellapsed_minutes, double cfb, double lb_ratio) {
  // Code taken from http://github.com/bcgov/wps
  /*
    Fire size based on Eq. 8 (Alexander, M.E. 1985. Estimating the length-to-breadth ratio of elliptical
    forest fire patterns.).
    */
  // Using acceleration:
  double fire_spread_distance =
      DISTtcalc(fuel_type, ros + bros, ellapsed_minutes, cfb);
  double length_to_breadth_at_time =
      LBtcalc(fuel_type, lb_ratio, ellapsed_minutes, cfb);
  // Not using acceleration:
  // fros = cffdrs.flank_rate_of_spread(ros, bros, lb_ratio)
  // # Flank Fire Spread Distance a.k.a. DF in R/FBPcalc.r
  // flank_fire_spread_distance = (ros + bros) / (2.0 * fros)
  // length_to_breadth_at_time = flank_fire_spread_distance
  // fire_spread_distance = (ros + bros) * ellapsed_minutes

  // Essentially using Eq. 8 (Alexander, M.E. 1985. Estimating the length-to-breadth ratio of elliptical
  // forest fire patterns.) - but feeding it L/B and ROS from CFFDRS.
  return pi /
      (4.0 * length_to_breadth_at_time) *
      pow(fire_spread_distance, 2.0) /
      10000.0;
}
