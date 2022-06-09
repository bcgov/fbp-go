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
// Define a custom Form widget.
import 'package:fire_behaviour_app/persist.dart';
import 'package:flutter/material.dart';

import 'cffdrs/fbp_calc.dart';
import 'fancy_slider.dart';
import 'fbp_results.dart';
import 'fire.dart';
import 'fire_widgets.dart';
import 'basic_input.dart';
import 'global.dart';

class AdvancedFireBehaviourPredictionForm extends StatefulWidget {
  const AdvancedFireBehaviourPredictionForm({Key? key}) : super(key: key);

  @override
  AdvancedFireBehaviourPredictionFormState createState() {
    return AdvancedFireBehaviourPredictionFormState();
  }
}

// Define a corresponding State class.
// This class holds data related to the form.
// Decisions: No fuel type drop down, crown base height or crown fuel load,
// we rely solely on the presets:
// There's good reason for this. Tinkering directly with fuel type can be a bad
//  idea if you don't have all the knowledge. E.g. change the crown base
//  height, you'd probably also need to change the crown fuel load. If you
//  go playing around too much, you'll get unrealistic results. It's also
//  difficult balancing the input, if you choose a fuel type, it means we
//  we need to de-select the pre-set, which in turn results in the fuel type
//  changing. We can avoid that adventure by just getting rid of fuel type.
class AdvancedFireBehaviourPredictionFormState
    extends State<AdvancedFireBehaviourPredictionForm> {
  // Create a global key that uniquely identifies the Form widget
  // and allows validation of the form.
  //
  // Note: This is a `GlobalKey<FormState>`,
  // not a GlobalKey<MyCustomFormState>.
  final _formKey = GlobalKey<FormState>();
  // FuelType _fuelType = FuelType.C2;
  FuelTypePreset? _fuelTypePreset = getC2BorealSpruce();
  BasicInput? _basicInput;
  double? _pc = 0;
  double? _pdf = 0;
  double? _cbh = 0;
  double? _fmc = 0;
  double _cfl = 0;
  double _minutes = 60;
  double _gfl = defaultGFL;

  // bool _expanded = false;

  final _fuelTypeState = GlobalKey<FormFieldState>();

  void setPreset(FuelTypePreset preset) {
    setState(() {
      _fuelTypePreset = preset;
      _fuelTypeState.currentState?.didChange(_fuelTypePreset);

      _pc = preset.pc;
      _pdf = preset.pdf;

      _cbh = preset.cbh;
      cbhController.text = _cbh.toString();

      _gfl = defaultGFL;

      _cfl = preset.cfl;
      _cflController.text = _cfl.toString();
    });
  }

  void _onPresetChanged(FuelTypePreset? preset) {
    if (preset != null) {
      setPreset(preset);
      persistFuelTypePreset(preset);
    }
  }

  void _onBasicInputChanged(BasicInput basicInput) {
    setState(() {
      _basicInput = basicInput;
    });
  }

  void _onPCChanged(double pc) {
    setState(() {
      _pc = pc;
      if ((_pc ?? 0) + (_pdf ?? 0) > 100.0) {
        _pdf = 100.0 - _pc!;
      }
    });
  }

  void _onPDFChanged(double pdf) {
    setState(() {
      _pdf = pdf;
      if ((_pdf ?? 0) + (_pc ?? 0) > 100.0) {
        _pc = 100.0 - _pdf!;
      }
    });
  }

  void _onGFLChanged(double gfl) {
    gfl = pinGFL(gfl);
    setState(() {
      _gfl = gfl;
    });
    persistSetting('gfl', _gfl);
  }

  void _onTChanged(double t) {
    persistSetting('t', t);
    setState(() {
      _minutes = t;
    });
  }

  void _onFMCChanged(double fmc) {
    setState(() {
      _fmc = fmc;
    });
  }

  final ccController = TextEditingController();
  final cbhController = TextEditingController();
  final _cflController = TextEditingController();
  final _gflController = TextEditingController();

  // double ros = _calculateRateOfSpread()

  @override
  void initState() {
    // _onPresetChanged(_getDefaultPreset());
    cbhController.text = _cbh.toString();
    _cflController.text = _cfl.toString();
    _gflController.text = _gfl.toString();

    loadAdvanced().then((settings) {
      setPreset(settings.fuelTypePreset);
      setState(() {
        _basicInput = settings.basicInput;
        _gfl = defaultGFL;
        _gflController.text = _gfl.toString();
        _minutes = settings.t;
      });
    });

    super.initState();
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is removed from the
    // widget tree.
    ccController.dispose();
    cbhController.dispose();
    _cflController.dispose();
    _gflController.dispose();
    super.dispose();
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

  Expanded makeInputLabel(String heading, String value, String unitOfMeasure,
      TextStyle textStyle, TextStyle textStyleBold) {
    const labelFlex = 5;
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
    if (_basicInput == null || _fuelTypePreset == null) {
      return const Text('Loading...');
    }
    double? fireSize;
    final dayOfYear = getDayOfYear();
    final input = FireBehaviourPredictionInput(
        FUELTYPE: _fuelTypePreset!.code.name,
        LAT: _basicInput!.coordinate.latitude,
        LONG: _basicInput!.coordinate.longitude,
        ELV: _basicInput!.coordinate.altitude,
        DJ: dayOfYear,
        D0: null,
        FMC: null,
        FFMC: _basicInput!.ffmc,
        BUI: _basicInput!.bui,
        WS: _basicInput!.ws,
        WD: _basicInput!.waz,
        GS: _basicInput!.gs,
        PC: _pc,
        PDF: _pdf,
        GFL: _gfl,
        CC: _basicInput!.cc,
        THETA: 0, // we don't use THETA - so just default to 0
        ACCEL: false,
        ASPECT: _basicInput!.aspect,
        BUIEFF: true,
        CBH: _cbh,
        CFL: _cfl,
        HR: _minutes / 60.0);
    // print('advanced: ${input}');
    FireBehaviourPredictionPrimary prediction = FBPcalc(input, output: "ALL");
    _onFMCChanged(prediction.FMC);
    // Wind direction correction:
    prediction.RAZ -= 180;
    prediction.RAZ = prediction.RAZ < 0 ? prediction.RAZ + 360 : prediction.RAZ;
    if (prediction.secondary != null) {
      fireSize = getFireSize(
          _fuelTypePreset!.code.name,
          prediction.ROS,
          prediction.secondary!.BROS,
          _minutes,
          prediction.CFB,
          prediction.secondary!.LB);
    }
    final surfaceFlameLength = calculateApproxFlameLength(prediction.HFI);
    const sliderFlex = 10;
    final intensityClass = getHeadFireIntensityClass(prediction.HFI);
    final intensityClassColour = getIntensityClassColor(intensityClass);
    final intensityClassTextColour = getIntensityClassTextColor(intensityClass);
    const TextStyle textStyle = TextStyle(fontSize: fontSize);
    const TextStyle textStyleBold =
        TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold);
    // Build a Form widget using the _formKey created above.
    return Column(children: [
      Form(
        key: _formKey,
        child: Column(
          children: <Widget>[
            // Presets
            Row(children: [
              Expanded(
                  child: FuelTypePresetDropdown(
                onChanged: (FuelTypePreset? value) {
                  _onPresetChanged(value);
                },
                initialValue: _fuelTypePreset!,
              ))
            ]),
            if (isGrassFuelType(_fuelTypePreset!.code))
              Row(children: [
                // GFL field
                makeInputLabel('Grass Fuel Load', _gfl.toStringAsFixed(2),
                    ' kg/\u33A1', textStyle, textStyleBold),
                Expanded(
                    flex: sliderFlex,
                    child: FancySliderWidget(
                      value: _gfl,
                      min: minGFL,
                      max: maxGFL,
                      divisions: ((maxGFL - minGFL) / 0.05).round(),
                      activeColor: intensityClassColour,
                      label: '${_gfl.toStringAsFixed(2)} kg/\u33A1',
                      onChanged: (value) {
                        _onGFLChanged(value);
                      },
                    )),
              ]),
            // PDF field
            if (canAdjustDeadFir(_fuelTypePreset!.code))
              Row(
                children: [
                  makeInputLabel('Dead Balsam', (_pdf ?? 0).toStringAsFixed(0),
                      '%', textStyle, textStyleBold),
                  Expanded(
                      flex: sliderFlex,
                      child: FancySliderWidget(
                        value: _pdf ?? 0,
                        min: 0,
                        max: 100,
                        divisions: 100,
                        activeColor: intensityClassColour,
                        label: '${(_pdf ?? 0).toStringAsFixed(0)}%',
                        onChanged: (value) {
                          _onPDFChanged(value.roundToDouble());
                        },
                      ))
                ],
              ),
            if (isBorealMixedWood(_fuelTypePreset!.code))
              Row(children: [
                makeInputLabel('Conifer', (_pc ?? 0).toStringAsFixed(0), '%',
                    textStyle, textStyleBold),
                Expanded(
                    flex: sliderFlex,
                    child: FancySliderWidget(
                      value: _pc ?? 0,
                      min: 0,
                      max: 100,
                      divisions: 100,
                      activeColor: intensityClassColour,
                      label: '${(_pc ?? 0).toStringAsFixed(0)}%',
                      onChanged: (value) {
                        _onPCChanged(value.roundToDouble());
                      },
                    ))
              ]),
            // Elapsed time
            Row(children: [
              makeInputLabel('Time elapsed', '${_minutes.toInt()}', ' minutes',
                  textStyle, textStyleBold),
              Expanded(
                  flex: sliderFlex,
                  child: FancySliderWidget(
                    value: _minutes,
                    min: 0,
                    max: 120,
                    divisions: 12,
                    activeColor: intensityClassColour,
                    label: '${_minutes.toInt()} minutes',
                    onChanged: (value) {
                      _onTChanged(value.roundToDouble());
                    },
                  )),
            ]),
            Row(
              children: [
                Expanded(
                  child: BasicInputWidget(
                    basicInput: _basicInput!,
                    prediction: prediction,
                    fuelTypePreset: _fuelTypePreset!,
                    onChanged: (BasicInput basicInput) {
                      _onBasicInputChanged(basicInput);
                    },
                  ),
                )
              ],
            ),
          ],
        ),
      ),
      Padding(
          padding: const EdgeInsets.only(top: 2.0),
          child: ResultsStateWidget(
              prediction: prediction,
              minutes: _minutes,
              fireSize: fireSize,
              surfaceFlameLength: surfaceFlameLength,
              input: input,
              intensityClass: intensityClass,
              intensityClassColour: intensityClassColour,
              intensityClassTextColor: intensityClassTextColour))
    ]);
  }
}
