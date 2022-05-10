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

// 1st attempt
// Colors.blueGrey.shade500;
// Colors.blueGrey.shade400;
// Colors.blueGrey.shade300;
// Colors.deepOrange.shade200;
// Colors.deepOrange.shade400;
// Colors.red.shade500;

// RED BOOK - I think:
// const Color intensityClass1 = Color(0xFF707070);
// const Color intensityClass2 = Color(0xFF8C8C8C);
// const Color intensityClass3 = Color(0xFFBFBFBF);
// const Color intensityClass4 = Color(0xFFE5C5C2);
// const Color intensityClass5 = Color(0xFFE5A099);
// const Color intensityClass6 = Color(0xFFFA0000);

// Proposal:
const Color intensityClass6 = Color(0xFFBE0000);
const Color intensityClass5 = Color(0xFFFA0000);
const Color intensityClass4 = Color(0xFFFF5935);
const Color intensityClass3 = Color(0xFFFF7A5C);
const Color intensityClass2 = Color(0xFFFFAB8A);
const Color intensityClass1 = Color(0xFFBFBFBF);

Color getIntensityClassColor(int intensityClass) {
  switch (intensityClass) {
    case 1:
      return intensityClass1;
    case 2:
      return intensityClass2;
    case 3:
      return intensityClass3;
    case 4:
      return intensityClass4;
    case 5:
      return intensityClass5;
    case 6:
      return intensityClass6;
    default:
      throw Exception('Invalid intensity class');
  }
}

Color getIntensityClassTextColor(int intensityClass) {
  switch (intensityClass) {
    case 6:
      return Colors.white;
    default:
      return Colors.black;
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
