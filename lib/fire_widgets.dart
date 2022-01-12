import 'fire.dart';
import 'package:flutter/material.dart';

Color getIntensityClassColor(int intensityClass) {
  switch (intensityClass) {
    case 1:
      return Colors.blueGrey.shade500;
    case 2:
      return Colors.blueGrey.shade400;
    case 3:
      return Colors.blueGrey.shade300;
    case 4:
      return Colors.deepOrange.shade200;
    case 5:
      return Colors.deepOrange.shade400;
    case 6:
      return Colors.red.shade500;
    default:
      throw Exception('Invalid intensity class');
  }
}

// ignore: non_constant_identifier_names
TextStyle getTextStyle(String FD) {
  switch (FD) {
    case ("I"): // I = Intermittent Crowning
      return const TextStyle(color: Colors.black);
    case ("S"): // S = Surface
      return const TextStyle(color: Colors.black);
    case ("C"): // C = Crowning
      return const TextStyle(color: Colors.white);
    default:
      throw Exception('Invalid Fire Description');
  }
}

class FuelTypePresetDropdownState extends State<FuelTypePresetDropdown> {
  final _presets = getFuelTypePresets();

  // FuelTypePresetDropdown({Key? key, required this.onChanged}) : super(key: key);

  @override
  void initState() {
    super.initState();
  }

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
        setState(() {
          widget.onChanged(value);
        });
      },
    );
  }
}

class FuelTypePresetDropdown extends StatefulWidget {
  final Function onChanged;

  const FuelTypePresetDropdown({Key? key, required this.onChanged})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => FuelTypePresetDropdownState();
}
