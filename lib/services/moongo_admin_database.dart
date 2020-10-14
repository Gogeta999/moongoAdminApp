import 'package:MoonGoAdmin/ui/utils/constants.dart';
import 'package:sqflite/sqflite.dart';

class MoonGoAdminDB {
  static final MoonGoAdminDB _instance = MoonGoAdminDB._();
  factory MoonGoAdminDB() => _instance;

  MoonGoAdminDB._();

  Database _db;

  final Future<Database> _database = openDatabase(
    kDataBaseName,
    onCreate: (db, version) {
      return db.execute(
        "CREATE TABLE $kSuggestionTableName(id INTEGER PRIMARY KEY, name TEXT)",
      );
    },
    version: 1,
  );

  init() async {
    _db = await _database;
  }

  insertSuggestions(List<String> suggestions, List<int> idList) async {
    for (int i = 0; i < suggestions.length; ++i) {
      _db.insert(
          kSuggestionTableName,
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
        'SELECT "name" FROM "$kSuggestionTableName" WHERE "name" LIKE "%$like%"'
    );
    return List.generate(suggestions.length, (index) {
      return suggestions[index]['name'] as String;
    });
  }

  dispose() async {
    await _db.close();
  }
}