import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('settings');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hive App',
      theme: ThemeData(
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late Box settingsBox;
  bool isRelaxMode = true;

  @override
  void initState() {
    super.initState();
    settingsBox = Hive.box('settings');
    isRelaxMode = settingsBox.get('isRelaxMode', defaultValue: true);
  }

  void _toggleMode() {
    setState(() {
      isRelaxMode = !isRelaxMode;
    });
    settingsBox.put('isRelaxMode', isRelaxMode);
  }

  @override
  Widget build(BuildContext context) {
    Color backgroundColor = isRelaxMode ? Colors.blue : Colors.green;
    String buttonText = isRelaxMode ? 'Modo Relax' : 'Modo Focado';

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Center(
        child: ElevatedButton(
          onPressed: _toggleMode,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
            textStyle: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          child: Text(buttonText),
        ),
      ),
    );
  }
}
