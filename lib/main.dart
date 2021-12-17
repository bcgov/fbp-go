import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_application_1/cffdrs/FMCcalc.dart';
import 'package:flutter_application_1/cffdrs/ROScalc.dart';
import 'package:flutter_application_1/cffdrs/FIcalc.dart';
import 'package:flutter_application_1/cffdrs/TFCcalc.dart';
import 'package:flutter_application_1/cffdrs/CFBcalc.dart';
import 'package:flutter_application_1/cffdrs/SFCcalc.dart';

void main() => runApp(const MyApp());

int getDayOfYear() {
  final now = DateTime.now();
  final diff = now.difference(DateTime(now.year, 1, 1, 0, 0));
  return diff.inDays;
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
  double _isi = 0;
  double _bui = 0;
  double _ffmc = 0;
  double? _pc = 0;
  double? _pdf = 0;
  double _cc = 0;
  double? _cbh = 0;
  double _cfl = 0;
  double _latitude = 0;
  double _longitude = 0;
  double _elevation = 0;

  bool _expanded = false;

  final _presetState = GlobalKey<FormFieldState>();

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

  void _onISIChanged(double isi) {
    setState(() {
      _isi = isi;
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

  final isiController = TextEditingController();
  final buiController = TextEditingController();
  final _ffmcController = TextEditingController();
  final ccController = TextEditingController();
  final pcController = TextEditingController();
  final pdfController = TextEditingController();
  final cbhController = TextEditingController();
  final _cflController = TextEditingController();
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();
  final _elevationController = TextEditingController();

  // double ros = _calculateRateOfSpread()

  void _isiListener() {
    print('_isiListener');
  }

  @override
  void initState() {
    isiController.text = _isi.toString();
    buiController.text = _bui.toString();
    ccController.text = _cc.toString();
    pcController.text = _pc.toString();
    pdfController.text = _pdf.toString();
    cbhController.text = _cbh.toString();
    isiController.addListener(_isiListener);
    _cflController.text = _cfl.toString();
    _ffmcController.text = _ffmc.toString();
    _latitudeController.text = _latitude.toString();
    _longitudeController.text = _longitude.toString();
    _elevationController.text = _elevation.toString();
    super.initState();
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is removed from the
    // widget tree.
    isiController.dispose();
    buiController.dispose();
    ccController.dispose();
    pcController.dispose();
    pdfController.dispose();
    cbhController.dispose();
    _cflController.dispose();
    _ffmcController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double? ros;
    double? hfi;
    double? cfb;
    double? fc;
    double? sfc;
    double? fmc;
    try {
      print('ffmc: $_ffmc');
      print('day of year: ${getDayOfYear()}');
      fmc = FMCcalc(_latitude, _longitude < 0 ? -_longitude : _longitude,
          _elevation, getDayOfYear(), 0);
      print('fmc: $fmc');
      sfc = SFCcalc(fuelType, _ffmc, _bui, _pc, _cc);
      print('sfc: ${sfc}');
      ros = ROScalc(fuelType, _isi, _bui, fmc, sfc, _pc, _pdf, _cc, _cbh);
      print('ros: $ros');
      cfb = CFBcalc(fuelType, fmc, sfc, ros, _cbh ?? 0);
      print('cfb: {$cfb}');
      fc = TFCcalc(fuelType, _cfl, cfb, sfc, _pc, _pdf);
      print('fc: {$fc}');
      hfi = FIcalc(fc, ros);
      print('hfi: {$hfi}');
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
                      'Detail',
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
          Row(children: [
            // ISI field
            Expanded(
                child: TextField(
              controller: isiController,
              decoration:
                  const InputDecoration(labelText: "Initial Spread Index"),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                if (double.tryParse(value) != null) {
                  _onISIChanged(double.parse(value));
                }
              },
            )),
            // BUI field
            Expanded(
                child: TextField(
              controller: buiController,
              decoration: const InputDecoration(labelText: "Buildup Index"),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                if (double.tryParse(value) != null) {
                  _onBUIChanged(double.parse(value));
                }
              },
            )),
          ]),
          Row(children: [
            // CC Field
            Expanded(
                child: TextField(
              controller: ccController,
              decoration: const InputDecoration(labelText: "Curing"),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                if (double.tryParse(value) != null) {
                  _onCCChanged(double.parse(value));
                }
              },
            )),
            // FFMC Field
            Expanded(
                child: TextField(
              controller: _ffmcController,
              decoration:
                  const InputDecoration(labelText: "Fine Fuel Moisture Code"),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                if (double.tryParse(value) != null) {
                  _onFFMCChanged(double.parse(value));
                }
              },
            ))
          ]),
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
          Text('Foliar Moisture Content: ${fmc}'),
          Text('Surface Fuel Consumption (kg/m^2): ${sfc}'),
          Text('Crown fraction burned: ${cfb}'),
          Text('Fuel Consumption (kg/m^2): ${fc}'),
          Text('Rate of spread: ${ros} (m/min)'),
          Text('Head fire intensity: ${hfi} (kW/m)'),
          // Text(
          //     // ignore: unnecessary_brace_in_string_interps
          //     'fuel: ${fuelType}, isi: ${_isi}, bui: ${_bui}, fmc: ${_fmc}, sfc: ${_sfc}, pc: ${_pc}, pdf: ${_pdf}, cc: ${_cc}, cbh: ${_cbh}, cfl: ${_cfl}'),
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
