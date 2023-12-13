import 'dart:convert'; //json encode/decode
import 'package:http/http.dart' as http;

enum RequestMethod { GET, POST, PUT, DELETE }

class RequestController {
  String path;
  String server;
  http.Response? _res;
  final Map<dynamic, dynamic> _body = {};
  final Map<String,String> _headers = {};
  dynamic _resultData;

  // New- RequestMethod parameter to the constructor
  RequestMethod method;

  RequestController({
    required this.path,
    this.server = "http://10.200.127.92",
    this.method = RequestMethod.GET,
  });
  setBody(Map<String, dynamic> data) {
    _body.clear();
    _body.addAll(data);
    _headers["Content-Type"] = "application/json; charset=UTF-8";
  }
  Future<void> post() async {
    _res = await http.post(
      Uri.parse(server + path),
      headers: _headers,
      body: jsonEncode(_body),
    );
    _parseResult();
  }
  Future<void> get() async {
    _res = await http.get(
      Uri.parse(server + path),
      headers: _headers,
    );
    _parseResult();
  }
  Future<void> put() async {
    _res = await http.put(
      Uri.parse(server + path),
      headers: _headers,
      body: jsonEncode(_body),
    );
    _parseResult();
  }
  Future<void> delete() async {
    _res = await http.delete(
      Uri.parse(server + path),
      headers: _headers,
      body: jsonEncode(_body),
    );
    _parseResult();
  }
/*
  // Function for updating expenses in the database
  Future<void> updateExpenseInDatabase(int id, String updatedDesc,
      double updatedAmount, String updatedDateTime) async {
    setBody({
      "id": id,
      "desc": updatedDesc,
      "amount": updatedAmount,
      "dateTime": updatedDateTime,
    });

    await put();
  }
*/
  Future<void> updateExpense(int id, String updatedDesc, double updatedAmount, String updatedDateTime) async {
    final Map<String, dynamic> updatedExpense = {
      "id": id,
      "desc": updatedDesc,
      "amount": updatedAmount,
      "dateTime": updatedDateTime,
    };

    // Construct the correct update endpoint based on the expense id
    path = "/api/updateExpense/$id"; // Replace with the actual update endpoint

    // Set the HTTP method to PUT for updating
    method = RequestMethod.PUT;

    await put();
  }

  Future<void> deleteExpense(int id) async {
    // Construct the correct delete endpoint based on the expense id
    path = "/api/deleteExpense/$id"; // Replace with the actual delete endpoint

    // Set the HTTP method to DELETE for deleting
    method = RequestMethod.DELETE;

    await delete();
  }

  void _parseResult(){
    // parse result into json structure if possible
    try{
      print("raw response:${_res?.body}" );
      _resultData = jsonDecode(_res?.body?? "");
    }catch(ex){
      // otherwise the response body will be stored as is
      _resultData = _res?.body;
      print("exception in http result parsing ${ex}");
    }
  }
  dynamic result() {
    return _resultData;
  }
  int status(){
    return _res?.statusCode??0;
  }


}