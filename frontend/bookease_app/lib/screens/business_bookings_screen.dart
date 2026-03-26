import 'package:flutter/material.dart';

class BusinessBookingsScreen extends StatelessWidget {
  const BusinessBookingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gelen Rezervasyonlar'),
      ),
      body: Center(
        child: Text('Business Bookings Screen'),
      ),
    );
  }
}