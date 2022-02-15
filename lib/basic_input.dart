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

import 'fire.dart';
import 'coordinate_picker.dart';

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

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // lat, long, elevation
        CoordinatePicker(onChanged: (coordinate) {
          _onCoordinateChanged(coordinate);
        }),
        // Wind Speed
        Row(children: [
          Expanded(child: Text('Wind Speed: ${_input.ws.toInt()} (km/h)')),
          Expanded(
              child: Slider(
            value: _input.ws,
            min: 0,
            max: 50,
            divisions: 100,
            label: '${_input.ws.toInt()} km/h',
            onChanged: (value) {
              _onWSChanged(value);
            },
          ))
        ]),
        // Wind Azimuth
        Row(children: [
          Expanded(
              child: Text(
                  'Wind Direction: ${degreesToCompassPoint(_input.waz)} ${_input.waz.toString()}\u00B0')),
          Expanded(
              child: Slider(
            value: _input.waz,
            min: 0,
            max: 360,
            divisions: 16,
            label: '${degreesToCompassPoint(_input.waz)} ${_input.waz}\u00B0',
            onChanged: (value) {
              _onWAZChanged(value);
            },
          )),
        ]),
        // Ground Slope
        Row(children: [
          Expanded(child: Text('Ground Slope: ${_input.gs.floor()}%')),
          Expanded(
              child: Slider(
            value: _input.gs,
            min: 0,
            max: 90,
            divisions: 18,
            label: '${_input.gs.floor()}%',
            onChanged: (value) {
              _onGSChanged(value);
            },
          )),
        ]),
        // Aspect
        Row(children: [
          Expanded(
              child: Text(
                  'Aspect: ${degreesToCompassPoint(_input.aspect)} ${_input.aspect.toString()}\u00B0')),
          Expanded(
              child: Slider(
            value: _input.aspect,
            min: 0,
            max: 360,
            divisions: 16,
            label:
                '${degreesToCompassPoint(_input.aspect)} ${_input.aspect.toString()}\u00B0',
            onChanged: (value) {
              _onAspectChanged(value);
            },
          )),
        ]),
        // BUI
        Row(children: [
          Expanded(child: Text('Buildup Index: ${_input.bui.toInt()}')),
          Expanded(
              child: Slider(
            value: _input.bui,
            min: 0,
            max: 200,
            divisions: 200,
            label: '${_input.bui.toInt()}',
            onChanged: (value) {
              _onBUIChanged(value);
            },
          )),
        ]),
        // FFMC
        Row(children: [
          Expanded(
              child: Text('Fine Fuel Moisture Code: ${_input.ffmc.toInt()}')),
          Expanded(
              child: Slider(
            value: _input.ffmc,
            min: 80,
            max: 100,
            divisions: 20,
            label: '${_input.ffmc.toInt()}',
            onChanged: (value) {
              _onFFMCChanged(value);
            },
          )),
        ]),
        // Curing
        Row(children: [
          Expanded(child: Text('Curing: ${_input.cc.toInt()}%')),
          Expanded(
              child: Slider(
            value: _input.cc,
            min: 0,
            max: 100,
            divisions: 20,
            label: '${_input.cc.toInt()}%',
            onChanged: (value) {
              _onCCChanged(value);
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

  const BasicInputWidget(
      {Key? key, required this.onChanged, required this.value})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return BasicInputState();
  }
}
