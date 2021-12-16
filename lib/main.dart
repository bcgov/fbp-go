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
  String? _preset;
  double _isi = 0;
  double _bui = 0;
  double _fmc = 0;
  double _sfc = 0;
  double _pc = 0;
  double? _pdf = 0;
  double _cc = 0;
  double _cbh = 0;

  final presetState = GlobalKey<FormFieldState>();

  String? get preset {
    return _preset;
  }

  set preset(String? value) {
    _preset = value;
  }

  final fuelTypeState = GlobalKey<FormFieldState>();

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

  final List<String> _presets = ['C1', 'C2'];

  void _onFuelTypeChanged(String? fuelType) {
    setState(() {
      if (fuelType != null) {
        _fuelType = fuelType;
      }
    });
  }

  void setPreset(
      {required String fuelType,
      required double pc,
      double? pdf,
      required double cbh}) {
    setState(() {
      _fuelType = fuelType;
      fuelTypeState.currentState?.didChange(_fuelType);

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

  void _onPresetChanged(String? preset) {
    setState(() {
      if (preset != null) {
        _preset = preset;
        switch (_preset) {
          case ("C1"):
            {
              setPreset(fuelType: "C1", pc: 100.0, pdf: null, cbh: 2.0);
              // _fuelType = "C1";
              // fuelTypeState.currentState?.didChange(_fuelType);
              // _pc = 100;
              // // TODO: gross - can't this be automatic?
              // pcController.text = _pc.toString();
              // _pdf = null;
              // pdfController.text = '';
              // _cbh = 2;
              // cbhController.text = _cbh.toString();
            }
            break;
          case ("C2"):
            {}
            break;
          default:
            break;
        }
      }
    });
  }

  void _onISIChanged(double isi) {
    setState(() {
      _preset = null;
      presetState.currentState?.didChange(_preset);
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
                      key: presetState,
                      decoration: const InputDecoration(labelText: "Pre-sets"),
                      items: _presets.map((String value) {
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
                        _onPresetChanged(value);
                      }))
            ],
          ),
          // Fuel type dropdown.
          Row(
            children: [
              Expanded(
                  child: DropdownButtonFormField(
                      key: fuelTypeState,
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
                if (double.tryParse(value) != null) {}
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
          Text(
              // ignore: unnecessary_brace_in_string_interps
              'fuel: ${fuelType}, isi: ${_isi}, bui: ${_bui}, fmc: ${_fmc}, sfc: ${_sfc}, pc: ${_pc}, pdf: ${_pdf}, cc: ${_cc}, cbh: ${_cbh}'),
          Text('Rate of spread: ${_calculateRateOfSpread()}'),

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
