import 'package:flutter/material.dart';
import 'package:hive_ce/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:todo_local/core/services/lifecycle_manager_service.dart';
import 'package:todo_local/ui/screens/home.dart';
import 'package:todo_local/core/viewmodels/home_viewmodel.dart';

void main() async {
  // Ensure Flutter Binding is initialized
  WidgetsFlutterBinding.ensureInitialized();

  final lm = LifecycleManager();
  lm.init();

  lm.registerHandler(
    name: 'test-timer',
    onPause: () {
      print('test-timer: pausing — cancel timers here');
      // yahan aap real timer cancel karenge
    },
    onResume: () {
      print('test-timer: resuming — restart timers here');
    },
  );

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
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.limeAccent),
      ),
      home: const HomeScreen(),
    );
  }
}
