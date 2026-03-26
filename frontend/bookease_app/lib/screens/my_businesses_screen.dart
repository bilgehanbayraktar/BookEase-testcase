import 'package:flutter/material.dart';

class MyBusinessesScreen extends StatelessWidget {
  const MyBusinessesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('İşletmelerim'),
      ),
      body: Center(
        child: Text('My Businesses Screen'),
      ),
    );
  }
}