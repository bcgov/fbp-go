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
import 'package:permission_handler/permission_handler.dart';

import 'fire.dart';
import 'global.dart';

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

  void _setLatitude(latitude) {
    // Limit to 2 decimal places for consistent input.
    _coordinate.latitude = roundDouble(latitude, 2);
  }

  void _setLongitude(longitude) {
    // Limit to 2 decimal places for consistent input.
    _coordinate.longitude = roundDouble(longitude, 2);
  }

  void _setAltitude(altitude) {
    // Only need integer level accuracy.
    _coordinate.altitude = altitude.roundToDouble();
  }

  void _updatePosition() {
    Permission.location.request().then((request) => {
          if (request.isGranted)
            {
              _getPosition().then((position) {
                if (mounted) {
                  setState(() {
                    _setLatitude(position.latitude);
                    _setLongitude(position.longitude);
                    _setAltitude(position.altitude > 0 ? position.altitude : 0);
                    widget.onChanged(_coordinate);
                    _updateCoordinateControllers();
                  });
                }
              })
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
    _elevationController.text = _coordinate.altitude.toStringAsFixed(0);
  }

  @override
  Widget build(BuildContext context) {
    const TextStyle textStyle = TextStyle(fontSize: labelFontSize);
    return Row(
      children: [
        // latitude Field
        Expanded(
            child: TextField(
          controller: _latitudeController,
          decoration: const InputDecoration(
              labelText: "Latitude", labelStyle: textStyle),
          keyboardType: const TextInputType.numberWithOptions(
              signed: true, decimal: true),
          onChanged: (value) {
            if (double.tryParse(value) != null) {
              double latitude = double.parse(value);
              if (latitude >= -90 && latitude <= 90) {
                setState(() {
                  _setLatitude(latitude);
                  widget.onChanged(_coordinate);
                });
              }
            }
          },
        )),
        // longitude Field
        Expanded(
            child: TextField(
          controller: _longitudeController,
          decoration: const InputDecoration(
              labelText: "Longitude", labelStyle: textStyle),
          keyboardType: const TextInputType.numberWithOptions(
              signed: true, decimal: true),
          onChanged: (value) {
            if (double.tryParse(value) != null) {
              double longitude = double.parse(value);
              if (longitude >= -180 && longitude.abs() <= 180) {
                _setLongitude(longitude);
                widget.onChanged(_coordinate);
              }
            }
          },
        )),
        Expanded(
            child: TextField(
          controller: _elevationController,
          decoration: const InputDecoration(
              labelText: "Elevation", labelStyle: textStyle),
          keyboardType: const TextInputType.numberWithOptions(
              signed: false, decimal: false),
          onChanged: (value) {
            if (double.tryParse(value) != null) {
              var altitude = double.parse(value);
              if (altitude >= 0) {
                _setAltitude(altitude);
                widget.onChanged(_coordinate);
              }
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
