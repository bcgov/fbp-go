import 'package:fire_behaviour_app/fire.dart';
import 'package:flutter/material.dart';

import 'coordinate_picker.dart';

class FuelTypePresetDropdown extends StatelessWidget {
  final _presets = getFuelTypePresets();
  final ValueChanged<FuelTypePreset?>? onChanged;

  FuelTypePresetDropdown({Key? key, required this.onChanged}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField(
      isExpanded: true,
      value: _presets[1],
      decoration: const InputDecoration(labelText: "Pre-sets"),
      items: _presets.map((FuelTypePreset value) {
        return DropdownMenuItem<FuelTypePreset>(
            value: value, child: Text(value.description));
      }).toList(),
      onChanged: (FuelTypePreset? value) {
        onChanged?.call(value);
      },
    );
  }
}

class BasicInputStruct {
  double ws = 5;
  Coordinate coordinate = Coordinate(latitude: 0, longitude: 0, altitude: 0);

  @override
  String toString() {
    return "BasicInputStruct(ws: $ws, coordinate: $coordinate)";
  }
}

class BasicInputState extends State<BasicInput> {
  final BasicInputStruct _input = BasicInputStruct();

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
          Expanded(child: Text('Wind Speed (km/h) ${_input.ws.toInt()}')),
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
          )),
        ]),
      ],
    );
  }
}

class BasicInput extends StatefulWidget {
  final Function onChanged;

  const BasicInput({Key? key, required this.onChanged}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return BasicInputState();
  }
}
