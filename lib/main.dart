import 'package:flutter/material.dart';
import 'dart:html';

void main() => runApp(TodoApp());

class TodoApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text('ToDoリスト'),
        ),
        body: TodoList(),
      ),
    );
  }
}

class TodoList extends StatefulWidget {
  @override
  _TodoListState createState() => _TodoListState();
}

class _TodoListState extends State<TodoList> {
  final GlobalKey<AnimatedListState> _listKey = GlobalKey();
  List<TodoTask> todoList = List();
  final myController = TextEditingController();
  WebStrage strage = WebStrage();

  @override
  void initState() {
    super.initState();
    if (strage.getTitleList().isEmpty) {
      return;
    }
    List<String> titleList = strage.getTitleList().split(',');
    titleList.forEach((f) => todoList.add(TodoTask.initialize(f)));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
          Card(
            child: ListTile(
              title: TextField(
                controller: myController,
              ),
              trailing: IconButton(
                onPressed: () {
                  _addItems(
                      myController.text != '' ? myController.text : 'no title');
                  _saveToLocalStrage();
                  myController.clear();
                },
                icon: Icon(Icons.add_circle),
              ),
            ),
          ),
          Expanded(
            child: AnimatedList(
              key: _listKey,
              initialItemCount: todoList.length,
              itemBuilder: (context, index, animation) {
                return _buildItem(todoList[index], animation, index);
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    myController.dispose();
    super.dispose();
  }

  Widget _buildItem(TodoTask todoTask, Animation animation, num index) {
    return SizeTransition(
      sizeFactor: animation,
      child: _createCard(todoTask, index),
    );
  }

  Widget _createCard(TodoTask todoTask, num index) {
    return Card(
      child: ListTile(
        leading: InkWell(
          splashColor: Colors.greenAccent,
          borderRadius: BorderRadius.circular(45.0),
          onTap: () {
            todoTask.checkIn();
            _removeItems(todoTask, index);
            _saveToLocalStrage();
          },
          child: todoTask.isDone
              ? Icon(
                  Icons.check_circle,
                  color: Colors.greenAccent,
                )
              : Icon(Icons.check_circle),
        ),
        title: Text(todoTask._title),
      ),
    );
  }

  void _saveToLocalStrage() {
    List<String> titleList = [];
    todoList.forEach((f) => titleList.add(f._title));
    strage.save(titleList);
  }

  void _addItems(String title) {
    todoList.insert(0, TodoTask.initialize(title));
    _listKey.currentState.insertItem(0);
  }

  void _removeItems(TodoTask todoTask, num index) {
    TodoTask removeItem = todoList.removeAt(index);
    AnimatedListRemovedItemBuilder builder = (context, animation) {
      return _buildItem(removeItem, animation, index);
    };
    _listKey.currentState.removeItem(index, builder);
  }
}

class TodoTask {
  String _title;
  bool _isDone;

  TodoTask.initialize(this._title) {
    _isDone = false;
  }

  String get title => _title;
  bool get isDone => _isDone;

  void checkIn() {
    _isDone = true;
  }
}

class WebStrage {
  final Storage _storage = window.localStorage;

  void save(List<String> titleList) {
    _storage['todo'] = titleList.join(',');
  }

  String getTitleList() => _storage['todo'];

  void invalidate() {
    _storage.remove('todo');
  }
}
