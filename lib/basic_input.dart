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
import 'package:fire_behaviour_app/beaufort.dart';
import 'package:flutter/material.dart';

import 'cffdrs/fbp_calc.dart';
import 'fire.dart';
import 'coordinate_picker.dart';
import 'fire_widgets.dart';
import 'global.dart';

class BasicInput {
  double ws;
  double waz = 0;
  double gs = 0;
  double aspect = 0;
  double bui;
  double cc = 50;
  double ffmc = 80;

  Coordinate coordinate;

  BasicInput({
    required this.ws,
    required this.bui,
    required this.coordinate,
  });

  @override
  String toString() {
    return 'BasicInputStruct{ws: $ws, waz: $waz, gs: $gs, aspect: $aspect, bui: $bui, cc: $cc, ffmc: $ffmc, coordinate: $coordinate}';
  }
}

class BasicInputState extends State<BasicInputWidget> {
  late BasicInput _input;

  void _onWSChanged(double ws) {
    setState(() {
      _input.ws = ws;
    });
    widget.onChanged(_input);
  }

  void _onCoordinateChanged(coordinate) {
    setState(() {
      _input.coordinate = coordinate;
    });
    widget.onChanged(_input);
  }

  void _onWAZChanged(double waz) {
    setState(() {
      _input.waz = waz;
    });
    widget.onChanged(_input);
  }

  void _onGSChanged(double gs) {
    setState(() {
      _input.gs = gs;
    });
    widget.onChanged(_input);
  }

  void _onAspectChanged(double aspect) {
    setState(() {
      _input.aspect = aspect;
    });
    widget.onChanged(_input);
  }

  void _onBUIChanged(double bui) {
    setState(() {
      _input.bui = bui;
    });
    widget.onChanged(_input);
  }

  void _onCCChanged(double cc) {
    setState(() {
      _input.cc = cc;
    });
    widget.onChanged(_input);
  }

  void _onFFMCChanged(double ffmc) {
    setState(() {
      _input.ffmc = ffmc;
    });
    widget.onChanged(_input);
  }

  @override
  void initState() {
    _input = widget.value;
    super.initState();
  }

  Expanded makeLabel(String heading, String value, String unitOfMeasure,
      TextStyle textStyle, TextStyle textStyleBold) {
    const labelFlex = 4;
    return Expanded(
        flex: labelFlex,
        child: Column(children: [
          Row(children: [
            Text(heading, style: textStyle),
            Text(':', style: textStyle)
          ]),
          Row(children: [
            Text(value, style: textStyleBold),
            Text(unitOfMeasure, style: textStyle)
          ])
        ]));
  }

  @override
  Widget build(BuildContext context) {
    const sliderFlex = 10;
    final beaufortScale = getBeaufortScale(_input.ws);
    final intensityClass = getHeadFireIntensityClass(widget.prediction.HFI);
    final activeColor = getIntensityClassColor(intensityClass);
    const TextStyle textStyle = TextStyle(fontSize: fontSize);
    const TextStyle textStyleBold =
        TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold);
    return Column(
      children: [
        // lat, long, elevation
        CoordinatePicker(onChanged: (coordinate) {
          _onCoordinateChanged(coordinate);
        }),
        // Wind Speed
        Row(children: [
          makeLabel('Wind Speed', '${_input.ws.toInt()}', ' (km/h)', textStyle,
              textStyleBold),
          Expanded(
              flex: sliderFlex,
              child: Slider(
                value: _input.ws,
                min: 0,
                max: 50,
                divisions: 50,
                activeColor: activeColor,
                label:
                    '${_input.ws.toInt()} km/h\nBeaufort scale:\n${beaufortScale.range}\n${beaufortScale.description}\n${beaufortScale.effects}',
                onChanged: (value) {
                  // We need to round the wind speed. The slider doesn't give
                  // us nice clean whole numbers! This way we ensure we get
                  // that.
                  _onWSChanged(value.roundToDouble());
                },
              ))
        ]),
        // Wind Azimuth
        Row(children: [
          makeLabel(
              'Wind Direction',
              '${degreesToCompassPoint(_input.waz)} ${_input.waz.toString()}',
              '\u00B0',
              textStyle,
              textStyleBold),
          Expanded(
              flex: sliderFlex,
              child: Slider(
                value: _input.waz,
                min: 0,
                max: 360,
                divisions: 16,
                activeColor: activeColor,
                label:
                    '${degreesToCompassPoint(_input.waz)} ${_input.waz}\u00B0',
                onChanged: (value) {
                  _onWAZChanged(value);
                },
              )),
        ]),
        // Ground Slope
        Row(children: [
          makeLabel('Ground Slope', '${_input.gs.toInt()}', '%', textStyle,
              textStyleBold),
          Expanded(
              flex: sliderFlex,
              child: Slider(
                value: _input.gs,
                min: 0,
                max: 90,
                divisions: 18,
                activeColor: activeColor,
                label: '${_input.gs.toInt()}%',
                onChanged: (value) {
                  // We need to round the ground slope. The slider doesn't give
                  // us nice clean whole numbers! This way we ensure we get
                  // that.
                  _onGSChanged(value.roundToDouble());
                },
              )),
        ]),
        // Aspect
        Row(children: [
          makeLabel(
              'Aspect',
              '${degreesToCompassPoint(_input.aspect)} ${_input.aspect.toString()}',
              '\u00B0',
              textStyle,
              textStyleBold),
          Expanded(
              flex: sliderFlex,
              child: Slider(
                value: _input.aspect,
                min: 0,
                max: 360,
                divisions: 16,
                activeColor: activeColor,
                label:
                    '${degreesToCompassPoint(_input.aspect)} ${_input.aspect.toString()}\u00B0',
                onChanged: (value) {
                  _onAspectChanged(value);
                },
              )),
        ]),
        // BUI
        Row(children: [
          makeLabel('Buildup Index', '${_input.bui.toInt()}', '', textStyle,
              textStyleBold),
          Expanded(
              flex: sliderFlex,
              child: Slider(
                value: _input.bui,
                min: 0,
                max: 200,
                divisions: 40,
                activeColor: activeColor,
                label: '${_input.bui.toInt()}',
                onChanged: (value) {
                  // We need to round the buildup index. The slider doesn't give
                  // us nice clean whole numbers! This way we ensure we get
                  // that.
                  _onBUIChanged(value.roundToDouble());
                },
              )),
        ]),
        // FFMC
        Row(children: [
          makeLabel(
              'FFMC', '${_input.ffmc.toInt()}', '', textStyle, textStyleBold),
          Expanded(
              flex: sliderFlex,
              child: Slider(
                value: _input.ffmc,
                min: 80,
                max: 100,
                divisions: 20,
                activeColor: activeColor,
                label: '${_input.ffmc.toInt()}',
                onChanged: (value) {
                  // We need to round the FFMC. The slider doesn't give
                  // us nice clean whole numbers! This way we ensure we get
                  // that.
                  _onFFMCChanged(value.roundToDouble());
                },
              )),
        ]),
        // Curing
        Row(children: [
          makeLabel(
              'Curing', '${_input.cc.toInt()}', '%', textStyle, textStyleBold),
          Expanded(
              flex: sliderFlex,
              child: Slider(
                value: _input.cc,
                min: 0,
                max: 100,
                divisions: 20,
                label: '${_input.cc.toInt()}%',
                activeColor: activeColor,
                onChanged: (value) {
                  // We need to round the curing. The slider doesn't give
                  // us nice clean whole numbers! This way we ensure we get
                  // that.
                  _onCCChanged(value.roundToDouble());
                },
              )),
        ]),
      ],
    );
  }
}

class BasicInputWidget extends StatefulWidget {
  final Function onChanged;
  final BasicInput value;
  final FireBehaviourPredictionPrimary prediction;

  const BasicInputWidget(
      {Key? key,
      required this.onChanged,
      required this.value,
      required this.prediction})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return BasicInputState();
  }
}
