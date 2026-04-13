import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import 'models/score_entry.dart';
import 'services/data_service.dart';
import 'services/progress_service.dart';
import 'features/home/quick_launch_screen.dart';
import 'features/vocabulary/deck_picker_screen.dart';
import 'features/practice/subject_picker_screen.dart';
import 'features/math_sprint/sprint_hub_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Hive init
  await Hive.initFlutter();
  Hive.registerAdapter(ScoreEntryAdapter());
  await Future.wait([
    Hive.openBox<String>('vocab_progress'),
    Hive.openBox<ScoreEntry>('math_scores'),
    Hive.openBox('practice_stats'),
  ]);

  // Load content
  final dataService = DataService();
  await dataService.load();

  runApp(
    MultiProvider(
      providers: [
        Provider<DataService>.value(value: dataService),
        Provider<ProgressService>(create: (_) => ProgressService()),
      ],
      child: const PsychoPrepApp(),
    ),
  );
}

class PsychoPrepApp extends StatelessWidget {
  const PsychoPrepApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Psycho Prep',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFF57C00),
          primary: const Color(0xFFF57C00),
          onPrimary: Colors.white,
          secondary: const Color(0xFF66BB6A),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFF57C00),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        scaffoldBackgroundColor: const Color(0xFFFFF8F0),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Color(0xFFE65100)),
          bodyMedium: TextStyle(color: Color(0xFFE65100)),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFF57C00),
            foregroundColor: Colors.white,
          ),
        ),
      ),
      home: const MainShell(),
    );
  }
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  static const _screens = [
    QuickLaunchScreen(),
    SubjectPickerScreen(),
    DeckPickerScreen(),
    SprintHubScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.edit_outlined), selectedIcon: Icon(Icons.edit), label: 'Practice'),
          NavigationDestination(icon: Icon(Icons.menu_book_outlined), selectedIcon: Icon(Icons.menu_book), label: 'Vocabulary'),
          NavigationDestination(icon: Icon(Icons.bolt_outlined), selectedIcon: Icon(Icons.bolt), label: 'Games'),
        ],
      ),
    );
  }
}
