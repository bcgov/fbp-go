/*
Copyright 2022 Province of British Columbia

This file is part of FBP Go.

FBP Go is free software: This program is free software; you can
redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with 
FBP Go. If not, see <https://www.gnu.org/licenses/>.
*/

import 'package:flutter/material.dart';

import 'cffdrs/ffmc_calc.dart';
import 'fancy_slider.dart';

class FWIForm extends StatefulWidget {
  const FWIForm({Key? key}) : super(key: key);

  @override
  FWIFormState createState() {
    return FWIFormState();
  }
}

class FWIFormState extends State<FWIForm> {
  final _formKey = GlobalKey<FormState>();
  double _ffmc = 10;
  double _temp = 10;
  double _rh = 10;
  double _ws = 10;
  double _prec = 10;

  void _onFFMChanged(double ffmc) {
    setState(() {
      _ffmc = ffmc;
    });
  }

  void _onTempChanged(double temperature) {
    setState(() {
      _temp = temperature;
    });
  }

  void _onRHChanged(double rh) {
    setState(() {
      _rh = rh;
    });
  }

  void _onWSChanged(double ws) {
    setState(() {
      _ws = ws;
    });
  }

  void _onPrecChanged(double prec) {
    setState(() {
      _prec = prec;
    });
  }

  Expanded makeInputLabel(String heading, String value, String unitOfMeasure) {
    return Expanded(
        flex: 3,
        child: Column(children: [
          Row(children: [Text(heading), const Text(':')]),
          Row(children: [Text(value), Text(unitOfMeasure)])
        ]));
  }

  @override
  Widget build(BuildContext context) {
    const sliderFlex = 7;
    return Column(
      children: [
        Form(
            key: _formKey,
            child: Column(children: <Widget>[
              Row(
                children: [
                  makeInputLabel('Initial FFMC', '$_ffmc', ''),
                  Expanded(
                      flex: sliderFlex,
                      child: FancySliderWidget(
                        value: _ffmc,
                        min: 0,
                        max: 100,
                        divisions: 100,
                        label: '$_ffmc',
                        onChanged: (double value) {
                          _onFFMChanged(value.roundToDouble());
                        },
                        activeColor: Colors.blue,
                      ))
                ],
              ),
              Row(children: [
                makeInputLabel('Temperature', '$_temp', '°C'),
                Expanded(
                  flex: sliderFlex,
                  child: FancySliderWidget(
                    value: _temp,
                    min: 0,
                    max: 50,
                    divisions: 50,
                    label: '$_temp',
                    onChanged: (double value) {
                      _onTempChanged(value.roundToDouble());
                    },
                    activeColor: Colors.blue,
                  ),
                )
              ]),
              Row(children: [
                makeInputLabel('Relative Humidity', '$_rh', '%'),
                Expanded(
                  flex: sliderFlex,
                  child: FancySliderWidget(
                    value: _rh,
                    min: 0,
                    max: 100,
                    divisions: 100,
                    label: '$_rh',
                    onChanged: (double value) {
                      _onRHChanged(value.roundToDouble());
                    },
                    activeColor: Colors.blue,
                  ),
                )
              ]),
              Row(children: [
                makeInputLabel('Wind Speed', '$_ws', 'm/s'),
                Expanded(
                  flex: sliderFlex,
                  child: FancySliderWidget(
                    value: _ws,
                    min: 0,
                    max: 100,
                    divisions: 100,
                    label: '$_ws',
                    onChanged: (double value) {
                      _onWSChanged(value.roundToDouble());
                    },
                    activeColor: Colors.blue,
                  ),
                )
              ]),
              Row(children: [
                makeInputLabel('Precipitation', '$_prec', 'mm'),
                Expanded(
                  flex: sliderFlex,
                  child: FancySliderWidget(
                    value: _prec,
                    min: 0,
                    max: 100,
                    divisions: 100,
                    label: '$_prec',
                    onChanged: (double value) {
                      _onPrecChanged(value.roundToDouble());
                    },
                    activeColor: Colors.blue,
                  ),
                )
              ]),
              // results
              Row(
                children: [
                  Text(
                      'Next Day FFMC ${ffmcCalc(_ffmc, _temp, _rh, _ws, _prec)}')
                ],
              )
            ]))
      ],
    );
  }
}
