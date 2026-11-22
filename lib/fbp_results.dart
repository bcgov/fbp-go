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

import 'cffdrs/fire_behaviour_prediction.dart';
import 'fire.dart';
import 'disclosure_header.dart';

String formatNumber(double? number, {int digits = 2}) {
  if (number == null) {
    return '';
  }
  return number.toStringAsFixed(digits);
}

abstract class Group {
  Group({required this.heading, this.isExpanded = false});
  String heading;
  bool isExpanded;

  bool showCrown(FireBehaviourPredictionInput input) {
    FuelType fuelType = FuelType.values.byName(input.FUELTYPE);
    return !(isGrassFuelType(fuelType) ||
        isSlashFuelType(fuelType) ||
        fuelType == FuelType.D1);
  }

  Widget _buildRow(String value, String uom, String label, Color? color) {
    return MergeSemantics(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: Color(0xFFE2E8ED))),
        ),
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: Text(
                label,
                style: const TextStyle(fontSize: 15, color: Color(0xFF304459)),
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              flex: 2,
              fit: FlexFit.tight,
              child: Text(
                '$value$uom',
                textAlign: TextAlign.end,
                style: TextStyle(
                  fontSize: 15,
                  color: color,
                  fontWeight: FontWeight.w600,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildBody(
    FireBehaviourPredictionInput input,
    FireBehaviourPredictionPrimary prediction,
    double minutes,
    num surfaceFlameLength,
  );

  Container buildContainer(List<Widget> children) {
    return Container(
      color: Colors.white,
      child: Column(children: children),
    );
  }
}

class SecondaryFireBehaviourGroup extends Group {
  SecondaryFireBehaviourGroup({required super.heading, super.isExpanded});

  @override
  Widget buildBody(
    FireBehaviourPredictionInput input,
    FireBehaviourPredictionPrimary prediction,
    double minutes,
    num surfaceFlameLength,
  ) {
    TextStyle textStyle = const TextStyle(color: Colors.black);
    double netEffectiveWindDirection = razToNetEffectiveWindDirection(
      prediction.RAZ,
    );
    return buildContainer([
      // Primary outputs
      ...(showCrown(input)
          ? [
              _buildRow(
                ((prediction.secondary!.FCFB * 100).toStringAsFixed(0)),
                '%',
                'Crown fraction burned - Flank',
                textStyle.color,
              ),
              _buildRow(
                ((prediction.secondary!.BCFB * 100).toStringAsFixed(0)),
                '%',
                'Crown fraction burned - Back',
                textStyle.color,
              ),
            ]
          : []),
      _buildRow(
        ((prediction.secondary!.FROS).toStringAsFixed(0)),
        ' (m/min)',
        'Rate of spread - Flank',
        textStyle.color,
      ),
      _buildRow(
        ((prediction.secondary!.BROS).toStringAsFixed(0)),
        ' (m/min)',
        'Rate of spread - Back',
        textStyle.color,
      ),
      _buildRow(
        ((prediction.secondary!.FFI).toStringAsFixed(0)),
        ' (kW/m)',
        'Flank fire intensity',
        textStyle.color,
      ),
      _buildRow(
        ((prediction.secondary!.BFI).toStringAsFixed(0)),
        ' (kW/m)',
        'Back fire intensity',
        textStyle.color,
      ),
      _buildRow(
        '${degreesToCompassPoint(prediction.RAZ)} ${prediction.RAZ.toStringAsFixed(1)}',
        '\u00B0',
        'Direction of spread',
        textStyle.color,
      ),
      // Planned ignition
      _buildRow(
        formatNumber(prediction.SFC),
        ' (kg/\u33A1)',
        'Surface fuel consumption',
        textStyle.color,
      ),
      ...(showCrown(input)
          ? [
              _buildRow(
                (prediction.CFC).toStringAsFixed(0),
                ' (kg/\u33A1)',
                'Crown fuel consumption',
                textStyle.color,
              ),
            ]
          : []),
      _buildRow(
        formatNumber(prediction.TFC),
        ' (kg/\u33A1)',
        'Total fuel consumption',
        textStyle.color,
      ),
      _buildRow(
        formatNumber(prediction.secondary?.FTFC),
        ' (kg/\u33A1)',
        'Total fuel consumption - flank',
        textStyle.color,
      ),
      _buildRow(
        formatNumber(prediction.secondary?.BTFC),
        ' (kg/\u33A1)',
        'Total fuel consumption - back',
        textStyle.color,
      ),
      // Fire growth potential
      _buildRow(
        prediction.WSV.toStringAsFixed(0),
        ' (km/h)',
        'Net effective wind speed',
        textStyle.color,
      ),
      _buildRow(
        '${degreesToCompassPoint(netEffectiveWindDirection)} ${netEffectiveWindDirection.toStringAsFixed(1)}',
        '\u00B0',
        'Net effective wind direction',
        textStyle.color,
      ),
      // Spread distance
      _buildRow(
        formatNumber(prediction.secondary?.RSO),
        ' (m/min)',
        'Surface fire rate of spread',
        textStyle.color,
      ),
      _buildRow(
        formatNumber(prediction.secondary?.LB),
        '',
        'Length to breadth ratio',
        textStyle.color,
      ),
      _buildRow(
        formatNumber(prediction.secondary?.DH),
        ' (m)',
        'Fire spread distance - head',
        textStyle.color,
      ),
      _buildRow(
        formatNumber(prediction.secondary?.DF),
        ' (m)',
        'Fire spread distance - flank',
        textStyle.color,
      ),
      _buildRow(
        formatNumber(prediction.secondary?.DB),
        ' (m)',
        'Fire spread distance - back',
        textStyle.color,
      ),
    ]);
  }
}

class PrimaryFireBehaviourGroup extends Group {
  PrimaryFireBehaviourGroup({required super.heading, super.isExpanded});

  @override
  Widget buildBody(
    FireBehaviourPredictionInput input,
    FireBehaviourPredictionPrimary prediction,
    double minutes,
    num surfaceFlameLength,
  ) {
    double? fireSize;
    if (prediction.secondary != null) {
      fireSize = calculateFireArea(
        prediction.secondary!.LBt,
        prediction.secondary!.DB + prediction.secondary!.DH,
      );
    }
    TextStyle textStyle = const TextStyle(color: Colors.black);
    return buildContainer([
      _buildRow(
        getFireDescription(prediction.FD),
        '',
        'Fire type',
        textStyle.color,
      ),
      ...(showCrown(input)
          ? [
              _buildRow(
                ((prediction.CFB * 100).toStringAsFixed(0)),
                '%',
                'Crown fraction burned',
                textStyle.color,
              ),
            ]
          : []),
      _buildRow(
        //  Using HROSt for primary rate of spread as it reflects head ROS at time differences when ACCEL is true or false
        ((prediction.secondary!.HROSt).toStringAsFixed(0)),
        ' (m/min)',
        'Rate of spread',
        textStyle.color,
      ),
      _buildRow(
        ((prediction.ISI).toStringAsFixed(0)),
        '',
        'Initial Spread Index',
        textStyle.color,
      ),
      _buildRow(
        surfaceFlameLength.toStringAsFixed(2),
        ' (m)',
        'Surface flame length',
        textStyle.color,
      ),
      _buildRow(
        ((getHeadFireIntensityClass(prediction.HFI)).toStringAsFixed(0)),
        '',
        'Intensity class',
        textStyle.color,
      ),
      _buildRow(
        ((prediction.HFI).toStringAsFixed(0)),
        ' (kW/m)',
        'Head fire intensity',
        textStyle.color,
      ),
      _buildRow(
        '${fireSize?.toStringAsFixed(1)}',
        ' (ha)',
        '$minutes minute fire size',
        textStyle.color,
      ),
    ]);
  }
}

List<Group> generateGroups() {
  List<Group> groups = [
    PrimaryFireBehaviourGroup(
      heading: 'Basic Fire Behaviour Outputs',
      isExpanded: true,
    ),
    SecondaryFireBehaviourGroup(
      heading: 'Advanced Fire Behaviour Outputs',
      isExpanded: true,
    ),
  ];
  return groups;
}

class ResultsState extends State<ResultsStateWidget> {
  final List<Group> _groups = generateGroups();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final group in _groups)
          Card(
            clipBehavior: Clip.antiAlias,
            margin: const EdgeInsets.only(bottom: 12),
            child: Column(
              children: [
                DisclosureHeader(
                  title: group.heading,
                  accent: widget.intensityClassColour,
                  expanded: group.isExpanded,
                  onPressed: () =>
                      setState(() => group.isExpanded = !group.isExpanded),
                ),
                if (group.isExpanded)
                  group.buildBody(
                    widget.input,
                    widget.prediction,
                    widget.minutes,
                    widget.surfaceFlameLength,
                  ),
              ],
            ),
          ),
      ],
    );
  }
}

class ResultsStateWidget extends StatefulWidget {
  final FireBehaviourPredictionPrimary prediction;
  final FireBehaviourPredictionInput input;
  final int intensityClass;
  final Color intensityClassColour;
  final Color intensityClassTextColor;
  final double minutes;
  final double? fireSize;
  final num surfaceFlameLength;

  const ResultsStateWidget({
    required this.prediction,
    required this.minutes,
    required this.fireSize,
    required this.input,
    required this.intensityClass,
    required this.intensityClassColour,
    required this.intensityClassTextColor,
    required this.surfaceFlameLength,
    super.key,
  });

  @override
  State<ResultsStateWidget> createState() => ResultsState();
}
