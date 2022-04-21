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
import 'dart:developer';

import 'package:flutter/material.dart';

import 'coordinate_picker.dart';
import 'cffdrs/fbp_calc.dart';
import 'fire_widgets.dart';
import 'fire.dart';
import 'basic_input.dart';
import 'global.dart';

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

  List<Widget> buildRows(TextStyle textStyle, Color intensityClassColor,
      Color intensityClassTextColor) {
    TextStyle labelStyle = const TextStyle(
        fontSize: fontSize, color: Colors.black, fontWeight: FontWeight.bold);
    List<Widget> rows = [
      Container(
          color: intensityClassColor,
          child: Row(
            children: [
              const Spacer(),
              Text('Fire Behaviour Outputs', style: labelStyle),
              const Spacer()
            ],
          )),
      // Fire type
      buildRow(getFireDescription(prediction.FD), 'Fire type', textStyle.color),
      // Crown fraction burned
      buildRow('${((prediction.CFB * 100).toStringAsFixed(0))}%',
          'Crown fraction burned (CFB)', textStyle.color),
      // Rate of spread
      buildRow('${prediction.ROS.toStringAsFixed(0)} (m/min)',
          'Rate of spread (ROS)', textStyle.color),
      // ISI
      buildRow(prediction.ISI.toStringAsFixed(0), 'Initial spread index (ISI)',
          textStyle.color),
      // Surface flame length (TBD!)
      // Intensity class
      buildRow('$intensityClass', 'Intensity class', textStyle.color),
      // HFI
      buildRow('${prediction.HFI.toStringAsFixed(0)} (kW/m)',
          'Head fire intensity (HFI)', textStyle.color),
      // 60 minute fire size
      buildRow('${fireSize?.toStringAsFixed(0)} (ha)',
          '${minutes.toStringAsFixed(0)} minute fire size', textStyle.color),
    ];

    if (prediction.WSV != 0) {
      rows.add(buildRow(
          '${degreesToCompassPoint(prediction.RAZ)} ${prediction.RAZ.toStringAsFixed(1)}\u00B0',
          'Direction of spread',
          textStyle.color));
    }

    return rows;
  }

  @override
  Widget build(BuildContext context) {
    Color intensityClassColor = getIntensityClassColor(intensityClass);
    Color intensityTextColor = getIntensityClassTextColor(intensityClass);
    return Container(
        decoration: BoxDecoration(
            border: Border.all(color: intensityClassColor),
            borderRadius: const BorderRadius.all(Radius.circular(5))),
        child: Column(
            children: buildRows(getTextStyle(prediction.FD),
                intensityClassColor, intensityTextColor)));
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
                      prediction: prediction,
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
