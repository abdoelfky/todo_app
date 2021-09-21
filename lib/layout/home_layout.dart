import 'package:conditional_builder/conditional_builder.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';
import 'package:todo_app/modules/new_tasks/new_tasks_screen.dart';
import 'package:todo_app/modules/done_tasks/done_taskes_screen.dart';
import 'package:todo_app/modules/archived_tasks/archived_taskes_screen.dart';
import 'package:todo_app/shared/components/components.dart';
import 'package:todo_app/shared/components/constants.dart';
import 'package:todo_app/shared/cubit/cubit.dart';
import 'package:todo_app/shared/cubit/states.dart';

class HomeLayout extends StatelessWidget {

  var titleController=TextEditingController();
  var timeController=TextEditingController();
  var dateController=TextEditingController();
  var formKey=GlobalKey<FormState>();
  var scaffoldKey=GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (BuildContext context)=>AppCubit()..createDatabase(),
        child: BlocConsumer<AppCubit,AppStates>(
          listener:(context,state){} ,
          builder: (context,state){
            AppCubit cubit=AppCubit.get(context);
            var tasks=AppCubit.get(context).newTasks;
            return Scaffold(
                    key: scaffoldKey,
                    appBar: AppBar(
                      backgroundColor: Colors.deepPurpleAccent,
                      title: Text(
                          '${cubit.screensText[cubit.currentIndex]}'
                      ),
                    ),
                    body:cubit.screens[cubit.currentIndex],
                    bottomNavigationBar: BottomNavigationBar(
                      selectedItemColor: Colors.deepPurpleAccent,
                      currentIndex: cubit.currentIndex,
                      onTap: (index){
                        cubit.changeIndex(index);
                      },

                      items: [
                        BottomNavigationBarItem(
                            icon:Icon(Icons.menu),
                            label: 'Tasks'
                        ),
                        BottomNavigationBarItem(
                            icon:Icon(Icons.archive_outlined),
                            label: 'Archived'
                        ),
                        BottomNavigationBarItem(
                            icon:Icon(Icons.check_circle_outline),
                            label: 'Done'
                        ),


                      ],

                    ),
                    floatingActionButton: FloatingActionButton(
                      child:
                      Icon(cubit.floatingActionButtonIcon),
                      onPressed: (){

                        if(cubit.isBottomSheetShown){
                          if(formKey.currentState.validate()){
                            cubit.insertToDatabase(title: titleController.text,
                              date: dateController.text,
                              time: timeController.text,
                            ).then((value){
                              cubit.getFromDatabase(cubit.database);
                                  tasks=value;
                                  Navigator.pop(context);
                                  cubit.changeBottomSheetState(icon: Icons.edit, isShow: false);
                              });

                          };
                        }else {
                          scaffoldKey.currentState.showBottomSheet(
                                  (context) =>
                                  Container(
                                    color: Colors.white,
                                    child: Padding(
                                      padding: const EdgeInsets.all(20.0),
                                      child: Form(
                                        key: formKey,
                                        child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              defaultFormFeild(
                                                validatorText: "Title Must not be empty",
                                                Controller: titleController,
                                                inputType: TextInputType.text,
                                                prefixIcon: Icon(Icons.title),
                                                labelText: "Task Title",

                                              ),
                                              SizedBox(height: 10,),
                                              defaultFormFeild(
                                                  validatorText: "Time Must not be empty",
                                                  Controller: timeController,
                                                  inputType: TextInputType.datetime,
                                                  prefixIcon: Icon(Icons.watch_later_outlined),
                                                  labelText: "Task Time",
                                                  onTap: (){
                                                    showTimePicker(context: context, initialTime:TimeOfDay.now() ).then((value){

                                                      timeController.text=value.format(context).toString();

                                                    });
                                                  }

                                              ),
                                              SizedBox(height: 10,),
                                              defaultFormFeild(
                                                  validatorText: "Date Must not be empty",
                                                  Controller: dateController,
                                                  inputType: TextInputType.datetime,
                                                  prefixIcon: Icon(Icons.date_range_rounded),
                                                  labelText: "Date",
                                                  onTap: (){
                                                    showDatePicker(
                                                      context: context,
                                                      initialDate: DateTime.now(),
                                                      firstDate:DateTime.now(),
                                                      lastDate: DateTime.parse('2021-10-03')
                                                      ,).then((value){
                                                      dateController.text=DateFormat.yMMMd().format(value);
                                                    });
                                                  }

                                              )

                                            ]
                                        ),
                                      ),
                                    ),
                                  ),
                              elevation:20.0
                          ).closed.then((value){
                            cubit.changeBottomSheetState(icon: Icons.edit, isShow: false);

                          });
                          cubit.changeBottomSheetState(icon: Icons.add, isShow: true);

                        }
                      },
                    ),

                  );


          },

        )
    );
  }
}
