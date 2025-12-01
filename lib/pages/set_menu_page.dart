import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
  runApp(MaterialApp(home: MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _showDialog = false;
  final _repsController = TextEditingController();
  final _weightController = TextEditingController();

  List<Map<String, String>> _exerciseData = [];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(primaryColor: Colors.black87),
      home: Scaffold(
        body: GestureDetector(
          onTap: () {
            if (_showDialog) {
              setState(() {
                _showDialog = false;
                _repsController.clear();
                _weightController.clear();
              });
            }
          },
          behavior: HitTestBehavior.translucent,
          child: Stack(
            children: [
              Container(color: const Color.fromARGB(255, 235, 227, 208)),
              Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: const EdgeInsets.only(top: 90.0),
                  child: Text("--Название упражнения--", style: TextStyle(fontSize: 25)),
                ),
              ),
              Positioned(
                top: 150,
                left: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _exerciseData.asMap().entries.map((entry) {
                    final int index = entry.key;
                    final int approachNumber = index + 1;
                    final Map<String, String> data = entry.value;

                    return GestureDetector(
                      onLongPress: () {
                        _showDeleteDialog(context, index);
                      },
                      child: Text(
                        "Подход №$approachNumber: Повторения: ${data['reps']} Вес: ${data['weight']}",
                      ),
                    );
                  }).toList(),
                ),
              ),
              if (_showDialog) Container(color: Colors.black.withOpacity(0.5)),
              if (_showDialog)
                Align(
                  alignment: Alignment(0, 0),
                  child: GestureDetector(
                    onTap: () {},
                    child: Container(
                      width: 300.0,
                      height: 300.0,
                      decoration: BoxDecoration(
                        color: Color.fromARGB(255, 235, 227, 208),
                        border: Border.all(color: Colors.black, width: 1.0),
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                      padding: EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          TextFormField(
                            controller: _repsController,
                            decoration: InputDecoration(labelText: "Кол-во повторений"),
                            keyboardType: TextInputType.number,
                          ),
                          TextFormField(
                            controller: _weightController,
                            decoration: InputDecoration(labelText: "Вес"),
                            keyboardType: TextInputType.number,
                          ),
                          ElevatedButton(
                            onPressed: () {
                              if (_repsController.text.isNotEmpty &&
                                  _weightController.text.isNotEmpty) {
                                setState(() {
                                  _exerciseData.add({
                                    'reps': _repsController.text,
                                    'weight': _weightController.text,
                                  });

                                  _showDialog = false;
                                  _repsController.clear();
                                  _weightController.clear();
                                });
                              } else {}
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  Color.fromARGB(240, 240, 169, 28),
                            ),
                            child: Text('Сохранить',
                                style: TextStyle(color: Colors.black)), // Цвет текста черный
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        floatingActionButton: _showDialog
            ? null
            : SizedBox(
                width: 100,
                height: 100,
                child: FittedBox(
                    child: FloatingActionButton(
                  onPressed: () {
                    setState(() {
                      _showDialog = !_showDialog;
                    });
                  },
                  child: const Icon(
                    Icons.add,
                    size: 40.0,
                    color: Colors.black87,
                  ),
                  backgroundColor: Color.fromARGB(255, 196, 196, 195),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(300.0),
                  ),
                  splashColor: Colors.transparent,
                  highlightElevation: 0,
                ))),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Удалить подход?"),
          content: const Text("Вы уверены, что хотите удалить этот подход?"),
          actions: [
            TextButton(
              child: const Text("Отмена"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text("Удалить"),
              onPressed: () {
                setState(() {
                  _exerciseData.removeAt(index);
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _repsController.dispose();
    _weightController.dispose();
    super.dispose();
  }
}

