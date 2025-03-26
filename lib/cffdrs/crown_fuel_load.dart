/// Computes the Crown Fuel Load (CFL) for a given fuel type.
///
/// If the given CFL is `null`, less than or equal to 0, greater than 2, or `NaN`,
/// it replaces the value with a predefined CFL value based on the `fuelType`.
///
/// - [fuelType]: A string representing the fuel type (e.g., "C1", "C2", "M1").
/// - [CFL]: A nullable double representing the Crown Fuel Load.
///
/// Returns the corrected CFL value as a `double`.
double crownFuelLoad(String fuelType, [double? CFL]) {
  // Predefined CFL values for each fuel type
  const Map<String, double> CFLs = {
    "C1": 0.75,
    "C2": 0.8,
    "C3": 1.15,
    "C4": 1.2,
    "C5": 1.2,
    "C6": 1.8,
    "C7": 0.5,
    "D1": 0.0,
    "M1": 0.8,
    "M2": 0.8,
    "M3": 0.8,
    "M4": 0.8,
    "S1": 0.0,
    "S2": 0.0,
    "S3": 0.0,
    "O1A": 0.0,
    "O1B": 0.0
  };

  // If CFL is null, ≤ 0, > 2, or NaN, use the mapped CFL value
  if (CFL == null || CFL <= 0 || CFL > 2 || CFL.isNaN) {
    return CFLs[fuelType] ?? 0.0; // Default to 0.0 if fuelType is unknown
  }

  return CFL;
}
