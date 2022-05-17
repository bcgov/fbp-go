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

class FancySliderState extends State<FancySliderWidget> {
  @override
  Widget build(BuildContext context) {
    const iconSize = 25.0;
    double step = (widget.max - widget.min) / widget.divisions;
    return Padding(
        padding: const EdgeInsets.only(top: 13, bottom: 13),
        child: Column(
          children: [
            Row(
              children: [
                IconButton(
                  constraints: const BoxConstraints(),
                  padding: const EdgeInsets.only(right: 10),
                  icon: const Icon(Icons.remove_circle_outline, size: iconSize),
                  onPressed: () {
                    if (widget.value > widget.min) {
                      widget.onChanged(widget.value - step);
                    }
                  },
                ),
                Expanded(
                    child: SliderTheme(
                        data: SliderThemeData(
                            overlayShape: SliderComponentShape.noOverlay),
                        child: Slider(
                          value: widget.value,
                          min: widget.min,
                          max: widget.max,
                          divisions: widget.divisions,
                          activeColor: widget.activeColor,
                          label: widget.label,
                          onChanged: (double value) {
                            widget.onChanged(value);
                          },
                        ))),
                IconButton(
                  constraints: const BoxConstraints(),
                  padding: const EdgeInsets.only(left: 10, right: 5),
                  icon: const Icon(Icons.add_circle_outline, size: iconSize),
                  onPressed: () {
                    if (widget.value < widget.max) {
                      widget.onChanged(widget.value + step);
                    }
                  },
                )
              ],
            )
          ],
        ));
  }
}

class FancySliderWidget extends StatefulWidget {
  final double value;
  final double min;
  final double max;
  final int divisions;
  final Color activeColor;
  final String label;
  final Function onChanged;

  const FancySliderWidget(
      {Key? key,
      required this.value,
      required this.min,
      required this.max,
      required this.divisions,
      required this.activeColor,
      required this.label,
      required this.onChanged})
      : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return FancySliderState();
  }
}
