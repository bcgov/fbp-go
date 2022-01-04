import 'package:fire_behaviour_app/fire.dart';
import 'package:flutter/material.dart';

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
