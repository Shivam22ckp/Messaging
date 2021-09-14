import 'package:zamazingo/components/GroupScreenComponents/group_bubble.dart';
import 'package:zamazingo/components/GroupScreenComponents/group_detail_page_appbar.dart';
import 'package:zamazingo/models/GroupScreenModels/group_message.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:zamazingo/models/send_menu_items.dart';



enum MessageType{
  Sender,
  Receiver,
}


class GroupDetailPage extends StatefulWidget{
  @override
  _GroupDetailPageState createState() => _GroupDetailPageState();
}

class _GroupDetailPageState extends State<GroupDetailPage> {
  List <GroupMessage> groupMessage =[
    GroupMessage(message: "Hi, guys! Welcome to Zamazingo Messaging. We are still developing it. So, please be understanding. While you are talking on private messages, be more careful. Because of we have some bugs on there. Also groups functions are not working for now. But you can use Global Page for talk with everyone. Don' t forget, you can' t talk +18, bad words etc. Otherwise you will ban and remove from Testers List!", type: MessageType.Receiver),
    GroupMessage(message: "If you see any bug, problem or if you have any suggestions; write to simurg16development@gmail.com", type: MessageType.Receiver),
    GroupMessage(message: "Thank you for your interested, have fun!", type: MessageType.Receiver),

  ];

  List<SendMenuItems> menuItems =[
    SendMenuItems(text: "Gallery", icons: Icons.image, color: Colors.amber),
    SendMenuItems(text: "Documents", icons: Icons.insert_drive_file, color: Colors.blue),
    SendMenuItems(text: "Audio", icons: Icons.music_note, color: Colors.orange),
    SendMenuItems(text: "Location", icons: Icons.location_on, color: Colors.green),
    SendMenuItems(text: "Contact", icons: Icons.person, color: Colors.purple),
  ];


  void showModal(){
    showModalBottomSheet(
        context: context,
        builder: (context){
          return Container(
            height: MediaQuery.of(context).size.height/2,
            color: Color(0xff737373),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(topRight: Radius.circular(20), topLeft: Radius.circular(20)),
              ),
              child: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    SizedBox(height: 16,),
                    Center(
                      child: Container(
                        height: 4,
                        width: 50,
                        color: Colors.grey.shade200,
                      ),
                    ),
                    SizedBox(height: 10,),
                    ListView.builder(
                      itemCount: menuItems.length,
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemBuilder: (context,index){
                        return Container(
                          padding: EdgeInsets.only(top:10,bottom: 10),
                          child: ListTile(
                            leading: Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(30),
                                  color: menuItems[index].color.shade100
                              ),
                              height: 50,
                              width: 50,
                              child: Icon(menuItems[index].icons,size: 20,color:menuItems[index].color.shade500,),
                            ),
                            title:Text(menuItems[index].text),
                          ),
                        );
                      },
                    )
                  ],
                ),
              ),
            ),
          );

        }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: GroupDetailAppBar(),
        body: Stack(
          children: <Widget>[
            ListView.builder(
              itemCount: groupMessage.length,
              shrinkWrap: true,
              padding: EdgeInsets.only(top: 10, bottom: 10),
              physics: NeverScrollableScrollPhysics(),
              itemBuilder: (context, index){
                return GroupBubble(
                  groupMessage: groupMessage[index],
                );
              },
            ),

          ],
        )
    );//Scaffold
  }
}