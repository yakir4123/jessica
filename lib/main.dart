import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'JSON List View',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: JsonListView(),
    );
  }
}

class JsonListView extends StatefulWidget {
  @override
  _JsonListViewState createState() => _JsonListViewState();
}

class _JsonListViewState extends State<JsonListView> {
  late WebSocketChannel channel;
  Map<String, dynamic> jsonData = {};

  @override
  void initState() {
    super.initState();
    channel = WebSocketChannel.connect(
      Uri.parse('ws://192.168.1.208:7000/ws'),
    );

    channel.stream.listen((message) {
      setState(() {
        jsonData = jsonDecode(message);
      });
    });
  }

  @override
  void dispose() {
    channel.sink.close(status.goingAway);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('JSON List View'),
      ),
      body: jsonData.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView(
        children: _buildList(jsonData, 0),
      ),
    );
  }

  List<Widget> _buildList(dynamic data, int indentLevel) {
    if (data is Map) {
      return data.keys.map<Widget>((key) {
        var value = data[key];
        if (value is Map || value is List) {
          return Padding(
            padding: EdgeInsets.only(left: indentLevel * 4.0),
            child: ExpansionTile(
              initiallyExpanded: (value is Map && value.length == 1) || (value is List && value.length == 1),
              title: Text(
                key,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              children: _buildList(value, indentLevel + 1),
            ),
          );
        } else {
          return Padding(
            padding: EdgeInsets.only(left: indentLevel * 4.0),
            child: ListTile(
              title: RichText(
                text: TextSpan(
                  text: '$key: ',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.black),
                  children: <TextSpan>[
                    TextSpan(
                      text: value.toString(),
                      style: TextStyle(fontWeight: FontWeight.normal),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
      }).toList();
    } else if (data is List) {
      return data.map<Widget>((item) {
        if (item is Map || item is List) {
          return Padding(
            padding: EdgeInsets.only(left: indentLevel * 4.0),
            child: ExpansionTile(
              initiallyExpanded: (item is Map && item.length == 1) || (item is List && item.length == 1),
              title: Text(
                item.toString(),
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              children: _buildList(item, indentLevel + 1),
            ),
          );
        } else {
          return Padding(
            padding: EdgeInsets.only(left: indentLevel * 4.0),
            child: ListTile(
              title: Text(item.toString()),
            ),
          );
        }
      }).toList();
    } else {
      return [Padding(
        padding: EdgeInsets.only(left: indentLevel * 4.0),
        child: ListTile(title: Text(data.toString())),
      )];
    }
  }
}
