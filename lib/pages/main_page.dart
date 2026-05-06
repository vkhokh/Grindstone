import 'dart:convert';

import 'package:dp/colors.dart';
import 'package:dp/pages/current_training_page.dart';
import 'package:dp/pages/progress_page.dart';
import 'package:dp/pages/profile_page.dart';
import 'package:dp/pages/training_archive_page.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/training_models.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  FullTrainingData? _currentTrainingData;

  static const Color _textPrimary = Color(0xFF1A1A1A);
  static const Color _textSecondary = Color(0xFF8E8E93);
  static const Color _cardColor = Color(0xFFFFFBF5);
  static const Color _softTileColor = Color(0xFFFCF7EF);
  static const Color _borderSoft = Color(0xFFE8E2D6);
  static const Color _navBackground = Color(0xFFF2EAD9);

  @override
  void initState() {
    super.initState();
    _loadCurrentTraining();
  }

  bool _hasCurrentTrainingDraft(FullTrainingData data) {
    return data.basicInfo.name.trim().isNotEmpty ||
        data.basicInfo.description.trim().isNotEmpty ||
        data.exercises.isNotEmpty;
  }

  Future<void> _loadCurrentTraining() async {
    final prefs = await SharedPreferences.getInstance();
    final trainingString = prefs.getString('current_training');
    if (!mounted) return;

    if (trainingString != null) {
      try {
        final jsonMap = jsonDecode(trainingString) as Map<String, dynamic>;
        final fullData = FullTrainingData.fromJson(jsonMap);

        setState(() {
          _currentTrainingData = _hasCurrentTrainingDraft(fullData)
              ? fullData
              : null;
        });
      } catch (_) {
        setState(() {
          _currentTrainingData = null;
        });
      }
    } else {
      setState(() {
        _currentTrainingData = null;
      });
    }
  }

  Future<void> _openCurrentTraining() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CurrentWorkoutScreen(),
      ),
    );
    if (!mounted) return;
    _loadCurrentTraining();
  }

  Future<void> _startNewTraining() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('current_training');
    if (!mounted) return;

    setState(() {
      _currentTrainingData = null;
    });

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CurrentWorkoutScreen(),
      ),
    );

    if (!mounted) return;
    _loadCurrentTraining();
  }

  @override
  Widget build(BuildContext context) {
    final hasCurrentTraining = _currentTrainingData != null;

    return Scaffold(
      backgroundColor: backGroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
          child: Column(
            children: [
              _buildHeader(),
              const SizedBox(height: 18),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      if (hasCurrentTraining)
                        _buildActiveTrainingCard()
                      else
                        _buildEmptyState(),
                      const SizedBox(height: 16),
                      _buildQuickActions(),
                      const SizedBox(height: 120),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  Widget _buildHeader() {
    final screenWidth = MediaQuery.of(context).size.width;
    final titleFontSize = (screenWidth * 0.08).clamp(26.0, 32.0);

    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                 'Добро пожаловать',
                  style: TextStyle(
                    fontSize: titleFontSize,
                    fontWeight: FontWeight.w800,
                    color: _textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ProfilePage(),
                ),
              );
            },
            child: Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: _cardColor,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: _borderSoft),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 14,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(
                Icons.person_outline_rounded,
                color: _textPrimary,
                size: 26,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveTrainingCard() {
    final training = _currentTrainingData!;
    final exercises = training.exercises;
    final exerciseCount = exercises.length;
    final trainingName = training.basicInfo.name.trim().isEmpty
        ? 'Тренировка без названия'
        : training.basicInfo.name;

    final totalApproaches = exercises.fold<int>(
      0,
      (sum, exercise) => sum + exercise.approaches.length,
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: _borderSoft),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Активная тренировка',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: _textSecondary,
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: elevatedButtonBackgroundColor.withOpacity(0.14),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  Icons.local_fire_department_rounded,
                  color: elevatedButtonBackgroundColor,
                  size: 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            trainingName,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: _textPrimary,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _buildInfoChip(
                icon: Icons.fitness_center_rounded,
                text: '$exerciseCount упражнений',
              ),
              _buildInfoChip(
                icon: Icons.repeat_rounded,
                text: '$totalApproaches подходов',
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (exercises.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 22,
              ),
              decoration: BoxDecoration(
                color: _softTileColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.fitness_center_rounded,
                    size: 34,
                    color: elevatedButtonBackgroundColor,
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Пока нет упражнений',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: _textPrimary,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Открой тренировку и добавь первое упражнение',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      color: _textSecondary,
                    ),
                  ),
                ],
              ),
            )
          else
            Column(
              children: exercises.take(4).map((exercise) {
                final approachCount = exercise.approaches.length;

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _borderSoft),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: _softTileColor,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.fitness_center_rounded,
                          color: _textPrimary,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          exercise.name,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: _textPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        approachCount == 0
                            ? 'без подходов'
                            : '$approachCount подход',
                        style: const TextStyle(
                          fontSize: 14,
                          color: _textSecondary,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          if (exercises.length > 4) ...[
            const SizedBox(height: 2),
            Text(
              'И ещё ${exercises.length - 4} упражнений',
              style: const TextStyle(
                fontSize: 14,
                color: _textSecondary,
              ),
            ),
          ],
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _openCurrentTraining,
              style: ElevatedButton.styleFrom(
                backgroundColor: elevatedButtonBackgroundColor,
                foregroundColor: elevatedButtonForegroundColor,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              child: const Text(
                'Открыть тренировку',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 28),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: _borderSoft),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 104,
            height: 104,
          ),
          const SizedBox(height: 18),
          const Text(
            'У тебя пока нет тренировки',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: _textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Создай первую тренировку и начни отслеживать упражнения и подходы.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: _textSecondary,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 22),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _startNewTraining,
              style: ElevatedButton.styleFrom(
                backgroundColor: elevatedButtonBackgroundColor,
                foregroundColor: elevatedButtonForegroundColor,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              child: const Text(
                'Создать тренировку',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

Widget _buildQuickActions() {
  final screenWidth = MediaQuery.of(context).size.width;
  final cardHeight = (screenWidth * 0.50).clamp(130.0, 180.0);

  return Row(
    children: [
      Expanded(
        child: SizedBox(
          height: cardHeight,
          child: _buildQuickActionCard(
            icon: Icons.add_circle_outline_rounded,
            title: 'Новая тренировка',
            subtitle: 'Начать сейчас',
            onTap: _startNewTraining,
          ),
        ),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: SizedBox(
          height: cardHeight,
          child: _buildQuickActionCard(
            icon: Icons.person_outline_rounded,
            title: 'Профиль',
            subtitle: 'Личные данные',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ProfilePage(),
                ),
              );
            },
          ),
        ),
      ),
    ],
  );
}

  Widget _buildQuickActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: _cardColor,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: _borderSoft),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 14,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  children: [
    Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        color: elevatedButtonBackgroundColor.withOpacity(0.14),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(
        icon,
        color: elevatedButtonBackgroundColor,
        size: 24,
      ),
    ),
    const SizedBox(height: 12),
    Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: _textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: const TextStyle(
            fontSize: 14,
            color: _textSecondary,
          ),
        ),
      ],
    ),
  ],
),
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String text,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: _softTileColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _borderSoft),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: _textPrimary),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: _textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.fromLTRB(8, 0, 8, 12),
       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        decoration: BoxDecoration(
          color: _navBackground,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 22,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: _buildTab(
                icon: Icons.home_rounded,
                label: 'Домой',
                isActive: true,
                onTap: null,
              ),
            ),
            Expanded(
              child: _buildTab(
                icon: Icons.view_list_rounded,
                label: 'Тренировки',
                isActive: false,
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const TrainingArchivePage(),
                    ),
                  );
                },
              ),
            ),
            _buildFloatingButton(),
            Expanded(
              child: _buildTab(
                icon: Icons.bar_chart_rounded,
                label: 'Прогресс',
                isActive: false,
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ProgressPage(),
                    ),
                  );
                },
              ),
            ),
            Expanded(
              child: _buildTab(
                icon: Icons.person_rounded,
                label: 'Профиль',
                isActive: false,
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ProfilePage(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTab({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback? onTap,
  }) {
    final color =
        isActive ? elevatedButtonBackgroundColor : const Color(0xFF6F6F74);

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isActive
                  ? elevatedButtonBackgroundColor.withOpacity(0.14)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 4),
          Text(
  label,
  maxLines: 1,
  overflow: TextOverflow.ellipsis,
  style: TextStyle(
    fontSize: 13, // 👈 уменьшили
    fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
    color: color,
  ),
),
        ],
      ),
    );
  }

  Widget _buildFloatingButton() {
    return GestureDetector(
      onTap: _startNewTraining,
      child: Container(
        width: 56,
        height: 56,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: elevatedButtonBackgroundColor,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: elevatedButtonBackgroundColor.withOpacity(0.35),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: const Icon(
          Icons.add_rounded,
          color: Colors.white,
          size: 32,
        ),
      ),
    );
  }
}
