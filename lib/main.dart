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
import 'package:flutter/services.dart';

import 'about.dart';
import 'fbp_advanced.dart';
import 'package:flutter/material.dart';
import 'cffdrs/fire_behaviour_prediction.dart';
import 'fmc.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'FBP Go (Fire Behaviour Prediction) App',
      child: const MaterialApp(
        title: 'FBP Go (Fire Behaviour Prediction)',
        home: HomePage(),
      ),
    );
  }
}

String getSecondaryText(FireBehaviourPredictionPrimary? prediction) {
  if (prediction != null && prediction.secondary != null) {
    return prediction.secondary.toString();
  }
  return '';
}

enum Section { advanced, fwi, about, fmc }

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<StatefulWidget> createState() {
    return HomePageState();
  }
}

class HomePageState extends State<HomePage> {
  Section _selectedSection = Section.advanced;
  bool showDisclaimer = true;

  String _getSectionText() {
    switch (_selectedSection) {
      case Section.advanced:
        return 'Fire Behaviour Prediction';
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

  Future<void> _showDisclaimer(BuildContext context) async {
    String disclaimer = await rootBundle.loadString('assets/DISCLAIMER.txt');
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Semantics(
          label: 'Disclaimer dialog',
          child: AlertDialog(
            title: const Text('Disclaimer'),
            content: SingleChildScrollView(child: Text(disclaimer)),
            actions: <Widget>[
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _getSelectedSection(Section section) {
    const double edgeInset = 3;
    switch (section) {
      case (Section.about):
        return const SingleChildScrollView(
          padding: EdgeInsets.only(left: edgeInset, right: edgeInset),
          child: Column(children: [AboutPage()]),
        );
      case (Section.advanced):
        return const Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.only(left: edgeInset, right: edgeInset),
            child: Column(children: [AdvancedFireBehaviourPredictionForm()]),
          ),
        );
      case (Section.fwi):
        return Container(
          padding: const EdgeInsets.only(left: edgeInset, right: edgeInset),
          child: const Text('FWI'),
        );
      case (Section.fmc):
        return Container(
          padding: const EdgeInsets.only(left: edgeInset, right: edgeInset),
          child: const FoliarMoistureContent(),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (showDisclaimer) {
      Future.delayed(Duration.zero, () => _showDisclaimer(context));
      showDisclaimer = false;
    }
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 53, 150, 243),
        foregroundColor: Color.fromARGB(255, 255, 255, 255),
        title: Text(_getSectionText()),
      ),
      body: _getSelectedSection(_selectedSection),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text('FBP Go\n\nFire Behaviour Prediction on the go'),
            ),
            ListTile(
              title: const Text('Fire Behaviour Prediction'),
              onTap: () {
                _changeSection(Section.advanced);
              },
            ),
            // TODO: Would be nice to have FWI
            // ListTile(
            //     title: const Text('Fire Weather Index (FWI)'),
            //     onTap: () {
            //       _changeSection(Section.fwi);
            //     }),
            ListTile(
              title: const Text('About'),
              onTap: () {
                _changeSection(Section.about);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _changeSection(Section section) {
    setState(() {
      _selectedSection = section;
    });
    Navigator.pop(context);
  }
}
