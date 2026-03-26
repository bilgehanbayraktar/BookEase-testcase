import 'package:flutter/material.dart';

class ManageBusinessScreen extends StatelessWidget {
  const ManageBusinessScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('İşletme Yönetimi'),
      ),
      body: Center(
        child: Text('Manage Business Screen'),
      ),
    );
  }
}