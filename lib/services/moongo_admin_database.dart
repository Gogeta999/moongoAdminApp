import 'package:MoonGoAdmin/ui/utils/constants.dart';
import 'package:sqflite/sqflite.dart';

class MoonGoAdminDB {
  static final MoonGoAdminDB _instance = MoonGoAdminDB._();
  factory MoonGoAdminDB() => _instance;

  MoonGoAdminDB._();

  final String _tableName = kSuggestionDevTableName; ///Switch to kSuggestionTableName for release
  Database _db;

  init() async {
    _db = await openDatabase(
      kDataBaseName,
      onCreate: (db, version) {
        return db.execute(
          "CREATE TABLE $_tableName(id INTEGER PRIMARY KEY, name TEXT)",
        );
      },
      version: 1,
    );
    print(_db.isOpen);
  }

  insertSuggestions(List<String> suggestions, List<int> idList) async {
    for (int i = 0; i < suggestions.length; ++i) {
      _db.insert(
          _tableName,
          {
            'id': idList[i],
            'name': suggestions[i]
          },
          conflictAlgorithm: ConflictAlgorithm.replace
      );
    }
  }

  ///Local
  Future<List<String>> retrieveSuggestions(String like) async {
    final List<Map<String, dynamic>> suggestions = await _db.rawQuery(
        'SELECT "name" FROM "$_tableName" WHERE "name" LIKE "%$like%"'
    );
    return List.generate(suggestions.length, (index) {
      return suggestions[index]['name'] as String;
    });
  }

  deleteSuggestion(String query) async {
    await _db.delete(_tableName, where: 'name = ?', whereArgs: [query]);
  }

  dispose() async {
    await _db.close();
  }
}