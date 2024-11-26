import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MyPolyLine extends StatefulWidget {
  const MyPolyLine({super.key});

  @override
  State<MyPolyLine> createState() => _MyPolyLineState();
}

class _MyPolyLineState extends State<MyPolyLine> {
  final Completer<GoogleMapController> _controller=Completer();
  static const CameraPosition _initialPosition=CameraPosition(
    target: LatLng(28.61360707246554, 77.2127014771071),
    zoom: 14,
  );
  final Set<Marker> myMarker={};
  final Set<Polyline> _myPolyLine={};
  
  List<LatLng> myPoints=[
    const LatLng(28.61360707246554, 77.2127014771071),
    const LatLng(30.0777, 78.2462),
  ];
  @override
  void initState() {
    super.initState();
    for (int a = 0; a < myPoints.length; a++) {
      myMarker.add(
        Marker(
          markerId: MarkerId(a.toString()),
          position: myPoints[a],
          infoWindow: InfoWindow(
              title: 'Adventure Place',
              snippet: '10 out of 10 Star'
          ),
          icon: BitmapDescriptor.defaultMarker,

        ),
      );
      setState(() {

      });
      _myPolyLine.add(
        Polyline(polylineId: const PolylineId('First'),
            points: myPoints,
            color: Colors.cyan
        ),
      );
    }
  }
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My PolyLine'),
      backgroundColor: Colors.cyan,
      ),
      body: SafeArea(
        child: GoogleMap(
          initialCameraPosition:_initialPosition ,
          mapType: MapType.normal,
          markers: myMarker,
          polylines: _myPolyLine,
          onMapCreated: (GoogleMapController controller){
            _controller.complete(controller);
          } ,



        ),
      ),
    );
  }
}
