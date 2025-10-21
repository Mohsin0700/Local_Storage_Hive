import 'package:flutter/material.dart';
import 'package:hive_ce/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:todo_local/screens/home.dart';
import 'package:todo_local/viewmodels/home_viewmodel.dart';

void main() async {
  // Ensure Flutter Binding is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Get the application documents directory
  final appDocumentDir = await getApplicationDocumentsDirectory();

  // Hive initialization
  Hive.init(appDocumentDir.path);

  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => HomeViewmodel())],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        appBarTheme: AppBarThemeData(backgroundColor: Colors.lime),
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const HomeScreen(),
    );
  }
}
