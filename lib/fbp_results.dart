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
import 'package:flutter/material.dart';

import 'cffdrs/fbp_calc.dart';
import 'fire.dart';
import 'fire_widgets.dart';
import 'global.dart';

abstract class Group {
  Group({required this.heading, this.isExpanded = false});
  String heading;
  bool isExpanded;

  Row _buildRow(String value, String label, Color? color) {
    TextStyle valueStyle = TextStyle(
        color: color, fontWeight: FontWeight.bold, fontSize: fontSize);
    TextStyle labelStyle = TextStyle(color: color, fontSize: fontSize);
    return Row(children: [
      Expanded(
          flex: 5,
          child: Padding(
              padding: const EdgeInsets.only(right: 5.0),
              child:
                  Text(value, textAlign: TextAlign.right, style: valueStyle))),
      Expanded(flex: 6, child: Text(label, style: labelStyle)),
    ]);
  }

  Widget buildBody(FireBehaviourPredictionInput input,
      FireBehaviourPredictionPrimary prediction);
}

class FireBehaviourGroup extends Group {
  FireBehaviourGroup({required String heading, isExpanded = false})
      : super(heading: heading, isExpanded: isExpanded);

  @override
  Widget buildBody(FireBehaviourPredictionInput input,
      FireBehaviourPredictionPrimary prediction) {
    TextStyle textStyle = getTextStyle(prediction.FD);
    return Column(
      children: [
        _buildRow(
            getFireDescription(prediction.FD), 'Fire type', textStyle.color),
        _buildRow('${((prediction.CFB * 100).toStringAsFixed(0))}%',
            'Crown fraction burned - Head', textStyle.color),
        _buildRow('${((prediction.secondary!.FCFB * 100).toStringAsFixed(0))}%',
            'Crown fraction burned - Flank', textStyle.color),
        _buildRow('${((prediction.secondary!.BCFB * 100).toStringAsFixed(0))}%',
            'Crown fraction burned - Back', textStyle.color),
      ],
    );
  }
}

class GenericGroup extends Group {
  GenericGroup({required String heading, isExpanded = false})
      : super(heading: heading, isExpanded: isExpanded);

  @override
  Widget buildBody(FireBehaviourPredictionInput input,
      FireBehaviourPredictionPrimary prediction) {
    return Container(
      child: const Text('Moo'),
    );
  }
}

List<Group> generateGroups() {
  List<Group> groups = [
    FireBehaviourGroup(heading: 'Fire Behaviour Outputs', isExpanded: true),
    GenericGroup(heading: 'Group 2', isExpanded: false),
    GenericGroup(heading: 'Group 3', isExpanded: false)
  ];
  return groups;
}

class ResultsState extends State<ResultsStateWidget> {
  final List<Group> _groups = generateGroups();

  Row buildRow(String value, String label, Color? color) {
    TextStyle valueStyle = TextStyle(
        color: color, fontWeight: FontWeight.bold, fontSize: fontSize);
    TextStyle labelStyle = TextStyle(color: color, fontSize: fontSize);
    return Row(children: [
      Expanded(
          flex: 5,
          child: Padding(
              padding: const EdgeInsets.only(right: 5.0),
              child:
                  Text(value, textAlign: TextAlign.right, style: valueStyle))),
      Expanded(flex: 6, child: Text(label, style: labelStyle)),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    TextStyle textStyle = getTextStyle(widget.prediction.FD);
    // Need to have a bunch of panels:
    // https://api.flutter.dev/flutter/material/ExpansionPanelList-class.html
    return Container(
        // color: intensityClassColour,
        decoration: BoxDecoration(
            border: Border.all(color: widget.intensityClassColour),
            borderRadius: const BorderRadius.all(Radius.circular(5))),
        child: Column(
          children: [
            ExpansionPanelList(
                expansionCallback: (int index, bool isExpanded) {
                  setState(() {
                    _groups[index].isExpanded = !isExpanded;
                  });
                },
                children: _groups.map<ExpansionPanel>((Group group) {
                  return ExpansionPanel(
                      backgroundColor: widget.intensityClassColour,
                      headerBuilder: (BuildContext context, bool isExpanded) {
                        return Row(
                          children: [
                            const Spacer(),
                            Text(group.heading),
                            const Spacer()
                          ],
                        );
                      },
                      body: group.buildBody(widget.input, widget.prediction),
                      isExpanded: group.isExpanded);
                }).toList()
                //  [
                //   ExpansionPanel(
                //       headerBuilder: (BuildContext context, bool isExpanded) {
                //         return Row(
                //           children: [
                //             const Spacer(),
                //             Text(_groups[0].heading),
                //             const Spacer()
                //           ],
                //         );
                //       },
                //       body: buildRow('${widget.input.CFL} (kg/m^2)',
                //           'Crown Fuel Load', textStyle.color),
                //       isExpanded: _groups[0].isExpanded),
                // ExpansionPanel(
                //     headerBuilder: (BuildContext context, bool isExpanded) {
                //       return Row(
                //         children: [
                //           const Spacer(),
                //           Text(_groups[1].heading),
                //           const Spacer()
                //         ],
                //       );
                //     },
                //     body: buildRow('${widget.input.CFL} (kg/m^2)',
                //         'Crown Fuel Load', textStyle.color),
                //     isExpanded: _groups[1].isExpanded)
                // ],
                ),
            Container(
                color: widget.intensityClassColour,
                child: Row(
                  children: const [Text('')],
                )),
            buildRow('${widget.input.CFL} (kg/m^2)', 'Crown Fuel Load',
                textStyle.color),
            buildRow('${widget.input.CBH} (m)', 'Crown to base height',
                textStyle.color),
            ...getPrimaryTextRow(widget.prediction, textStyle),
            buildRow(
                '$widget.intensityClass', 'Intensity class', textStyle.color),
            buildRow(
                '${widget.fireSize?.toStringAsFixed(0)} (ha)',
                '${widget.minutes.toStringAsFixed(0)} minute fire size',
                textStyle.color),
            ...getSecondaryTextRow(widget.prediction, textStyle),
          ],
        ));
  }

  List<Row> getPrimaryTextRow(
      FireBehaviourPredictionPrimary? prediction, TextStyle textStyle) {
    List<Row> rows = <Row>[];
    if (prediction != null) {
      for (var key in prediction.lookup.keys) {
        ValueDescriptionPair value = prediction.getProp(key);
        rows.add(
            buildRow(value.toString(), value.description, textStyle.color));
      }
    }
    return rows;
  }

  List<Row> getSecondaryTextRow(
      FireBehaviourPredictionPrimary? prediction, TextStyle textStyle) {
    List<Row> rows = <Row>[];
    if (prediction != null) {
      var secondary = prediction.secondary;
      if (secondary != null) {
        for (var key in secondary.lookup.keys) {
          ValueDescriptionPair value = secondary.getProp(key);
          rows.add(
              buildRow(value.toString(), value.description, textStyle.color));
        }
      }
    }
    return rows;
  }
}

class ResultsStateWidget extends StatefulWidget {
  final FireBehaviourPredictionPrimary prediction;
  final FireBehaviourPredictionInput input;
  final int intensityClass;
  final Color intensityClassColour;
  final double minutes;
  final double? fireSize;

  const ResultsStateWidget(
      {required this.prediction,
      required this.minutes,
      required this.fireSize,
      required this.input,
      required this.intensityClass,
      required this.intensityClassColour,
      Key? key})
      : super(key: key);

  @override
  State<ResultsStateWidget> createState() => ResultsState();
}
