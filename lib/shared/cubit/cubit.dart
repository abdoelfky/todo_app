import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sqflite/sqflite.dart';
import 'package:todo_app/modules/archived_tasks/archived_taskes_screen.dart';
import 'package:todo_app/modules/done_tasks/done_taskes_screen.dart';
import 'package:todo_app/modules/new_tasks/new_tasks_screen.dart';
import 'package:todo_app/shared/cubit/states.dart';

class AppCubit extends Cubit<AppStates>{
  AppCubit() : super(InitialStates());
  static AppCubit get(context)=>BlocProvider.of(context);

  int currentIndex=0;
  Database database;

  List <Map> newTasks=[];
  List <Map> doneTasks=[];
  List <Map> archivedTasks=[];

  List <Widget> screens=[
    NewTasksScreen(),
    ArchivedTasksScreen(),
    DoneTasksScreen(),
  ];


  List <String> screensText=
  [
    'New Tasks',
    'Archived Tasks',
    'Done Tasks',
  ];

  void changeIndex(int index){
    currentIndex=index;
    emit(ChangeBottomNavState());

  }



  void createDatabase(){
     openDatabase(
        'todo.db',
        version: 1,
        onCreate: (database,version)
        {
          print('database created');
          database.execute(
              'CREATE TABLE TASKS(ID INTEGER PRIMARY KEY,TITLE TEXT,DATE TEXT,TIME TEXT,STATUS TEXT)').then((value){
            print('table created');
          });
        },
        onOpen: (database)
        {
          getFromDatabase(database);
          print('database opened');
        }
    ).then((value){
      database=value;
      emit(CreateDatabaseState());
     });
  }


  Future insertToDatabase ({
    @required String title,
    @required String date,
    @required String time,

  })async
  {
     await database.transaction((txn)async{
       txn
           .rawInsert(
          'INSERT INTO TASKS(TITLE, DATE,TIME,STATUS) VALUES("$title","$date","$time","NEW")',
      ).then((value)
      {print('inserted: $value');
      emit(InsertToDatabaseState());
      getFromDatabase(database);
      }).catchError((error){
        print('not inserted because $error');
      });

    });

  }

  void getFromDatabase(database){

    emit(AppGetDatabaseLoadingState());

     database.rawQuery('SELECT * FROM TASKS').then((value){
       newTasks=[];
       doneTasks=[];
       archivedTasks=[];

      value.forEach((element) {
          if(element['STATUS']=='NEW'){
          newTasks.add(element);
          }
          else if (element['STATUS']=='DONE'){
            doneTasks.add(element);
          }
          else archivedTasks.add(element);
      });

      emit(GetFromDatabaseState());
    });

  }

  void updateData({
    @required String status,
    @required int id,

  })async{

    database.rawUpdate(
        'UPDATE TASKS SET STATUS = ? WHERE ID = ?',
        ['$status',id]
    ).then((value)
    {
      getFromDatabase(database);
      emit(UpdateDatabaseState());

    });

  }
  void deleteData({
    @required int id,

  })async{

    database.rawUpdate(
        'DELETE FROM TASKS WHERE ID = ?',
        [id]
    ).then((value)
    {
      getFromDatabase(database);
      emit(DeleteFromDatabaseState());

    });

  }





  IconData floatingActionButtonIcon=Icons.edit;
  bool isBottomSheetShown=false;

  void changeBottomSheetState({
  @required IconData icon,
  @required bool isShow}){
    isBottomSheetShown=isShow;
    floatingActionButtonIcon= icon;
    emit(ChangeBottomSheetState());
  }


}