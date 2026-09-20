import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:valuate_app/widgets/common/app_snack_bar.dart';

void main() {
  testWidgets('AppSnackBar renders at top with animation and message', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        navigatorKey: AppSnackBar.navigatorKey,
        home: Scaffold(
          body: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () {
                  AppSnackBar.showSuccess(
                    context,
                    message: 'تم حفظ البيانات بنجاح',
                    title: 'نجاح العملية',
                  );
                },
                child: const Text('Show'),
              );
            },
          ),
        ),
      ),
    );

    // Tap the button to trigger AppSnackBar
    await tester.tap(find.text('Show'));
    await tester.pump(); // Start animation
    await tester.pump(const Duration(milliseconds: 300)); // Advance animation

    // Verify snackbar is rendered with title and message
    expect(find.text('نجاح العملية'), findsOneWidget);
    expect(find.text('تم حفظ البيانات بنجاح'), findsOneWidget);

    // Fast forward past duration and exit animation
    await tester.pump(const Duration(milliseconds: 4000));
    await tester.pump(const Duration(milliseconds: 500));

    // Should be dismissed
    expect(find.text('تم حفظ البيانات بنجاح'), findsNothing);
  });
}
