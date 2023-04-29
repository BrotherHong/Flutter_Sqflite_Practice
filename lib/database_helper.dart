import 'package:sqflite/sqflite.dart';
import 'package:flutter/foundation.dart';

class SQLHelper {
  // create table
  static Future<void> createTable(Database database) async {
    await database.execute("""
      CREATE TABLE items (
        id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        title TEXT,
        description TEXT,
        createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
      )
    """);
  }

  // create and open database
  static Future<Database> db() async {
    return openDatabase(
      'dbtest.db',
      version: 1,
      onCreate: (Database db, int version) async {
        print("Creating a table");
        await createTable(db);
      },
    );
  }

  // CRUD

  // C: create item
  static Future<int> createItem(String title, String? description) async {
    final Database db = await SQLHelper.db();

    final data = {'title': title, 'description': description};

    final id = await db.insert(
      'items',
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    return id;
  }

  // R : read items
  static Future<List<Map<String, dynamic>>> getItems() async {
    final Database db = await SQLHelper.db();

    return await db.query('items', orderBy: 'id');
  }

  // U: update item
  static Future<int> updateItme(int id, String title, String? description) async {
    final Database db = await SQLHelper.db();

    final data = {
      'title': title,
      'description': description,
      'createdAt': DateTime.now().toString(),
    };

    final result = await db.update('items', data, where: 'id = ?', whereArgs: [id]);

    return result;
  }

  // D: delete item
  static Future<void> deleteItem(int id) async {
    final Database db = await SQLHelper.db();

    try {
      await db.delete('items', where: 'id = ?', whereArgs: [id]);
    } catch (err) {
      debugPrint("Something get wrong while deleting item: $err");
    }
  }
}
