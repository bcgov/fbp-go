import 'package:fire_behaviour_app/fire.dart';
import 'package:flutter/material.dart';
// import 'package:flutter/scheduler.dart';
import 'package:geolocator/geolocator.dart';
import 'cffdrs/fbp_calc.dart';
import 'fbp_results.dart';

void main() => runApp(const MyApp());

int getDayOfYear() {
  final now = DateTime.now();
  final diff = now.difference(DateTime(now.year, 1, 1, 0, 0));
  return diff.inDays;
}

Color getIntensityClassColor(int? intensityClass) {
  switch (intensityClass) {
    case 1:
      return Colors.blueGrey.shade700;
    case 2:
      return Colors.blueGrey.shade500;
    case 3:
      return Colors.blueGrey.shade200;
    case 4:
      return Colors.red.shade200;
    case 5:
      return Colors.red;
    case 6:
      return Colors.red.shade700;
    default:
      throw Exception('Invalid intensity class');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
        title: 'Fire Behaviour Prediction', home: HomePage());
  }
}

class BasicFireBehaviourPredictionForm extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return BasicFireBehaviourPredictionFormState();
  }
}

// Define a custom Form widget.
class AdvancedFireBehaviourPredictionForm extends StatefulWidget {
  const AdvancedFireBehaviourPredictionForm({Key? key}) : super(key: key);

  @override
  AdvancedFireBehaviourPredictionFormState createState() {
    return AdvancedFireBehaviourPredictionFormState();
  }
}

String getSecondaryText(FireBehaviourPredictionPrimary? prediction) {
  if (prediction != null && prediction.secondary != null) {
    return prediction.secondary.toString();
  }
  return '';
}

class FuelTypeStruct {
  final FuelType code;
  final String description;
  final double cfl;
  final double? pc;
  final double? pdf;
  final double? cbh;
  FuelTypeStruct(this.code, this.description,
      {required this.cfl, this.pc, this.pdf, this.cbh});
}

class BasicFireBehaviourPredictionFormState
    extends State<BasicFireBehaviourPredictionForm> {
  @override
  Widget build(BuildContext context) {
    throw UnimplementedError();
  }
}

enum FuelType {
  // ignore: constant_identifier_names
  C1,
  // ignore: constant_identifier_names
  C2,
  // ignore: constant_identifier_names
  C3,
  // ignore: constant_identifier_names
  C4,
  // ignore: constant_identifier_names
  C5,
  // ignore: constant_identifier_names
  C6,
  // ignore: constant_identifier_names
  C7,
  // ignore: constant_identifier_names
  D1,
  // ignore: constant_identifier_names
  D2,
  // ignore: constant_identifier_names
  M1,
  // ignore: constant_identifier_names
  M2,
  // ignore: constant_identifier_names
  M3,
  // ignore: constant_identifier_names
  M4,
  // ignore: constant_identifier_names
  O1A,
  // ignore: constant_identifier_names
  O1B,
  // ignore: constant_identifier_names
  S1,
  // ignore: constant_identifier_names
  S2,
  // ignore: constant_identifier_names
  S3
}

List<FuelTypeStruct> getFuelTypePresets() {
  return [
    FuelTypeStruct(FuelType.C1, 'C-1 spruce-lichen woodland',
        cfl: 0.75, pc: 100, cbh: 2),
    FuelTypeStruct(FuelType.C2, 'C-2 boreal spruce', cfl: 0.8, pc: 100, cbh: 3),
    FuelTypeStruct(FuelType.C3, 'C-3 mature jack or lodgepole pine',
        cfl: 1.15, pc: 100, cbh: 3),
    FuelTypeStruct(FuelType.C4, 'C-4 immature jack or lodgepole pine',
        cfl: 1.2, pc: 100, cbh: 4),
    FuelTypeStruct(FuelType.C5, 'C-5 red and white pine',
        cfl: 1.2, pc: 100, cbh: 18),
    FuelTypeStruct(FuelType.C6, 'C-6 conifer plantation, 7-m CBH',
        cfl: 1.8, pc: 100, cbh: 7),
    FuelTypeStruct(FuelType.C6, 'C-6 conifer plantation, 2-m CBH',
        cfl: 1.8, pc: 100, cbh: 7),
    FuelTypeStruct(FuelType.C7, 'C-7 ponderosa pine/Douglas-far',
        cfl: 0.5, pc: 100, cbh: 10),
    FuelTypeStruct(FuelType.D1, 'D-1 leafless aspen', cfl: 1.0),
    FuelTypeStruct(FuelType.D2, 'D-2 green aspen', cfl: 1.0),
    FuelTypeStruct(FuelType.M1, 'M-1 boreal mixedwood-leafless, 75% conifer',
        cfl: 0.8, pc: 75, cbh: 6),
    FuelTypeStruct(FuelType.M1, 'M-1 boreal mixedwood-leafless, 50% conifer',
        cfl: 0.8, pc: 50, cbh: 6),
    FuelTypeStruct(FuelType.M1, 'M-1 boreal mixedwood-leafless, 25% conifer',
        cfl: 0.8, pc: 25, cbh: 6),
    FuelTypeStruct(FuelType.M2, 'M-2 boreal mixedwood-green, 75% conifer',
        cfl: 0.8, pc: 75, cbh: 6),
    FuelTypeStruct(FuelType.M2, 'M-2 boreal mixedwood-green, 50% conifer',
        cfl: 0.8, pc: 50, cbh: 6),
    FuelTypeStruct(FuelType.M2, 'M-2 boreal mixedwood-green, 25% conifer',
        cfl: 0.8, pc: 25, cbh: 6),
    FuelTypeStruct(
        FuelType.M3, 'M-3 dead balsam mixedwood-leafless, 30% dead fir',
        cfl: 0.8, pdf: 30, cbh: 6),
    FuelTypeStruct(
        FuelType.M3, 'M-3 dead balsam mixedwood-leafless, 60% dead fir',
        cfl: 0.8, pdf: 60, cbh: 6),
    FuelTypeStruct(
        FuelType.M3, 'M-3 dead balsam mixedwood-leafless, 100% dead fir',
        cfl: 0.8, pdf: 100, cbh: 6),
    FuelTypeStruct(FuelType.M4, 'M-4 dead balsam mixedwood-green, 30% dead fir',
        cfl: 0.8, pdf: 30, cbh: 6),
    FuelTypeStruct(FuelType.M4, 'M-4 dead balsam mixedwood-green, 60% dead fir',
        cfl: 0.8, pdf: 60, cbh: 6),
    FuelTypeStruct(
        FuelType.M4, 'M-4 dead balsam mixedwood-green, 100% dead fir',
        cfl: 0.8, pdf: 100, cbh: 6),
    FuelTypeStruct(FuelType.O1A, 'O-1a matted grass', cfl: 1.0),
    FuelTypeStruct(FuelType.O1B, 'O-1b standing grass', cfl: 1.0),
    FuelTypeStruct(FuelType.S1, 'S-1 jack or lodgepole pine slash', cfl: 1.0),
    FuelTypeStruct(FuelType.S2, 'S-2 white spruce/balsam slash', cfl: 1.0),
    FuelTypeStruct(FuelType.S3, 'S-3 coastal cedar/hemlock/Douglas-fir slash',
        cfl: 1.0),
  ];
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
  FuelTypeStruct? _preset;
  double _bui = 50;
  double _ffmc = 77;
  double? _pc = 0;
  double? _pdf = 0;
  double _cc = 50;
  double? _cbh = 0;
  double _cfl = 0;
  double _latitude = 37;
  double _longitude = -122;
  double _elevation = 5;
  double _ws = 5;
  double _waz = 0;
  double _gs = 0;
  double _aspect = 0;
  double _t = 60;
  double _gfl = 0.35;
  double _theta = 0;

  bool _expanded = false;

  final _presetState = GlobalKey<FormFieldState>();

  final List<FuelTypeStruct> _presets = getFuelTypePresets();

  FuelTypeStruct _getDefaultPreset() {
    return _presets[1];
  }

  final _fuelTypeState = GlobalKey<FormFieldState>();

  void setPreset(FuelTypeStruct preset) {
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
    });
  }

  void _onPresetChanged(FuelTypeStruct? preset) {
    print('_onPresetChanged ${preset}');
    if (preset != null) {
      _preset = preset;
      setPreset(preset);
    }
  }

  void _onFuelTypeChanged(FuelType fuelType) {
    print('onFuelTypeChanged ${fuelType}');
    setState(() {
      _fuelType = fuelType;
    });
  }

  void _onGSChanged(double gs) {
    setState(() {
      _gs = gs;
    });
  }

  void _onAspectChanged(double aspect) {
    setState(() {
      _aspect = aspect;
    });
  }

  void _onWAZChanged(double waz) {
    print('_onWAZChanged ${waz}');
    setState(() {
      _waz = waz;
    });
  }

  void _onWSChanged(double ws) {
    setState(() {
      _ws = ws;
    });
  }

  void _onBUIChanged(double bui) {
    setState(() {
      _bui = bui;
    });
  }

  void _onFFMCChanged(double ffmc) {
    setState(() {
      _ffmc = ffmc;
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

  void _onCCChanged(double cc) {
    setState(() {
      _cc = cc;
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

  void _onLongitudeChanged(double longitude) {
    setState(() {
      _longitude = longitude;
    });
  }

  void _onLatitudeChanged(double latitude) {
    setState(() {
      _latitude = latitude;
    });
  }

  void _onElevationChanged(double elevation) {
    setState(() {
      _elevation = elevation;
    });
  }

  void _onTChanged(double t) {
    setState(() {
      _t = t;
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
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();
  final _elevationController = TextEditingController();
  final _gflController = TextEditingController();

  // double ros = _calculateRateOfSpread()

  void _updatePosition() {
    _getPosition().then((position) {
      setState(() {
        print('setState ${position.latitude} ${position.longitude}');
        _latitude = position.latitude;
        _longitude = position.longitude;
        _elevation = position.altitude;
        _updateCoordainteControllers();
      });
    });
  }

  void _updateCoordainteControllers() {
    _latitudeController.text = _latitude.toStringAsFixed(2);
    _longitudeController.text = _longitude.toStringAsFixed(2);
    _elevationController.text = _elevation.toStringAsFixed(0);
  }

  @override
  void initState() {
    _onPresetChanged(_getDefaultPreset());
    ccController.text = _cc.toString();
    pcController.text = _pc.toString();
    pdfController.text = _pdf.toString();
    cbhController.text = _cbh.toString();
    _cflController.text = _cfl.toString();
    _gflController.text = _gfl.toString();
    _updateCoordainteControllers();
    super.initState();
    _updatePosition();
  }

  _getPosition() async {
    print('calling _getPosition');
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      print('got position ${position}');
      return position;
    } catch (e) {
      print('error getting position ${e}');
    }
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
    int? intensityClass;
    FireBehaviourPredictionPrimary? prediction;
    try {
      final dayOfYear = getDayOfYear();
      final input = FireBehaviourPredictionInput(
          FUELTYPE: _fuelType.name,
          LAT: _latitude,
          LONG: _longitude,
          ELV: _elevation,
          DJ: dayOfYear,
          D0: null,
          FMC: null,
          FFMC: _ffmc,
          BUI: _bui,
          WS: _ws,
          WD: _waz,
          GS: _gs,
          PC: _pc,
          PDF: _pdf,
          GFL: _gfl,
          CC: _cc,
          THETA: _theta,
          ACCEL: false,
          ASPECT: _aspect,
          BUIEFF: true,
          CBH: _cbh,
          CFL: _cfl,
          MINUTES: _t);
      prediction = FBPcalc(input, output: "ALL");
      // Wind direction correction:
      prediction.RAZ -= 180;
      prediction.RAZ =
          prediction.RAZ < 0 ? prediction.RAZ + 360 : prediction.RAZ;
      // print('ffmc: $_ffmc');
      // print('day of year: $dayOfYear');
      print('prediction.SFC: ${prediction.SFC}');
      print('prediction.FMC: ${prediction.FMC}');
      print('prediction.WSV: ${prediction.WSV}');
      print('prediction.RAZ: ${prediction.RAZ}');
      print('prediction.ISI: ${prediction.ISI}');
      print('prediction.ROS: ${prediction.ROS}');
      print('prediction.CFB: ${prediction.CFB}');
      print('prediction.TFC: ${prediction.TFC}');
      print('prediction.HFI: ${prediction.HFI}');
      print('prediction.FD: ${prediction.FD}');
      print('prediction.FD: ${prediction.CFC}');
      intensityClass = getHeadFireIntensityClass(prediction.HFI);
      if (prediction.secondary != null) {
        fireSize = getFireSize(
            _fuelType.name,
            prediction.ROS,
            prediction.secondary!.BROS,
            _t,
            prediction.CFB,
            prediction.secondary!.LB);
      }

      print('fireSize: $fireSize');
    } catch (e) {
      print('error $e');
    }
    // Build a Form widget using the _formKey created above.
    return Column(children: [
      Form(
        key: _formKey,
        child: Column(
          children: <Widget>[
            // Presets
            Row(
              children: [
                Expanded(
                    child: DropdownButtonFormField(
                        isExpanded: true,
                        value: _getDefaultPreset(),
                        key: _presetState,
                        decoration:
                            const InputDecoration(labelText: "Pre-sets"),
                        items: _presets.map((FuelTypeStruct value) {
                          return DropdownMenuItem<FuelTypeStruct>(
                              value: value, child: Text(value.description));
                          // Row(
                          //   children: [
                          //     // const Icon(Icons.park_outlined),
                          //     Text(value.description),
                          //   ],
                          // ));
                        }).toList(),
                        onChanged: (FuelTypeStruct? value) {
                          _onPresetChanged(value);
                        }))
              ],
            ),
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
                          child: Text('Time ellapsed: ${_t.toInt()} minutes')),
                      Expanded(
                          child: Slider(
                        value: _t,
                        min: 0,
                        max: 120,
                        divisions: 12,
                        label: '${_t.toInt()} minutes',
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
                        label:
                            '${degreesToCompassPoint(_theta)} ${_theta}\u00B0',
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
            // lat, long, elevation
            Row(children: [
              // latitude Field
              Expanded(
                  child: TextField(
                controller: _latitudeController,
                decoration: const InputDecoration(labelText: "Latitude"),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  if (double.tryParse(value) != null) {
                    _onLatitudeChanged(double.parse(value));
                  }
                },
              )),
              // longitude Field
              Expanded(
                  child: TextField(
                controller: _longitudeController,
                decoration: const InputDecoration(labelText: "Longitude"),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  if (double.tryParse(value) != null) {
                    _onLongitudeChanged(double.parse(value));
                  }
                },
              )),
              // elevation Field
              Expanded(
                  child: TextField(
                controller: _elevationController,
                decoration: const InputDecoration(labelText: "Elevation"),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  if (double.tryParse(value) != null) {
                    _onElevationChanged(double.parse(value));
                  }
                },
              )),
              Expanded(
                  child: IconButton(
                      icon: const Icon(Icons.my_location),
                      onPressed: () {
                        _updatePosition();
                      }))
            ]),
            // Wind Speed
            Row(children: [
              Expanded(child: Text('Wind Speed (km/h) ${_ws.toInt()}')),
              Expanded(
                  child: Slider(
                value: _ws,
                min: 0,
                max: 100,
                divisions: 100,
                label: '${_ws.toInt()} km/h',
                onChanged: (value) {
                  _onWSChanged(value);
                },
              )),
            ]),
            // Wind Azimuth
            Row(children: [
              Expanded(
                  child: Text(
                      'Wind Direction: ${degreesToCompassPoint(_waz)} ${_waz.toString()}\u00B0')),
              Expanded(
                  child: Slider(
                value: _waz,
                min: 0,
                max: 360,
                divisions: 16,
                label: '${degreesToCompassPoint(_waz)} ${_waz}\u00B0',
                onChanged: (value) {
                  _onWAZChanged(value);
                },
              )),
            ]),
            // Ground Slope
            Row(children: [
              Expanded(child: Text('Ground Slope: ${_gs.floor()}%')),
              Expanded(
                  child: Slider(
                value: _gs,
                min: 0,
                max: 90,
                divisions: 90,
                label: '${_gs.floor()}%',
                onChanged: (value) {
                  _onGSChanged(value);
                },
              )),
            ]),
            // Aspect
            Row(children: [
              Expanded(
                  child: Text(
                      'Aspect: ${degreesToCompassPoint(_aspect)} ${_aspect.toString()}\u00B0')),
              Expanded(
                  child: Slider(
                value: _aspect,
                min: 0,
                max: 360,
                divisions: 16,
                label:
                    '${degreesToCompassPoint(_aspect)} ${_aspect.toString()}\u00B0',
                onChanged: (value) {
                  _onAspectChanged(value);
                },
              )),
            ]),
            Row(children: [
              Expanded(child: Text('Buildup Index: ${_bui.toInt()}')),
              Expanded(
                  child: Slider(
                value: _bui,
                min: 0,
                max: 200,
                divisions: 200,
                label: '${_bui.toInt()}',
                onChanged: (value) {
                  _onBUIChanged(value);
                },
              )),
            ]),
            Row(children: [
              Expanded(child: Text('Curing: ${_cc.toInt()}%')),
              Expanded(
                  child: Slider(
                value: _cc,
                min: 0,
                max: 100,
                divisions: 100,
                label: '${_cc.toInt()}%',
                onChanged: (value) {
                  _onCCChanged(value);
                },
              )),
            ]),
            // FFMC
            Row(children: [
              Expanded(
                  child: Text('Fine Fuel Moisture Code: ${_ffmc.toInt()}')),
              Expanded(
                  child: Slider(
                value: _ffmc,
                min: 0,
                max: 100,
                divisions: 100,
                label: '${_ffmc.toInt()}',
                onChanged: (value) {
                  _onFFMCChanged(value);
                },
              )),
            ]),
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
          ? Results(prediction: prediction, minutes: _t, fireSize: fireSize)
          : Container(),
    ]);
  }
}

enum Section { basic, advanced, about }

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return HomePageState();
  }
}

class HomePageState extends State<HomePage> {
  Section _selectedSection = Section.basic;

  _getSelectedSection(Section _section) {
    switch (_section) {
      case (Section.about):
        return const Text('About');
      case (Section.basic):
        return const Text('Basic');
      case (Section.advanced):
        return Center(
            child: SingleChildScrollView(
                child: Column(
          children: const [AdvancedFireBehaviourPredictionForm()],
        )));
    }
  }

  @override
  Widget build(BuildContext context) {
    final ButtonStyle style =
        TextButton.styleFrom(primary: Theme.of(context).colorScheme.onPrimary);
    return Scaffold(
      appBar: AppBar(title: const Text('Fire Behaviour Prediction')),
      body: _getSelectedSection(_selectedSection),
      drawer: Drawer(
          child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            child: Text('Fire Behaviour Prediction'),
            decoration: BoxDecoration(color: Colors.blue),
          ),
          ListTile(
              title: const Text('Basic'),
              onTap: () {
                _changeSection(Section.basic);
              }),
          ListTile(
              title: const Text('Advanced'),
              onTap: () {
                _changeSection(Section.advanced);
              }),
          ListTile(
              title: const Text('About'),
              onTap: () {
                _changeSection(Section.about);
              })
        ],
      )),
    );
  }

  void _changeSection(Section section) {
    setState(() {
      _selectedSection = section;
    });
    Navigator.pop(context);
  }
}
