import 'package:flutter/material.dart';
import "image_banner.dart";
import "secondscreen.dart";
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';

class Id {
  var id;
  Id(this.id);
}

Id id;

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  TextEditingController userNameInputController = TextEditingController();
  TextEditingController userPhoneInputController = TextEditingController();
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomPadding: false,
        appBar: AppBar(
          title: Text("Let's Get Started"),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Container(
                height: 0.25 * MediaQuery.of(context).size.height,
                child: Center(
                    child: Text(
                  "Sathi Tracker",
                  style: TextStyle(fontSize: 40, fontWeight: FontWeight.w500),
                ))),
            Container(
              height: 0.36 * MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: Padding(
                padding: EdgeInsets.fromLTRB(75.0, 0.0, 75.0, 0.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Container(
                      child: Text(
                        " Name",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.fromLTRB(0, 0, 0, 20),
                      child: TextField(
                        controller: userNameInputController,
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.person),
                          border: OutlineInputBorder(
                            borderRadius: const BorderRadius.all(
                              const Radius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      child: Text(
                        " Phone",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.fromLTRB(0, 0, 0, 20),
                      child: TextField(
                        controller: userPhoneInputController,
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.phone),
                          border: OutlineInputBorder(
                            borderRadius: const BorderRadius.all(
                              const Radius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 40,
                      width: 40,
                      child: RaisedButton(
                        color: Color(0xFF1963F2),
                        child: Text(
                          "Start",
                          style: TextStyle(fontSize: 20, color: Colors.white),
                        ),
                        onPressed: () async {
                          if (userPhoneInputController.text.isNotEmpty &&
                              userNameInputController.text.isNotEmpty) {

                            await Firestore.instance.collection('users').add({
                              "name": userNameInputController.text,
                              "phone": userPhoneInputController.text,
                              "group_id": "",
                              "lat" : "",
                              "lng" : "",
                              // "lat": position.latitude,
                              // "lng": position.longitude
                            }).then((value) async {
                              id = Id(value.documentID);
                              print(id);

                              SharedPreferences preferences =
                                  await SharedPreferences.getInstance();
                              preferences.setString(
                                  'localID', value.documentID);
                              //  print(id.id);
                              Fluttertoast.showToast(
                                  // Bottom Alert
                                  msg: "Login Successful",
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.BOTTOM,
                                  // timeInSecForIos: 1,
                                  backgroundColor: Colors.green,
                                  textColor: Colors.white,
                                  fontSize: 16.0);
                            });
                          }
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => SecondScreen(id: id)));
                        },
                        shape: new RoundedRectangleBorder(
                          borderRadius: new BorderRadius.circular(8.0),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            ImageBanner("assets/images/way.jpg"),
          ],
        ));
  }
}
