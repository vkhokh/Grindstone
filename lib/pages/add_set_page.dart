import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/workout_provider.dart';
import '../theme/theme.dart';

class AddSetPage extends StatefulWidget {
  final int exerciseIndex; 

  const AddSetPage({super.key, required this.exerciseIndex});

  @override
  State<AddSetPage> createState() => _AddSetPageState();
}

class _AddSetPageState extends State<AddSetPage> {
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _repsController = TextEditingController();

  @override
  void dispose() {
    _weightController.dispose();
    _repsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
       appBar: AppBar(
        title: const Text('Добавить подход'),
        backgroundColor: Colors.transparent, 
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: _weightController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Вес (кг)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _repsController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Повторения',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                final weight = double.tryParse(_weightController.text) ?? 0.0;
                final reps = int.tryParse(_repsController.text) ?? 0;

                if (weight > 0 && reps > 0) {
                  Provider.of<WorkoutProvider>(context, listen: false)
                      .addSetToExercise(widget.exerciseIndex, weight, reps);
                  Navigator.pop(context);
                }
              },
              child: const Text('СОХРАНИТЬ'),
            ),
          ],
        ),
      ),
    );
  }
}