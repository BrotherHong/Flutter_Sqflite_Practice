import 'package:flutter/material.dart';
import 'package:sqflite_practice/database_helper.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'sqflite practice',
      theme: ThemeData(primaryColor: Colors.blue),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Map<String, dynamic>> _itemList = [];
  bool _isLoading = true;

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  void _refreshItems() async {
    final data = await SQLHelper.getItems();

    setState(() {
      _itemList = data;
      _isLoading = false;
    });

    print("Number of items: ${_itemList.length}");
  }

  @override
  void initState() {
    super.initState();
    _refreshItems();
  }

  Future<void> _addItem(String title, String description) async {
    await SQLHelper.createItem(title, description);
    _refreshItems();
  }

  Future<void> _updateItem(int id, String title, String description) async {
    await SQLHelper.updateItme(id, title, description);
    _refreshItems();
  }

  Future<void> _deleteItem(int id) async {
    await SQLHelper.deleteItem(id);
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Successfully delete an item!')));
    _refreshItems();
  }

  void showEditField(int? id) {
    if (id != null) {
      final item = _itemList.firstWhere((element) => element['id'] == id);
      _titleController.text = item['title'];
      _descriptionController.text = item['description'];
    }

    showModalBottomSheet(
      context: context,
      elevation: 5,
      builder: (context) => Container(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _titleController,
                decoration: const InputDecoration(hintText: "Title"),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(hintText: "Description"),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            ElevatedButton(
              onPressed: () async {
                String title = _titleController.text;
                String description = _descriptionController.text;

                if (id == null) {
                  await _addItem(title, description);
                } else {
                  await _updateItem(id, title, description);
                }

                // clear text field
                _titleController.text = '';
                _descriptionController.text = '';

                Navigator.of(context).pop();
              },
              child: Text(id == null ? 'Create' : 'Update'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Database Practice'),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => showEditField(null),
      ),
      body: (_itemList.isEmpty)
          ? Container()
          : Container(
              child: ListView.builder(
                itemCount: _itemList.length,
                itemBuilder: (context, index) {
                  final int id = _itemList[index]['id'];
                  final String title = _itemList[index]['title'];
                  final String description = _itemList[index]['description'];

                  return ListTile(
                    title: Text(title),
                    subtitle: Text(description),
                    trailing: SizedBox(
                      width: 100,
                      child: Row(
                        children: [
                          // Edit Button
                          IconButton(
                            onPressed: () => showEditField(id),
                            icon: const Icon(Icons.edit),
                          ),

                          // Delete Button
                          IconButton(
                            onPressed: () => _deleteItem(id),
                            icon: const Icon(Icons.delete),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
