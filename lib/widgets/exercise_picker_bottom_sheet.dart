import 'package:flutter/material.dart';

import '../models/exercise_catalog_data.dart';
import '../models/exercise_catalog_item.dart';
import '../services/custom_exercise_service.dart';

class ExercisePickerBottomSheet extends StatefulWidget {
  const ExercisePickerBottomSheet({super.key});

  @override
  State<ExercisePickerBottomSheet> createState() =>
      _ExercisePickerBottomSheetState();
}

class _ExercisePickerBottomSheetState extends State<ExercisePickerBottomSheet> {
  final TextEditingController _searchController = TextEditingController();

  static const Color _cardColor = Color(0xFFFFFBF5);
  static const Color _softTileColor = Color(0xFFFCF7EF);
  static const Color _borderSoft = Color(0xFFE8E2D6);
  static const Color _textPrimary = Color(0xFF1A1A1A);
  static const Color _textSecondary = Color(0xFF8E8E93);
  static const Color _accentColor = Color(0xFFF5A623);

  String _selectedGroup = 'Все';
  List<ExerciseCatalogItem> _customExercises = [];
  bool _isLoading = true;

  List<ExerciseCatalogItem> get _allExercises => [
        ...exerciseCatalog,
        ..._customExercises,
      ];

  List<String> get _groups {
    final groups = _allExercises.map((e) => e.muscleGroup).toSet().toList()
      ..sort();
    return ['Все', ...groups];
  }

  List<ExerciseCatalogItem> get _filteredExercises {
    final query = _searchController.text.trim();

    return _allExercises.where((exercise) {
      final matchesGroup =
          _selectedGroup == 'Все' || exercise.muscleGroup == _selectedGroup;
      final matchesQuery = exercise.matchesQuery(query);
      return matchesGroup && matchesQuery;
    }).toList();
  }

  List<ExerciseCatalogItem> get _popularExercises {
    const popularIds = {
      'bench_press_barbell',
      'barbell_squat',
      'deadlift',
      'lat_pulldown',
      'shoulder_press',
      'push_ups',
    };

    return _allExercises
        .where((exercise) => popularIds.contains(exercise.id))
        .toList();
  }

  @override
  void initState() {
    super.initState();
    _loadCustomExercises();
  }

  Future<void> _loadCustomExercises() async {
    final custom = await CustomExerciseService.instance.loadExercises();
    if (!mounted) return;

    setState(() {
      _customExercises = custom;
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _trackingTypeLabel(ExerciseTrackingType type) {
    switch (type) {
      case ExerciseTrackingType.weightReps:
        return 'Вес + повторения';
      case ExerciseTrackingType.bodyweightReps:
        return 'Собственный вес';
      case ExerciseTrackingType.duration:
        return 'Время';
    }
  }

  Future<void> _createCustomExercise() async {
  final nameController = TextEditingController(
    text: _searchController.text.trim(),
  );

  ExerciseTrackingType selectedType = ExerciseTrackingType.weightReps;

  final result = await showModalBottomSheet<ExerciseCatalogItem>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setModalState) {
          return Padding(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              bottom: MediaQuery.of(context).viewInsets.bottom + 16,
            ),
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
              decoration: BoxDecoration(
                color: _cardColor,
                borderRadius: BorderRadius.circular(28),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Создать своё упражнение',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: _textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      hintText: 'Название упражнения',
                      prefixIcon: const Icon(Icons.edit_note_rounded),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: const BorderSide(color: _borderSoft),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: const BorderSide(color: _borderSoft),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: const BorderSide(
                          color: _accentColor,
                          width: 1.4,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'Выберите как отслеживать упражнение',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: _textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...ExerciseTrackingType.values.map(
                    (type) => RadioListTile<ExerciseTrackingType>(
                      value: type,
                      groupValue: selectedType,
                      onChanged: (value) {
                        if (value == null) return;
                        setModalState(() {
                          selectedType = value;
                        });
                      },
                      title: Text(
  _trackingTypeLabel(type),
  style: const TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    color: _textPrimary,
  ),
),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        final customName = nameController.text.trim();
                        if (customName.isEmpty) return;

                        Navigator.pop(
                          context,
                          ExerciseCatalogItem(
                            id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
                            name: customName,
                            muscleGroup: 'Другое',
                            equipment: 'Не указано',
                            trackingType: selectedType,
                            isCustom: true,
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _accentColor,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
  'Создать упражнение',
  style: TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w700,
  ),
),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );

  if (result == null) return;

  await CustomExerciseService.instance.addExercise(result);

  if (!mounted) return;

  setState(() {
    final alreadyExists = _customExercises.any((e) => e.id == result.id);
    if (!alreadyExists) {
      _customExercises = [..._customExercises, result];
    }
  });

  Navigator.pop(context, result);
}

  @override
  Widget build(BuildContext context) {
    final filteredExercises = _filteredExercises;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(bottom: bottomInset),
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.88,
          ),
          decoration: const BoxDecoration(
            color: _cardColor,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  children: [
                    const SizedBox(height: 12),
                    Container(
                      width: 42,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.black12,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                    const SizedBox(height: 18),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Выберите упражнение',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                color: _textPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Найди упражнение по названию или группе мышц',
                          style: TextStyle(
                            fontSize: 15,
                            color: _textSecondary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Padding(
  padding: const EdgeInsets.symmetric(horizontal: 20),
  child: TextField(
    controller: _searchController,
    onChanged: (_) => setState(() {}),
    decoration: InputDecoration(
      hintText: 'Например: жим, спина, присед',
      prefixIcon: const Icon(Icons.search_rounded),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 14,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: _borderSoft),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: _borderSoft),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(
          color: _accentColor,
          width: 1.4,
        ),
      ),
    ),
  ),
),
const SizedBox(height: 12),
Padding(
  padding: const EdgeInsets.symmetric(horizontal: 20),
  child: SizedBox(
    width: double.infinity,
    child: ElevatedButton.icon(
      onPressed: _createCustomExercise,
      icon: const Icon(Icons.add_rounded),
      label: const Text(
  'Создать своё упражнение',
  style: TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w700,
  ),
),
      style: ElevatedButton.styleFrom(
        backgroundColor: _accentColor,
        foregroundColor: Colors.black,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 0,
      ),
    ),
  ),
),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 42,
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        scrollDirection: Axis.horizontal,
                        itemCount: _groups.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (context, index) {
                          final group = _groups[index];
                          final isSelected = group == _selectedGroup;

                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedGroup = group;
                              });
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected ? _accentColor : _softTileColor,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: isSelected ? _accentColor : _borderSoft,
                                ),
                              ),
                              child: Text(
                                group,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: isSelected ? Colors.white : _textPrimary,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 18),
                    Expanded(
                      child: filteredExercises.isEmpty
                          ? _buildEmptyState()
                          : ListView(
                              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                              children: [
                                if (_searchController.text.trim().isEmpty &&
                                    _selectedGroup == 'Все') ...[
                                  const Text(
                                    'Популярные упражнения',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                      color: _textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  ..._popularExercises.map(_buildExerciseTile),
                                  const SizedBox(height: 18),
                                  if (_customExercises.isNotEmpty) ...[
                                    const Text(
                                      'Мои упражнения',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w800,
                                        color: _textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    ..._customExercises.map(_buildExerciseTile),
                                    const SizedBox(height: 18),
                                  ],
                                  const Text(
                                    'Все упражнения',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                      color: _textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                ],
                                ...filteredExercises.map(_buildExerciseTile),
                              ],
                            ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildExerciseTile(ExerciseCatalogItem exercise) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: _softTileColor,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => Navigator.pop(context, exercise),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _borderSoft),
            ),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    exercise.isCustom
                        ? Icons.edit_note_rounded
                        : Icons.fitness_center_rounded,
                    color: _textPrimary,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        exercise.name,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: _textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${exercise.muscleGroup} • ${exercise.equipment}',
                        style: const TextStyle(
                          fontSize: 13,
                          color: _textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                if (exercise.isCustom)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Моё',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: _textPrimary,
                      ),
                    ),
                  )
                else
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: _textSecondary,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final query = _searchController.text.trim();

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: _softTileColor,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: _borderSoft),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.search_off_rounded,
                  size: 40,
                  color: _textSecondary,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Ничего не найдено',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: _textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  query.isEmpty
                      ? 'Попробуйте выбрать другую группу мышц'
                      : 'Можно создать своё упражнение на основе запроса',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    color: _textSecondary,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 16),
                if (query.isNotEmpty)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _createCustomExercise,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _accentColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: Text('Создать упражнение "$query"'),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}