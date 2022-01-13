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
import 'package:fire_behaviour_app/cffdrs/fmc_calc.dart';
import 'package:flutter/material.dart';

class FoliarMoistureContentState extends State<FoliarMoistureContent> {
  double latitude = 37;
  double longitude = -122;
  double elevation = 100;
  int dayOfYear = 100;
  int dateOfMinimumFoliarMoistureContent = -1;

  void _onLatitudeChanged(double latitude) {
    setState(() {
      this.latitude = latitude;
    });
  }

  void _onLongitudeChanged(double longitude) {
    setState(() {
      this.longitude = longitude;
    });
  }

  void _onElevationChanged(double elevation) {
    setState(() {
      this.elevation = elevation;
    });
  }

  void _onDayOfYearChanged(double dayOfYear) {
    setState(() {
      this.dayOfYear = dayOfYear.floor();
    });
  }

  void _onDateOfMinimumFoliarMoistureContentChanged(
      double dateOfMinimumFoliarMoistureContent) {
    setState(() {
      this.dateOfMinimumFoliarMoistureContent =
          dateOfMinimumFoliarMoistureContent.floor();
    });
  }

  @override
  Widget build(BuildContext context) {
    double fmc = FMCcalc(latitude, longitude.abs(), elevation, dayOfYear,
        dateOfMinimumFoliarMoistureContent.toDouble());
    return Column(
      children: [
        Row(children: [
          Expanded(child: Text('Latitude ${latitude.toStringAsFixed(2)}')),
          Expanded(
              child: Slider(
                  value: latitude,
                  onChanged: _onLatitudeChanged,
                  label: latitude.toStringAsFixed(2),
                  divisions: 89,
                  min: 1,
                  max: 90)),
        ]),
        Row(children: [
          Expanded(child: Text('Longitude ${longitude.toStringAsFixed(2)}')),
          Expanded(
              child: Slider(
                  value: longitude,
                  onChanged: _onLongitudeChanged,
                  label: longitude.toStringAsFixed(2),
                  divisions: 179,
                  min: -180,
                  max: -1)),
        ]),
        Row(children: [
          Expanded(child: Text('Elevation ${elevation.toStringAsFixed(2)}')),
          Expanded(
              child: Slider(
                  value: elevation,
                  onChanged: _onElevationChanged,
                  label: elevation.toStringAsFixed(2),
                  min: 0,
                  divisions: 5000,
                  max: 5000)),
        ]),
        Row(children: [
          Expanded(child: Text('Day of year $dayOfYear')),
          Expanded(
              child: Slider(
                  value: dayOfYear.toDouble(),
                  onChanged: _onDayOfYearChanged,
                  label: dayOfYear.toString(),
                  divisions: 365,
                  min: 0,
                  max: 365)),
        ]),
        Row(children: [
          Expanded(
              child: Text(
                  'Date of minimum foliar moisture content $dateOfMinimumFoliarMoistureContent')),
          Expanded(
              child: Slider(
                  value: dateOfMinimumFoliarMoistureContent.toDouble(),
                  onChanged: _onDateOfMinimumFoliarMoistureContentChanged,
                  label: dateOfMinimumFoliarMoistureContent.toString(),
                  divisions: 365,
                  min: -1,
                  max: 365)),
        ]),
        Row(children: [
          Expanded(child: Text('Foliar Moisture Content (FMC): $fmc'))
        ]),
      ],
    );
  }
}

class FoliarMoistureContent extends StatefulWidget {
  const FoliarMoistureContent({Key? key}) : super(key: key);

  @override
  FoliarMoistureContentState createState() => FoliarMoistureContentState();
}
