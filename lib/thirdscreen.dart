import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'secondscreen.dart';
import 'firstscreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:math' show cos, sqrt, asin;

var userLatitude;
var userLongitude;
// var radius;
var groupId;

class ThirdScreen extends StatefulWidget {
  // ThirdScreen() : super();
  // final String title =" Maps";s

  Id id;
  Group group;
  int radius;
  ThirdScreen({this.id, this.group, this.radius});

  @override
  MapsState createState() => MapsState();
}

class MapsState extends State<ThirdScreen> {
  Completer<GoogleMapController> _controller = Completer();

  var geolocator = Geolocator();
  // radiusVal = radius;
  var locationOptions =
      LocationOptions(accuracy: LocationAccuracy.high, distanceFilter: 10);
  var group = [];
  var alreadyPresent = new Set();
  StreamSubscription<Position> positionStream;
  @override
  void initState() {
    super.initState();
    positionStream = geolocator
        .getPositionStream(locationOptions)
        .listen((Position position) {
      updateLocation(
          position.latitude.toString(), position.longitude.toString());
    });
    updateGroup();
  }

  @override
  void dispose() {
    super.dispose();
    positionStream.cancel();
  }

  void updateLocation(String lat, String lng) async {
    userLatitude = lat;
    userLongitude = lng;
    await Firestore.instance
        .collection('users')
        .document(widget.id.id)
        .updateData({"lat": lat, "lng": lng});
  }

  double _coordinateDistance(lat1, lon1, lat2, lon2) {
    var p = 0.017453292519943295;
    var a = 0.5 -
        cos((lat2 - lat1) * p) / 2 +
        cos(lat1 * p) * cos(lat2 * p) * (1 - cos((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }

  void updateGroup() {
    group.clear();
    Firestore.instance
        .collection("users")
        .where("group_id", isEqualTo: widget.group.gid)
        .snapshots()
        .listen((result) {
      result.documents.forEach((result) {
        if (alreadyPresent.contains(result.data['phone'])) {
          //do nothing
        } else {
          group.add(result.data);
          alreadyPresent.add(result.data['phone']);
        }
        final String userName = result.data['name'];
        final String markerIdVal = 'marker_id_$userName';
        final MarkerId markerId = MarkerId(markerIdVal);

        double distanceInMeters = _coordinateDistance(
          double.parse(userLatitude),
          double.parse(userLongitude),
          double.parse(result.data['lat']),
          double.parse(result.data['lng']),
        );

        // print(distanceInMeters);

        // distanceInMeters = 3000;

        if (distanceInMeters > widget.radius*1000) {
          Fluttertoast.showToast(
              // Bottom Alert
              msg: "$userName has moved out of Range",
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.TOP,
              // timeInSecForIos: 1,
              backgroundColor: Colors.red,
              textColor: Colors.white,
              fontSize: 16.0);
        }

        final Marker marker = Marker(
          markerId: markerId,
          position: LatLng(double.parse(result.data['lat']),
              double.parse(result.data['lng'])),
          infoWindow: InfoWindow(title: markerIdVal, snippet: '*'),
        );
        setState(() {
          markers[markerId] = marker;
        });
      });
    });
  }

  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};
  // MarkerId selectedMarker;
  // int _markerIdCounter = 0;
  // void _markers() {

  //   for (int index = 0; index < group.length; index++) {
  //     final String markerIdVal = 'marker_id_$_markerIdCounter';
  //     final MarkerId markerId = MarkerId(markerIdVal);
  //     final Marker marker = Marker(
  //       markerId: markerId,
  //       position: LatLng(double.parse(result.data['lat']),
  //           double.parse(result.data['lng'])),
  //       infoWindow: InfoWindow(title: markerIdVal, snippet: '*'),
  //     );
  // setState(() {
  //   markers[markerId] = marker;
  // });
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text((widget.group.gn).toString()),
      ),
      body: SlidingUpPanel(
        panelBuilder: (sc) => _panel(sc),
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20), topRight: Radius.circular(20)),
        minHeight: 50,
        body: Stack(
          children: <Widget>[
            Container(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                child: GoogleMap(
                  initialCameraPosition: CameraPosition(
                      target: LatLng(22.2116722, 75.4699746), zoom: 5),
                  onMapCreated: (GoogleMapController controller) {
                    _controller.complete(controller);
                  },
                  markers: Set<Marker>.of(markers.values),
                ))
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        // child: Container(
        //   height: 40,
        //   child: Row(
        //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
        // children: <Widget>[
        // IconButton(
        //   icon: Icon(
        //     Icons.group,
        //     color: Colors.black,
        //   ),
        //   onPressed: () {
        //     // do something
        //     //    Firestore.instance.collection("users").document(id.id).get().then((value){
        //     //   print(value.data["group_id"]);
        //     //   groupId=value.data["group_id"];
        //     // });
        //     Firestore.instance
        //         .collection("users")
        //         .where("group_id", isEqualTo: widget.group.gid)
        //         .snapshots()
        //         .listen((result) {
        //       result.documents.forEach((result) {
        //         print(result.data);
        //       });
        //     });
        //   },
        // ),
        child: OutlineButton.icon(
          label: Text(
            "end",
            style: TextStyle(fontSize: 20, color: Colors.red),
          ),
          icon: Icon(
            Icons.cancel,
            color: Colors.red,
          ),
          onPressed: () async {
            await Firestore.instance
                .collection('users')
                .document(widget.id.id)
                .updateData({
              "group_id": "",
            });
            updateGroup();
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => SecondScreen(id: widget.id)));
          },
          shape: new RoundedRectangleBorder(
            borderRadius: new BorderRadius.circular(8.0),
          ),
        ),
        // ],
      ),
      // ),
      // ),
    );
  }

  Widget _panel(ScrollController sc) {
    return MediaQuery.removePadding(
        context: context,
        removeTop: true,
        child: Column(
          children: <Widget>[
            SizedBox(
              height: 15,
            ),
            Text("Group Details",
                style: TextStyle(
                  fontWeight: FontWeight.normal,
                  fontSize: 24.0,
                )),
            SizedBox(
              height: 15,
            ),
            SizedBox(
              height: 20,
              width: 20,
              child: RaisedButton.icon(
                icon: Icon(
                  Icons.add,
                  color: Colors.white,
                ),
                color: Color(0xFF1963F2),
                label: Text(
                  "debuggggg",
                  style: TextStyle(fontSize: 10, color: Colors.white),
                ),
                onPressed: () async {
                  print("ThirdScreen");
                  print(widget.id.id);
                  print("RADIUS=");
                  print(widget.radius);
                  // print(userLatitude);
                  // print(userLongitude);
                  // group=[];
                  // updateGroup();
                  // initState();
                  // print(group);
                  print("len=");
                  print(markers.length);
                  print(group.length);
                  markers.forEach((k, v) => print('$k: $v'));
                },
                shape: new RoundedRectangleBorder(
                  borderRadius: new BorderRadius.circular(1.0),
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                itemCount: group.length,
                itemBuilder: (BuildContext context, int index) {
                  return Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Container(
                            padding: EdgeInsets.symmetric(horizontal: 12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  group[index]['name'].toString(),
                                  style: TextStyle(fontSize: 20),
                                ),
                              ],
                            )),
                        ListTile(
                          onTap: () => launch(
                              "google.navigation:q=${group[index]['lat']},${group[index]['lng']}"),
                          title: Text(group[index]['phone']),
                          trailing: Icon(Icons.navigation),
                        ),
                      ],
                    ),
                  );
                },
              ),
            )
          ],
        ));
  }
}
