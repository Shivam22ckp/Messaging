import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';


class GlobalDetailAppBar extends StatelessWidget implements PreferredSizeWidget
{
  @override
  Widget build(BuildContext context) {
    return
      Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(left:15, right:16, top: 10),
          child: Row(

            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[

              Center(
                   child: Text("Global Chat", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold,),),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  // TODO: implement preferredSize
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}