import 'package:fire_behaviour_app/fbp_advanced.dart';
import 'package:fire_behaviour_app/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  for (final width in [320.0, 1440.0]) {
    testWidgets('calculator and disclaimer fit at width $width', (
      tester,
    ) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = Size(width, 900);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      SharedPreferences.setMockInitialValues({});
      rootBundle.evict('assets/DISCLAIMER.txt');
      final disclaimer = await tester.runAsync(
        () => rootBundle.load('assets/DISCLAIMER.txt'),
      );
      tester.binding.defaultBinaryMessenger.setMockMessageHandler(
        'flutter/assets',
        (message) async {
          final path = const StringCodec().decodeMessage(message);
          return path == 'assets/DISCLAIMER.txt' ? disclaimer : null;
        },
      );
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();
      final dialog = find
          .descendant(
            of: find.byType(AlertDialog),
            matching: find.byType(Material),
          )
          .first;
      expect(tester.getSize(dialog).width, lessThanOrEqualTo(560));
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      final fields = find.byType(TextField);
      final latitude = tester.getTopLeft(fields.at(0));
      final elevation = tester.getTopLeft(fields.at(2));
      expect(
        elevation.dy,
        width == 320 ? greaterThan(latitude.dy) : latitude.dy,
      );
      expect(find.byType(Slider), findsWidgets);
      expect(
        tester.getSize(find.byType(AdvancedFireBehaviourPredictionForm)).width,
        lessThanOrEqualTo(960),
      );
    });
  }
}
