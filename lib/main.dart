// BLOCK 1: Import Flutter's Material widgets and launch the app.
import 'package:flutter/material.dart';

void main() => runApp(const CounterApp());

// BLOCK 2: This app shell does not change, so it is a StatelessWidget.
class CounterApp extends StatelessWidget {
  const CounterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: CounterPage(),
    );
  }
}

// BLOCK 3: This screen changes after user interactions, so it is stateful.
class CounterPage extends StatefulWidget {
  const CounterPage({super.key});

  @override
  State<CounterPage> createState() => _CounterPageState();
}

class _CounterPageState extends State<CounterPage> {
  // BLOCK 4: State fields determine what the user sees at any moment.
  int _counter = 40;
  int _increment = 7;
  final List<int> _history = [];
  final TextEditingController _incrementController = TextEditingController(text: '7');
  final FocusNode _incrementFocusNode = FocusNode();

  // The first value of a slider drag becomes one undoable transition.
  int? _sliderDragStartCounter;
  int _incrementAtEditStart = 7;

  @override
  void initState() {
    super.initState();
    _incrementFocusNode.addListener(() {
      if (_incrementFocusNode.hasFocus) {
        _incrementAtEditStart = _increment;
      }
    });
  }

  @override
  void dispose() {
    // Controllers use resources; dispose them when this screen is removed.
    _incrementController.dispose();
    _incrementFocusNode.dispose();
    super.dispose();
  }

  // BLOCK 5: Helper methods enforce rules before they change UI state.
  bool _isValidValue(int value) => value >= 10 && value <= 150;

  // Activity 05 color-feedback rule, driven by the same counter state.
  Color _counterColor() {
    if (_counter == 10) return Colors.red;
    if (_counter > 90) return Colors.green;
    return Colors.black;
  }

  void _showMessage(String message) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.clearSnackBars();
    messenger.showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _moveTo(int nextValue) {
    // Identical values do not create a new history entry.
    if (nextValue == _counter) return;

    // Reject the action before changing state or creating a history record.
    if (!_isValidValue(nextValue)) {
      if (nextValue < 10) {
        _showMessage(
          'Minimum limit reached: Counter cannot go below 10 (attempted $nextValue).',
        );
      } else {
        _showMessage(
          'Maximum limit reached: Counter cannot exceed 150 (attempted $nextValue).',
        );
      }
      return;
    }

    setState(() {
      _history.add(_counter); // Save only the state that can be restored.
      _counter = nextValue;
    });
  }

  void _rejectIncrement(String message) {
    final retained = _incrementAtEditStart;
    if (_increment != retained) {
      setState(() => _increment = retained);
    }
    _showMessage('$message Prior increment ($retained) retained.');
  }

  void _readIncrement(String input) {
    final trimmed = input.trim();

    if (trimmed.isEmpty) {
      _rejectIncrement(
        'Increment cannot be empty. Enter a positive whole number, such as 1, 5, or 10.',
      );
      return;
    }

    if (trimmed.contains('.')) {
      _rejectIncrement(
        '$input is invalid. Decimals are not allowed; enter a positive whole number, such as 1, 5, or 10.',
      );
      return;
    }

    final value = int.tryParse(trimmed);
    if (value == null) {
      _rejectIncrement(
        'Invalid input "$input". Enter a positive whole number, such as 1, 5, or 10.',
      );
      return;
    }

    if (value <= 0) {
      _rejectIncrement(
        'Increment must be greater than 0. Enter a whole number, such as 1, 5, or 10.',
      );
      return; // Keep the last valid increment unchanged.
    }
    setState(() => _increment = value);
  }

  void _undo() {
    if (_history.isEmpty) {
      _showMessage('There is no earlier value to restore.');
      return;
    }
    setState(() => _counter = _history.removeLast());
  }

  void _reset() {
    if (_counter != 10) _moveTo(10);
  }

  @override
  Widget build(BuildContext context) {
    // BLOCK 6: Build reads state and connects widgets to user actions.
    return Scaffold(
      appBar: AppBar(
        title: const Text('Activity 05 Counter'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Min: 10'),
                Text('Max: 150'),
              ],
            ),
            Text(
              '$_counter',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    color: _counterColor(),
                  ),
            ),
            Slider(
              value: _counter.toDouble(),
              min: 10,
              max: 150,
              divisions: 140,
              // Preview slider values, then commit one history entry when released.
              onChangeStart: (_) {
                _sliderDragStartCounter = _counter;
              },
              onChanged: (value) {
                setState(() => _counter = value.round());
              },
              onChangeEnd: (value) {
                final target = value.round();
                final start = _sliderDragStartCounter ?? _counter;
                _sliderDragStartCounter = null;

                if (start != target) {
                  setState(() => _counter = start);
                  _moveTo(target);
                }
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Step size for Increase/Decrease',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(
                  '(Current: $_increment)',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
            TextField(
              controller: _incrementController,
              focusNode: _incrementFocusNode,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: 'Enter a number, such as 1, 5, or 10',
              ),
              onChanged: _readIncrement,
            ),
            Card(
              margin: const EdgeInsets.only(top: 12),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Input guide',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 4),
                    const Text('Positive whole number: 1, 2, 3...'),
                    const Text('Allowed: 1, 5, 10, or any number above 0.'),
                    const Text('Not allowed: 0, negatives, decimals, or words.'),
                    const Text('Increase adds; Decrease subtracts.'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () => _moveTo(_counter - _increment),
                  child: const Text('Decrease'),
                ),
                ElevatedButton(
                  onPressed: () => _moveTo(_counter + _increment),
                  child: const Text('Increase'),
                ),
                OutlinedButton(
                  onPressed: _reset,
                  child: const Text('Reset to 10'),
                ),
                OutlinedButton(
                  onPressed: _undo,
                  child: const Text('Undo'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              _history.isEmpty
                  ? 'History: none'
                  : 'History: ${_history.join(', ')}',
            ),
          ],
        ),
      ),
    );
  }
}
