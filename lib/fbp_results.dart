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
import 'fire_widgets.dart';
import 'global.dart';

class Results extends StatelessWidget {
  final FireBehaviourPredictionPrimary prediction;
  final FireBehaviourPredictionInput input;

  final int intensityClass;
  final Color intensityClassColour;
  final double minutes;
  final double? fireSize;
  const Results(
      {required this.prediction,
      required this.minutes,
      required this.fireSize,
      required this.input,
      required this.intensityClass,
      required this.intensityClassColour,
      Key? key})
      : super(key: key);

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
    TextStyle textStyle = getTextStyle(prediction.FD);
    // Need to have a bunch of panels:
    // https://api.flutter.dev/flutter/material/ExpansionPanelList-class.html
    return Container(
        // color: intensityClassColour,
        decoration: BoxDecoration(
            border: Border.all(color: intensityClassColour),
            borderRadius: const BorderRadius.all(Radius.circular(5))),
        child: Column(
          children: [
            Container(
                color: intensityClassColour,
                child: Row(
                  children: const [Text('')],
                )),
            buildRow(
                '${input.CFL} (kg/m^2)', 'Crown Fuel Load', textStyle.color),
            buildRow(
                '${input.CBH} (m)', 'Crown to base height', textStyle.color),
            ...getPrimaryTextRow(prediction, textStyle),
            buildRow('$intensityClass', 'Intensity class', textStyle.color),
            buildRow(
                '${fireSize?.toStringAsFixed(0)} (ha)',
                '${minutes.toStringAsFixed(0)} minute fire size',
                textStyle.color),
            ...getSecondaryTextRow(prediction, textStyle),
          ],
        ));
  }

  List<Row> getPrimaryTextRow(
      FireBehaviourPredictionPrimary? prediction, TextStyle textStyle) {
    List<Row> rows = <Row>[];
    if (prediction != null) {
      for (var key in prediction.lookup.keys) {
        ValueDescriptionPair value = prediction.getProp(key);
        rows.add(
            buildRow(value.toString(), value.description, textStyle.color));
      }
    }
    return rows;
  }

  List<Row> getSecondaryTextRow(
      FireBehaviourPredictionPrimary? prediction, TextStyle textStyle) {
    List<Row> rows = <Row>[];
    if (prediction != null) {
      var secondary = prediction.secondary;
      if (secondary != null) {
        for (var key in secondary.lookup.keys) {
          ValueDescriptionPair value = secondary.getProp(key);
          rows.add(
              buildRow(value.toString(), value.description, textStyle.color));
        }
      }
    }
    return rows;
  }
}
