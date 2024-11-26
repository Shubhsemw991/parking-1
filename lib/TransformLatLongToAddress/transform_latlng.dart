import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TransformLatLngToAddress extends StatefulWidget {
  const TransformLatLngToAddress({super.key});

  @override
  State<TransformLatLngToAddress> createState() => _TransformLatLngToAddressState();
}

class _TransformLatLngToAddressState extends State<TransformLatLngToAddress> {
  @override
  Widget build(BuildContext context) {
    return  Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(colors: [Colors.orange,Colors.teal],
        begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          stops: [0.0,1.0],
          tileMode: TileMode.clamp,
        )
      ),
      child: Scaffold(
        backgroundColor:Colors.transparent ,
      ),
    );
  }
}
