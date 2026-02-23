import 'package:dp/pages/current_training_page.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dp/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'dart:convert';
import '../models/training_models.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  Duration _duration = Duration();
  bool _timerStoped = false;
  Timer? _timer;
  FullTrainingData? _currentTrainingData;

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _duration = _duration + Duration(seconds: 1);
      });
    });
  }

  void _stopTimer() {
    _timer?.cancel();
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadCurrentTraining();
    _startTimer();
  }

  Future<void> _loadCurrentTraining() async {
    final prefs = await SharedPreferences.getInstance();
    final trainingString = prefs.getString('current_training');
    if (trainingString != null) {
      try {
        final jsonMap = jsonDecode(trainingString) as Map<String, dynamic>;
        final fullData = FullTrainingData.fromJson(jsonMap);
        if (fullData.basicInfo.hasTraining) {
          setState(() {
            _currentTrainingData = fullData;
          });
        } else {
          setState(() {
            _duration = Duration(seconds: 0);
            _currentTrainingData = null;
          });
        }
      } catch (e) {
        setState(() {
          _duration = Duration(seconds: 0);
          _currentTrainingData = null;
        });
      }
    } else {
      setState(() {
        _duration = Duration(seconds: 0);
        _currentTrainingData = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    bool hasCurrentTraining = _currentTrainingData != null;

    return Scaffold(
      backgroundColor: backGroundColor,
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const SizedBox(height: 30),
            
            // Блок текущей тренировки - ПОЯВЛЯЕТСЯ ТОЛЬКО КОГДА ЕСТЬ ТРЕНИРОВКА
            if (hasCurrentTraining && _currentTrainingData != null)
              Container(
                width: 360,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black, width: 2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _currentTrainingData!.basicInfo.name,
                      style: GoogleFonts.barlow(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Colors.black,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _formatDuration(_duration),
                      style: GoogleFonts.barlow(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    // Кнопка паузы/продолжения
                    ElevatedButton(
                      onPressed: () {
                        if (!_timerStoped) {
                          _stopTimer();
                        } else {
                          _startTimer();
                        }
                        setState(() {
                          _timerStoped = !_timerStoped;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        elevation: 0,
                        padding: EdgeInsets.zero,
                      ),
                      child: Image.asset(
                        _timerStoped
                            ? 'assets/images/continue.png'
                            : 'assets/images/pause.png',
                        fit: BoxFit.contain,
                        width: 40,
                        height: 40,
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Отображение упражнений
                    Container(
                      constraints: BoxConstraints(maxHeight: 150),
                      child: _currentTrainingData!.exercises.isEmpty
                          ? const Text(
                              "Нет упражнений",
                              textAlign: TextAlign.center,
                            )
                          : ListView.builder(
                              shrinkWrap: true,
                              itemCount: _currentTrainingData!.exercises.length,
                              itemBuilder: (context, idx) {
                                final ex = _currentTrainingData!.exercises[idx];
                                final hasApproaches = ex.approaches.isNotEmpty;
                                String exInfo = ex.name;
                                if (hasApproaches) {
                                  exInfo += " (${ex.approaches.length} подходов)";
                                }
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 2.0,
                                  ),
                                  child: Text(
                                    exInfo,
                                    style: GoogleFonts.barlow(
                                      fontSize: 14,
                                      color: Colors.black87,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                );
                              },
                            ),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const CurrentWorkoutScreen(),
                          ),
                        ).then((result) {
                          _loadCurrentTraining();
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: elevatedButtonBackgroundColor,
                        foregroundColor: elevatedButtonForegroundColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 24,
                        ),
                        textStyle: GoogleFonts.barlow(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      child: const Text(
                        'перейти в текущую тренировку',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            
            const SizedBox(height: 40),
            
            // Когда нет тренировки - картинка и текст
            if (!hasCurrentTraining || _currentTrainingData == null)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 200,
                        height: 200,
                        child: Image.asset(
                          'assets/images/sad.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'нет тренировки',
                        style: GoogleFonts.barlow(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: elevatedButtonForegroundColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
      // Добавляем нашу панель навигации
      bottomNavigationBar: SafeArea(
        bottom: true,
        child: Container(
          height: 100,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Color.fromARGB(255, 225, 216, 195),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: Row(
            children: [
              _buildTab(Icons.home, 'Домой', true),
              const Spacer(),
              _buildTab(Icons.view_list, 'Тренировки', false),
              const Spacer(),
              _buildFloatingButton(context),
              const Spacer(),
              _buildTab(Icons.bar_chart, 'Прогресс', false),
              const Spacer(),
              _buildTab(Icons.person, 'Профиль', false),
            ],
          ),
        ),
      ),
    );
  }

  // Метод для создания вкладок навигации
  Widget _buildTab(IconData icon, String label, bool isActive) {
    final color = isActive ? elevatedButtonBackgroundColor : Colors.grey[700];
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.barlow(
            fontSize: 14,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            color: color,
          ),
        ),
      ],
    );
  }

  // Метод для оранжевой круглой кнопки
  Widget _buildFloatingButton(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: GestureDetector(
        onTap: () async {
          final prefs = await SharedPreferences.getInstance();
          await prefs.remove('current_training');
          setState(() {
            _currentTrainingData = null;
          });

          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CurrentWorkoutScreen(),
            ),
          );
          _loadCurrentTraining();
        },
        child: Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                elevatedButtonBackgroundColor.withOpacity(0.9),
                elevatedButtonBackgroundColor.withOpacity(0.7),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: elevatedButtonBackgroundColor.withOpacity(0.4),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: const Center(
            child: Icon(Icons.fitness_center, color: Colors.white, size: 28),
          ),
        ),
      ),
    );
  }
}