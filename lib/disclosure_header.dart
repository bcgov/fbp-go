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

class DisclosureHeader extends StatelessWidget {
  const DisclosureHeader({
    required this.title,
    required this.expanded,
    required this.onPressed,
    this.accent,
    super.key,
  });
  final String title;
  final bool expanded;
  final VoidCallback onPressed;
  final Color? accent;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      expanded: expanded,
      child: TextButton(
        style: TextButton.styleFrom(
          foregroundColor: const Color(0xFF19364F),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          shape: const RoundedRectangleBorder(),
        ),
        onPressed: onPressed,
        child: Row(
          children: [
            if (accent != null) ...[
              Container(
                width: 4,
                height: 24,
                decoration: BoxDecoration(
                  color: accent,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 14),
            ],
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Icon(expanded ? Icons.expand_less : Icons.expand_more),
          ],
        ),
      ),
    );
  }
}
