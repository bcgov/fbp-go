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
import 'package:flutter/material.dart';

class AssumptionsPage extends StatelessWidget {
  const AssumptionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BulletPoint(
            text:
                'Fuel conditions are similar to one of the 18 benchmark fuel types.',
          ),
          BulletPoint(
            text:
                'The fuel moisture codes used are representative of the site conditions.',
          ),
          BulletPoint(
            text:
                'Fuels are uniform and continuous, topography is simple and homogenous, and the wind is constant and unidirectional during the burning period.',
          ),
          BulletPoint(
            text:
                'The fire is wind or wind/slope driven, and spread is not unduly affected by a convection column. Wind is measured in the open, at or corrected to 10 m.',
          ),
          BulletPoint(
            text:
                'The rate of fire spread levels off at very high wind speed and initial spread index (ISI) values.',
          ),
          BulletPoint(
            text:
                'The fire is unaffected by suppression activities (free burning).',
          ),
          BulletPoint(
            text:
                'A fire starting from a point source will have an elliptical shape under the above conditions.',
          ),
          BulletPoint(
            text:
                'The effect of short-range spotting of firebrands on spread is taken into account.',
          ),
        ],
      ),
    );
  }
}

class BulletPoint extends StatelessWidget {
  final String text;

  const BulletPoint({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontSize: 16)),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 16))),
        ],
      ),
    );
  }
}
