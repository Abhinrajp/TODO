import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Addtodo extends StatefulWidget {
  final Map? todo;
  const Addtodo({super.key, this.todo});

  @override
  State<Addtodo> createState() => _AddtodoState();
}

class _AddtodoState extends State<Addtodo> {
  TextEditingController titlecontroller = TextEditingController();
  TextEditingController contentcontroller = TextEditingController();
  bool isedit = false;
  @override
  void initState() {
    final todo = widget.todo;
    super.initState();
    if (todo != null) {
      isedit = true;
      final title = todo["title"];
      final content = todo["description"];
      titlecontroller.text = title;
      contentcontroller.text = content;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 249, 253, 255),
      appBar: AppBar(
        title: isedit
            ? const Text(
                'edit todo',
                style:
                    TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
              )
            : const Text(
                'Add todo',
                style:
                    TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
              ),
        backgroundColor: Colors.blueGrey,
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Form(
              child: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(
                  hintText: 'title',
                ),
                controller: titlecontroller,
              ),
              const SizedBox(
                height: 20,
              ),
              TextFormField(
                decoration: const InputDecoration(
                  hintText: 'Content',
                ),
                controller: contentcontroller,
                minLines: 5,
                maxLines: 8,
              ),
            ],
          )),
          const SizedBox(
            height: 20,
          ),
          ElevatedButton(
              onPressed: () {
                submitdata();
              },
              style: ButtonStyle(
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(0.0),
                    ),
                  ),
                  elevation: MaterialStateProperty.all(5),
                  foregroundColor: MaterialStateProperty.all(Colors.black),
                  backgroundColor: MaterialStateProperty.all(Colors.blueGrey)),
              child: isedit ? const Text('Edit') : const Text('submit'))
        ],
      ),
    );
  }

  void submitdata() async {
    final title = titlecontroller.text;
    final content = contentcontroller.text;
    final body = {
      "title": title,
      "description": content,
      "is_completed": false
    };

    // submit the data into server

    final url = 'https://api.nstack.in/v1/todos';
    final uri = Uri.parse(url);
    final responce = await http.post(
      uri,
      body: jsonEncode(body),
      headers: {'Content-Type': 'application/json'},
    );
    if (responce.statusCode == 201) {
      titlecontroller.text = '';
      respomessage('Creation success');
      Navigator.of(context).pop();
    } else {
      respomessage('Creation failed');
    }
  }

  void editdata() async {
    final todo = widget.todo;
    final title = titlecontroller.text;
    final content = contentcontroller.text;
    if (todo == null) {}
    final id = todo!['_id'];
    final body = {
      "title": title,
      "description": content,
      "is_completed": false
    };

    // edited the data into server

    final url = 'https://api.nstack.in/v1/todos/$id';
    final uri = Uri.parse(url);
    final responce = await http.put(
      uri,
      body: jsonEncode(body),
      headers: {'Content-Type': 'application/json'},
    );
    if (responce.statusCode == 200) {
      respomessage('Edited successfuly');
      Navigator.of(context).pop();
    } else {
      respomessage('Editing failed');
    }
  }

  void respomessage(String message) {
    if (message == 'Creation success') {
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
