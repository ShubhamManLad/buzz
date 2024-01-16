import 'package:buzz/widgets/user_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';

class UsersScreen extends StatefulWidget {
  String email;
  UsersScreen({super.key, required this.email});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {

  late String sender;

  String message = '';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    sender = widget.email;
    print(sender);
  }

  TextEditingController controller = TextEditingController();

  Future<List> getUsers()async{
    var response = await http.get(Uri.parse('https://buzzzzer.vercel.app/api/getusers'));
    print(response.body.toString());
    print(response.body.length);
    List users = jsonDecode(response.body);
    print(users.length);
    for (var user in users){
      print(user['id']+"\n");
    }
    return(users);
    
  }

  void broadcast() async{
    var response = await http.post(
      Uri.parse('https://buzzzzer.vercel.app/api/sendbroadcast'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'sender': sender,
      }),
    );
    print(response.statusCode);
  }


  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding:const EdgeInsets.symmetric(horizontal: 16.0, vertical: 32),
                    child: Text("Buzz",
                      style: GoogleFonts.lemon(textStyle: const TextStyle(fontSize: 32,color: Color(0xff0a0948))
                      ),
                    ),
                  ),
                  TextButton(child: Icon(Icons.cell_tower, size: 36,color: const Color(0xff0a0948)), onPressed: (){broadcast();},)
                ],
              ),

              Padding(
                padding:const EdgeInsets.all(16.0),
                child: TextField(
                  controller: controller,
                  onSubmitted: (value){
                    setState(() {
                      message = value.toString();
                    });
                  },
                  style: const TextStyle(
                    color:  Color(0xff0a0948),
                  ),
                  cursorColor: const Color(0xff0a0948),
                  decoration:const InputDecoration(
                      labelText: 'Send a buzz..',
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

              Expanded(
                child: FutureBuilder<List?>(
                    future: getUsers(),
                    builder: (context, snapshot) {
                      switch (snapshot.connectionState) {
                        case ConnectionState.waiting:
                          return Center(child: SpinKitChasingDots(color: const Color(0xff0a0948),));
                        default:
                          if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}');
                          } else {
                            List data = snapshot.data ?? [];
                            return ListView.builder(
                              itemBuilder: (context, index) {

                                  return UserWidget(
                                    sender: sender,
                                    email: data[index]?['email'],
                                    message: message,
                                  );
                              },
                              itemCount: data.length,
                            );
                          }
                      }
                    }),
              ),
            ],
          )),
    );
  }

}
