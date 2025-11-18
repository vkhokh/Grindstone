import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/workout_provider.dart';
import '../theme/theme.dart';
import 'add_set_page.dart'; 

class CurrentWorkoutPage extends StatelessWidget {
  const CurrentWorkoutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<WorkoutProvider>(context);
    final currentWorkout = provider.currentWorkout;

    if (currentWorkout == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Текущая тренировка'),
          backgroundColor: Colors.transparent, 
          elevation: 0, 
        ),
        body: const Center(child: Text('Нет активной тренировки')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(currentWorkout.name),
        backgroundColor: Colors.transparent, 
        elevation: 0, 
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Упражнения:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: currentWorkout.exercises.length,
                itemBuilder: (context, index) {
                  final exercise = currentWorkout.exercises[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      title: Text(exercise.name),
                      subtitle: Text('Подходов: ${exercise.sets.length} | Прогресс: ${exercise.totalWeightLifted} кг*повт.'),
                      trailing: IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AddSetPage(exerciseIndex: index), 
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/add_exercise');
                      },
                      child: const Text('Добавить упражнение'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(double.infinity, 50), // Устанавливаем минимальную высоту 50
                        // Если вы хотите установить точную высоту, можно использовать fixedSize:
                        // fixedSize: Size(double.infinity, 50), // Это зафиксирует и ширину (равной доступной), и высоту.
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: ElevatedButton(
                      onPressed: () {
                        // Здесь можно добавить логику завершения тренировки
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Тренировка сохранена!')),
                        );
                      },
                      child: const Text('Завершить'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(double.infinity, 50), // Устанавливаем минимальную высоту 50
                        // fixedSize: Size(double.infinity, 50), // То же самое, если хотите точный размер
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}