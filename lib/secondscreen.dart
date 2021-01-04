import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'thirdscreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:android_intent/android_intent.dart';
import 'package:geolocator/geolocator.dart';
import 'firstscreen.dart';
import 'dart:math';

class Group {
  var gid;
  var gn;
  Group(this.gid, this.gn);
}

Group group;
int radius;

class SecondScreen extends StatelessWidget {
  var id;
  SecondScreen({this.id});
  // Position position;
  TextEditingController userGroupIDInputController = TextEditingController();
  TextEditingController userRadiusInputController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomPadding: false,
        appBar: AppBar(
          title: Text("Start your trip"),
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
              height: 0.60 * MediaQuery.of(context).size.height,
              width: 0.60 * MediaQuery.of(context).size.width,
              padding: EdgeInsets.fromLTRB(75, 0, 75, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Container(
                    child: Text(
                      " Group ID",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.fromLTRB(0, 0, 0, 20),
                    child: TextField(
                      controller: userGroupIDInputController,
                      decoration: InputDecoration(
                        // prefixIcon: Icon(Icons.keyboard),
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
                      " Radius",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.fromLTRB(0, 0, 0, 20),
                    child: TextField(
                      controller: userRadiusInputController,
                      decoration: InputDecoration(
                        // prefixIcon: Icon(Icons.keyboard),
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
                    child: RaisedButton.icon(
                      icon: Icon(
                        Icons.group_add,
                        color: Colors.white,
                      ),
                      color: Color(0xFF1963F2),
                      label: Text(
                        "Join trip",
                        style: TextStyle(fontSize: 20, color: Colors.white),
                      ),
                      onPressed: () async {
                        // print(id.id);
                        if (userGroupIDInputController.text.isNotEmpty) {
                          print("Hello");
                          // group = Group(int.parse(userGroupIDInputController.text));
                          QuerySnapshot result = await Firestore.instance
                              .collection('groups')
                              .where('group_no',
                                  isEqualTo: int.parse(
                                      userGroupIDInputController.text))
                              .limit(1)
                              .getDocuments();
                          // print(result.documents[0].documentID);
                          if (result.documents.length == 1) {
                            if (!(await Geolocator()
                                .isLocationServiceEnabled())) {
                              final AndroidIntent intent = AndroidIntent(
                                  action:
                                      'android.settings.LOCATION_SOURCE_SETTINGS');
                              intent.launch();
                            }
                            Position position = await Geolocator()
                                .getCurrentPosition(
                                    desiredAccuracy: LocationAccuracy.high);
                            group = Group(result.documents[0].documentID,
                                int.parse(userGroupIDInputController.text));
                            await Firestore.instance
                                .collection('users')
                                .document(id.id)
                                .updateData({
                              "group_id": group.gid,
                              "lat": position.latitude,
                              "lng": position.longitude,
                            });
                            await Firestore.instance
                                .collection('groups')
                                .document(group.gid)
                                .updateData({
                              "member": FieldValue.arrayUnion([id.id]),
                            });

                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ThirdScreen(
                                        id: id, group: group, radius: radius)));
                          }
                        }
                      },
                      shape: new RoundedRectangleBorder(
                        borderRadius: new BorderRadius.circular(8.0),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  Divider(color: Colors.black),
                  Container(
                    padding: EdgeInsets.fromLTRB(0, 0, 0, 20),
                    child: Text(
                      "OR",
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  // Container(
                  //   child: Text(
                  //     "Maximum allowed distance ( in KM )",
                  //     style:
                  //         TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  //   ),
                  // ),
                  // Container(
                  //   padding: EdgeInsets.fromLTRB(0, 0, 0, 20),
                  //   child: TextField(
                  //     controller: userRadiusInputController,
                  //     decoration: InputDecoration(
                  //       // prefixIcon: Icon(Icons.keyboard),
                  //       border: OutlineInputBorder(
                  //         borderRadius: const BorderRadius.all(
                  //           const Radius.circular(8),
                  //         ),
                  //       ),
                  //     ),
                  //   ),
                  // ),
                  SizedBox(
                    height: 40,
                    width: 40,
                    child: RaisedButton.icon(
                      icon: Icon(
                        Icons.add,
                        color: Colors.white,
                      ),
                      color: Color(0xFF1963F2),
                      label: Text(
                        "Create trip",
                        style: TextStyle(fontSize: 20, color: Colors.white),
                      ),
                      onPressed: () async {
                        Random random = new Random();
                        while (true) {
                          group = Group(0, random.nextInt(8999) + 1000);
                          QuerySnapshot result = await Firestore.instance
                              .collection('groups')
                              .where('group_no', isEqualTo: group.gn)
                              .limit(1)
                              .getDocuments();
                          if (result.documents.length == 0) break;
                        }

                        print("second screen");
                        print(id.id);
                        await Firestore.instance.collection('groups').add({
                          "radius": int.parse(userRadiusInputController.text),
                          "radius": 2,
                          "group_no": group.gn,
                          "member": [id.id],
                        }).then((value) async {
                          group = Group(value.documentID, group.gn);
                        });
                        print(id);
                        print(id.id);
                        print(group.gid);
                        if (!(await Geolocator().isLocationServiceEnabled())) {
                          final AndroidIntent intent = AndroidIntent(
                              action:
                                  'android.settings.LOCATION_SOURCE_SETTINGS');
                          intent.launch();
                        }
                        Position position = await Geolocator()
                            .getCurrentPosition(
                                desiredAccuracy: LocationAccuracy.high);
                        // group=Group(result.documents[0].documentID);
                        await Firestore.instance
                            .collection('users')
                            .document(id.id)
                            .updateData({
                          "group_id": group.gid,
                          "lat": position.latitude,
                          "lng": position.longitude,
                        });
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ThirdScreen(
                                    id: id,
                                    group: group,
                                    radius: int.parse(
                                        userRadiusInputController.text))));
                      },
                      shape: new RoundedRectangleBorder(
                        borderRadius: new BorderRadius.circular(8.0),
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ));
  }
}
