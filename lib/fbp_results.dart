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
import 'fire_widgets.dart';

class Results extends StatelessWidget {
  final FireBehaviourPredictionPrimary prediction;
  final FireBehaviourPredictionInput input;

  final int intensityClass;
  final double minutes;
  final double? fireSize;
  Results(
      {required this.prediction,
      required this.minutes,
      required this.fireSize,
      required this.input,
      Key? key})
      : intensityClass = getHeadFireIntensityClass(prediction.HFI),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    TextStyle textStyle = getTextStyle(prediction.FD);
    return Container(
        color: getIntensityClassColor(intensityClass),
        child: Column(
          children: [
            Row(children: [
              Expanded(child: Text('Crown Fuel Load', style: textStyle)),
              Expanded(child: Text('${input.CFL} (kg/m^2)'))
            ]),
            Row(children: [
              Expanded(child: Text('Crown to base height', style: textStyle)),
              Expanded(child: Text('${input.CBH} (m)'))
            ]),
            ...getPrimaryTextRow(prediction, textStyle),
            Row(children: [
              Expanded(
                  child: Text(
                'Intensity class',
                style: textStyle,
              )),
              Expanded(child: Text('$intensityClass', style: textStyle)),
            ]),
            Row(children: [
              Expanded(
                  child: Text('${minutes.toStringAsFixed(0)} minute fire size',
                      style: textStyle)),
              Expanded(
                  child: Text(
                '${fireSize?.toStringAsFixed(0)} (ha)',
                style: textStyle,
              ))
            ]),
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
        rows.add(Row(children: [
          Expanded(child: Text(value.description, style: textStyle)),
          Expanded(child: Text(value.toString(), style: textStyle))
        ]));
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
          rows.add(Row(children: [
            Expanded(
                child: Text(
              value.description,
              style: textStyle,
            )),
            Expanded(child: Text(value.toString(), style: textStyle))
          ]));
        }
      }
    }
    return rows;
  }
}
