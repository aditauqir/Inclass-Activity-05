import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inclass05/main.dart';

void main() {
  testWidgets('Case 1: Lower boundary (At 10, press Decrease -> remains 10, no invalid history)',
      (WidgetTester tester) async {
    await tester.pumpWidget(const CounterApp());

    // Reset to 10 first
    await tester.tap(find.text('Reset to 10'));
    await tester.pump();
    expect(find.text('10'), findsOneWidget);
    expect(find.text('History: 40'), findsOneWidget);

    // At 10, press Decrease
    await tester.tap(find.text('Decrease'));
    await tester.pump();

    // Value remains 10; no invalid history entry is created
    expect(find.text('10'), findsOneWidget);
    expect(find.text('History: 40'), findsOneWidget);
    expect(find.textContaining('Minimum limit reached'), findsOneWidget);
  });

  testWidgets('Case 2: Upper boundary (At 150, press Increase -> remains 150, limit feedback appears)',
      (WidgetTester tester) async {
    await tester.pumpWidget(const CounterApp());

    // Set increment to 110 to get from 40 to 150
    await tester.enterText(find.byType(TextField), '110');
    await tester.pump();
    await tester.tap(find.text('Increase'));
    await tester.pump();

    // Verify at 150
    expect(find.text('150'), findsOneWidget);
    expect(find.text('History: 40'), findsOneWidget);

    // Press Increase at 150
    await tester.tap(find.text('Increase'));
    await tester.pump();

    // Remains 150, feedback appears, no extra history entry
    expect(find.text('150'), findsOneWidget);
    expect(find.text('History: 40'), findsOneWidget);
    expect(find.textContaining('Maximum limit reached'), findsOneWidget);
  });

  testWidgets('Case 3: Overshoot (Increment would pass 150 -> rejected, state and history valid)',
      (WidgetTester tester) async {
    await tester.pumpWidget(const CounterApp());

    // Counter is 40. Set increment to 120 (40 + 120 = 160 > 150)
    await tester.enterText(find.byType(TextField), '120');
    await tester.pump();

    // Tap Increase
    await tester.tap(find.text('Increase'));
    await tester.pump();

    // Entire action is rejected; previous state (40) and history (none) remain valid
    expect(find.text('40'), findsOneWidget);
    expect(find.text('History: none'), findsOneWidget);
    expect(find.textContaining('Maximum limit reached'), findsOneWidget);
  });

  testWidgets('Case 4: Invalid input (Try blank, -2, 2.5, and hello -> valid increment retained)',
      (WidgetTester tester) async {
    await tester.pumpWidget(const CounterApp());
    expect(find.text('(Current: 7)'), findsOneWidget);

    // 1. Blank
    await tester.enterText(find.byType(TextField), '');
    await tester.pump();
    expect(find.textContaining('Increment cannot be empty'), findsOneWidget);
    expect(find.text('(Current: 7)'), findsOneWidget);

    // 2. -2
    await tester.enterText(find.byType(TextField), '-2');
    await tester.pump();
    expect(find.textContaining('Increment must be greater than 0'), findsOneWidget);
    expect(find.text('(Current: 7)'), findsOneWidget);

    // 3. 2.5
    await tester.enterText(find.byType(TextField), '2.5');
    await tester.pump();
    expect(find.textContaining('Decimals are not allowed'), findsOneWidget);
    expect(find.text('(Current: 7)'), findsOneWidget);

    // 4. hello
    await tester.enterText(find.byType(TextField), 'hello');
    await tester.pump();
    expect(find.textContaining('Invalid input "hello"'), findsOneWidget);
    expect(find.text('(Current: 7)'), findsOneWidget);
  });

  testWidgets('Case 5: Undo chain (Three valid changes, then four undos -> restores in reverse, 4th harmless)',
      (WidgetTester tester) async {
    await tester.pumpWidget(const CounterApp());

    // Counter starts at 40, increment is 7
    // Change 1: 40 -> 47
    await tester.tap(find.text('Increase'));
    await tester.pump();
    expect(find.text('47'), findsOneWidget);

    // Change 2: 47 -> 54
    await tester.tap(find.text('Increase'));
    await tester.pump();
    expect(find.text('54'), findsOneWidget);

    // Change 3: 54 -> 61
    await tester.tap(find.text('Increase'));
    await tester.pump();
    expect(find.text('61'), findsOneWidget);
    expect(find.text('History: 40, 47, 54'), findsOneWidget);

    // Undo 1: restores 54
    await tester.tap(find.text('Undo'));
    await tester.pump();
    expect(find.text('54'), findsOneWidget);
    expect(find.text('History: 40, 47'), findsOneWidget);

    // Undo 2: restores 47
    await tester.tap(find.text('Undo'));
    await tester.pump();
    expect(find.text('47'), findsOneWidget);
    expect(find.text('History: 40'), findsOneWidget);

    // Undo 3: restores 40
    await tester.tap(find.text('Undo'));
    await tester.pump();
    expect(find.text('40'), findsOneWidget);
    expect(find.text('History: none'), findsOneWidget);

    // Undo 4 (extra): harmless, does not crash or change value
    await tester.tap(find.text('Undo'));
    await tester.pump();
    expect(find.text('40'), findsOneWidget);
    expect(find.text('History: none'), findsOneWidget);
    expect(find.text('There is no earlier value to restore.'), findsOneWidget);
  });

  testWidgets('Invalid decimal typed in stages retains the prior increment',
      (WidgetTester tester) async {
    await tester.pumpWidget(const CounterApp());
    final field = find.byType(TextField);

    await tester.tap(field);
    await tester.enterText(field, '2');
    await tester.pump();
    await tester.enterText(field, '2.5');
    await tester.pump();

    expect(find.text('(Current: 7)'), findsOneWidget);
    expect(find.textContaining('Decimals are not allowed'), findsOneWidget);
  });

  testWidgets('Case 6: Slider consistency (Move slider, then undo -> counter, slider, history all agree)',
      (WidgetTester tester) async {
    await tester.pumpWidget(const CounterApp());
    expect(find.text('40'), findsOneWidget);

    // Drag slider
    final sliderFinder = find.byType(Slider);
    expect(sliderFinder, findsOneWidget);

    await tester.drag(sliderFinder, const Offset(100, 0));
    await tester.pump();

    // Verify counter updated from 40
    expect(find.text('40'), findsNothing);
    final Slider slider = tester.widget(sliderFinder);
    expect(find.text(slider.value.round().toString()), findsOneWidget);

    // Press Undo
    await tester.tap(find.text('Undo'));
    await tester.pump();

    // Value restored to 40
    expect(find.text('40'), findsOneWidget);
    final Slider restoredSlider = tester.widget(sliderFinder);
    expect(restoredSlider.value.round(), 40);
    expect(find.text('History: none'), findsOneWidget);
  });

  testWidgets('Monday/Wednesday Color Rule: Red at 10, Green above 90, Black otherwise',
      (WidgetTester tester) async {
    await tester.pumpWidget(const CounterApp());

    // Initial 40: black
    Text counterText = tester.widget(find.text('40'));
    expect(counterText.style?.color, Colors.black);

    // Reset to 10: red
    await tester.tap(find.text('Reset to 10'));
    await tester.pump();
    counterText = tester.widget(find.text('10'));
    expect(counterText.style?.color, Colors.red);

    // Increase to 95: green
    await tester.enterText(find.byType(TextField), '85');
    await tester.pump();
    await tester.tap(find.text('Increase'));
    await tester.pump();
    counterText = tester.widget(find.text('95'));
    expect(counterText.style?.color, Colors.green);
  });
}
