import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_application_1/cffdrs/ROScalc.dart';

void main() => runApp(const MyApp());

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
  final double? pc;
  final double? pdf;
  final double? cbh;
  FuelTypeStruct(this.code, this.description, {this.pc, this.pdf, this.cbh});
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
  double _fmc = 0;
  double _sfc = 0;
  double? _pc = 0;
  double? _pdf = 0;
  double _cc = 0;
  double? _cbh = 0;

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
    FuelTypeStruct('C1', 'C-1 spruce-lichen woodland', pc: 100, cbh: 2),
    FuelTypeStruct('C2', 'C-2 boreal spruce', pc: 100, cbh: 3),
    FuelTypeStruct('C3', 'C-3 mature jack or lodgepole pine', pc: 100, cbh: 3),
    FuelTypeStruct('C4', 'C-4 immature jack or lodgepole pine',
        pc: 100, cbh: 4),
    FuelTypeStruct('C5', 'C-5 red and white pine', pc: 100, cbh: 18),
    FuelTypeStruct('C6', 'C-6 conifer plantation, 7-m CBH', pc: 100, cbh: 7),
    FuelTypeStruct('C6', 'C-6 conifer plantation, 2-m CBH', pc: 100, cbh: 7),
    FuelTypeStruct('C7', 'C-7 ponderosa pine/Douglas-far', pc: 100, cbh: 10),
    FuelTypeStruct('D1', 'D-1 leafless aspen'),
    FuelTypeStruct('D2', 'D-2 green aspen'),
    FuelTypeStruct(
        'M1', 'M-1 boreal mixedwood-leafless, 75% conifer / 25 % deciduous',
        pc: 75, cbh: 6),
    FuelTypeStruct(
        'M1', 'M-1 boreal mixedwood-leafless, 50% conifer / 50 % deciduous',
        pc: 50, cbh: 6),
    FuelTypeStruct(
        'M1', 'M-1 boreal mixedwood-leafless, 25% conifer / 75 % deciduous',
        pc: 25, cbh: 6),
    FuelTypeStruct(
        'M2', 'M-2 boreal mixedwood-green, 75% conifer / 25 % deciduous',
        pc: 75, cbh: 6),
    FuelTypeStruct(
        'M2', 'M-2 boreal mixedwood-green, 50% conifer / 50 % deciduous',
        pc: 50, cbh: 6),
    FuelTypeStruct(
        'M2', 'M-2 boreal mixedwood-green, 25% conifer / 75 % deciduous',
        pc: 25, cbh: 6),
    FuelTypeStruct('M3', 'M-3 dead balsam fir mixedwood-leafless, 30% dead fir',
        pdf: 30, cbh: 6),
    FuelTypeStruct('M3', 'M-3 dead balsam fir mixedwood-leafless, 60% dead fir',
        pdf: 60, cbh: 6),
    FuelTypeStruct(
        'M3', 'M-3 dead balsam fir mixedwood-leafless, 100% dead fir',
        pdf: 100, cbh: 6),
    FuelTypeStruct('M4', 'M-4 dead balsam fir mixedwood-green, 30% dead fir',
        pdf: 30, cbh: 6),
    FuelTypeStruct('M4', 'M-4 dead balsam fir mixedwood-green, 60% dead fir',
        pdf: 60, cbh: 6),
    FuelTypeStruct('M4', 'M-4 dead balsam fir mixedwood-green, 100% dead fir',
        pdf: 100, cbh: 6),
    FuelTypeStruct('O1A', 'O-1a matted grass'),
    FuelTypeStruct('O1B', 'O-1b standing grass'),
    FuelTypeStruct('S1', 'S-1 jack or lodgepole pine slash'),
    FuelTypeStruct('S2', 'S-2 white spruce/balsam slash'),
    FuelTypeStruct('S3', 'S-3 coastal cedar/hemlock/Douglas-fir slash'),
  ];

  void setPreset(
      {required String fuelType,
      required double? pc,
      double? pdf,
      required double? cbh}) {
    setState(() {
      _fuelType = fuelType;
      _fuelTypeState.currentState?.didChange(_fuelType);

      _pc = pc;
      pcController.text = _pc.toString();

      _pdf = pdf;
      if (_pdf == null) {
        pdfController.text = '';
      } else {
        pdfController.text = _pdf.toString();
      }

      _cbh = cbh;
      cbhController.text = _cbh.toString();
    });
  }

  void _onPresetChanged(FuelTypeStruct? preset) {
    print('_onPresetChanged ${preset}');
    if (preset != null) {
      _preset = preset;
      setPreset(
          fuelType: preset.code,
          pc: preset.pc,
          cbh: preset.cbh,
          pdf: preset.pdf);
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

  void _onFMCChanged(double fmc) {
    setState(() {
      _fmc = fmc;
    });
  }

  void _onSFCChanged(double sfc) {
    setState(() {
      _sfc = sfc;
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

  double? _calculateRateOfSpread() {
    try {
      return ROScalc(fuelType, _isi, _bui, _fmc, _sfc, _pc, _pdf, _cc, _cbh);
    } catch (e) {
      return null;
    }
  }

  double? _calculateHeadFireIntensity() {
    return null;
  }

  final isiController = TextEditingController();
  final buiController = TextEditingController();
  final fmcContoller = TextEditingController();
  final ccController = TextEditingController();
  final sfcController = TextEditingController();
  final pcController = TextEditingController();
  final pdfController = TextEditingController();
  final cbhController = TextEditingController();

  void _isiListener() {
    print('_isiListener');
  }

  @override
  void initState() {
    isiController.text = _isi.toString();
    buiController.text = _bui.toString();
    fmcContoller.text = _fmc.toString();
    ccController.text = _cc.toString();
    sfcController.text = _sfc.toString();
    pcController.text = _pc.toString();
    pdfController.text = _pdf.toString();
    cbhController.text = _cbh.toString();
    isiController.addListener(_isiListener);
    super.initState();
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is removed from the
    // widget tree.
    isiController.dispose();
    buiController.dispose();
    fmcContoller.dispose();
    ccController.dispose();
    sfcController.dispose();
    pcController.dispose();
    pdfController.dispose();
    cbhController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
          // Fuel type dropdown.
          Row(
            children: [
              Expanded(
                  child: DropdownButtonFormField(
                      key: _fuelTypeState,
                      decoration: const InputDecoration(labelText: "Fuel Type"),
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
            // FMC field
            Expanded(
                child: TextField(
              controller: fmcContoller,
              decoration:
                  const InputDecoration(labelText: "Foliar Moisture Content"),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                if (double.tryParse(value) != null) {
                  _onFMCChanged(double.parse(value));
                }
              },
            )),
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
            ))
          ]),

          Row(children: [
            // SFC field
            Expanded(
                child: TextField(
              controller: sfcController,
              decoration: const InputDecoration(
                  labelText: "Surface Fuel Consumption (kg/m^2)"),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                if (double.tryParse(value) != null) {
                  _onSFCChanged(double.parse(value));
                }
              },
            )),
            // PC field
            Expanded(
                child: TextField(
              controller: pcController,
              decoration: const InputDecoration(labelText: "Percent Conifer"),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                if (double.tryParse(value) != null) {
                  _onPCChanged(double.parse(value));
                }
              },
            ))
          ]),
          // PDF field
          Row(children: [
            Expanded(
                child: TextField(
              controller: pdfController,
              decoration:
                  const InputDecoration(labelText: "Percent Dead Balsam Fir"),
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
              decoration:
                  const InputDecoration(labelText: "Crown to base height (m)"),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                if (double.tryParse(value) != null) {
                  _onCBHChanged(double.parse(value));
                }
              },
            ))
          ]),
          Text('Rate of spread: ${_calculateRateOfSpread()} (m/min)'),
          Text('Head fire intensity: ${_calculateHeadFireIntensity()} (kW/m)'),
          Text(
              // ignore: unnecessary_brace_in_string_interps
              'fuel: ${fuelType}, isi: ${_isi}, bui: ${_bui}, fmc: ${_fmc}, sfc: ${_sfc}, pc: ${_pc}, pdf: ${_pdf}, cc: ${_cc}, cbh: ${_cbh}')

          // TextFormField(
          //   // The validator receives the text that the user has entered.
          //   validator: (value) {
          //     if (value == null || value.isEmpty) {
          //       return 'Please enter some text';
          //     }
          //     return null;
          //   },
          // ),
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
