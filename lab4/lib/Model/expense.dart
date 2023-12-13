import 'package:lab4/Controller/request_controller.dart';
import 'package:lab4/Controller/sqlite_db.dart';

class Expense {
  static const String SQLiteTable = "expenses";
  int? id;
  String desc;
  double amount;
  String dateTime;
  Expense(this.amount, this.desc, this.dateTime);

  Expense.fromJson(Map<String, dynamic> json)
      : desc = json['Desc'] as String,
        amount = double.parse (json['Amount'] as dynamic),
        dateTime = json['dateTime'] as String,
        id = json['id'] as int?;


  // toJson will be automatically called by jsonEncode when necessary
  Map<String, dynamic> toJson() =>
      {'amount': amount, 'desc': desc, 'dateTime': dateTime};

  Future<bool> save() async {
    // Save to local SQlite
    await SQLiteDB().insert(SQLiteTable, toJson());
    // API Operation
    RequestController req = RequestController(path: "/api/expenses.php");
    req. setBody(toJson ());
    await req.post();
    if (req.status() == 200) {
      return true;
    }
    else
      {
        if (await SQLiteDB().insert(SQLiteTable, toJson()) !=0){
          return true;
        } else {
          return false;
        }
      }
    }
    static Future<List<Expense>> loadAll() async {
      // API Operation
      List<Expense> result = [];
      RequestController req = RequestController(path: "/api/expenses.php");
      await req.get();
      if (req.status() == 200 && req.result () != null) {
        for(var item in req.result()) {
          result.add(Expense. fromJson (item));
        }
      }
      else
        {
          List<Map<String, dynamic>> result =  await SQLiteDB().queryAll(SQLiteTable);
          List<Expense> expenses = [];
          for (var item in result){
            result.add(Expense.fromJson(item) as Map<String, dynamic>);
          }
        }
      return result;
    }

  Future<void> update() async {
    // Update in local SQLite
    await SQLiteDB().updateExpense(toJson());

    // Update on the remote API
    await RequestController(path: "/api/expenses.php", method: RequestMethod.PUT)
        .setBody(toJson())
        .put();
  }

  Future<void> delete() async {
    // Delete from local SQLite
    await SQLiteDB().deleteExpense(id!);

    // Delete on the remote API
    await RequestController(path: "/api/expenses.php", method: RequestMethod.DELETE)
        .setBody({"id": id})
        .delete();
  }
/*
    static Future<void> updateExpenseInDatabase(int id, String desc, double amount, String dateTime) async {
      RequestController updateReq = RequestController(path: "/api/expenses.php",
        method: RequestMethod.PUT,
      );

      Map<String, dynamic> updateData = {
        "id": id,
        "desc": desc,
        "amount": amount,
        "dateTime": dateTime,
      };

      updateReq.setBody(updateData);

      await updateReq.put();

      if (updateReq.status() == 200) {
        // Handle success
        print("Update successful!");
      } else {
        // Handle failure
        print("Update failed with status code: ${updateReq.status()}");
      }
    }

  // Add a method to delete an expense from SQLite
  Future<void> delete() async {
    await SQLiteDB().delete(SQLiteTable, 'id', id);
  }*/

}