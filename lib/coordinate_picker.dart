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
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class Coordinate {
  double latitude;
  double longitude;
  double altitude;

  Coordinate(
      {required this.latitude,
      required this.longitude,
      required this.altitude});

  @override
  String toString() {
    return 'Coordinate{latitude: $latitude, longitude: $longitude, elevation: $altitude}';
  }
}

class CoordinatePickerState extends State<CoordinatePicker> {
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();
  final _elevationController = TextEditingController();

  final Coordinate _coordinate =
      Coordinate(latitude: 37, longitude: -122, altitude: 5);

  _getPosition() async {
    log('calling _getPosition');
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      log('got position $position');
      return position;
    } catch (e) {
      log('error getting position $e');
    }
  }

  void _updatePosition() {
    _getPosition().then((position) {
      // The position might come back after the component has been disposed,
      // so we need to check before setting the state.
      if (mounted) {
        setState(() {
          _coordinate.latitude = position.latitude;
          _coordinate.longitude = position.longitude;
          _coordinate.altitude = position.altitude > 0 ? position.altitude : 0;
          widget.onChanged(_coordinate);
          _updateCoordinateControllers();
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _updatePosition();
    _updateCoordinateControllers();
  }

  void _updateCoordinateControllers() {
    _latitudeController.text = _coordinate.latitude.toStringAsFixed(2);
    _longitudeController.text = _coordinate.longitude.toStringAsFixed(2);
    _elevationController.text = _coordinate.altitude.toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // latitude Field
        Expanded(
            child: TextField(
          controller: _latitudeController,
          decoration: const InputDecoration(labelText: "Latitude"),
          keyboardType: TextInputType.number,
          onChanged: (value) {
            if (double.tryParse(value) != null) {
              _coordinate.latitude = double.parse(value);
              widget.onChanged(_coordinate);
            }
          },
        )),
        // longitude Field
        Expanded(
            child: TextField(
          controller: _longitudeController,
          decoration: const InputDecoration(labelText: "Longitude"),
          keyboardType: TextInputType.number,
          onChanged: (value) {
            if (double.tryParse(value) != null) {
              _coordinate.longitude = double.parse(value);
              widget.onChanged(_coordinate);
            }
          },
        )),
        Expanded(
            child: TextField(
          controller: _elevationController,
          decoration: const InputDecoration(labelText: "Elevation"),
          keyboardType: TextInputType.number,
          onChanged: (value) {
            if (double.tryParse(value) != null) {
              _coordinate.altitude = double.parse(value);
              widget.onChanged(_coordinate);
            }
          },
        )),
        Expanded(
            child: IconButton(
                icon: const Icon(Icons.my_location),
                onPressed: () {
                  _updatePosition();
                }))
      ],
    );
  }
}

class CoordinatePicker extends StatefulWidget {
  final Function onChanged;

  const CoordinatePicker({Key? key, required this.onChanged}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return CoordinatePickerState();
  }
}
