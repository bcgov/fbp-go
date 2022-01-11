// Define a custom Form widget.
import 'dart:developer';

import 'package:flutter/material.dart';

import 'coordinate_picker.dart';
import 'cffdrs/fbp_calc.dart';
import 'fbp_results.dart';
import 'fire.dart';
import 'fire_widgets.dart';

class AdvancedFireBehaviourPredictionForm extends StatefulWidget {
  const AdvancedFireBehaviourPredictionForm({Key? key}) : super(key: key);

  @override
  AdvancedFireBehaviourPredictionFormState createState() {
    return AdvancedFireBehaviourPredictionFormState();
  }
}

// Define a corresponding State class.
// This class holds data related to the form.
class AdvancedFireBehaviourPredictionFormState
    extends State<AdvancedFireBehaviourPredictionForm> {
  // Create a global key that uniquely identifies the Form widget
  // and allows validation of the form.
  //
  // Note: This is a `GlobalKey<FormState>`,
  // not a GlobalKey<MyCustomFormState>.
  final _formKey = GlobalKey<FormState>();
  FuelType _fuelType = FuelType.C2;
  late BasicInput _basicInput;
  double? _pc = 0;
  double? _pdf = 0;
  double? _cbh = 0;
  double _cfl = 0;
  double _minutes = 60;
  double _gfl = 0.35;
  double _theta = 0;

  bool _expanded = false;

  final _fuelTypeState = GlobalKey<FormFieldState>();

  void setPreset(FuelTypePreset preset) {
    setState(() {
      _fuelType = preset.code;
      _fuelTypeState.currentState?.didChange(_fuelType);

      _pc = preset.pc;
      pcController.text = _pc.toString();

      _pdf = preset.pdf;
      if (_pdf == null) {
        pdfController.text = '';
      } else {
        pdfController.text = _pdf.toString();
      }

      _cbh = preset.cbh;
      cbhController.text = _cbh.toString();

      _cfl = preset.cfl;
      _cflController.text = _cfl.toString();

      _basicInput.bui = preset.averageBUI;
    });
  }

  void _onPresetChanged(FuelTypePreset? preset) {
    if (preset != null) {
      setPreset(preset);
    }
  }

  void _onBasicInputChanged(BasicInput basicInput) {
    setState(() {
      _basicInput = basicInput;
    });
  }

  void _onFuelTypeChanged(FuelType fuelType) {
    setState(() {
      _fuelType = fuelType;
    });
  }

  void _onPCChanged(double pc) {
    setState(() {
      _pc = pc;
    });
  }

  void _onPDFChanged(double pdf) {
    setState(() {
      _pdf = pdf;
    });
  }

  void _onCBHChanged(double cbh) {
    setState(() {
      _cbh = cbh;
    });
  }

  void _onCFLChanged(double cfl) {
    setState(() {
      _cfl = cfl;
    });
  }

  void _onGFLChanged(double gfl) {
    setState(() {
      _gfl = gfl;
    });
  }

  void _onTChanged(double t) {
    setState(() {
      _minutes = t;
    });
  }

  void _onThetaChanged(double theta) {
    setState(() {
      _theta = theta;
    });
  }

  final ccController = TextEditingController();
  final pcController = TextEditingController();
  final pdfController = TextEditingController();
  final cbhController = TextEditingController();
  final _cflController = TextEditingController();
  final _gflController = TextEditingController();

  // double ros = _calculateRateOfSpread()

  @override
  void initState() {
    // _onPresetChanged(_getDefaultPreset());
    pcController.text = _pc.toString();
    pdfController.text = _pdf.toString();
    cbhController.text = _cbh.toString();
    _cflController.text = _cfl.toString();
    _gflController.text = _gfl.toString();
    _basicInput = BasicInput(
        ws: 5,
        bui: 0,
        coordinate: Coordinate(latitude: 37, longitude: -122, altitude: 100));
    super.initState();
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is removed from the
    // widget tree.
    ccController.dispose();
    pcController.dispose();
    pdfController.dispose();
    cbhController.dispose();
    _cflController.dispose();
    _gflController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double? fireSize;
    FireBehaviourPredictionPrimary? prediction;
    try {
      final dayOfYear = getDayOfYear();
      final input = FireBehaviourPredictionInput(
          FUELTYPE: _fuelType.name,
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
          PC: _pc,
          PDF: _pdf,
          GFL: _gfl,
          CC: _basicInput.cc,
          THETA: _theta,
          ACCEL: false,
          ASPECT: _basicInput.aspect,
          BUIEFF: true,
          CBH: _cbh,
          CFL: _cfl,
          HR: _minutes / 60.0);
      prediction = FBPcalc(input, output: "ALL");
      // Wind direction correction:
      prediction.RAZ -= 180;
      prediction.RAZ =
          prediction.RAZ < 0 ? prediction.RAZ + 360 : prediction.RAZ;
      // print('ffmc: $_ffmc');
      // print('day of year: $dayOfYear');
      log('prediction.SFC: ${prediction.SFC}');
      log('prediction.FMC: ${prediction.FMC}');
      log('prediction.WSV: ${prediction.WSV}');
      log('prediction.RAZ: ${prediction.RAZ}');
      log('prediction.ISI: ${prediction.ISI}');
      log('prediction.ROS: ${prediction.ROS}');
      log('prediction.CFB: ${prediction.CFB}');
      log('prediction.TFC: ${prediction.TFC}');
      log('prediction.HFI: ${prediction.HFI}');
      log('prediction.FD: ${prediction.FD}');
      log('prediction.FD: ${prediction.CFC}');
      if (prediction.secondary != null) {
        fireSize = getFireSize(
            _fuelType.name,
            prediction.ROS,
            prediction.secondary!.BROS,
            _minutes,
            prediction.CFB,
            prediction.secondary!.LB);
      }

      log('fireSize: $fireSize');
    } catch (e) {
      log('error $e');
    }
    // Build a Form widget using the _formKey created above.
    return Column(children: [
      Form(
        key: _formKey,
        child: Column(
          children: <Widget>[
            // Presets
            Row(children: [
              Expanded(child: FuelTypePresetDropdown(
                onChanged: (FuelTypePreset? value) {
                  _onPresetChanged(value);
                },
              ))
            ]),
            ExpansionPanelList(
              children: [
                ExpansionPanel(
                  headerBuilder: (context, isExpanded) {
                    return const ListTile(
                      title: Text(
                        'Advanced',
                        style: TextStyle(color: Colors.black),
                      ),
                    );
                  },
                  body: Column(children: <Widget>[
                    Row(
                      children: [
                        Expanded(
                            child: DropdownButtonFormField(
                                key: _fuelTypeState,
                                decoration: const InputDecoration(
                                    labelText: "Fuel Type"),
                                items: FuelType.values.map((FuelType value) {
                                  return DropdownMenuItem(
                                      value: value,
                                      child: Row(
                                        children: [
                                          // const Icon(Icons.park_outlined),
                                          Text(value.name)
                                        ],
                                      ));
                                }).toList(),
                                onChanged: (FuelType? value) {
                                  _onFuelTypeChanged(value!);
                                }))
                      ],
                    ),
                    Row(children: [
                      // CFL field
                      Expanded(
                          child: TextField(
                        controller: _cflController,
                        decoration: const InputDecoration(
                            labelText: "Crown Fuel Load (kg/m^2)"),
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          if (double.tryParse(value) != null) {
                            _onCFLChanged(double.parse(value));
                          }
                        },
                      )),
                      // GFL field
                      Expanded(
                          child: TextField(
                        controller: _gflController,
                        decoration: const InputDecoration(
                            labelText: "Grass Fuel Load (kg/m^2)"),
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          if (double.tryParse(value) != null) {
                            _onGFLChanged(double.parse(value));
                          }
                        },
                      )),
                    ]),
                    // PDF field
                    Row(children: [
                      Expanded(
                          child: TextField(
                        controller: pdfController,
                        decoration: const InputDecoration(
                            labelText: "Percent Dead Balsam Fir"),
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          if (double.tryParse(value) != null) {
                            _onPDFChanged(double.parse(value));
                          }
                        },
                      )),
                      // CBH field
                      Expanded(
                          child: TextField(
                        controller: cbhController,
                        decoration: const InputDecoration(
                            labelText: "Crown to base height (m)"),
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          if (double.tryParse(value) != null) {
                            _onCBHChanged(double.parse(value));
                          }
                        },
                      ))
                    ]),
                    Row(children: [
                      // PC field
                      Expanded(
                          child: TextField(
                        controller: pcController,
                        decoration:
                            const InputDecoration(labelText: "Percent Conifer"),
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          if (double.tryParse(value) != null) {
                            _onPCChanged(double.parse(value));
                          }
                        },
                      ))
                    ]),
                    // Ellapsed time
                    Row(children: [
                      Expanded(
                          child: Text(
                              'Time ellapsed: ${_minutes.toInt()} minutes')),
                      Expanded(
                          child: Slider(
                        value: _minutes,
                        min: 0,
                        max: 120,
                        divisions: 12,
                        label: '${_minutes.toInt()} minutes',
                        onChanged: (value) {
                          _onTChanged(value);
                        },
                      )),
                    ]),
                    // Theta
                    Row(children: [
                      Expanded(
                          child: Text(
                              'Theta: ${degreesToCompassPoint(_theta)} ${_theta.toString()}\u00B0')),
                      Expanded(
                          child: Slider(
                        value: _theta,
                        min: 0,
                        max: 360,
                        divisions: 16,
                        label: '${degreesToCompassPoint(_theta)} $_theta\u00B0',
                        onChanged: (value) {
                          _onThetaChanged(value);
                        },
                      )),
                    ]),
                  ]),
                  isExpanded: _expanded,
                  canTapOnHeader: true,
                ),
              ],
              expansionCallback: (panelIndex, isExpanded) {
                _expanded = !_expanded;
                setState(() {});
              },
            ),
            Row(
              children: [
                Expanded(
                  child: BasicInputWidget(
                    value: _basicInput,
                    onChanged: (BasicInput basicInput) {
                      _onBasicInputChanged(basicInput);
                    },
                  ),
                )
              ],
            ),
            // Text('Initial Spread Index: ${isi?.toStringAsFixed(0)}'),
            // Text('Foliar Moisture Content: ${fmc?.toStringAsFixed(0)}'),
            // Text('Surface Fuel Consumption (kg/m^2): ${sfc?.toStringAsFixed(0)}'),
            // Text(
            //     'Crown fraction burned: ${(cfb == null ? 0.0 : cfb * 100).toStringAsFixed(0)} %'),
            // Text('Fuel Consumption (kg/m^2): ${fc?.toStringAsFixed(0)}'),
            // Text('Rate of spread: ${ros?.toStringAsFixed(0)} (m/min)'),
            // Text(
            //   'Head fire intensity: ${hfi?.toStringAsFixed(0)} (kW/m)',
            //   style: TextStyle(
            //       backgroundColor: getIntensityClassColor(intensityClass!)),
            // ),
            // Text('Intensity class: $intensityClass',
            //     style: TextStyle(
            //         backgroundColor: getIntensityClassColor(intensityClass))),
            // Text('Type of fire: $fireDescription')
            // Text(
            //     // ignore: unnecessary_brace_in_string_interps
            //     'fuel: ${fuelType}, bui: ${_bui}, fmc: ${_fmc}, sfc: ${_sfc}, pc: ${_pc}, pdf: ${_pdf}, cc: ${_cc}, cbh: ${_cbh}, cfl: ${_cfl}'),
          ],
        ),
      ),
      prediction != null
          ? Results(
              prediction: prediction, minutes: _minutes, fireSize: fireSize)
          : Container(),
    ]);
  }
}
