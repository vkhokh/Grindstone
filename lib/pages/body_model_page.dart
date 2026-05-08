import 'package:flutter/material.dart';

import '../models/exercise_catalog_data.dart';
import '../models/exercise_catalog_item.dart';
import '../services/custom_exercise_service.dart';

class MuscleGroup {
  final String id;
  final String name;
  final List<String> exercises;
  final bool isFront;
  final Path Function(double w, double h) buildPath;

  MuscleGroup({
    required this.id,
    required this.name,
    required this.exercises,
    required this.isFront,
    required this.buildPath,
  });
}

Path smoothPath(List<Offset> points) {
  final path = Path();
  if (points.length < 3) {
    path.moveTo(points[0].dx, points[0].dy);
    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }
    path.close();
    return path;
  }

  final first = points[0];
  final last = points[points.length - 1];
  path.moveTo(
    (last.dx + first.dx) / 2,
    (last.dy + first.dy) / 2,
  );

  for (int i = 0; i < points.length; i++) {
    final current = points[i];
    final next = points[(i + 1) % points.length];
    final midX = (current.dx + next.dx) / 2;
    final midY = (current.dy + next.dy) / 2;
    path.quadraticBezierTo(current.dx, current.dy, midX, midY);
  }

  path.close();
  return path;
}

List<Offset> relToAbs(List<List<double>> rel, double w, double h) {
  return rel.map((p) => Offset(p[0] * w, p[1] * h)).toList();
}

List<MuscleGroup> buildAllMuscleGroups() {
  return [
    MuscleGroup(
      id: 'chest',
      name: 'Грудные мышцы',
      exercises: ['Жим штанги лёжа', 'Отжимания от пола', 'Сведение гантелей лёжа'],
      isFront: true,
      buildPath: (w, h) => smoothPath(relToAbs([
        [0.325, 0.263],
        [0.4, 0.2],
        [0.5, 0.23],
        [0.6, 0.2],
        [0.68, 0.263],
        [0.6, 0.32],
        [0.5, 0.3],
        [0.41, 0.32],
        [0.37, 0.30],
      ], w, h)),
    ),
    MuscleGroup(
      id: 'shoulders_left',
      name: 'Плечи',
      exercises: ['Армейский жим штанги', 'Махи гантелей в стороны', 'Подъём гантелей перед собой'],
      isFront: true,
      buildPath: (w, h) => smoothPath(relToAbs([
        [0.34, 0.2],
        [0.290, 0.21],
        [0.278, 0.228],
        [0.253, 0.260],
        [0.278, 0.29],
        [0.3, 0.280],
        [0.32, 0.265],
        [0.36, 0.23],
        [0.4, 0.21],
        [0.350, 0.20],
        [0.335, 0.20],
      ], w, h)),
    ),
    MuscleGroup(
      id: 'shoulders_right',
      name: 'Плечи',
      exercises: ['Армейский жим штанги', 'Махи гантелей в стороны', 'Подъём гантелей перед собой'],
      isFront: true,
      buildPath: (w, h) => smoothPath(relToAbs([
        [0.66, 0.2],
        [0.71, 0.21],
        [0.722, 0.228],
        [0.747, 0.260],
        [0.722, 0.29],
        [0.70, 0.280],
        [0.68, 0.265],
        [0.64, 0.23],
        [0.60, 0.21],
        [0.65, 0.20],
        [0.665, 0.20],
      ], w, h)),
    ),
    MuscleGroup(
      id: 'biceps_left',
      name: 'Бицепсы',
      exercises: ['Подъём штанги на бицепс', 'Молотковые сгибания', 'Концентрированный подъём'],
      isFront: true,
      buildPath: (w, h) => smoothPath(relToAbs([
        [0.345, 0.28],
        [0.34, 0.265],
        [0.26, 0.29],
        [0.22, 0.34],
        [0.28, 0.39],
        [0.32, 0.36],
        [0.34, 0.32],
        [0.3, 0.34],
        [0.34, 0.33],
      ], w, h)),
    ),
    MuscleGroup(
      id: 'biceps_right',
      name: 'Бицепсы',
      exercises: ['Подъём штанги на бицепс', 'Молотковые сгибания', 'Концентрированный подъём'],
      isFront: true,
      buildPath: (w, h) => smoothPath(relToAbs([
        [0.655, 0.28],
        [0.66, 0.265],
        [0.74, 0.29],
        [0.78, 0.34],
        [0.72, 0.39],
        [0.68, 0.36],
        [0.66, 0.32],
        [0.70, 0.34],
        [0.66, 0.33],
      ], w, h)),
    ),
    MuscleGroup(
      id: 'abs',
      name: 'Пресс',
      exercises: ['Скручивания на полу', 'Планка 60 сек', 'Подъём ног в висе', 'Велосипед лёжа'],
      isFront: true,
      buildPath: (w, h) => smoothPath(relToAbs([
        [0.420, 0.32],
        [0.43, 0.320],
        [0.41, 0.320],
        [0.339, 0.29],
        [0.380, 0.400],
        [0.375, 0.440],
        [0.380, 0.450],
        [0.500, 0.480],
        [0.570, 0.470],
        [0.600, 0.440],
        [0.630, 0.420],
        [0.622, 0.40],
        [0.628, 0.38],
        [0.65, 0.310],
        [0.66, 0.29],
        [0.59, 0.320],
        [0.500, 0.3],
      ], w, h)),
    ),
    MuscleGroup(
      id: 'legs',
      name: 'Ноги',
      exercises: ['Приседания со штангой', 'Жим ногами в тренажёре', 'Разгибания ног сидя'],
      isFront: true,
      buildPath: (w, h) => smoothPath(relToAbs([
        [0.5, 0.5],
        [0.4, 0.43],
        [0.356, 0.45],
        [0.32, 0.620],
        [0.360, 0.680],
        [0.320, 0.780],
        [0.360, 0.850],
        [0.350, 0.890],
        [0.410, 0.890],
        [0.410, 0.810],
        [0.440, 0.780],
        [0.430, 0.710],
        [0.470, 0.650],
        [0.500, 0.515],
        [0.530, 0.650],
        [0.570, 0.710],
        [0.560, 0.780],
        [0.590, 0.810],
        [0.590, 0.890],
        [0.650, 0.890],
        [0.640, 0.850],
        [0.680, 0.780],
        [0.640, 0.680],
        [0.670, 0.620],
        [0.67, 0.55],
        [0.65, 0.48],
        [0.610, 0.43],
      ], w, h)),
    ),
    MuscleGroup(
      id: 'back_front_left',
      name: 'Спина',
      exercises: ['Подтягивания широким хватом', 'Тяга штанги в наклоне', 'Тяга верхнего блока'],
      isFront: true,
      buildPath: (w, h) => smoothPath(relToAbs([
        [0.33, 0.205],
        [0.43, 0.18],
        [0.44, 0.17],
        [0.5, 0.17],
        [0.565, 0.17],
        [0.57, 0.18],
        [0.67, 0.205],
        [0.5, 0.21],
      ], w, h)),
    ),
    MuscleGroup(
      id: 'shoulders_back_left',
      name: 'Плечи',
      exercises: ['Жим гантелей сидя', 'Махи гантелей в стороны', 'Тяга штанги к подбородку'],
      isFront: false,
      buildPath: (w, h) => smoothPath(relToAbs([
        [0.290, 0.213],
        [0.278, 0.237],
        [0.258, 0.260],
        [0.278, 0.29],
        [0.28, 0.280],
        [0.32, 0.265],
        [0.36, 0.25],
        [0.4, 0.22],
        [0.350, 0.20],
        [0.335, 0.2],
      ], w, h)),
    ),
    MuscleGroup(
      id: 'shoulders_back_right',
      name: 'Плечи',
      exercises: ['Жим гантелей сидя', 'Махи гантелей в стороны', 'Тяга штанги к подбородку'],
      isFront: false,
      buildPath: (w, h) => smoothPath(relToAbs([
        [0.710, 0.213],
        [0.722, 0.237],
        [0.742, 0.260],
        [0.722, 0.29],
        [0.720, 0.280],
        [0.680, 0.265],
        [0.640, 0.25],
        [0.60, 0.22],
        [0.650, 0.20],
        [0.665, 0.2],
      ], w, h)),
    ),
    MuscleGroup(
      id: 'triceps_back_left',
      name: 'Трицепс',
      exercises: ['Французский жим', 'Разгибание рук на блоке', 'Отжимания на брусьях'],
      isFront: false,
      buildPath: (w, h) => smoothPath(relToAbs([
        [0.345, 0.28],
        [0.34, 0.265],
        [0.26, 0.29],
        [0.22, 0.34],
        [0.28, 0.39],
        [0.32, 0.36],
        [0.34, 0.32],
        [0.3, 0.34],
        [0.34, 0.33],
      ], w, h)),
    ),
    MuscleGroup(
      id: 'triceps_back_right',
      name: 'Трицепс',
      exercises: ['Французский жим', 'Разгибание рук на блоке', 'Отжимания на брусьях'],
      isFront: false,
      buildPath: (w, h) => smoothPath(relToAbs([
        [0.655, 0.28],
        [0.66, 0.265],
        [0.74, 0.29],
        [0.78, 0.34],
        [0.72, 0.39],
        [0.68, 0.36],
        [0.66, 0.32],
        [0.70, 0.34],
        [0.66, 0.33],
      ], w, h)),
    ),
    MuscleGroup(
      id: 'legs_back',
      name: 'Ноги',
      exercises: ['Становая тяга', 'Сгибание ног лёжа', 'Выпады назад', 'Ягодичный мостик'],
      isFront: false,
      buildPath: (w, h) => smoothPath(relToAbs([
        [0.5, 0.46],
        [0.4, 0.43],
        [0.356, 0.45],
        [0.32, 0.620],
        [0.360, 0.680],
        [0.320, 0.780],
        [0.360, 0.850],
        [0.350, 0.890],
        [0.410, 0.890],
        [0.410, 0.810],
        [0.440, 0.780],
        [0.430, 0.710],
        [0.470, 0.650],
        [0.500, 0.505],
        [0.530, 0.650],
        [0.570, 0.710],
        [0.560, 0.780],[0.590, 0.810],
        [0.590, 0.890],
        [0.650, 0.890],
        [0.640, 0.850],
        [0.680, 0.780],
        [0.640, 0.680],
        [0.670, 0.620],
        [0.67, 0.55],
        [0.65, 0.48],
        [0.610, 0.43],
      ], w, h)),
    ),
    MuscleGroup(
      id: 'back_back',
      name: 'Спина',
      exercises: ['Подтягивания широким хватом', 'Тяга штанги в наклоне', 'Тяга верхнего блока'],
      isFront: false,
      buildPath: (w, h) => smoothPath(relToAbs([
        [0.67, 0.205],
        [0.56, 0.17],
        [0.57, 0.18],
        [0.5, 0.12],
        [0.43, 0.18],
        [0.44, 0.17],
        [0.33, 0.205],
        [0.41, 0.22],
        [0.33, 0.26],
        [0.36, 0.35],
        [0.38, 0.39],
        [0.36, 0.43],
        [0.50, 0.46],
        [0.64, 0.43],
        [0.62, 0.39],
        [0.64, 0.35],
        [0.67, 0.26],
        [0.59, 0.22],
      ], w, h)),
    ),
  ];
}

class BodyModelPage extends StatefulWidget {
  const BodyModelPage({super.key});

  @override
  State<BodyModelPage> createState() => _BodyModelPageState();
}

class _BodyModelPageState extends State<BodyModelPage> {
  late List<MuscleGroup> allGroups;

  List<ExerciseCatalogItem> _allExercises = [];
  bool _isLoadingExercises = true;

  bool showFront = true;
  String? selectedGroupId;
  final double canvasWidth = 300;
  final double canvasHeight = 500;

  @override
  void initState() {
    super.initState();
    allGroups = buildAllMuscleGroups();
    _loadExercises();
  }

  Future<void> _loadExercises() async {
    final customExercises = await CustomExerciseService.instance.loadExercises();

    if (!mounted) return;

    setState(() {
      _allExercises = [
        ...exerciseCatalog,
        ...customExercises,
      ];
      _isLoadingExercises = false;
    });
  }

  String _catalogMuscleGroupName(String bodyModelGroupName) {
    switch (bodyModelGroupName) {
      case 'Грудные мышцы':
        return 'Грудь';
      case 'Бицепсы':
        return 'Бицепс';
      case 'Плечи':
        return 'Плечи';
      case 'Пресс':
        return 'Пресс';
      case 'Ноги':
        return 'Ноги';
      case 'Спина':
        return 'Спина';
      case 'Трицепс':
        return 'Трицепс';
      default:
        return bodyModelGroupName;
    }
  }

  List<ExerciseCatalogItem> _exercisesForGroup(MuscleGroup group) {
    final targetGroup = _catalogMuscleGroupName(group.name);

    final exercises = _allExercises.where((exercise) {
      return exercise.muscleGroup.trim().toLowerCase() ==
          targetGroup.trim().toLowerCase();
    }).toList()
      ..sort((a, b) => a.name.compareTo(b.name));

    return exercises;
  }

  List<MuscleGroup> get currentGroups =>
      allGroups.where((g) => g.isFront == showFront).toList();

  String? getPairedGroupId(String groupId) {
    if (groupId == 'shoulders_back_left') return 'shoulders_back_right';
    if (groupId == 'shoulders_back_right') return 'shoulders_back_left';
    if (groupId == 'shoulders_left') return 'shoulders_right';
    if (groupId == 'shoulders_right') return 'shoulders_left';
    if (groupId == 'biceps_left') return 'biceps_right';
    if (groupId == 'biceps_right') return 'biceps_left';
    if (groupId == 'triceps_back_left') return 'triceps_back_right';
    if (groupId == 'triceps_back_right') return 'triceps_back_left';
    if (groupId == 'back_front_left') return 'back_front_right';
    if (groupId == 'back_front_right') return 'back_front_left';
    return null;
  }

  MuscleGroup? getSelectedGroup() {
    if (selectedGroupId == null) return null;
    return allGroups.firstWhere((g) => g.id == selectedGroupId);
  }

  Set<String> getHighlightedIds() {
    if (selectedGroupId == null) return {};
    final Set<String> highlighted = {selectedGroupId!};
    final pairedId = getPairedGroupId(selectedGroupId!);
    if (pairedId != null) highlighted.add(pairedId);
    return highlighted;
  }

  void _onTapDown(TapDownDetails details) {
    final pos = details.localPosition;
    final groups = currentGroups.reversed.toList();
    for (var group in groups) {
      final path = group.buildPath(canvasWidth, canvasHeight);
      if (path.contains(pos)) {
        setState(() {
          selectedGroupId = selectedGroupId == group.id ? null : group.id;
        });
        return;
      }
    }
    setState(() => selectedGroupId = null);
  }

  void _toggleSide() {
    setState(() {
      showFront = !showFront;
      selectedGroupId = null;
    });
  }

  void _deleteExercise(int index) {
    final selectedGroup = getSelectedGroup();
    if (selectedGroup == null) return;
    setState(() {
      final groupIndex = allGroups.indexWhere((g) => g.id == selectedGroup.id);
      if (groupIndex != -1) {
        final updatedExercises = List<String>.from(allGroups[groupIndex].exercises);
        final deletedExercise = updatedExercises.removeAt(index);
        allGroups[groupIndex] = MuscleGroup(
          id: allGroups[groupIndex].id,
          name: allGroups[groupIndex].name,
          exercises: updatedExercises,
          isFront: allGroups[groupIndex].isFront,
          buildPath: allGroups[groupIndex].buildPath,
        );
        final pairedId = getPairedGroupId(selectedGroup.id);
        if (pairedId != null) {
          final pairedIndex = allGroups.indexWhere((g) => g.id == pairedId);if (pairedIndex != -1 && index < allGroups[pairedIndex].exercises.length) {
            final pairedExercises = List<String>.from(allGroups[pairedIndex].exercises);
            pairedExercises.removeAt(index);
            allGroups[pairedIndex] = MuscleGroup(
              id: allGroups[pairedIndex].id,
              name: allGroups[pairedIndex].name,
              exercises: pairedExercises,
              isFront: allGroups[pairedIndex].isFront,
              buildPath: allGroups[pairedIndex].buildPath,
            );
          }
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Упражнение "$deletedExercise" удалено'), backgroundColor: Colors.red),
        );
      }
    });
  }

  void _addExerciseToTraining(ExerciseCatalogItem exercise) {
    Navigator.pop(context, exercise);
  }

  @override
  Widget build(BuildContext context) {
    final highlightedIds = getHighlightedIds();
    final selectedGroup = getSelectedGroup();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Выбор группы мышц'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 8),
              Text(
                showFront ? '▼ Нажми на мышцу (вид спереди)' : '▼ Нажми на мышцу (вид сзади)',
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 4),
              Center(
                child: GestureDetector(
                  onTapDown: _onTapDown,
                  child: SizedBox(
                    width: canvasWidth,
                    height: canvasHeight,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.asset(
                          showFront ? 'assets/images/bodyup.png' : 'assets/images/bodyback.png',
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: const Color(0xFFEBE3D0),
                              child: const Center(child: Text('Загрузите изображение\nтела', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey))),
                            );
                          },
                        ),
                        ...currentGroups.where((g) => highlightedIds.contains(g.id)).map((group) {
                          return CustomPaint(
                            painter: MuscleHighlightPainter(
                              path: group.buildPath(canvasWidth, canvasHeight),
                              color: const Color(0xFFF0A91C).withOpacity(0.5),
                            ),
                            size: Size(canvasWidth, canvasHeight),
                          );
                        }),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Center(
                  child: ElevatedButton.icon(
                    onPressed: _toggleSide,
                    icon: const Icon(Icons.refresh),
                    label: Text(showFront ? 'Переключить на вид сзади' : 'Переключить на вид спереди'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF0A91C),
                      foregroundColor: Colors.white,padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ),
              const Divider(thickness: 1.5, height: 24),
              selectedGroup == null
                  ? Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.touch_app, size: 48, color: Colors.grey.shade400),
                          const SizedBox(height: 8),
                          Text('Выберите мышечную группу', style: TextStyle(fontSize: 16, color: Colors.grey.shade500)),
                        ],
                      ),
                    )
                  : SizedBox(
                      height: 350,
                      child: WorkoutList(
                        group: selectedGroup,
                        exercises: _exercisesForGroup(selectedGroup),
                        isLoading: _isLoadingExercises,
                        onAddExercise: _addExerciseToTraining,
                      ),
                    ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class MuscleHighlightPainter extends CustomPainter {
  final Path path;
  final Color color;

  const MuscleHighlightPainter({required this.path, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawPath(path, Paint()..color = color..style = PaintingStyle.fill);
  }

  @override
  bool shouldRepaint(covariant MuscleHighlightPainter oldDelegate) => oldDelegate.path != path || oldDelegate.color != color;
}


class WorkoutList extends StatelessWidget {
  final MuscleGroup group;
  final List<ExerciseCatalogItem> exercises;
  final bool isLoading;
  final ValueChanged<ExerciseCatalogItem> onAddExercise;

  const WorkoutList({
    super.key,
    required this.group,
    required this.exercises,
    required this.isLoading,
    required this.onAddExercise,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFFF0A91C),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            children: [
              Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: const Color(0xFFF0A91C),
                  borderRadius: BorderRadius.circular(7),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  group.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFF0A91C),
                  ),
                ),
              ),
            ],
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Нажми на упражнение, чтобы добавить его в тренировку',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey,
            ),
          ),
        ),
        const SizedBox(height: 8),
        if (exercises.isEmpty)
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  'Для этой группы мышц пока нет упражнений в каталоге.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey.shade600,
                    height: 1.35,
                  ),
                ),
              ),
            ),
          )
        else
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: exercises.length,
              itemBuilder: (context, index) {
                final exercise = exercises[index];

                return Card(
                  elevation: 3,
                  margin: const EdgeInsets.symmetric(vertical: 5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: ListTile(
                    onTap: () => onAddExercise(exercise),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    leading: CircleAvatar(
                      backgroundColor:
                          const Color(0xFFF0A91C).withOpacity(0.16),
                      child: Text(
                        '${index + 1}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFF0A91C),
                        ),
                      ),
                    ),
                    title: Text(
                      exercise.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      exercise.equipment,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    trailing: const Icon(
                      Icons.chevron_right_rounded,
                      color: Color(0xFF8E8E93),
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}
