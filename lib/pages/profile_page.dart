import 'package:flutter/material.dart';
import 'package:dp/pages/main_page.dart';
import 'package:dp/colors.dart';
import 'package:google_fonts/google_fonts.dart'; // Добавлен недостающий импорт
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'dart:convert';
import '../models/training_models.dart';
import 'current_training_page.dart'; // Добавлен импорт для CurrentWorkoutScreen

class ProfilePage extends StatefulWidget { // Исправлено название класса (с большой буквы)
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => ProfilePageState(); // Исправлено название состояния
}

class ProfilePageState extends State<ProfilePage> { // Исправлено название класса
  final TextEditingController nameController = TextEditingController();
  final TextEditingController surnameController = TextEditingController();
  
  // Переменные для единообразного стиля
  final double fieldWidth = 320;
  final double fieldHeight = 56;
  final double verticalPadding = 25;
  
  // Переменные для хранения сохраненных данных
  String savedName = '';
  String savedSurname = '';
  
  // Флаг для отображения режима редактирования или просмотра
  bool isEditing = true;
  
  bool isRegister = true;

  @override
  void initState() {
    super.initState();
    nameController.addListener(_checkFields);
    surnameController.addListener(_checkFields);
  }

  @override
  void dispose() {
    nameController.removeListener(_checkFields);
    surnameController.removeListener(_checkFields);
    nameController.dispose();
    surnameController.dispose();
    super.dispose();
  }

  bool get _isBothFieldsFilled {
    return nameController.text.isNotEmpty && surnameController.text.isNotEmpty;
  }

  void _checkFields() {
    setState(() {});
  }

  // Функция сохранения данных
  void _saveData() {
    setState(() {
      savedName = nameController.text;
      savedSurname = surnameController.text;
      isEditing = false; // Переключаем в режим просмотра
    });
  }

  // Функция редактирования данных - ТОЛЬКО по иконке карандаша
  void _editData() {
    setState(() {
      nameController.text = savedName;
      surnameController.text = savedSurname;
      isEditing = true; // Переключаем в режим редактирования
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backGroundColor,
      body: Padding(
        padding: const EdgeInsets.only(left: 30.0, right: 30.0),
        child: SizedBox.expand(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Логотип/Иконка пользователя
              Padding(
                padding: const EdgeInsets.only(top: 40, bottom: 0),
                child: Image.asset(
                  'assets/images/icon_user.png',
                  height: 150,
                  width: 150,
                  errorBuilder: (context, error, stackTrace) { // Добавлен обработчик ошибок для изображения
                    return Container(
                      height: 150,
                      width: 150,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.person,
                        size: 80,
                        color: Colors.grey,
                      ),
                    );
                  },
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Отображение имени и фамилии в режиме просмотра
              if (!isEditing) ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10
                  ),
                  child: Column(
                    children: [
                      // Ряд с именем и иконкой карандаша
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            savedName.isEmpty && savedSurname.isEmpty 
                                ? 'Имя Фамилия' 
                                : '$savedName $savedSurname',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Иконка карандаша для редактирования
                          GestureDetector(
                            onTap: _editData,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.orange,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.orange.withOpacity(0.3),
                                    blurRadius: 4,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.edit,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
              
              const SizedBox(height: 30),
              
              // Поля ввода (видны только в режиме редактирования)
              if (isEditing) ...[
                // Поле ИМЯ
                Padding(
                  padding: const EdgeInsets.only(top: 0, bottom: 20),
                  child: Container(
                    width: fieldWidth,
                    height: fieldHeight,
                    child: TextField(
                      decoration: const InputDecoration(
                        hintText: 'Имя',
                        border: OutlineInputBorder(),
                      ),
                      controller: nameController,
                    ),
                  ),
                ),
                
                // Поле ФАМИЛИЯ
                Padding(
                  padding: const EdgeInsets.only(top: 5, bottom: 20),
                  child: Container(
                    width: fieldWidth,
                    height: fieldHeight,
                    child: TextField(
                      decoration: const InputDecoration(
                        hintText: 'Фамилия',
                        border: OutlineInputBorder(),
                      ),
                      controller: surnameController,
                    ),
                  ),
                ),
              ],
              
              const Spacer(),
              
              // Кнопка СОХРАНИТЬ в режиме редактирования
              if (isEditing && _isBothFieldsFilled)
                Padding(
                  padding: const EdgeInsets.only(bottom: 40),
                  child: ElevatedButton(
                    onPressed: _saveData,
                    style: ElevatedButton.styleFrom(
                      fixedSize: const Size(210, 60),
                      backgroundColor: const Color.fromARGB(255, 250, 167, 41),
                    ),
                    child: const Text(
                      'Сохранить', 
                      style: TextStyle(
                        fontSize: 16.5, 
                        fontWeight: FontWeight.w900,
                        color: Color.fromARGB(255, 0, 0, 0),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
      // Добавляем нашу панель навигации - ИСПРАВЛЕНО: теперь это часть Scaffold
      bottomNavigationBar: SafeArea(
        bottom: true,
        child: Container(
          height: 100,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 225, 216, 195),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: Row(
            children: [
              _buildTab(Icons.home, 'Домой', false, onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const MainPage()),
                );
              }),
              const Spacer(),
              _buildTab(Icons.view_list, 'Тренировки', false, onTap: () {
                // Добавьте навигацию на страницу тренировок
              }),
              const Spacer(),
              _buildFloatingButton(context),
              const Spacer(),
              _buildTab(Icons.bar_chart, 'Прогресс', false, onTap: () {
                // Добавьте навигацию на страницу прогресса
              }),
              const Spacer(),
              _buildTab(Icons.person, 'Профиль', true, onTap: null), // Текущая страница
            ],
          ),
        ),
      ),
    );
  }

  // Метод для создания вкладок навигации - ИСПРАВЛЕНО: добавлен параметр onTap
  Widget _buildTab(IconData icon, String label, bool isActive, {VoidCallback? onTap}) {
    final color = isActive ? elevatedButtonBackgroundColor : Colors.grey[700];
    return GestureDetector(
      onTap: onTap,
      child: Column(
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
      ),
    );
  }

  // Метод для оранжевой круглой кнопки - ИСПРАВЛЕНО: убраны несуществующие переменные
  Widget _buildFloatingButton(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: GestureDetector(
        onTap: () async {
          final prefs = await SharedPreferences.getInstance();
          await prefs.remove('current_training');

          // Исправлено: убраны обращения к _currentTrainingData и _loadCurrentTraining
          // так как этих переменных и методов нет в этом классе
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CurrentWorkoutScreen(),
            ),
          );
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