import 'dart:developer';

import 'package:flutter/material.dart';

import 'coordinate_picker.dart';
import 'cffdrs/fbp_calc.dart';
import 'fire_widgets.dart';
import 'fire.dart';
import 'basic_input.dart';

class BasicResults extends StatelessWidget {
  final FireBehaviourPredictionPrimary prediction;
  final int intensityClass;
  final double minutes;
  final double? fireSize;
  BasicResults(
      {required this.prediction,
      required this.minutes,
      required this.fireSize,
      Key? key})
      : intensityClass = getHeadFireIntensityClass(prediction.HFI),
        super(key: key);

  List<Widget> buildRows(TextStyle textStyle) {
    List<Widget> rows = [
      Row(children: [
        Expanded(child: Text('Initial Spread Index', style: textStyle)),
        Expanded(
          child: Text(
            prediction.ISI.toStringAsFixed(0),
            style: textStyle,
          ),
        )
      ]),
      Row(children: [
        Expanded(child: Text('Crown fraction burned', style: textStyle)),
        Expanded(
            child: Text('${((prediction.CFB * 100).toStringAsFixed(0))} %',
                style: textStyle))
      ]),
      Row(children: [
        Expanded(child: Text('Rate of spread', style: textStyle)),
        Expanded(
            child: Text('${prediction.ROS.toStringAsFixed(0)} (m/min)',
                style: textStyle)),
      ]),
      Row(children: [
        Expanded(child: Text('Head fire intensity', style: textStyle)),
        Expanded(
            child: Text('${prediction.HFI.toStringAsFixed(0)} (kW/m)',
                style: textStyle)),
      ]),
      Row(children: [
        Expanded(child: Text('Intensity class', style: textStyle)),
        Expanded(child: Text('$intensityClass', style: textStyle)),
      ]),
      Row(children: [
        Expanded(child: Text('Type of fire', style: textStyle)),
        Expanded(
            child: Text(getFireDescription(prediction.FD), style: textStyle))
      ]),
      Row(children: [
        Expanded(
            child: Text('${minutes.toStringAsFixed(0)} minute fire size',
                style: textStyle)),
        Expanded(
            child:
                Text('${fireSize?.toStringAsFixed(0)} (ha)', style: textStyle))
      ])
    ];

    if (prediction.WSV != 0) {
      rows.add(Row(children: [
        Expanded(child: Text('Direction of spread', style: textStyle)),
        Expanded(
            child: Text(
                '${degreesToCompassPoint(prediction.RAZ)} ${prediction.RAZ.toStringAsFixed(1)}(\u00B0)',
                style: textStyle))
      ]));
    }

    return rows;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        color: getIntensityClassColor(intensityClass),
        child: Column(children: buildRows(getTextStyle(prediction.FD))));
  }
}

class BasicFireBehaviourPredictionFormState
    extends State<BasicFireBehaviourPredictionForm> {
  FuelTypePreset _fuelTypePreset = getC2BorealSpruce();
  late BasicInput _basicInput;

  void _onPresetChanged(FuelTypePreset fuelTypePreset) {
    setState(() {
      log('preset changed to $fuelTypePreset');
      _fuelTypePreset = fuelTypePreset;
      _basicInput.bui = _fuelTypePreset.averageBUI;
    });
  }

  void _onBasicInputChanged(BasicInput basicInput) {
    setState(() {
      _basicInput = basicInput;
    });
  }

  @override
  void initState() {
    _basicInput = BasicInput(
        ws: 5,
        bui: _fuelTypePreset.averageBUI,
        coordinate: Coordinate(latitude: 37, longitude: -122, altitude: 100));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final dayOfYear = getDayOfYear();
    const double minutes = 60; // 60 minutes.
    final input = FireBehaviourPredictionInput(
        FUELTYPE: _fuelTypePreset.code.name,
        LAT: _basicInput.coordinate.latitude,
        LONG: _basicInput.coordinate.longitude,
        ELV: _basicInput.coordinate.altitude,
        DJ: dayOfYear,
        D0: null,
        FMC: null,
        FFMC: _basicInput.ffmc,
        BUI: _basicInput.bui,
        WS: _basicInput.ws,
        WD: _basicInput.waz,
        GS: _basicInput.gs,
        PC: _fuelTypePreset.pc,
        PDF: _fuelTypePreset.pdf,
        GFL: _fuelTypePreset.gfl,
        CC: _basicInput.cc,
        ACCEL: false,
        ASPECT: _basicInput.aspect,
        BUIEFF: true,
        CBH: _fuelTypePreset.cbh,
        CFL: _fuelTypePreset.cfl,
        HR: minutes / 60.0);
    try {
      FireBehaviourPredictionPrimary prediction = FBPcalc(input, output: "ALL");
      prediction.RAZ =
          prediction.RAZ < 0 ? prediction.RAZ + 360 : prediction.RAZ;
      double? fireSize;
      if (prediction.secondary != null) {
        fireSize = getFireSize(
            _fuelTypePreset.code.name,
            prediction.ROS,
            prediction.secondary!.BROS,
            minutes,
            prediction.CFB,
            prediction.secondary!.LB);
      }
      return Column(
        children: <Widget>[
          // Presets
          Row(children: [
            Expanded(child: FuelTypePresetDropdown(
              onChanged: (FuelTypePreset? value) {
                if (value != null) {
                  _onPresetChanged(value);
                }
              },
            ))
          ]),
          Row(
            children: [
              Expanded(
                  child: BasicInputWidget(
                      value: _basicInput,
                      onChanged: (BasicInput basicInput) {
                        _onBasicInputChanged(basicInput);
                      }))
            ],
          ),
          BasicResults(
              prediction: prediction, minutes: minutes, fireSize: fireSize)
        ],
      );
    } catch (e) {
      return Text('$e');
    }
  }
}

class BasicFireBehaviourPredictionForm extends StatefulWidget {
  const BasicFireBehaviourPredictionForm({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return BasicFireBehaviourPredictionFormState();
  }
}
