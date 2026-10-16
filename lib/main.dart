import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/about.dart';
import 'screens/explore.dart';
import 'screens/saved.dart';
import 'services/saved_store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await savedStore.load();
  runApp(const BoholExplorerApp());
}

ThemeData buildTheme() {
  final scheme = ColorScheme.fromSeed(seedColor: const Color(0xFF00796B));
  final base = ThemeData(colorScheme: scheme, useMaterial3: true);
  return base.copyWith(
    textTheme: GoogleFonts.poppinsTextTheme(base.textTheme),
    scaffoldBackgroundColor: const Color(0xFFF5F8F7),
    appBarTheme: AppBarTheme(
      backgroundColor: scheme.primary,
      foregroundColor: scheme.onPrimary,
      centerTitle: true,
      titleTextStyle: GoogleFonts.poppins(
          fontSize: 20, fontWeight: FontWeight.w600, color: scheme.onPrimary),
    ),
    inputDecorationTheme: const InputDecorationTheme(border: OutlineInputBorder()),
  );
}

class BoholExplorerApp extends StatelessWidget {
  const BoholExplorerApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Bohol Explorer',
        debugShowCheckedModeBanner: false,
        theme: buildTheme(),
        home: const HomeShell(),
      );
}

/// Bottom-navigation shell (StatefulWidget: tracks the selected tab).
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});
  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;
  static const _pages = [ExploreScreen(), SavedScreen(), AboutScreen()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _pages),
      bottomNavigationBar: ListenableBuilder(
        listenable: savedStore,
        builder: (context, _) => NavigationBar(
          selectedIndex: _index,
          onDestinationSelected: (i) => setState(() => _index = i),
          destinations: [
            const NavigationDestination(
                icon: Icon(Icons.explore_outlined),
                selectedIcon: Icon(Icons.explore),
                label: 'Explore'),
            NavigationDestination(
                icon: Badge(
                    isLabelVisible: savedStore.items.isNotEmpty,
                    label: Text('${savedStore.items.length}'),
                    child: const Icon(Icons.bookmark_border)),
                selectedIcon: const Icon(Icons.bookmark),
                label: 'My Trip'),
            const NavigationDestination(
                icon: Icon(Icons.info_outline),
                selectedIcon: Icon(Icons.info),
                label: 'About'),
          ],
        ),
      ),
    );
  }
}
