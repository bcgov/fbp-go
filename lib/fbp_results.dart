import 'package:flutter/material.dart';

import 'cffdrs/fbp_calc.dart';
import 'fire.dart';
import 'fire_widgets.dart';

class Results extends StatelessWidget {
  final FireBehaviourPredictionPrimary prediction;
  final int intensityClass;
  final double minutes;
  final double? fireSize;
  Results(
      {required this.prediction,
      required this.minutes,
      required this.fireSize,
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
            ...getSecondaryTextRow(prediction)
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

  List<Row> getSecondaryTextRow(FireBehaviourPredictionPrimary? prediction) {
    List<Row> rows = <Row>[];
    if (prediction != null) {
      var secondary = prediction.secondary;
      if (secondary != null) {
        for (var key in secondary.lookup.keys) {
          ValueDescriptionPair value = secondary.getProp(key);
          rows.add(Row(children: [
            Expanded(child: Text(value.description)),
            Expanded(child: Text(value.toString()))
          ]));
        }
      }
    }
    return rows;
  }
}
