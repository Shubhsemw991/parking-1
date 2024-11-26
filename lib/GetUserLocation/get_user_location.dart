import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class GetUserLocation extends StatefulWidget {
  const GetUserLocation({super.key});

  @override
  State<GetUserLocation> createState() => _GetUserLocationState();
}

class _GetUserLocationState extends State<GetUserLocation> {
  final Completer<GoogleMapController> _controller=Completer();
  static const CameraPosition _initialPosition=CameraPosition(
    target: LatLng(28.61360707246554, 77.2127014771071),
    zoom: 14,
  );

  final List<Marker> myMarker=[];
  final List<Marker> makerList=[
  const Marker(markerId: MarkerId('first'),
  position: LatLng(28.61360707246554, 77.2127014771071),
  infoWindow: InfoWindow(
  title: 'My home'
  ),
  ),];

  void initState(){
    super.initState();
    myMarker.addAll(makerList);

  }

  Future<Position> getUserLocation()async
  {
    await Geolocator.requestPermission().then((value)
        {

        }).onError((error,stackTrace)
    {
          print('error$error');
    });
   return await Geolocator.getCurrentPosition();
  }
  packData(){
    getUserLocation().then((value)async{
      print('My Location');
      print('${value.latitude} ${value.longitude}');
      myMarker.add(
        Marker(markerId:const MarkerId('second'),
        position: LatLng(value.latitude,value.longitude),
          infoWindow:const InfoWindow(
            title: 'My Location',
          )
        )


      );
      CameraPosition cameraPosition=CameraPosition(
        target: LatLng(value.latitude,value.longitude),
        zoom: 14,
      );
      final GoogleMapController controller=await _controller.future;
      
      controller.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
      setState(() {

      });
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: GoogleMap(
          initialCameraPosition:_initialPosition ,
          mapType: MapType.normal,
          markers: Set<Marker>.of(myMarker),
          onMapCreated: (GoogleMapController controller)
          {
            _controller.complete(controller);
          } ,



        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
         packData();

        },
        child: Icon(Icons.radio_button_off),
      ),
    );
  }
}
