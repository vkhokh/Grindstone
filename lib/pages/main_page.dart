import 'package:dp/pages/current_training_page.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dp/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Training {
  final String name;
  final String timer;
  final bool hasTraining;

  Training({
    required this.name,
    required this.timer,
    this.hasTraining = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'timer': timer,
      'hasTraining': hasTraining,
    };
  }

  static Training fromJson(Map<String, dynamic> json) {
    return Training(
      name: json['name'],
      timer: json['timer'],
      hasTraining: json['hasTraining'] ?? true,
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  Training? _currentTraining;

  @override
  void initState() {
    super.initState();
    _loadCurrentTraining();
  }

  Future<void> _loadCurrentTraining() async {
    final prefs = await SharedPreferences.getInstance();
    final trainingString = prefs.getString('current_training');
    if (trainingString != null) {
      // Преобразуем строку обратно в JSON и создаем Training
      var json = trainingString.substring(1, trainingString.length - 1).split(', ');
      Map<String, dynamic> jsonMap = {};
      for (var item in json) {
        var parts = item.split(': ');
        var key = parts[0].replaceAll(RegExp(r'^{|}$'), '');
        var value = parts[1];
        if (key == 'hasTraining') {
          jsonMap[key] = value == 'true';
        } else {
          jsonMap[key] = value.replaceAll('"', '');
        }
      }
      setState(() {
        _currentTraining = Training.fromJson(jsonMap);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    bool hasCurrentTraining = _currentTraining?.hasTraining ?? false;

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 159,
                  height: 238,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                  ),
                  child: Image.asset('assets/images/logo.png', fit: BoxFit.contain),
                ),
                Container(
                  width: 146,
                  height: 146,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                  ),
                  padding: const EdgeInsets.only(right: 36),
                  child: Image.asset('assets/images/icon_user.png', fit: BoxFit.contain),
                ),
              ],
            ),
            const SizedBox(height: 30),

            // Блок текущей тренировки
            SizedBox(
              width: 360,
              height: 312,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black, width: 2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: hasCurrentTraining
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _currentTraining!.name,
                            style: GoogleFonts.barlow(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              color: Colors.black,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            _currentTraining!.timer,
                            style: GoogleFonts.barlow(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Colors.grey[600],
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const CurrentWorkoutScreen(),
                                ),
                              ).then((result) {
                                if (result != null && result is Training) {
                                  setState(() {
                                    _currentTraining = result;
                                  });
                                }
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: elevatedButtonBackgroundColor,
                              foregroundColor: elevatedButtonForegroundColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                              textStyle: GoogleFonts.barlow(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            child: const Text('перейти в текущую тренировку'),
                          ),
                          const SizedBox(height: 15),
                          ElevatedButton(
                            onPressed: () async {
                              final prefs = await SharedPreferences.getInstance();
                              await prefs.remove('current_training');
                              setState(() {
                                _currentTraining = null;
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: elevatedButtonBackgroundColor,
                              foregroundColor: elevatedButtonForegroundColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                              textStyle: GoogleFonts.barlow(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            child: const Text('завершить тренировку'),
                          ),
                        ],
                      )
                    : const SizedBox.shrink(),
              ),
            ),
            const SizedBox(height: 40),

            // Нижние кнопки: "Начать тренировку" и "Архив тренировок"
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const CurrentWorkoutScreen()),
                      );
                      if (result != null && result is Training) {
                        setState(() {
                          _currentTraining = result;
                        });
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: elevatedButtonBackgroundColor,
                      foregroundColor: elevatedButtonForegroundColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      textStyle: GoogleFonts.barlow(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    child: const Text('Начать\nтренировку', textAlign: TextAlign.center),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: elevatedButtonBackgroundColor,
                      foregroundColor: elevatedButtonForegroundColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      textStyle: GoogleFonts.barlow(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    child: const Text('Архив\nтренировок', textAlign: TextAlign.center),
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