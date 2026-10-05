import 'package:flutter/material.dart';
import 'MainScreen.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'task.dart';
import 'boxes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive for Flutter
  await Hive.initFlutter();

  Hive.registerAdapter(TaskAdapter());
  // Open the Hive box to store items
  boxTaks = await Hive.openBox<Task>('tasksBox');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Task Manager',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFB9B0F0), // soft lavender
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: Pastel.bg,
        fontFamily: 'Roboto',
      ),
      home: const MainScreen(),
    );
  }
}
