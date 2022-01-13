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
import 'about.dart';
import 'fbp_advanced.dart';
import 'package:flutter/material.dart';
import 'cffdrs/fbp_calc.dart';
import 'fbp_basic.dart';
import 'fmc.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
        title: 'Fire Behaviour Prediction', home: HomePage());
  }
}

String getSecondaryText(FireBehaviourPredictionPrimary? prediction) {
  if (prediction != null && prediction.secondary != null) {
    return prediction.secondary.toString();
  }
  return '';
}

enum Section { basic, advanced, fwi, about, fmc }

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return HomePageState();
  }
}

class HomePageState extends State<HomePage> {
  Section _selectedSection = Section.basic;

  String _getSectionText() {
    switch (_selectedSection) {
      case Section.basic:
        return 'Basic FBP';
      case Section.advanced:
        return 'Advanced FBP';
      case Section.fwi:
        return 'Fire Weather Index';
      case Section.about:
        return 'About';
      case Section.fmc:
        return 'FMC';
      default:
        throw Exception('Unknown section');
    }
  }

  _getSelectedSection(Section _section) {
    const double edgeInset = 3;
    switch (_section) {
      case (Section.about):
        return Container(
            // padding: const EdgeInsets.only(left: edgeInset, right: edgeInset),
            // child: RichText(text: const TextSpan(text: 'About')));
            child: SingleChildScrollView(
                padding:
                    const EdgeInsets.only(left: edgeInset, right: edgeInset),
                child: Column(
                  children: [AboutPage()],
                )));
      case (Section.basic):
        return Center(
            child: SingleChildScrollView(
                padding:
                    const EdgeInsets.only(left: edgeInset, right: edgeInset),
                child: Column(
                  children: const [BasicFireBehaviourPredictionForm()],
                )));
      case (Section.advanced):
        return Center(
            child: SingleChildScrollView(
                padding:
                    const EdgeInsets.only(left: edgeInset, right: edgeInset),
                child: Column(
                  children: const [AdvancedFireBehaviourPredictionForm()],
                )));
      case (Section.fwi):
        return Container(
            padding: const EdgeInsets.only(left: edgeInset, right: edgeInset),
            child: const Text('FWI'));
      case (Section.fmc):
        return Container(
            padding: const EdgeInsets.only(left: edgeInset, right: edgeInset),
            child: const FoliarMoistureContent());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_getSectionText())),
      body: _getSelectedSection(_selectedSection),
      drawer: Drawer(
          child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            child: Text('\u{1F525} Fire Behaviour Prediction'),
            decoration: BoxDecoration(color: Colors.blue),
          ),
          ListTile(
              title: const Text('Basic Fire Behaviour Prediction (FBP)'),
              onTap: () {
                _changeSection(Section.basic);
              }),
          ListTile(
              title: const Tooltip(
                  message: 'FBP for nerds',
                  child: Text('Advanced Fire Behaviour Prediction (FBP)')),
              onTap: () {
                _changeSection(Section.advanced);
              }),
          // TODO: Would be nice to have FWI
          // ListTile(
          //     title: const Text('Fire Weather Index (FWI)'),
          //     onTap: () {
          //       _changeSection(Section.fwi);
          //     }),
          // TODO: No-one wants this, but just keep it here for now.
          // ListTile(
          //     title: const Text('Foliar Moisture Content (FMC)'),
          //     onTap: () {
          //       _changeSection(Section.fmc);
          //     }),
          ListTile(
              title: const Text('About'),
              onTap: () {
                _changeSection(Section.about);
              })
        ],
      )),
    );
  }

  void _changeSection(Section section) {
    setState(() {
      _selectedSection = section;
    });
    Navigator.pop(context);
  }
}
