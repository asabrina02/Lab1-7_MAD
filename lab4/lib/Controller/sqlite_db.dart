import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class SQLiteDB{
  static const String _dbName = "dbexpense";

  Database? _db;

  SQLiteDB._();
  static final SQLiteDB _instance = SQLiteDB._();//private constructor

  factory SQLiteDB(){
    return _instance;
  }

  Future<Database> get database async {
    if(_db != null){
      return _db!;
    }
    String path = join(await getDatabasesPath(), _dbName,);
    _db = await openDatabase(path, version: 1, onCreate: (createDb, version) async {
      for(String tableSql in SQLiteDB.tableSQLStrings){
        await createDb.execute(tableSql);

      }
    },);
    return _db!;
  }

  static List<String> tableSQLStrings =
  [
    '''
    CREATE TABLE IF NOT EXISTS expenses (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    amount DOUBLE,
    desc TEXT,
    dateTime DATETIME)
    ''',
  ];

  Future<int> insert(String tableName, Map<String, dynamic> row) async {
    Database db = await _instance.database;
    return await db.insert(tableName, row);
  }

  Future<List<Map<String, dynamic>>> queryAll(String tableName) async {
    Database db = await _instance.database;
    return await db.query(tableName);
  }


  Future<int> updateExpense(Map<String, dynamic> expense) async {
    Database db = await _instance.database;
    int id = expense['id'];
    return await db.update(
      'expenses',
      expense,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteExpense(int id) async {
    Database db = await _instance.database;
    return await db.delete(
      'expenses',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

}