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
import 'package:fire_behaviour_app/global.dart';
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
  return const TextStyle(color: Colors.black);
  // if we want to match the red book, we'd be doing white on red
  // switch (FD) {
  //   case ("I"): // I = Intermittent Crowning
  //     return const TextStyle(color: Colors.black);
  //   case ("S"): // S = Surface
  //     return const TextStyle(color: Colors.black);
  //   case ("C"): // C = Crowning
  //     return const TextStyle(color: Colors.white);
  //   default:
  //     throw Exception('Invalid Fire Description');
  // }
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
      decoration: const InputDecoration(
          labelText: "Fuel type",
          labelStyle: TextStyle(fontSize: labelFontSize)),
      items: _presets.map((FuelTypePreset value) {
        return DropdownMenuItem<FuelTypePreset>(
            value: value,
            child: Text(value.description,
                style: const TextStyle(fontSize: fontSize)));
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
