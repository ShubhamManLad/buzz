import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class UserWidget extends StatelessWidget {
  String sender,email,message;
  UserWidget({super.key, required this.sender, required this.email, required this.message});

  void send_message() async{
    print(message);
    if (message!='' || message.isNotEmpty) {

      var response = await http.post(
        Uri.parse('https://buzzer-api.onrender.com/api/sendnotification'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'sender': sender,
          'receiver': email,
          'body': message
        }),
      );
      print(response.statusCode);
    }
    else{
      var response = await http.post(
        Uri.parse('https://buzzer-api.onrender.com/api/sendnotification'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'sender': sender,
          'receiver': email,
        }),
      );
      print(response.statusCode);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5,horizontal: 24),
      child: Material(
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            color: Color(0xfff5f5f5),
            boxShadow: [
              BoxShadow(
                color: Color(0xafbebebe),
                offset: Offset(0.0, 0.0), //(x,y)
                blurRadius: 4.0,
                spreadRadius: 1,

              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16),
            child: Row(
              children: [
                Icon(Icons.person, size: 36),
                Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal:32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            email,
                            style: GoogleFonts.salsa(
                              textStyle: TextStyle(fontSize: 18)
                            ),
                          ),
                          // Text(
                          //   email,
                          //   style: GoogleFonts.salsa(
                          //       textStyle: TextStyle(fontSize: 15)
                          //   ),
                          // ),
                        ],
                      ),
                    )
                ),
                TextButton(
                  child: Icon(Icons.notifications_none, size: 36,color: const Color(0xff0a0948)),
                  onPressed: (){send_message();},
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

