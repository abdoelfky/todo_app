import 'dart:ui';
import 'package:bloc/bloc.dart';
import 'package:conditional_builder/conditional_builder.dart';
import 'package:todo_app/shared/cubit/cubit.dart';
import 'package:flutter/material.dart';

Widget defaultButton({
  double width = double.infinity,
  double height = 50.0,
  Color color = Colors.lightBlueAccent,
  @required String string,
  @required Function function,
}) =>
    Container(
      width: width,
      height: height,
      color: color,
      child: Center(
        child: MaterialButton(
            minWidth: width,
            textColor: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(string.toUpperCase(),
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ),
            onPressed: function),
      ),
    );





Widget defaultFormFeild({
  @required String validatorText,
  @required var Controller,
  @required var inputType,
  IconButton suffixIcon ,
  @required Icon prefixIcon ,
  @required String labelText,
  bool isObsecured=false,
  Function onTap,
  bool isEnabled=true,


})=>TextFormField(
  validator: (value){
    if(value.isEmpty)
    {return validatorText;}
    return null;
  },
  onTap: onTap,
  enabled:isEnabled,
  controller: Controller,
  keyboardType: inputType,
  obscureText: isObsecured,
  decoration: InputDecoration(
    labelText: labelText,
    prefixIcon: prefixIcon,
    suffixIcon: suffixIcon,
    border: OutlineInputBorder(),

  ),
);



Widget buildTaskItem(Map model,context)=>Dismissible(
  key: Key(model['ID'].toString()),
  child:   Padding(
    padding: const EdgeInsets.all(25.0),
    child: Row(
      children: [
        CircleAvatar(
          radius: 40.0,
          child: Text('${model['TIME']}'),
        ),
        SizedBox(width: 20.0,),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${model['TITLE']}',
                style: TextStyle(
                    fontSize: 20.0,
                    fontWeight:FontWeight.bold
                ),
              ),
              Text(
                '${model['DATE']}',
                style: TextStyle(
                    fontSize: 15.0,
                    color: Colors.grey
                ),
              ),

            ],
          ),
        ),
        SizedBox(width: 20.0,),
        IconButton(icon: Icon(Icons.check_box,color: Colors.green[500],)
            , onPressed:(){
              AppCubit.get(context).updateData(status: 'DONE', id: model['ID']);
            }),
        IconButton(icon: Icon(Icons.archive,color: Colors.black45,),
            onPressed:(){
              AppCubit.get(context).updateData(status: 'ARCHIVED', id: model['ID']);

            }),



      ],
    ),
  ),
  onDismissed: (direction){
  AppCubit.get(context).deleteData(id: model['ID']);

  },
);


Widget tasksBuilder({
  @required List<Map> tasks,
}) => ConditionalBuilder(
  condition: tasks.length > 0,
  builder: (context) => ListView.separated(
    itemBuilder: (context, index)
    {
      return buildTaskItem(tasks[index], context);
    },
    separatorBuilder: (context, index) => Padding(
      padding: const EdgeInsetsDirectional.only(
        start: 20.0,
      ),
      child: Container(
        width: double.infinity,
        height: 1.0,
        color: Colors.grey[300],
      ),
    ),
    itemCount: tasks.length,
  ),
  fallback: (context) => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.menu,
          size: 100.0,
          color: Colors.grey,
        ),
        Text(
          'No Tasks Yet, Please Add Some Tasks',
          style: TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
      ],
    ),
  ),
);