import 'package:dp/colors.dart';
import 'package:dp/pages/current_training_page.dart';
import 'package:dp/pages/main_page.dart';
import 'package:dp/pages/progress_page.dart';
import 'package:dp/pages/profile_page.dart';
import 'package:dp/pages/training_archive_detail_page.dart';
import 'package:dp/services/workout_archive_service.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/archived_training.dart';
import '../models/training_models.dart';

class TrainingArchivePage extends StatefulWidget {
  const TrainingArchivePage({super.key});

  @override
  State<TrainingArchivePage> createState() => _TrainingArchivePageState();
}

class _TrainingArchivePageState extends State<TrainingArchivePage> {
  static const Color _textPrimary = Color(0xFF1A1A1A);
  static const Color _textSecondary = Color(0xFF8E8E93);
  static const Color _cardColor = Color(0xFFFFFBF5);
  static const Color _softTileColor = Color(0xFFFCF7EF);
  static const Color _borderSoft = Color(0xFFE8E2D6);
  static const Color _navBackground = Color(0xFFF2EAD9);

  Future<void> _startNewTraining() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('current_training');

    if (!mounted) return;

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CurrentWorkoutScreen(),
      ),
    );
  }

  void _openTrainingDetails(ArchivedTraining archivedTraining) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TrainingArchiveDetailPage(
          archivedTraining: archivedTraining,
        ),
      ),
    );
  }

  Future<void> _confirmDeleteTraining(ArchivedTraining archivedTraining) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: const Text('Удалить тренировку?'),
          content: Text(
            'Тренировка "${archivedTraining.name}" будет удалена из архива.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Отмена'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE15241),
                foregroundColor: Colors.white,
              ),
              child: const Text('Удалить'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) return;

    try {
      await WorkoutArchiveService.instance.deleteTraining(archivedTraining.id);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Тренировка удалена из архива')),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Не удалось удалить тренировку. Попробуйте снова.'),
        ),
      );
    }
  }

  Widget _buildCardActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: _softTileColor,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: color),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                child: StreamBuilder<List<ArchivedTraining>>(
                  stream: WorkoutArchiveService.instance.watchArchive(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return _buildErrorState();
                    }

                    if (snapshot.connectionState == ConnectionState.waiting &&
                        !snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final trainings = snapshot.data ?? const <ArchivedTraining>[];
                    if (trainings.isEmpty) {
                      return _buildEmptyState();
                    }

                    return ListView.separated(
                      padding: const EdgeInsets.only(bottom: 120),
                      itemCount: trainings.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 14),
                      itemBuilder: (context, index) {
                        final training = trainings[index];
                        return _buildArchiveCard(training);
                      },
                    );
                  },
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
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Архив тренировок',
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w800,
            color: _textPrimary,
          ),
        ),
        SizedBox(height: 6),
        Text(
          'Здесь собраны все завершенные тренировки вашего аккаунта.',
          style: TextStyle(
            fontSize: 15,
            color: _textSecondary,
            height: 1.3,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return SingleChildScrollView(
      child: Container(
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
              width: 92,
              height: 92,
              decoration: BoxDecoration(
                color: _softTileColor,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.history_rounded,
                size: 42,
                color: elevatedButtonBackgroundColor,
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Архив пока пуст',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: _textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Как только вы завершите тренировку, она автоматически появится здесь со всеми упражнениями и подходами.',
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
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: _cardColor,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: _borderSoft),
        ),
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.cloud_off_rounded,
              size: 40,
              color: _textSecondary,
            ),
            SizedBox(height: 14),
            Text(
              'Не удалось загрузить архив тренировок',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: _textPrimary,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Проверьте подключение к интернету и настройки Firestore.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: _textSecondary,
                height: 1.35,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildArchiveCard(ArchivedTraining archivedTraining) {
    final exercises = archivedTraining.exercises;

    return GestureDetector(
      onTap: () => _openTrainingDetails(archivedTraining),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: _cardColor,
          borderRadius: BorderRadius.circular(30),
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
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: elevatedButtonBackgroundColor.withOpacity(0.14),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    _formatDate(archivedTraining.completedAt),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: _textPrimary,
                    ),
                  ),
                ),
                const Spacer(),
                _buildCardActionButton(
                  icon: Icons.delete_outline_rounded,
                  color: const Color(0xFFE15241),
                  onTap: () => _confirmDeleteTraining(archivedTraining),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: elevatedButtonBackgroundColor.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Icon(
                    Icons.local_fire_department_rounded,
                    color: elevatedButtonBackgroundColor,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        archivedTraining.name,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: _textPrimary,
                          height: 1.15,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        archivedTraining.description.isEmpty
                            ? 'Описание не добавлено'
                            : archivedTraining.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          color: _textSecondary,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _buildInfoChip(
                  icon: Icons.fitness_center_rounded,
                  text:
                      '${archivedTraining.exerciseCount} ${_pluralize(archivedTraining.exerciseCount, 'упражнение', 'упражнения', 'упражнений')}',
                ),
                _buildInfoChip(
                  icon: Icons.repeat_rounded,
                  text:
                      '${archivedTraining.approachCount} ${_pluralize(archivedTraining.approachCount, 'подход', 'подхода', 'подходов')}',
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (exercises.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: _softTileColor,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Text(
                  'Тренировка сохранена без упражнений. Откройте карточку, чтобы посмотреть подробности.',
                  style: TextStyle(
                    fontSize: 14,
                    color: _textSecondary,
                    height: 1.35,
                  ),
                ),
              )
            else
              Column(
                children: [
                  ...exercises.take(3).map(_buildPreviewExerciseTile),
                  if (exercises.length > 3) ...[
                    const SizedBox(height: 6),
                    Text(
                      'И еще ${exercises.length - 3} ${_pluralize(exercises.length - 3, 'упражнение', 'упражнения', 'упражнений')}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: _textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            const SizedBox(height: 14),
            const Text(
              'Открыть детали тренировки',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: _textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewExerciseTile(Exercise exercise) {
    final approachesCount = exercise.approaches.length;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _borderSoft),
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
            approachesCount == 0
                ? 'без подходов'
                : '$approachesCount ${_pluralize(approachesCount, 'подход', 'подхода', 'подходов')}',
            style: const TextStyle(
              fontSize: 13,
              color: _textSecondary,
            ),
          ),
        ],
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
                isActive: false,
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MainPage(),
                    ),
                  );
                },
              ),
            ),
            Expanded(
              child: _buildTab(
                icon: Icons.view_list_rounded,
                label: 'Тренировки',
                isActive: true,
                onTap: null,
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
              fontSize: 12,
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

  String _formatDate(DateTime? value) {
    if (value == null) {
      return 'Недавно';
    }

    final local = value.toLocal();
    final day = local.day.toString().padLeft(2, '0');
    final month = local.month.toString().padLeft(2, '0');
    final year = local.year.toString();

    return '$day.$month.$year';
  }

  String _pluralize(int count, String one, String few, String many) {
    final remainder100 = count % 100;
    if (remainder100 >= 11 && remainder100 <= 19) {
      return many;
    }

    switch (count % 10) {
      case 1:
        return one;
      case 2:
      case 3:
      case 4:
        return few;
      default:
        return many;
    }
  }
}
