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
import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AboutPageState extends State<AboutPage> {
  String aboutText = 'About: loading...';
  String licenseText = 'License: Loading...';

  void getAboutText() {
    rootBundle
        .loadString('ABOUT.txt')
        .then(
          (value) => {
            setState(() {
              aboutText = value;
            }),
          },
        );
  }

  void getLicenseText() {
    rootBundle
        .loadString('LICENSE')
        .then(
          (value) => {
            setState(() {
              // short term hack to get license to display a little better.
              licenseText = value
                  .replaceAll('\n\n', '\r')
                  .replaceAll('\n', ' ')
                  .replaceAll('\r', '\n\n')
                  .replaceAll('</br>', '\n');
            }),
          },
        );
  }

  String get _licenseFontFamily {
    try {
      return Platform.isIOS ? "Courier" : "monospace";
    } catch (e) {
      return "Courier";
    }
  }

  double get _licenseFontSize {
    try {
      return Platform.isIOS ? 9 : 11;
    } catch (e) {
      return 11;
    }
  }

  @override
  void initState() {
    getAboutText();
    getLicenseText();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: DefaultTextStyle.of(context).style,
        children: [
          const TextSpan(
            text: 'About\n\n',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          TextSpan(text: aboutText),
          const TextSpan(
            text: '\n\nLicense\n\n',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          TextSpan(
            text: licenseText,
            style: TextStyle(
              // On iOS "Courier" gives us a mono spaced font.
              fontFamily: _licenseFontFamily,
              // Not the best idea, but I think iOS phones have slightly
              // smaller screens? Really need a better way to handle the
              // license.
              fontSize: _licenseFontSize,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return AboutPageState();
  }
}
