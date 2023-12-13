import 'package:flutter/material.dart';
import 'package:lab4/Controller/request_controller.dart';
import 'package:lab4/Model/expense.dart';

void main(){
  runApp(DailyExpensesApp(username: 'YourUsername'));
}

class DailyExpensesApp extends StatelessWidget {
  final String username;

  DailyExpensesApp({required this.username});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ExpenseList(username: username),
    );
  }
}

class ExpenseList extends StatefulWidget {
  final String username;

  ExpenseList({required this.username});

  @override
  _ExpenseListState createState() => _ExpenseListState();
}

class _ExpenseListState extends State<ExpenseList> {
  final List<Expense> expenses = [];
  final TextEditingController descController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController totalAmountController = TextEditingController();
  final TextEditingController txtDateController = TextEditingController();
  double totalAmount = 0;

  void _addExpense() async {
    String desc = descController.text.trim();
    String amount = amountController.text.trim();

    if (amount.isNotEmpty && desc.isNotEmpty){
      Expense exp =
      Expense(double.parse(amount), desc, txtDateController.text);
      if (await exp.save()) {
        setState(() {
          expenses.add(exp);
          descController.clear();
          amountController.clear();
          calculateTotal();
        });
      } else {
        _showMessage("Failed to save Expenses data");
      }
    }
  }

  void calculateTotal() {
    totalAmount = 0;
    for (Expense ex in expenses) {
      totalAmount += ex.amount;
    }
    totalAmountController.text = totalAmount.toString();
  }

  /*void _removeExpense(int index) async {
    //Delete from local SQLite storage
    await expenses[index].delete();

    // Perform delete in the remote MySQL database
    await RequestController(path: '/api/deleteExpense/${expenses[index].id}').delete();

    setState(() {
      totalAmount -= expenses[index].amount;
      expenses.removeAt(index);
      totalAmountController.text = totalAmount.toString();
    });

    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('Expense deleted')));
  }*/
  // function to display message at bottom of Scaffold
  void _showMessage(String msg) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg),
        ),
      );
    }
  }

  /*void _editExpense(int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditExpenseScreen(
          expense: expenses[index],
          onSave: (editedExpense) async {

            //Update local SQLite storage
            await editedExpense.save();

            // Perform update to the remote MySQL database
            await RequestController(path: '/api/updateExpense').updateExpenseInDatabase(
              expenses[index].id!,
              descController.text,
              amountController.text as double,
              txtDateController.text,
            );

            setState(() {
              totalAmount += editedExpense.amount - expenses[index].amount;
              expenses[index] = editedExpense;
              totalAmountController.text = totalAmount.toString();
            });

            Navigator.pop(context);
          },
        ),
      ),
    );
  }*/

  void _removeExpense(int index) async {
    // Get the expense to be deleted
    Expense expenseToDelete = expenses[index];

    // Delete from local SQLite storage
    await expenseToDelete.delete();

    // Perform delete in the remote MySQL database
    await RequestController(path: '/api/deleteExpense/${expenseToDelete.id}').delete();

    setState(() {
      totalAmount -= expenseToDelete.amount;
      expenses.removeAt(index);
      totalAmountController.text = totalAmount.toString();
    });

    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('Expense deleted')));
  }

  void _editExpense(int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditExpenseScreen(
          expense: expenses[index],
          onSave: (editedExpense) async {
            // Calculate the difference in amounts
            double amountDifference = editedExpense.amount - expenses[index].amount;

            // Update local SQLite storage
            await editedExpense.save();

            // Perform update to the remote MySQL database
            await RequestController(path: '/api/updateExpense').updateExpense(
              expenses[index].id!,
              editedExpense.desc,
              editedExpense.amount,
              editedExpense.dateTime,
            );

            setState(() {
              totalAmount += amountDifference;
              expenses[index] = editedExpense;
              totalAmountController.text = totalAmount.toString();
            });

            Navigator.pop(context);
          },
        ),
      ),
    );
  }


  // assignment - function for date and time picker
  _selectDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedDate != null && pickedTime != null) {
      setState(() {
        txtDateController.text =
        "${pickedDate.year}-${pickedDate.month}-${pickedDate.day} "
            "${pickedTime.hour}:${pickedTime.minute}:00";
      });
    }
  }

  // new
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      _showMessage("Welcome ${widget.username}");

      RequestController req = RequestController(
          path: "api/timezone/Asia/Kuala_Lumpur",
          server: "http://worldtimeapi.org");
      req.get().then((value) {
        dynamic res = req.result();
        txtDateController.text =
            res["dateTime"].toString().substring(0,19).replaceAll('T', ' ');
      });
      expenses.addAll(await Expense.loadAll());

      setState(() {
        calculateTotal();
      });
    });
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: Text('Daily Expenses'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Welcome, ${widget.username}!',
              style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: descController,
              decoration: InputDecoration(
                labelText: 'Description',
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: amountController,
              decoration: InputDecoration(
                labelText: 'Amount (RM)',
              ),
            ),
          ),
          // new textfield
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              keyboardType: TextInputType.datetime,
              controller: txtDateController,
              readOnly: true,
              onTap: _selectDate,
              decoration: InputDecoration(
                labelText: 'Date',
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: totalAmountController,
              readOnly: true,
              decoration: InputDecoration(
                labelText: 'Total Spend (RM)',
              ),
            ),
          ),
          Center(
            child: ElevatedButton(
              onPressed: _addExpense,
              child: Text('Add Expense'),
            ),
          ),
          Container(
            child: _buildListView(),
          ),
        ],
      ),
    );
  }

  Widget _buildListView(){
    return Expanded(
      child: ListView.builder(
        itemCount: expenses.length,
        itemBuilder: (context, index){
          return Dismissible(
            key: Key(expenses[index].amount.toStringAsFixed(2)),
            background: Container(
              color: Colors.red,
              child: Center(
                child: Text(
                  'Delete',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
            onDismissed: (direction){
              _removeExpense(index);
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text('Item dismissed')));
            },
            child: Card(
              margin: EdgeInsets.all(8.0),
              child: ListTile(
                  title: Text(expenses[index].desc),
                  subtitle: Row(
                    children: [
                      Text('Amount: ${expenses[index].amount}'),
                      const Spacer(),
                      Text('Date: ${expenses[index].dateTime}')
                    ],
                  ),
                  trailing: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () => _removeExpense(index),
                  ),
                  onLongPress: () {
                    _editExpense(index);
                  }
              ),
            ),
          );
        },
      ),
    );
  }
}

class EditExpenseScreen extends StatefulWidget {
  final Expense expense;
  final Function(Expense) onSave;

  EditExpenseScreen({required this.expense, required this.onSave});

  @override
  _EditExpenseScreenState createState() => _EditExpenseScreenState();
}

class _EditExpenseScreenState extends State<EditExpenseScreen> {
  // Assignment - allow editing date and time
  late TextEditingController descController;
  late TextEditingController amountController;
  late TextEditingController txtDateController;

  //final TextEditingController descController = TextEditingController();
  //final TextEditingController amountController = TextEditingController();

  // assignment
  @override
  void initState() {
    super.initState();
    descController = TextEditingController(text: widget.expense.desc);
    amountController = TextEditingController(text: widget.expense.amount.toStringAsFixed(2));
    txtDateController = TextEditingController(text: widget.expense.dateTime);
  }

  @override
  Widget build(BuildContext context) {
    //descController.text = expense.desc;
    //amountController.text = expense.amount.toStringAsFixed(2);

    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Expense'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: descController,
              decoration: InputDecoration(
                labelText: 'Description',
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: amountController,
              decoration: InputDecoration(
                labelText: 'Amount (RM)',
              ),
            ),
          ),
          // assignment
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: txtDateController,
              readOnly: true,
              onTap: _selectDate,     // Enable date and time picker
              decoration: InputDecoration(
                labelText: 'Date',
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              // edited
              await _selectDate();
              widget.onSave(
                  Expense(
                      double.parse(amountController.text),
                      descController.text,
                      txtDateController.text
                  )
              );


              Navigator.pop(context);
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
  }

  // assignment - function for date and time picker
  _selectDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedDate != null && pickedTime != null) {
      setState(() {
        txtDateController.text =
        "${pickedDate.year}-${pickedDate.month}-${pickedDate.day} "
            "${pickedTime.hour}:${pickedTime.minute}:00";
      });
    }
  }

}
