import 'package:flutter/material.dart';
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
  double _isi = 0;
  double _bui = 0;
  double _fmc = 0;
  double _sfc = 0;
  double _pc = 0;
  double _pdf = 0;
  double _cc = 0;
  double _cbh = 0;

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

  void _onFuelTypeChanged(String? fuelType) {
    setState(() {
      if (fuelType != null) {
        _fuelType = fuelType;
      }
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

  double _calculateRateOfSpread() {
    return ROScalc(fuelType, _isi, _bui, _fmc, _sfc, _pc, _pdf, _cc, _cbh);
  }

  @override
  Widget build(BuildContext context) {
    // Build a Form widget using the _formKey created above.
    return Form(
      key: _formKey,
      child: Column(
        children: <Widget>[
          // Fuel type dropdown.
          Row(
            children: [
              const Text('Fuel Type:'),
              DropdownButton(
                value: _fuelType,
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
                },
              )
            ],
          ),
          // ISI field
          Row(children: [
            Expanded(
                child: TextField(
              decoration: const InputDecoration(labelText: "ISI"),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                if (double.tryParse(value) != null) {
                  _onISIChanged(double.parse(value));
                }
              },
            ))
          ]),
          // BUI field
          Row(children: [
            Expanded(
                child: TextField(
              decoration: const InputDecoration(labelText: "BUI"),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                if (double.tryParse(value) != null) {
                  _onBUIChanged(double.parse(value));
                }
              },
            ))
          ]),
          // FMC field
          Row(children: [
            Expanded(
                child: TextField(
              decoration: const InputDecoration(labelText: "FMC"),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                if (double.tryParse(value) != null) {
                  _onFMCChanged(double.parse(value));
                }
              },
            ))
          ]),
          // SFC field
          Row(children: [
            Expanded(
                child: TextField(
              decoration: const InputDecoration(labelText: "SFC"),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                if (double.tryParse(value) != null) {
                  _onSFCChanged(double.parse(value));
                }
              },
            ))
          ]),
          // PC field
          Row(children: [
            Expanded(
                child: TextField(
              decoration: const InputDecoration(labelText: "PC"),
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
              decoration: const InputDecoration(labelText: "PDF"),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                if (double.tryParse(value) != null) {
                  _onPDFChanged(double.parse(value));
                }
              },
            ))
          ]),
          // CC field
          Row(children: [
            Expanded(
                child: TextField(
              decoration: const InputDecoration(labelText: "CC"),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                if (double.tryParse(value) != null) {
                  _onCCChanged(double.parse(value));
                }
              },
            ))
          ]),
          // CBH field
          Row(children: [
            Expanded(
                child: TextField(
              decoration: const InputDecoration(labelText: "CBH"),
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
