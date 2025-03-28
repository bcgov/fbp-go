# TODO: create requirement.txt or toml file for this script.

from math import pi
import json
import random
import rpy2.robjects as robjs
from rpy2.robjects import DataFrame
from rpy2.robjects.packages import importr
import rpy2.robjects.conversion as cv
from rpy2.rinterface import NULL


def _none2null(_):
    """Turn None values into null"""
    return robjs.r("NULL")


none_converter = cv.Converter("None converter")
none_converter.py2rpy.register(type(None), _none2null)


def random_fmc():
    if random.getrandbits(1) == 0:
        return 0.0
    else:
        return random.uniform(0, 100)


def generate_input_data() -> dict:
    fuel_types = [
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
        "O1B",
    ]
    data = []
    # seed with meaning of life, for consistency.
    random.seed(42)
    # for each fuel type.
    for fuel_type in fuel_types:
        # create 10 random samples.
        for _ in range(10):
            pc = random.uniform(0, 100)
            # percentage dead fir + percentage confier cannot exceed 100%
            pdf = random.uniform(0, 100.0 - pc)
            data.append(
                {
                    #   D0 <- input$D0
                    #   SD <- input$SD
                    #   SH <- input$SH
                    #   HR <- input$HR
                    #   GFL <- input$GFL
                    #   CFL <- input$CFL
                    #   ISI <- input$ISI
                    "FUELTYPE": fuel_type,
                    "LAT": random.uniform(40, 70),
                    "LONG": random.uniform(-180, 0),
                    "ELV": random.uniform(0, 5000),
                    "DJ": random.randint(0, 365),
                    "FFMC": random.uniform(0, 100),
                    "BUI": random.uniform(0, 200),
                    "WS": random.uniform(0, 50),
                    "WD": random.uniform(0, 360),
                    "GS": random.uniform(0, 90),
                    "ACCEL": random.randint(0, 1),
                    "ASPECT": random.uniform(0, 360),
                    "BUIEFF": random.randint(0, 1),
                    "HR": random.uniform(0, 24),
                    "THETA": random.uniform(0, 360),
                    "CC": random.uniform(0, 100),
                    "PDF": pdf,
                    "CBH": random.uniform(0, 100),
                    "PC": pc,
                    "FMC": random_fmc(),
                    "GFL": random.uniform(
                        0, 10
                    ),  # Grass Fuel Load (kg/m^2) - default is 0.35
                }
            )
    return data


def main():
    # assumes you've installed the cffdrs R package.
    cffdrs = importr("cffdrs")

    # data = generate_input_data()
    with open("./test/resources/FBCCalc_input.json", "r") as f:
        data = json.load(f)
    results = []

    for item in data:
        dataFrame = DataFrame(item)
        prediction = cffdrs._FBPcalc(dataFrame, "All")
        result = {}

        for i in range(len(prediction)):
            result[prediction.colnames[i]] = prediction[i][0]

        results.append(result)

    with open("./FBCCalc_output.json", "w") as f:
        json.dump(results, f, indent=4)


if __name__ == "__main__":
    main()
