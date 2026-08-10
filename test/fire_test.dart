/*
Copyright 2021, 2022 Province of British Columbia

This file is part of FBP Go.

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
import 'package:fire_behaviour_app/fire.dart';
import 'package:fire_behaviour_app/global.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('getDayOfYear', () {
    test('January 1st is day 1', () {
      expect(getDayOfYear(DateTime(2023, 1, 1)), 1);
    });

    test('December 31st in a non-leap year is day 365', () {
      expect(getDayOfYear(DateTime(2023, 12, 31)), 365);
    });

    test('December 31st in a leap year is day 366', () {
      expect(getDayOfYear(DateTime(2024, 12, 31)), 366);
    });

    test('is not affected by the time of day', () {
      expect(getDayOfYear(DateTime(2023, 6, 15, 23, 59)), 166);
      expect(getDayOfYear(DateTime(2023, 6, 15, 0, 1)), 166);
    });
  });

  group('degreesToCompassPoint', () {
    test('cardinal points', () {
      expect(degreesToCompassPoint(0), 'N');
      expect(degreesToCompassPoint(90), 'E');
      expect(degreesToCompassPoint(180), 'S');
      expect(degreesToCompassPoint(270), 'W');
    });

    test('360 degrees wraps around to north', () {
      expect(degreesToCompassPoint(360), 'N');
    });

    test('rounds to the nearest compass point', () {
      expect(degreesToCompassPoint(11), 'N');
      expect(degreesToCompassPoint(12), 'NNE');
      expect(degreesToCompassPoint(20), 'NNE');
      expect(degreesToCompassPoint(355), 'N');
    });
  });

  group('razToNetEffectiveWindDirection', () {
    test('is the opposite of the direction of spread', () {
      expect(razToNetEffectiveWindDirection(0), 180);
      expect(razToNetEffectiveWindDirection(270), 90);
    });
  });

  group('getHeadFireIntensityClass', () {
    test('classifies intensity into the six classes', () {
      expect(getHeadFireIntensityClass(0), 1);
      expect(getHeadFireIntensityClass(10), 2);
      expect(getHeadFireIntensityClass(500), 3);
      expect(getHeadFireIntensityClass(2000), 4);
      expect(getHeadFireIntensityClass(4000), 5);
      expect(getHeadFireIntensityClass(10000), 6);
    });
  });

  group('pinValue', () {
    test('keeps values within range', () {
      expect(pinGS(-10), minGS);
      expect(pinGS(100), maxGS);
      expect(pinGS(30), 30);
    });
  });
}
