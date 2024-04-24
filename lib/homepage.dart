import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:todo/addpage.dart';
import 'package:http/http.dart' as http;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isbool = true;
  List<dynamic> item = [];
  @override
  void initState() {
    super.initState();
    fecthalldata();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: const Color.fromARGB(255, 136, 95, 41),
      appBar: AppBar(
        title: const Text(
          'Todo list',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.blueGrey,
      ),
      body: Visibility(
        visible: isbool,
        replacement: RefreshIndicator(
          onRefresh: fecthalldata,
          child: Visibility(
            visible: item.isNotEmpty,
            replacement: const Center(
              child: Text(
                'No Todo item',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            child: ListView.builder(
              padding: const EdgeInsets.all(6),
              itemCount: item.length,
              itemBuilder: (context, index) {
                final items = item[index] as Map;
                final id = items["_id"] as String;
                return Card(
                  color: Colors.blueGrey,
                  elevation: 5,
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.white70,
                      child: Text('${index + 1}'),
                    ),
                    trailing: PopupMenuButton(
                      onSelected: (value) {
                        if (value == 'edit') {
                          pushtoedit(items);
                        } else if (value == 'delete') {
                          dlt(id);
                        }
                      },
                      itemBuilder: (context) {
                        return [
                          const PopupMenuItem(
                            value: 'edit',
                            child: Text('Edit'),
                          ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Text('Delete'),
                          ),
                        ];
                      },
                    ),
                    title: Text(
                      items['title'],
                      style: const TextStyle(
                          color: Colors.black, fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      items["description"],
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      ),
      floatingActionButton: ElevatedButton(
          style: ButtonStyle(
              elevation: MaterialStateProperty.all(5),
              foregroundColor: MaterialStateProperty.all(Colors.black),
              backgroundColor:
                  MaterialStateProperty.all(Colors.blueGrey.shade400)),
          onPressed: () {
            pushtoadd();
          },
          child: const Text('Add')),
    );
  }

  Future<void> pushtoadd() async {
    final route = MaterialPageRoute(
      builder: (context) => const Addtodo(),
    );
    await Navigator.push(context, route);
    setState(() {
      isbool = true;
    });
    fecthalldata();
  }

  Future<void> pushtoedit(Map item) async {
    final route = MaterialPageRoute(
      builder: (context) => Addtodo(todo: item),
    );
    await Navigator.push(context, route);
    setState(() {
      isbool = true;
    });
    fecthalldata();
  }

  Future<void> fecthalldata() async {
    final url = 'https://api.nstack.in/v1/todos?page=1&limit=10';
    final uri = Uri.parse(url);
    final responce = await http.get(uri);
    if (responce.statusCode == 200) {
      final json = jsonDecode(responce.body) as Map;

      final result = json['items'] as List;
      setState(() {
        item = result;
      });
    }
    setState(() {
      isbool = false;
    });
  }

  Future<void> dlt(String id) async {
    final url = 'https://api.nstack.in/v1/todos/$id';
    final uri = Uri.parse(url);
    final responce = await http.delete(uri);
    dltmessage('Delection success');
    if (responce.statusCode == 200) {
      final filter = item.where((element) => element["_id"] != id).toList();
      setState(() {
        item = filter;
      });
    } else {
      dltmessage('Delection failed');
    }
  }

  void dltmessage(String message) {
    if (message == 'Delection success') {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ));
    }
  }
}
