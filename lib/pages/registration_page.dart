import 'package:flutter/material.dart';
import 'package:dp/pages/main_page.dart';

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key});

  @override
  State<RegistrationPage> createState() => RegistrationPageState();
}

class RegistrationPageState extends State<RegistrationPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  
  // Переменные для единообразного стиля
  final double fieldWidth = 320;
  final double fieldHeight = 56; // Высота всех полей
  final double verticalPadding = 25; // Внутренний отступ сверху/снизу
  
  bool isRegister = true;

    @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.only(left: 30.0, right: 30.0),
        child: SizedBox.expand(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.only(top: 0, bottom: 0),
                child: Image.asset(
                  'assets/images/logo.png',
                  height: 300,
                  width: 300,
                ),
              ),
              Transform.translate(
                offset: Offset(0, -40),
                child: Padding(
                  padding: EdgeInsets.only(top: 5, bottom: 0),
                  child: Text(
                    "GRINDSTONE",
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.displayLarge,
                  ),
                ),
              ),
              
            
              
              // Поле ПОЧТА
              Padding(
                padding: const EdgeInsets.only(top: 20, bottom: 20),
                child: Container(
                  width: fieldWidth,
                  height: fieldHeight,
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Почта',
                      contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 13),
                      border: const OutlineInputBorder(),
                    ),
                    controller: emailController,
                  ),
                ),
              ),
              
              // Поле ПАРОЛЬ
              Padding(
                padding: const EdgeInsets.only(top: 5, bottom: 20),
                child: Container(
                  width: fieldWidth,
                  height: fieldHeight,
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Пароль',
                      contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 13),
                      border: const OutlineInputBorder(),
                    ),
                    controller: passwordController,
                    obscureText: true,
                  ),
                ),
              ),
              
              // Поле ПОВТОРИТЕ ПАРОЛЬ
              Padding(
                padding: const EdgeInsets.only(top: 5, bottom: 30),
                child: Container(
                  width: fieldWidth,
                  height: fieldHeight,
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Повторите пароль',
                      contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 13),
                      border: const OutlineInputBorder(),
                    ),
                    controller: confirmPasswordController,
                    obscureText: true,
                  ),
                ),
              ),

              // Кнопка регистрации
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const MainPage()),
                  );
                },
                style: ElevatedButton.styleFrom(fixedSize: Size(265, 60)),
                child: Text('Зарегистрироваться', maxLines: 1,),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 