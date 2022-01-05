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
    return Column(
      children: [
        Row(children: [
          const Expanded(child: Text('Initial Spread Index')),
          Expanded(
            child: Text(prediction.ISI.toStringAsFixed(0)),
          )
        ]),
        Row(children: [
          const Expanded(child: Text('Foliar Moisture Content')),
          Expanded(child: Text(prediction.FMC.toStringAsFixed(0)))
        ]),
        Row(children: [
          const Expanded(child: Text('Surface Fuel Consumption')),
          Expanded(child: Text('${prediction.SFC.toStringAsFixed(0)} (kg/m^2)'))
        ]),
        Row(children: [
          const Expanded(child: Text('Crown fraction burned')),
          Expanded(
              child: Text('${((prediction.CFB * 100).toStringAsFixed(0))} %'))
        ]),
        Row(children: [
          const Expanded(child: Text('Fuel Consumption')),
          Expanded(child: Text('${prediction.TFC.toStringAsFixed(2)} (kg/m^2)'))
        ]),
        Container(
            color: getIntensityClassColor(intensityClass),
            child: Row(children: [
              const Expanded(child: Text('Rate of spread')),
              Expanded(
                  child: Text('${prediction.ROS.toStringAsFixed(0)} (m/min)')),
            ])),
        Container(
            color: getIntensityClassColor(intensityClass),
            child: Row(children: [
              const Expanded(child: Text('Head fire intensity')),
              Expanded(
                  child: Text('${prediction.HFI.toStringAsFixed(0)} (kW/m)')),
            ])),
        Container(
            color: getIntensityClassColor(intensityClass),
            child: Row(children: [
              const Expanded(child: Text('Intensity class')),
              Expanded(child: Text('$intensityClass')),
            ])),
        Row(children: [
          const Expanded(child: Text('Type of fire')),
          Expanded(child: Text(getFireDescription(prediction.FD)))
        ]),
        Row(children: [
          const Expanded(child: Text('Crown Fuel Consumption')),
          Expanded(child: Text('${prediction.CFC.toStringAsFixed(0)} (kg/m^2)'))
        ]),
        Row(children: [
          Expanded(
              child: Text('${minutes.toStringAsFixed(0)} minute fire size')),
          Expanded(child: Text('${fireSize?.toStringAsFixed(0)} (ha)'))
        ]),
        Row(children: [
          const Expanded(child: Text('Back rate of spread')),
          Expanded(
              child: Text(
                  '${prediction.secondary?.BROS.toStringAsFixed(0)} (m/min)'))
        ]),
        Row(children: [
          const Expanded(child: Text('Length to breadth ratio')),
          Expanded(
              child: Text('${prediction.secondary?.LB.toStringAsFixed(2)}'))
        ]),
        Row(children: [
          const Expanded(child: Text('Net effective wind speed')),
          Expanded(child: Text('${prediction.WSV.toStringAsFixed(0)} (km/h)'))
        ]),
        Row(children: [
          const Expanded(child: Text('Net effective wind direction')),
          Expanded(
              child: Text(
                  '${degreesToCompassPoint(prediction.RAZ)} ${prediction.RAZ.toStringAsFixed(1)}(\u00B0)'))
        ]),
        ...getSecondaryTextRow(prediction)
      ],
    );
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
            Expanded(child: Text(value.valueToString()))
          ]));
        }
      }
    }
    return rows;
  }
}
