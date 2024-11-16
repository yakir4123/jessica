import 'package:flutter/services.dart';
import 'package:jessica/pages/logs_page.dart';
import 'package:jessica/pages/orders_table_page.dart';

import 'custom_theme_extension.dart';
import 'package:flutter/material.dart';
import 'package:jessica/pages/orders_page.dart';
import 'package:jessica/pages/routes_page.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jessica/pages/general_params_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]).then((_) {
    runApp(const ProviderScope(child: MyApp()));
  });
}

const Color primaryColor = Color(0xff1F205B);
const Color accentColor = Color(0xFFEBA3C8);
const Color backgroundColor = Color(0xdd021526);
const Color textColor = Color(0xFFFDFDFE);
const Color secondaryColor = Color(0xFF3C3D78);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Jessica',
      theme: buildTheme(),
      onGenerateRoute: (settings) {
        final page = switch (settings.name) {
          '/home_screen' => const MyHomePage(),
          _ => const Center(child: Text('404 Page Not Found'))
        };
        return MaterialPageRoute<Widget>(
          builder: (context) => page,
          settings: settings,
        );
      },
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends ConsumerStatefulWidget {
  const MyHomePage({super.key});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends ConsumerState<MyHomePage> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          const GeneralParamsPage(),
          OrdersPage(navigateToRoutesPage: navigateToRoutesPage),
          const RoutesPage(),
          OrdersTablePage(navigateToRoutesPage: navigateToRoutesPage),
          const LogsTablePage(),
        ],
      ),
      bottomNavigationBar: Theme(
        data: ThemeData(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'General',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.business),
              label: 'Orders',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.add_road),
              label: 'Routes',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.table_chart),
              label: 'Orders Table',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.note_alt),
              label: 'Logs',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Theme.of(context).colorScheme.secondary,
          unselectedItemColor:
              Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          backgroundColor: Theme.of(context).colorScheme.surface,
          onTap: _onItemTapped,
        ),
      ),
    );
  }

  // Function to navigate to the Routes page and update providers
  void navigateToRoutesPage() {
    setState(() {
      _selectedIndex = 2;
    });
  }
}
