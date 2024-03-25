import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Table Calendar Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Roboto', // Use custom font if needed
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  String? _diaryEntry;

  @override
  void initState() {
    super.initState();
    _loadDiaryEntry(_focusedDay);
  }

  void _loadDiaryEntry(DateTime date) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _diaryEntry = prefs.getString(_getStorageKey(date));
    });
  }

  void _saveDiaryEntry(DateTime date, String entry) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_getStorageKey(date), entry);
  }

  String _getStorageKey(DateTime date) {
    return 'diary_${date.year}-${date.month}-${date.day}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Table Calendar Example'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TableCalendar(
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              calendarFormat: _calendarFormat,
              onFormatChanged: (format) {
                setState(() {
                  _calendarFormat = format;
                });
              },
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                  _loadDiaryEntry(selectedDay);
                });
              },
              selectedDayPredicate: (day) {
                return _selectedDay != null
                    ? isSameDay(_selectedDay!, day)
                    : false;
              },
            ),
            SizedBox(height: 20),
            if (_selectedDay != null) ...[
              Text(
                'Selected Day: ${_selectedDay!.toString()}',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                'Diary Entry:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.blueGrey),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: _diaryEntry != null
                    ? Text(
                        _diaryEntry!,
                        style: TextStyle(fontSize: 16),
                      )
                    : Text('No entry for this date.'),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  _editDiaryEntry(context);
                },
                child: Text('Edit Entry'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  bool isSameDay(DateTime dayA, DateTime dayB) {
    return dayA.year == dayB.year &&
        dayA.month == dayB.month &&
        dayA.day == dayB.day;
  }

  Future<void> _editDiaryEntry(BuildContext context) async {
    String? newEntry = await showDialog(
      context: context,
      builder: (BuildContext context) {
        TextEditingController _textEditingController = TextEditingController();
        return AlertDialog(
          title: Text('Edit Diary Entry'),
          content: TextField(
            controller: _textEditingController,
            maxLines: null,
            keyboardType: TextInputType.multiline,
            decoration: InputDecoration(
              hintText: 'Write your entry here...',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(_textEditingController.text);
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
    if (newEntry != null) {
      _saveDiaryEntry(_selectedDay!, newEntry);
      setState(() {
        _diaryEntry = newEntry;
      });
    }
  }
}
