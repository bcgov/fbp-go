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

import 'cffdrs/fbp_calc.dart';
import 'fire.dart';
import 'global.dart';

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

  Row _buildRow(String value, String uom, String label, Color? color) {
    const int valueFlex = 3;
    const int labelFlex = 6;
    const double textPadding = 1.0;
    TextStyle valueStyle = TextStyle(
        color: color, fontWeight: FontWeight.bold, fontSize: fontSize);
    TextStyle labelStyle = TextStyle(color: color, fontSize: fontSize);
    TextStyle uomStyle = valueStyle;
    return Row(children: [
      Expanded(
          flex: valueFlex,
          child: Padding(
            padding: const EdgeInsets.only(
                right: 5.0, top: textPadding, bottom: textPadding),
            child:
                // Text(value, textAlign: TextAlign.right, style: valueStyle)
                RichText(
                    textAlign: TextAlign.right,
                    text: TextSpan(
                        text: value,
                        style: valueStyle,
                        children: [TextSpan(text: uom, style: uomStyle)])),
          )),
      Expanded(
          flex: labelFlex,
          child: Padding(
              padding:
                  const EdgeInsets.only(top: textPadding, bottom: textPadding),
              child: Text(label, style: labelStyle))),
    ]);
  }

  Widget buildBody(
      FireBehaviourPredictionInput input,
      FireBehaviourPredictionPrimary prediction,
      double minutes,
      num surfaceFlameLength);

  Container buildContainer(List<Widget> children) {
    return Container(color: Colors.white, child: Column(children: children));
  }
}

class SecondaryFireBehaviourGroup extends Group {
  SecondaryFireBehaviourGroup({required String heading})
      : super(heading: heading);

  @override
  Widget buildBody(
      FireBehaviourPredictionInput input,
      FireBehaviourPredictionPrimary prediction,
      double minutes,
      num surfaceFlameLength) {
    TextStyle textStyle = const TextStyle(color: Colors.black);
    double netEffectiveWindDirection =
        razToNetEffectiveWindDirection(prediction.RAZ);
    return buildContainer([
      // Primary outputs
      ...(showCrown(input)
          ? [
              _buildRow(((prediction.secondary!.FCFB * 100).toStringAsFixed(0)),
                  '%', 'Crown fraction burned - Flank', textStyle.color),
              _buildRow(((prediction.secondary!.BCFB * 100).toStringAsFixed(0)),
                  '%', 'Crown fraction burned - Back', textStyle.color)
            ]
          : []),
      _buildRow(((prediction.secondary!.FROS).toStringAsFixed(0)), ' (m/min)',
          'Rate of spread - Flank', textStyle.color),
      _buildRow(((prediction.secondary!.BROS).toStringAsFixed(0)), ' (m/min)',
          'Rate of spread - Back', textStyle.color),
      _buildRow(((prediction.secondary!.FFI).toStringAsFixed(0)), ' (kW/m)',
          'Flank fire intensity', textStyle.color),
      _buildRow(((prediction.secondary!.BFI).toStringAsFixed(0)), ' (kW/m)',
          'Back fire intensity', textStyle.color),
      _buildRow(
          '${degreesToCompassPoint(prediction.RAZ)} ${prediction.RAZ.toStringAsFixed(1)}',
          '\u00B0',
          'Direction of spread',
          textStyle.color),
      // Planned ignition
      _buildRow(formatNumber(prediction.SFC), ' (kg/\u33A1)',
          'Surface fuel consumption', textStyle.color),
      ...(showCrown(input)
          ? [
              _buildRow((prediction.CFC).toStringAsFixed(0), ' (kg/\u33A1)',
                  'Crown fuel consumption', textStyle.color)
            ]
          : []),
      _buildRow(formatNumber(prediction.TFC), ' (kg/\u33A1)',
          'Total fuel consumption', textStyle.color),
      _buildRow(formatNumber(prediction.secondary?.FTFC), ' (kg/\u33A1)',
          'Total fuel consumption - flank', textStyle.color),
      _buildRow(formatNumber(prediction.secondary?.BTFC), ' (kg/\u33A1)',
          'Total fuel consumption - back', textStyle.color),
      // Fire growth potential
      _buildRow(prediction.WSV.toStringAsFixed(0), ' (km/h)',
          'Net effective wind speed', textStyle.color),
      _buildRow(
          '${degreesToCompassPoint(netEffectiveWindDirection)} ${netEffectiveWindDirection.toStringAsFixed(1)}',
          '\u00B0',
          'Net effective wind direction',
          textStyle.color),
      // Spread distance
      _buildRow(formatNumber(prediction.secondary?.RSO), ' (m/min)',
          'Surface fire rate of spread', textStyle.color),
      _buildRow(formatNumber(prediction.secondary?.LB), '',
          'Length to breadth ratio', textStyle.color),
      _buildRow(formatNumber(prediction.secondary?.DH), ' (m)',
          'Fire spread distance - head', textStyle.color),
      _buildRow(formatNumber(prediction.secondary?.DB), ' (m)',
          'Fire spread distance - flank', textStyle.color),
      _buildRow(formatNumber(prediction.secondary?.DF), ' (m)',
          'Fire spread distance - back', textStyle.color),
    ]);
  }
}

class PrimaryFireBehaviourGroup extends Group {
  PrimaryFireBehaviourGroup({required String heading, isExpanded = false})
      : super(heading: heading, isExpanded: isExpanded);

  @override
  Widget buildBody(
      FireBehaviourPredictionInput input,
      FireBehaviourPredictionPrimary prediction,
      double minutes,
      num surfaceFlameLength) {
    double? fireSize;
    if (prediction.secondary != null) {
      fireSize = getFireSize(
          input.FUELTYPE,
          prediction.ROS,
          prediction.secondary!.BROS,
          minutes,
          prediction.CFB,
          prediction.secondary!.LB);
    }
    TextStyle textStyle = const TextStyle(color: Colors.black);
    return buildContainer([
      _buildRow(
          getFireDescription(prediction.FD), '', 'Fire type', textStyle.color),
      ...(showCrown(input)
          ? [
              _buildRow(((prediction.CFB * 100).toStringAsFixed(0)), '%',
                  'Crown fraction burned', textStyle.color)
            ]
          : []),
      _buildRow(((prediction.ROS).toStringAsFixed(0)), ' (m/min)',
          'Rate of spread', textStyle.color),
      _buildRow(((prediction.ISI).toStringAsFixed(0)), '',
          'Initial Spread Index', textStyle.color),
      _buildRow(surfaceFlameLength.toStringAsFixed(2), ' (m)',
          'Surface flame length', textStyle.color),
      _buildRow(
          ((getHeadFireIntensityClass(prediction.HFI)).toStringAsFixed(0)),
          '',
          'Intensity class',
          textStyle.color),
      _buildRow(((prediction.HFI).toStringAsFixed(0)), ' (kW/m)',
          'Head fire intensity', textStyle.color),
      _buildRow('${fireSize?.toStringAsFixed(1)}', ' (ha)',
          '$minutes minute fire size', textStyle.color),
    ]);
  }
}

List<Group> generateGroups() {
  List<Group> groups = [
    PrimaryFireBehaviourGroup(
        heading: 'Basic Fire Behaviour Outputs', isExpanded: true),
    SecondaryFireBehaviourGroup(heading: 'Advanced Fire Behaviour Outputs'),
  ];
  return groups;
}

class ResultsState extends State<ResultsStateWidget> {
  final List<Group> _groups = generateGroups();

  Row buildRow(String value, String label, Color? color) {
    TextStyle valueStyle = TextStyle(
        color: color, fontWeight: FontWeight.bold, fontSize: fontSize);
    TextStyle labelStyle = TextStyle(color: color, fontSize: fontSize);
    return Row(children: [
      Expanded(
          flex: 5,
          child: Padding(
              padding: const EdgeInsets.only(right: 5.0),
              child:
                  Text(value, textAlign: TextAlign.right, style: valueStyle))),
      Expanded(flex: 6, child: Text(label, style: labelStyle)),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    // Need to have a bunch of panels:
    // https://api.flutter.dev/flutter/material/ExpansionPanelList-class.html
    return Container(
        // color: intensityClassColour,
        decoration: BoxDecoration(
            border: Border.all(color: widget.intensityClassColour),
            borderRadius: const BorderRadius.all(Radius.circular(5))),
        child: Column(
          children: [
            ExpansionPanelList(
                expandedHeaderPadding: const EdgeInsets.all(0),
                expansionCallback: (int index, bool isExpanded) {
                  setState(() {
                    _groups[index].isExpanded = isExpanded;
                  });
                  if (!isExpanded) {
                    // this doesn't seem perfect - we're waiting delaying
                    // by "kThemeAnimationDuration" (that's what
                    // ExpansionPanelList is using) - and then trying
                    // to make everything visible.
                    Future.delayed(kThemeAnimationDuration).then((value) => {
                          Scrollable.ensureVisible(context,
                              duration: const Duration(milliseconds: 200))
                        });
                  }
                },
                children: _groups.map<ExpansionPanel>((Group group) {
                  return ExpansionPanel(
                      backgroundColor: widget.intensityClassColour,
                      headerBuilder: (BuildContext context, bool isExpanded) {
                        return Row(
                          children: [
                            // using spacers to centre text horizontally
                            // const Spacer(),
                            Padding(
                              padding: const EdgeInsets.only(left: 10),
                              child: Text(group.heading,
                                  style: TextStyle(
                                      fontSize: fontSize,
                                      color: widget.intensityClassTextColor,
                                      fontWeight: FontWeight.bold)),
                            ),
                            // const Spacer()
                          ],
                        );
                      },
                      body: group.buildBody(widget.input, widget.prediction,
                          widget.minutes, widget.surfaceFlameLength),
                      isExpanded: group.isExpanded,
                      canTapOnHeader: true);
                }).toList()),
          ],
        ));
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

  const ResultsStateWidget(
      {required this.prediction,
      required this.minutes,
      required this.fireSize,
      required this.input,
      required this.intensityClass,
      required this.intensityClassColour,
      required this.intensityClassTextColor,
      required this.surfaceFlameLength,
      Key? key})
      : super(key: key);

  @override
  State<ResultsStateWidget> createState() => ResultsState();
}
