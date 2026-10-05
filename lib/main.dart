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

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(),
      home: const MainScreen(),
    );
  }
}
