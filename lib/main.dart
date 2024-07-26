import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jessica/pages/general_params_page.dart';
import 'package:jessica/pages/orders_page.dart';
import 'package:jessica/pages/unique_params_page.dart';
import 'package:jessica/services/providers.dart';
import 'custom_theme_extension.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  runApp(const ProviderScope(child: MyApp()));
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
    final dataService = ref.read(dataServiceProvider.notifier);
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: Icon(
              Icons.list,
              color: Theme.of(context).colorScheme.secondary,
            ),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text('Select Route'),
                    content: SizedBox(
                      width: double.maxFinite,
                      child: ListView(
                        children: dataService.decodedMessage.keys.map((key) {
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 8.0),
                            child: ListTile(
                              title: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: key.split(':').map(
                                  (part) {
                                    return Text(
                                      part,
                                      style: const TextStyle(
                                        fontSize: 14,
                                      ),
                                    );
                                  },
                                ).toList(),
                              ),
                              onTap: () {
                                dataService.selectKey(key);
                                Navigator.of(context).pop();
                              },
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ],
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: dataService.selectedKey.split(':').map(
            (part) {
              return Text(
                part,
                style: const TextStyle(
                  fontSize: 14,
                  overflow: TextOverflow.ellipsis,
                ),
              );
            },
          ).toList(),
        ),
        toolbarHeight: 100,
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          GeneralParamsPage(),
          const OrdersPage(),
          const UniqueParamsPage(),
        ],
      ),
      bottomNavigationBar: Theme(
        data: ThemeData(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: BottomNavigationBar(
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
              icon: Icon(Icons.school),
              label: 'Unique',
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
}
