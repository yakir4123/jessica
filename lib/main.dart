import 'package:flutter/material.dart';
import 'package:jessica/pages/general_params_page.dart';
import 'package:jessica/pages/orders_page.dart';
import 'package:jessica/pages/unique_params_page.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'mock_data.dart'; // Import the mock data

Future<void> main() async {
  await dotenv.load(fileName: ".env");
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xff1F205B);
    const Color accentColor = Color(0xFFEBA3C8);
    const Color backgroundColor = Color(0xdd021526);
    const Color textColor = Color(0xFFFDFDFE);
    const Color secondaryColor = Color(0xFF3C3D78);
    return MaterialApp(
      title: 'Jessica',
      theme: ThemeData(
        primaryColor: primaryColor,
        scaffoldBackgroundColor: backgroundColor,
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: textColor),
          bodyMedium: TextStyle(color: textColor),
          bodySmall: TextStyle(color: textColor),
          headlineLarge: TextStyle(color: textColor),
          headlineMedium: TextStyle(color: textColor),
          headlineSmall: TextStyle(color: textColor),
        ),
        dialogBackgroundColor: backgroundColor,
        cardTheme: const CardTheme(
          color: secondaryColor,
        ),
        buttonTheme: const ButtonThemeData(
          buttonColor: accentColor,
          textTheme: ButtonTextTheme.primary,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: primaryColor,
          titleTextStyle: TextStyle(color: textColor, fontSize: 20),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: accentColor,
        ),
        cardColor: secondaryColor,
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: primaryColor,
          primaryContainer: backgroundColor,
          secondary: accentColor,
          secondaryContainer: secondaryColor,
          surface: backgroundColor,
          onPrimary: backgroundColor,
          onSecondary: textColor,
          onSurface: textColor,
        ),
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  WebSocketChannel? channel;
  int _selectedIndex = 0;
  Map<String, dynamic> _data = {};
  Map<String, dynamic> decodedMessage = {};
  String selectedKey = "LiveStrategy:Binance Perpetual Futures:SOL-USDT:15m";

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    try {
      channel = WebSocketChannel.connect(
        Uri.parse(
            "ws://${dotenv.env["JESSE_SERVER_IP"]}:${dotenv.env["JESSE_SERVER_PORT"]}/ws"),
      );

      channel?.stream.listen((message) {
        final decodedMessage = json.decode(message);
        setState(() {
          this.decodedMessage = decodedMessage;
          _data = decodedMessage[selectedKey];
        });
      });
    } catch (e) {
      // Use mock data if the server is not available
      setState(() {
        decodedMessage = mockData;
        _data = mockData[selectedKey];
      });
    }
  }

  void _selectKey(String key) {
    setState(() {
      selectedKey = key;
      _data = decodedMessage[key];
    });
  }

  @override
  void dispose() {
    channel?.sink.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: selectedKey.split(':').map((part) {
                    return Text(
                      part,
                      style: const TextStyle(
                        fontSize: 14, // Adjust font size as needed
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.list),
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  builder: (context) {
                    return Container(
                      color: Color(0xdd021526),
                      padding: const EdgeInsets.all(16.0),
                      child: ListView(
                        children: decodedMessage.keys.map((key) {
                          return Card(
                            color: Theme.of(context)
                                .colorScheme
                                .secondaryContainer,
                            margin: const EdgeInsets.symmetric(vertical: 8.0),
                            child: ListTile(
                              title: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: key.split(':').map((part) {
                                  return Text(
                                    part,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSecondaryContainer,
                                        ),
                                  );
                                }).toList(),
                              ),
                              onTap: () {
                                _selectKey(key);
                                Navigator.of(context).pop();
                              },
                            ),
                          );
                        }).toList(),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
        toolbarHeight: 100, // Adjust height as needed
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          GeneralParamsPage(data: _data),
          OrdersPage(data: _data),
          UniqueParamsPage(data: _data),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
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
    );
  }
}
