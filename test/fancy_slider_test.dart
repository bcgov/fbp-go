import 'dart:ui' show SemanticsAction;

import 'package:fire_behaviour_app/fancy_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('elapsed time exposes minutes and names each step button', (
    tester,
  ) async {
    double minutes = 10;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) => FancySliderWidget(
              fieldName: 'Time elapsed',
              label: '${minutes.round()} minutes',
              formatValue: (value) => '${value.round()} minutes',
              value: minutes,
              min: 0,
              max: 20,
              divisions: 2,
              activeColor: Colors.blue,
              onChanged: (value) => setState(() => minutes = value),
            ),
          ),
        ),
      ),
    );

    final slider = tester.getSemantics(find.byType(Slider));
    expect(slider.label, contains('Time elapsed'));
    expect(slider.value, 'Time elapsed: 10 minutes');
    expect(slider.increasedValue, 'Time elapsed: 20 minutes');
    expect(slider.decreasedValue, 'Time elapsed: 0 minutes');

    final increase = find.byTooltip('Increase Time elapsed');
    final decrease = find.byTooltip('Decrease Time elapsed');
    await tester.tap(increase);
    await tester.pump();
    expect(minutes, 20);
    expect(
      tester
          .getSemantics(increase)
          .getSemanticsData()
          .hasAction(SemanticsAction.tap),
      isFalse,
    );
    await tester.tap(decrease);
    await tester.pump();
    await tester.tap(decrease);
    await tester.pump();
    expect(minutes, 0);
    expect(
      tester
          .getSemantics(decrease)
          .getSemanticsData()
          .hasAction(SemanticsAction.tap),
      isFalse,
    );
  });
}
