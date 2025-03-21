double crownBaseHeight(String fuelType, double cbh, double sd, double sh) {
  // Mapping of fuel types to CBH values
  final Map<String, double> cbhs = {
    "C1": 2,
    "C2": 3,
    "C3": 8,
    "C4": 4,
    "C5": 18,
    "C6": 7,
    "C7": 10,
    "D1": 0,
    "M1": 6,
    "M2": 6,
    "M3": 6,
    "M4": 6,
    "S1": 0,
    "S2": 0,
    "S3": 0,
    "O1A": 0,
    "O1B": 0
  };

  if (cbh <= 0 || cbh > 50 || cbh.isNaN) {
    if (fuelType == "C6" && sd > 0 && sh > 0) {
      cbh = -11.2 + 1.06 * sh + 0.0017 * sd;
    } else {
      cbh = cbhs[fuelType] ?? 0; // Default to 0 if fuelType is not found
    }
  }

  // Ensure CBH is at least 1e-07
  return cbh < 0 ? 1e-07 : cbh;
}
