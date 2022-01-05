import 'dart:developer';

import 'package:flutter/material.dart';
import 'fire_widgets.dart';
import 'fire.dart';

class BasicFireBehaviourPredictionFormState
    extends State<BasicFireBehaviourPredictionForm> {
  void setPreset(FuelTypePreset preset) {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        // Presets
        Row(children: [
          Expanded(child: FuelTypePresetDropdown(
            onChanged: (FuelTypePreset? value) {
              if (value != null) {
                setPreset(value);
              }
            },
          ))
        ]),
        Row(
          children: [
            Expanded(child: BasicInputWidget(onChanged: (dynamic thing) {
              log('basic input changed to $thing');
            }))
          ],
        )
      ],
    );
  }
}

class BasicFireBehaviourPredictionForm extends StatefulWidget {
  const BasicFireBehaviourPredictionForm({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return BasicFireBehaviourPredictionFormState();
  }
}
