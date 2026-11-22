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
import 'package:flutter/services.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import 'disclosure_header.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  bool showLicense = false;
  late final content = Future.wait([
    rootBundle.loadString('ABOUT.txt'),
    rootBundle.loadString('LICENSE'),
  ]);

  @override
  Widget build(BuildContext context) {
    const ink = Color(0xFF19364F);
    const body = TextStyle(
      fontSize: 16,
      height: 1.55,
      color: Color(0xFF304459),
    );
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: EdgeInsets.all(
          MediaQuery.sizeOf(context).width < 600 ? 18 : 36,
        ),
        child: FutureBuilder<List<String>>(
          future: content,
          builder: (context, snapshot) {
            if (snapshot.hasError)
              return const Text('Unable to load the application information.');
            if (!snapshot.hasData) return const LinearProgressIndicator();
            final license = snapshot.data![1]
                .replaceAll('\r\n', '\n')
                .trim()
                .split(RegExp(r'\n\s*\n'))
                .map(
                  (paragraph) => paragraph
                      .split('\n')
                      .map((line) => line.trim())
                      .join(' ')
                      .replaceAll('</br> ', '\n'),
                )
                .join('\n\n');
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                MarkdownBody(
                  data: snapshot.data![0],
                  styleSheet: MarkdownStyleSheet(
                    p: body,
                    h1: const TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.w700,
                      color: ink,
                    ),
                    h2: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: ink,
                    ),
                    h2Padding: const EdgeInsets.only(top: 16),
                    blockSpacing: 10,
                    a: const TextStyle(
                      color: Color(0xFF175A90),
                      decoration: TextDecoration.underline,
                    ),
                  ),
                  onTapLink: (_, href, _) async {
                    if (href == null) return;
                    final opened = await launchUrl(Uri.parse(href));
                    if (!opened && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Unable to open $href')),
                      );
                    }
                  },
                ),
                const SizedBox(height: 16),
                const Divider(),
                DisclosureHeader(
                  title: 'Full license text',
                  expanded: showLicense,
                  onPressed: () => setState(() => showLicense = !showLicense),
                ),
                if (showLicense) SelectableText(license, style: body),
              ],
            );
          },
        ),
      ),
    );
  }
}
