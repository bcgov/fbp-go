import 'package:flutter/material.dart';
// import 'package:flutter/scheduler.dart';
import 'package:geolocator/geolocator.dart';
import 'cffdrs/FMCcalc.dart';
import 'cffdrs/ROScalc.dart';
import 'cffdrs/FIcalc.dart';
import 'cffdrs/Slopecalc.dart';
import 'cffdrs/TFCcalc.dart';
import 'cffdrs/CFBcalc.dart';
import 'cffdrs/SFCcalc.dart';
import 'cffdrs/ISIcalc.dart';

void main() => runApp(const MyApp());

int getDayOfYear() {
  final now = DateTime.now();
  final diff = now.difference(DateTime(now.year, 1, 1, 0, 0));
  return diff.inDays;
}

int getHeadFireIntensityClass(double headFireIntensity) {
  if (headFireIntensity < 10) {
    return 1;
  } else if (headFireIntensity < 500) {
    return 2;
  } else if (headFireIntensity < 2000) {
    return 3;
  } else if (headFireIntensity < 4000) {
    return 4;
  } else if (headFireIntensity < 10000) {
    return 5;
  }
  return 6;
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

String getFireType(String fuelType, double crownFractionBurned) {
  /*
    Returns Fire Type (as FireTypeEnum) based on percentage Crown Fraction Burned (CFB).
    These definitions come from the Red Book (p.69).
    Abbreviations for fire types have been taken from the red book (p.9).

    CROWN FRACTION BURNED           TYPE OF FIRE                ABBREV.
    < 10%                           Surface fire                SUR
    10-89%                          Intermittent crown fire     IC
    > 90%                           Continuous crown fire       CC
    */
  if (["D1", "O1A", "O1B", "S1", "S2", "S3"].contains(fuelType)) {
    // From red book "crown fires are not expected in deciduous fuel types but high intensity surface fires
    // can occur.
    return "Surface fire";
  }
  // crown fraction burnt is a floating point number from 0 to 1 inclusive.
  else if (crownFractionBurned < 0.1) {
    return "Surface fire";
  } else if (crownFractionBurned < 0.9) {
    return "Intermittent crown fire";
  } else if (crownFractionBurned >= 0.9) {
    return "Continuous crown fire";
  }
  throw Exception(
      "Cannot calculate fire type. Invalid Crown Fraction Burned percentage received.");
}

String azimuthToCompassPoint(double azimuth) {
  final values = [
    'N',
    'NNE',
    'NE',
    'ENE',
    'E',
    'ESE',
    'SE',
    'SSE',
    'S',
    'SSW',
    'SW',
    'WSW',
    'W',
    'WNW',
    'NW',
    'NNW',
    'N'
  ];
  return values[(azimuth / 22.5).floor()];
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(title: 'Fire Behaviour Tool', home: HomePage());
  }
}

// Define a custom Form widget.
class MyCustomForm extends StatefulWidget {
  const MyCustomForm({Key? key}) : super(key: key);

  @override
  MyCustomFormState createState() {
    return MyCustomFormState();
  }
}

class FuelTypeStruct {
  final String code;
  final String description;
  final double cfl;
  final double? pc;
  final double? pdf;
  final double? cbh;
  FuelTypeStruct(this.code, this.description,
      {required this.cfl, this.pc, this.pdf, this.cbh});
}

// Define a corresponding State class.
// This class holds data related to the form.
class MyCustomFormState extends State<MyCustomForm> {
  // Create a global key that uniquely identifies the Form widget
  // and allows validation of the form.
  //
  // Note: This is a `GlobalKey<FormState>`,
  // not a GlobalKey<MyCustomFormState>.
  final _formKey = GlobalKey<FormState>();
  String? _fuelType;
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
  double _saz = 0;

  bool _expanded = false;

  final _presetState = GlobalKey<FormFieldState>();

  final List<FuelTypeStruct> _presets = [
    FuelTypeStruct('C1', 'C-1 spruce-lichen woodland',
        cfl: 0.75, pc: 100, cbh: 2),
    FuelTypeStruct('C2', 'C-2 boreal spruce', cfl: 0.8, pc: 100, cbh: 3),
    FuelTypeStruct('C3', 'C-3 mature jack or lodgepole pine',
        cfl: 1.15, pc: 100, cbh: 3),
    FuelTypeStruct('C4', 'C-4 immature jack or lodgepole pine',
        cfl: 1.2, pc: 100, cbh: 4),
    FuelTypeStruct('C5', 'C-5 red and white pine', cfl: 1.2, pc: 100, cbh: 18),
    FuelTypeStruct('C6', 'C-6 conifer plantation, 7-m CBH',
        cfl: 1.8, pc: 100, cbh: 7),
    FuelTypeStruct('C6', 'C-6 conifer plantation, 2-m CBH',
        cfl: 1.8, pc: 100, cbh: 7),
    FuelTypeStruct('C7', 'C-7 ponderosa pine/Douglas-far',
        cfl: 0.5, pc: 100, cbh: 10),
    FuelTypeStruct('D1', 'D-1 leafless aspen', cfl: 1.0),
    FuelTypeStruct('D2', 'D-2 green aspen', cfl: 1.0),
    FuelTypeStruct(
        'M1', 'M-1 boreal mixedwood-leafless, 75% conifer / 25 % deciduous',
        cfl: 0.8, pc: 75, cbh: 6),
    FuelTypeStruct(
        'M1', 'M-1 boreal mixedwood-leafless, 50% conifer / 50 % deciduous',
        cfl: 0.8, pc: 50, cbh: 6),
    FuelTypeStruct(
        'M1', 'M-1 boreal mixedwood-leafless, 25% conifer / 75 % deciduous',
        cfl: 0.8, pc: 25, cbh: 6),
    FuelTypeStruct(
        'M2', 'M-2 boreal mixedwood-green, 75% conifer / 25 % deciduous',
        cfl: 0.8, pc: 75, cbh: 6),
    FuelTypeStruct(
        'M2', 'M-2 boreal mixedwood-green, 50% conifer / 50 % deciduous',
        cfl: 0.8, pc: 50, cbh: 6),
    FuelTypeStruct(
        'M2', 'M-2 boreal mixedwood-green, 25% conifer / 75 % deciduous',
        cfl: 0.8, pc: 25, cbh: 6),
    FuelTypeStruct('M3', 'M-3 dead balsam fir mixedwood-leafless, 30% dead fir',
        cfl: 0.8, pdf: 30, cbh: 6),
    FuelTypeStruct('M3', 'M-3 dead balsam fir mixedwood-leafless, 60% dead fir',
        cfl: 0.8, pdf: 60, cbh: 6),
    FuelTypeStruct(
        'M3', 'M-3 dead balsam fir mixedwood-leafless, 100% dead fir',
        cfl: 0.8, pdf: 100, cbh: 6),
    FuelTypeStruct('M4', 'M-4 dead balsam fir mixedwood-green, 30% dead fir',
        cfl: 0.8, pdf: 30, cbh: 6),
    FuelTypeStruct('M4', 'M-4 dead balsam fir mixedwood-green, 60% dead fir',
        cfl: 0.8, pdf: 60, cbh: 6),
    FuelTypeStruct('M4', 'M-4 dead balsam fir mixedwood-green, 100% dead fir',
        cfl: 0.8, pdf: 100, cbh: 6),
    FuelTypeStruct('O1A', 'O-1a matted grass', cfl: 1.0),
    FuelTypeStruct('O1B', 'O-1b standing grass', cfl: 1.0),
    FuelTypeStruct('S1', 'S-1 jack or lodgepole pine slash', cfl: 1.0),
    FuelTypeStruct('S2', 'S-2 white spruce/balsam slash', cfl: 1.0),
    FuelTypeStruct('S3', 'S-3 coastal cedar/hemlock/Douglas-fir slash',
        cfl: 1.0),
  ];

  FuelTypeStruct? get preset {
    return _preset;
  }

  set preset(FuelTypeStruct? value) {
    _preset = value;
  }

  final _fuelTypeState = GlobalKey<FormFieldState>();

  String get fuelType {
    return _fuelType ?? '';
  }

  set fuelType(String fuelType) {
    _fuelType = fuelType;
  }

  final List<String> _fuelTypes = [
    'C1',
    'C2',
    'C3',
    'C4',
    'C5',
    'C6',
    'C7',
    'D1',
    'D2',
    'M1',
    'M2',
    'M3',
    'M4',
    'S1',
    'S2',
    'S3',
    'O1A',
    'O1B'
  ];

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

  void _onFuelTypeChanged(String? fuelType) {
    print('onFuelTypeChanged ${fuelType}');
    setState(() {
      if (fuelType != null) {
        _fuelType = fuelType;
      }
      // TODO: figure out how to blank out the preset without it bubbling back
      // to the fuel type.
      // _preset = null;
      // _presetState.currentState?.didChange(_preset);
    });
  }

  void _onGSChanged(double gs) {
    setState(() {
      _gs = gs;
    });
  }

  void _onSAZChanged(double saz) {
    setState(() {
      _saz = saz;
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

  final ccController = TextEditingController();
  final pcController = TextEditingController();
  final pdfController = TextEditingController();
  final cbhController = TextEditingController();
  final _cflController = TextEditingController();
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();
  final _elevationController = TextEditingController();

  // double ros = _calculateRateOfSpread()

  @override
  void initState() {
    _onPresetChanged(_presets[0]);
    ccController.text = _cc.toString();
    pcController.text = _pc.toString();
    pdfController.text = _pdf.toString();
    cbhController.text = _cbh.toString();
    _cflController.text = _cfl.toString();
    _latitudeController.text = _latitude.toString();
    _longitudeController.text = _longitude.toString();
    _elevationController.text = _elevation.toString();
    super.initState();
    _getPosition().then((position) {
      setState(() {
        print('setState ${position.latitude} ${position.longitude}');
        _latitude = position.latitude;
        _longitude = position.longitude;
        _elevation = position.altitude;
        _latitudeController.text = _latitude.toStringAsFixed(3);
        _longitudeController.text = _longitude.toStringAsFixed(3);
        _elevationController.text = _elevation.toStringAsFixed(3);
      });
    });
  }

  _getPosition() async {
    print('calling _getPosition');
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    print('got position ${position}');
    return position;
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double? isi;
    double? ros;
    double? hfi;
    double? cfb;
    double? fc;
    double? sfc;
    double? fmc;
    String fireDescription = '';
    int? intensityClass;
    try {
      print('ffmc: $_ffmc');
      print('day of year: ${getDayOfYear()}');
      fmc = FMCcalc(_latitude, _longitude < 0 ? -_longitude : _longitude,
          _elevation, getDayOfYear(), 0);
      print('fmc: $fmc');
      sfc = SFCcalc(fuelType, _ffmc, _bui, _pc, _cc);
      print('sfc: ${sfc}');
      isi = 0;
      if (_gs > 0 && _ffmc > 0) {
        // Calculate the net effective windspeed (WSV)
        double wsv = Slopecalc(fuelType, _ffmc, _bui, _ws, _waz, _gs, _saz, fmc,
            sfc, _pc, _pdf, _cc, _cbh, isi,
            output: "WSV");
        print('wsv: ${wsv}');
        // Calculate the net effective wind direction (RAZ)
        double raz = Slopecalc(fuelType, _ffmc, _bui, _ws, _waz, _gs, _saz, fmc,
            sfc, _pc, _pdf, _cc, _cbh, isi,
            output: "RAZ");
        print('raz: ${raz} (net effective wind direction)');
        isi = ISIcalc(_ffmc, wsv, fbpMod: true);
        print('isi: ${isi}');
      } else {
        isi = ISIcalc(_ffmc, _ws);
        print('isi: ${isi}');
      }
      ros = ROScalc(fuelType, isi, _bui, fmc, sfc, _pc, _pdf, _cc, _cbh);
      print('ros: $ros');
      cfb = CFBcalc(fuelType, fmc, sfc, ros, _cbh ?? 0);
      print('cfb: $cfb');
      fc = TFCcalc(fuelType, _cfl, cfb, sfc, _pc, _pdf);
      print('fc: $fc');
      hfi = FIcalc(fc, ros);
      print('hfi: $hfi');
      intensityClass = getHeadFireIntensityClass(hfi);
      print('intensityClass: $intensityClass');

      fireDescription = getFireType(fuelType, cfb);
    } catch (e) {
      print('error $e');
    }
    // Build a Form widget using the _formKey created above.
    return Form(
      key: _formKey,
      child: Column(
        children: <Widget>[
          // Presets
          Row(
            children: [
              Expanded(
                  child: DropdownButtonFormField(
                      isExpanded: true,
                      value: _presets[0],
                      key: _presetState,
                      decoration: const InputDecoration(labelText: "Pre-sets"),
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
          Container(
              child: ExpansionPanelList(
            children: [
              ExpansionPanel(
                headerBuilder: (context, isExpanded) {
                  return const ListTile(
                    title: Text(
                      'Custom',
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
                              decoration:
                                  const InputDecoration(labelText: "Fuel Type"),
                              items: _fuelTypes.map((String value) {
                                return DropdownMenuItem(
                                    value: value,
                                    child: Row(
                                      children: [
                                        // const Icon(Icons.park_outlined),
                                        Text(value)
                                      ],
                                    ));
                              }).toList(),
                              onChanged: (String? value) {
                                _onFuelTypeChanged(value);
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
                ]),
                isExpanded: _expanded,
                canTapOnHeader: true,
              ),
            ],
            expansionCallback: (panelIndex, isExpanded) {
              _expanded = !_expanded;
              setState(() {});
            },
          )),
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
                    'Wind Azimith: ${azimuthToCompassPoint(_waz)} ${_waz.toString()}\u00B0')),
            Expanded(
                child: Slider(
              value: _waz,
              min: 0,
              max: 360,
              divisions: 16,
              label: '${azimuthToCompassPoint(_waz)} ${_waz}\u00B0',
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
          // Slope Azimith
          Row(children: [
            Expanded(
                child: Text(
                    'Slope Azimith: ${azimuthToCompassPoint(_saz)} ${_saz.toString()}\u00B0')),
            Expanded(
                child: Slider(
              value: _saz,
              min: 0,
              max: 360,
              divisions: 16,
              label: '${azimuthToCompassPoint(_saz)} ${_saz.toString()}\u00B0',
              onChanged: (value) {
                _onSAZChanged(value);
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
            Expanded(child: Text('Fine Fuel Moisture Code: ${_ffmc.toInt()}')),
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
          Row(children: [
            const Expanded(child: Text('Initial Spread Index')),
            Expanded(
              child: Text('${isi?.toStringAsFixed(0)}'),
            )
          ]),
          Row(children: [
            const Expanded(child: Text('Foliar Moisture Content')),
            Expanded(child: Text('${fmc?.toStringAsFixed(0)}'))
          ]),
          Row(children: [
            const Expanded(child: Text('Surface Fuel Consumption')),
            Expanded(child: Text('${sfc?.toStringAsFixed(0)} (kg/m^2)'))
          ]),
          Row(children: [
            const Expanded(child: Text('Crown fraction burned')),
            Expanded(
                child: Text(
                    '${(cfb == null ? 0.0 : cfb * 100).toStringAsFixed(0)} %'))
          ]),
          Row(children: [
            const Expanded(child: Text('Fuel Consumption')),
            Expanded(child: Text('${fc?.toStringAsFixed(0)} (kg/m^2)'))
          ]),
          Container(
              color: getIntensityClassColor(intensityClass),
              child: Row(children: [
                const Expanded(child: Text('Rate of spread')),
                Expanded(child: Text('${ros?.toStringAsFixed(0)} (m/min)')),
              ])),
          Container(
              color: getIntensityClassColor(intensityClass),
              child: Row(children: [
                const Expanded(child: Text('Head fire intensity')),
                Expanded(child: Text('${hfi?.toStringAsFixed(0)} (kW/m)')),
              ])),
          Container(
              color: getIntensityClassColor(intensityClass),
              child: Row(children: [
                const Expanded(child: Text('Intensity class')),
                Expanded(child: Text('$intensityClass')),
              ])),
          Row(children: [
            const Expanded(child: Text('Type of fire')),
            Expanded(child: Text(fireDescription))
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
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Fire Behaviour Tool'),
        ),
        body: const Center(
          child: MyCustomForm(),
        )
        // body: ListView(
        //   children: [...demos.map((d) => DemoTile(demo: d))],
        // ),
        );
  }
}
