import 'dart:convert';
import 'package:buzz/screens/users_screen.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:permission_handler/permission_handler.dart';

final box = Hive.box('Local_Storage');

class LoginScreen extends StatefulWidget {

  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController emailController = TextEditingController();
  String token = '';

  void getToken() async{
    setState(() {
      FirebaseMessaging.instance.getToken().then((value) {
        token = value!;
        print(value);
      });
    });
  }

  void getPermission() async{
    await Permission.notification.request();
    await Permission.accessNotificationPolicy.request();
  }

  void login(String email, String token, BuildContext context) async{
    print(token);
    var response =  await http.post(
      Uri.parse('https://buzzzzer.vercel.app/api/login'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'email': email,
        'token': token,
      }),
    );
    if(response.statusCode==200 || response.statusCode==201){
      await box.put('email', email);
      await box.put('token',token);
      // Go to User Page
      print('Successfully Logged in');
      print(email);
      Navigator.push(context, MaterialPageRoute(builder: (context)=>UsersScreen(email: email,)));
    }
    else{
      print('Invalid Username');
    }
    print(response.statusCode);

  }

  void send_message() async{
    var response =  await http.post(
      Uri.parse('http://192.168.55.162:3000/sendnotification'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'sender': 'darsh@gmail.com',
        'receiver': 'darsh@gmail.com'

      }),
    );
    print(response.statusCode);
  }

  void getUsers()async{
    var response = await http.get(Uri.parse('http://192.168.55.162:3000/getusers'));
    print(response.body.toString());
    print(response.body.length);
    List users = jsonDecode(response.body);
    print(users.length);
    for (var user in users){
      print(user+"\n");
    }
    print(users);

  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getPermission();
    getToken();
    print(token);
    checkUser();



  }

  void checkUser() async{
    String? email = await box.get('email');
    if(email!=null){
      Navigator.push(context, MaterialPageRoute(builder: (context)=>UsersScreen(email: email,)));
    }
  }

  @override
  Widget build(BuildContext context) {

    return SafeArea(
        child: Scaffold(
          body: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // Buzz logo
              Padding(
                padding:const EdgeInsets.symmetric(horizontal: 16.0, vertical: 32),
                child: Text("Buzz",
                  style: GoogleFonts.lemon(textStyle: const TextStyle(fontSize: 48,color: Color(0xff0a0948))
                  ),
                ),
              ),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Input Email
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32.0),
                    child: Container(
                      child: TextField(
                        controller: emailController,
                        style: const TextStyle(
                          color:  Color(0xff0a0948),
                        ),
                        cursorColor: const Color(0xff0a0948),
                        decoration:const InputDecoration(
                          labelText: 'Username',
                          labelStyle: TextStyle(
                            color:  Color(0xff0a0948),
                          ),
                          floatingLabelStyle: TextStyle(
                            color:  Color(0xff0a0948),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color:  Color(0xff0a0948)),
                            borderRadius: BorderRadius.all(Radius.circular(18)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Color(0xff0a0948)),
                            borderRadius: BorderRadius.all(Radius.circular(18)),
                          ),

                        ),
                      ),
                    ),
                  ),

                  // Submit Button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 16),
                        child: TextButton(
                          style: ElevatedButton.styleFrom(
                            textStyle: TextStyle(fontSize: 18),
                            onPrimary: Colors.white,
                            backgroundColor:  Color(0xff0a0948),
                            minimumSize: Size(88, 36),
                            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(Radius.circular(15)),
                            ),
                          ),
                          child: const Text("Submit"),
                          onPressed: (){
                            login(emailController.value.text, token, context);
                            //send_message();
                            //getUsers();
                          },
                        ),
                      ),
                    ],
                  )
                ],
              ),

              SizedBox(),

            ],
          ),
        )
    );
  }
}
